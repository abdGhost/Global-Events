"""
RSVPs API: join/leave event, keep rsvp_count in sync.
"""
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.database import get_async_session
from app.models.event import Event
from app.models.rsvp import Rsvp
from app.models.user import User
from app.schemas.rsvp import RsvpResponse, RsvpStatus

router = APIRouter(prefix="/api/events/{event_id}/rsvp", tags=["rsvps"])


async def _get_event(event_id: UUID, session: AsyncSession) -> Event:
    result = await session.execute(select(Event).where(Event.id == event_id))
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Event not found")
    return event


@router.get("", response_model=RsvpStatus)
async def get_rsvp_status(
    event_id: UUID,
    session: AsyncSession = Depends(get_async_session),
    current_user: User = Depends(get_current_user),
) -> RsvpStatus:
    """Return RSVP count and whether current user is going."""
    event = await _get_event(event_id, session)
    result = await session.execute(
        select(Rsvp).where(Rsvp.event_id == event.id, Rsvp.user_id == current_user.id)
    )
    existing = result.scalar_one_or_none()
    return RsvpStatus(event_id=event.id, count=event.rsvp_count, is_going=bool(existing))


@router.post("", response_model=RsvpResponse, status_code=status.HTTP_201_CREATED)
async def create_rsvp(
    event_id: UUID,
    session: AsyncSession = Depends(get_async_session),
    current_user: User = Depends(get_current_user),
) -> RsvpResponse:
    """RSVP to an event. Idempotent: second call just returns existing RSVP."""
    event = await _get_event(event_id, session)

    result = await session.execute(
        select(Rsvp).where(Rsvp.event_id == event.id, Rsvp.user_id == current_user.id)
    )
    existing = result.scalar_one_or_none()
    if existing:
        return RsvpResponse.model_validate(existing)

    rsvp = Rsvp(event_id=event.id, user_id=current_user.id)
    session.add(rsvp)
    # increment rsvp_count
    event.rsvp_count += 1
    await session.flush()
    return RsvpResponse.model_validate(rsvp)


@router.delete("", status_code=status.HTTP_204_NO_CONTENT)
async def delete_rsvp(
    event_id: UUID,
    session: AsyncSession = Depends(get_async_session),
    current_user: User = Depends(get_current_user),
) -> None:
    """Cancel RSVP. Idempotent: no error if not currently RSVPed."""
    event = await _get_event(event_id, session)

    result = await session.execute(
        select(Rsvp).where(Rsvp.event_id == event.id, Rsvp.user_id == current_user.id)
    )
    rsvp = result.scalar_one_or_none()
    if not rsvp:
        return

    await session.delete(rsvp)
    if event.rsvp_count > 0:
        event.rsvp_count -= 1
    await session.flush()

