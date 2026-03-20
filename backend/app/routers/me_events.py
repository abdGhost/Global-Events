"""
Current user's events — never shadowed by /api/events/{event_id}.

Some deployments had /created and /rsvped swallowed by the UUID path; these
routes live under /api/me so routing is unambiguous.
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.database import get_async_session
from app.models.event import Event
from app.models.rsvp import Rsvp
from app.models.user import User
from app.schemas.event import EventListItem

router = APIRouter(prefix="/api/me", tags=["me"])


@router.get("/events/created", response_model=list[EventListItem])
async def get_my_created_events_me(
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(get_async_session),
    current_user: User = Depends(get_current_user),
) -> list[EventListItem]:
    """Events created by the current user."""
    stmt = (
        select(Event)
        .where(Event.created_by == current_user.id)
        .order_by(Event.created_at.desc())
        .offset(offset)
        .limit(limit)
    )
    result = await session.execute(stmt)
    events = result.scalars().all()
    return [EventListItem.model_validate(e) for e in events]


@router.get("/events/rsvped", response_model=list[EventListItem])
async def get_my_rsvped_events_me(
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(get_async_session),
    current_user: User = Depends(get_current_user),
) -> list[EventListItem]:
    """Events the current user has RSVPed to."""
    stmt = (
        select(Event)
        .join(Rsvp, Rsvp.event_id == Event.id)
        .where(Rsvp.user_id == current_user.id)
        .order_by(Event.start_utc.asc())
        .offset(offset)
        .limit(limit)
    )
    result = await session.execute(stmt)
    events = result.scalars().all()
    return [EventListItem.model_validate(e) for e in events]
