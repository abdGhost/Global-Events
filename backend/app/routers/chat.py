"""
Chat API: HTTP history + WebSocket /ws/chat/{event_id}.
Current implementation uses in-process broadcast; can be swapped to Redis later.
"""
from collections import defaultdict
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.database import get_async_session
from app.models.chat_message import ChatMessage
from app.models.event import Event
from app.models.user import User
from app.schemas.chat import ChatMessageCreate, ChatMessageResponse

router = APIRouter(prefix="/api/events/{event_id}/chat", tags=["chat"])


async def _get_event(event_id: UUID, session: AsyncSession) -> Event:
    result = await session.execute(select(Event).where(Event.id == event_id))
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
    return event


@router.get("/messages", response_model=list[ChatMessageResponse])
async def get_messages(
    event_id: UUID,
    limit: int = 50,
    session: AsyncSession = Depends(get_async_session),
) -> list[ChatMessageResponse]:
    """Return latest chat messages for an event (newest last)."""
    stmt = (
        select(ChatMessage)
        .where(ChatMessage.event_id == event_id)
        .order_by(ChatMessage.created_at.desc())
        .limit(limit)
    )
    result = await session.execute(stmt)
    messages = list(reversed(result.scalars().all()))
    return [ChatMessageResponse.model_validate(m) for m in messages]


@router.post("/messages", response_model=ChatMessageResponse, status_code=status.HTTP_201_CREATED)
async def post_message(
    event_id: UUID,
    body: ChatMessageCreate,
    session: AsyncSession = Depends(get_async_session),
    current_user: User = Depends(get_current_user),
) -> ChatMessageResponse:
    """Post a chat message via HTTP (useful for simple clients or testing)."""
    await _get_event(event_id, session)
    msg = ChatMessage(event_id=event_id, user_id=current_user.id, content=body.content)
    session.add(msg)
    await session.flush()
    return ChatMessageResponse.model_validate(msg)


# -------- WebSocket chat (in-process broadcaster) --------


class ChatManager:
    def __init__(self) -> None:
        self._connections: dict[UUID, set[WebSocket]] = defaultdict(set)

    async def connect(self, event_id: UUID, websocket: WebSocket) -> None:
        await websocket.accept()
        self._connections[event_id].add(websocket)

    def disconnect(self, event_id: UUID, websocket: WebSocket) -> None:
        self._connections[event_id].discard(websocket)
        if not self._connections[event_id]:
            self._connections.pop(event_id, None)

    async def broadcast(self, event_id: UUID, message: dict) -> None:
        dead: list[WebSocket] = []
        for ws in self._connections.get(event_id, set()):
            try:
                await ws.send_json(message)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self.disconnect(event_id, ws)


manager = ChatManager()


@router.websocket("/ws")
async def websocket_endpoint(
    websocket: WebSocket,
    event_id: UUID,
    session: AsyncSession = Depends(get_async_session),
) -> None:
    """
    WebSocket endpoint: ws://.../api/events/{event_id}/chat/ws
    Expects/returns JSON:
      { "user_id": "...", "content": "Hello", "created_at": "..." }
    For now, no auth on WS; frontend should include user_id in payload.
    """
    await _get_event(event_id, session)
    await manager.connect(event_id, websocket)
    try:
        while True:
            data = await websocket.receive_json()
            content = (data.get("content") or "").strip()
            user_id_str = data.get("user_id")
            if not content or not user_id_str:
                continue
            try:
                from uuid import UUID as _UUID

                user_id = _UUID(user_id_str)
            except ValueError:
                continue

            # Persist message
            msg = ChatMessage(event_id=event_id, user_id=user_id, content=content)
            session.add(msg)
            await session.flush()

            payload = ChatMessageResponse.model_validate(msg).model_dump()
            await manager.broadcast(event_id, payload)
    except WebSocketDisconnect:
        manager.disconnect(event_id, websocket)

