"""
Events API: trending, search, nearby, CRUD.
All times stored in UTC; read endpoints accept ?tz= or X-Timezone for local times in response.
"""
from datetime import datetime
from uuid import UUID

from fastapi import APIRouter, Depends, Header, Query
from sqlalchemy import func, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.deps import get_current_user
from app.core.utils.timezone import normalize_timezone
from app.database import get_async_session
from app.models.event import Event
from app.models.rsvp import Rsvp
from app.models.user import User
from app.schemas.event import EventCreate, EventListItem, EventResponse, EventUpdate

router = APIRouter(prefix="/api/events", tags=["events"])


def _get_tz_from_request(tz_query: str | None = Query(None, alias="tz"), x_timezone: str | None = Header(None)) -> str | None:
    return tz_query or x_timezone


# ---------- Trending ----------


@router.get("/trending", response_model=list[EventListItem])
async def get_trending(
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    session: AsyncSession = Depends(get_async_session),
) -> list[EventListItem]:
    """High rsvp/views, recent events (global)."""
    stmt = (
        select(Event)
        .where(Event.is_approved == True, Event.end_utc >= func.now())
        .order_by(Event.rsvp_count.desc(), Event.views_count.desc(), Event.created_at.desc())
        .offset(offset)
        .limit(limit)
    )
    result = await session.execute(stmt)
    events = result.scalars().all()
    return [EventListItem.model_validate(e) for e in events]


# ---------- Search ----------


@router.get("/search", response_model=list[EventListItem])
async def search_events(
    query: str | None = Query(None),
    category: str | None = Query(None),
    start_after: str | None = Query(None, description="ISO datetime UTC"),
    end_before: str | None = Query(None, description="ISO datetime UTC"),
    country: str | None = Query(None, description="ISO2 country code"),
    is_virtual: bool | None = Query(None),
    sort: str = Query("popular", description="popular | date"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    session: AsyncSession = Depends(get_async_session),
) -> list[EventListItem]:
    """Global search with filters."""
    stmt = select(Event).where(Event.is_approved == True)
    if query and query.strip():
        q = f"%{query.strip()}%"
        stmt = stmt.where(
            or_(
                Event.title.ilike(q),
                Event.description.ilike(q),
                Event.city.ilike(q),
            )
        )
    if category:
        stmt = stmt.where(Event.category == category)
    if start_after:
        try:
            after = datetime.fromisoformat(start_after.replace("Z", "+00:00"))
            stmt = stmt.where(Event.start_utc >= after)
        except ValueError:
            pass
    if end_before:
        try:
            before = datetime.fromisoformat(end_before.replace("Z", "+00:00"))
            stmt = stmt.where(Event.end_utc <= before)
        except ValueError:
            pass
    if country:
        stmt = stmt.where(Event.country_code == country.upper()[:2])
    if is_virtual is not None:
        stmt = stmt.where(Event.is_virtual == is_virtual)

    if sort == "date":
        stmt = stmt.order_by(Event.start_utc.asc())
    else:
        stmt = stmt.order_by(Event.rsvp_count.desc(), Event.start_utc.asc())

    stmt = stmt.offset((page - 1) * page_size).limit(page_size)
    result = await session.execute(stmt)
    events = result.scalars().all()
    return [EventListItem.model_validate(e) for e in events]


# ---------- Nearby (requires lat/lng; optional PostGIS later) ----------


@router.get("/nearby", response_model=list[EventListItem])
async def get_nearby(
    lat: float = Query(..., ge=-90, le=90),
    lng: float = Query(..., ge=-180, le=180),
    radius_km: float = Query(50, ge=0.1, le=500),
    limit: int = Query(20, ge=1, le=100),
    session: AsyncSession = Depends(get_async_session),
) -> list[EventListItem]:
    """Events within radius (approximate Haversine; replace with PostGIS ST_DWithin when available)."""
    # Approximate: 1 deg lat ~ 111 km; 1 deg lng ~ 111*cos(lat) km
    import math
    deg_lat = radius_km / 111.0
    deg_lng = radius_km / (111.0 * math.cos(math.radians(lat)))
    stmt = (
        select(Event)
        .where(
            Event.is_approved == True,
            Event.lat.isnot(None),
            Event.lng.isnot(None),
            Event.end_utc >= func.now(),
            Event.lat >= lat - deg_lat,
            Event.lat <= lat + deg_lat,
            Event.lng >= lng - deg_lng,
            Event.lng <= lng + deg_lng,
        )
        .order_by(Event.start_utc.asc())
        .limit(limit)
    )
    result = await session.execute(stmt)
    events = result.scalars().all()
    # Optional: sort by distance (Haversine) in Python if needed
    return [EventListItem.model_validate(e) for e in events]


# ---------- My created events (auth required) ----------


@router.get("/created", response_model=list[EventListItem])
async def get_my_created_events(
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


# ---------- My RSVPed events (auth required) ----------


@router.get("/rsvped", response_model=list[EventListItem])
async def get_my_rsvped_events(
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


# ---------- Get one (with timezone for local times) ----------


@router.get("/{event_id}", response_model=EventResponse)
async def get_event(
    event_id: UUID,
    tz: str | None = Query(None, alias="tz"),
    x_timezone: str | None = Header(None),
    session: AsyncSession = Depends(get_async_session),
) -> EventResponse:
    """Return event; pass ?tz= or X-Timezone to get start_local/end_local in that timezone."""
    stmt = select(Event).where(Event.id == event_id)
    result = await session.execute(stmt)
    event = result.scalar_one_or_none()
    if not event:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Event not found")
    # Increment views (fire-and-forget or await)
    event.views_count += 1
    await session.flush()
    request_tz = tz or x_timezone
    return EventResponse.from_orm_with_tz(event, request_tz)


# ---------- Create (convert local → UTC) ----------


@router.post("", response_model=EventResponse, status_code=201)
async def create_event(
    body: EventCreate,
    session: AsyncSession = Depends(get_async_session),
    current_user: User = Depends(get_current_user),
) -> EventResponse:
    """Create event; start/end in body are in event timezone → stored as UTC."""
    start_utc, end_utc = body.to_utc_times()
    event = Event(
        title=body.title,
        description=body.description,
        start_utc=start_utc,
        end_utc=end_utc,
        timezone=normalize_timezone(body.timezone),
        lat=body.lat,
        lng=body.lng,
        address=body.address,
        city=body.city,
        country_code=body.country_code.upper()[:2] if body.country_code else None,
        is_virtual=body.is_virtual,
        category=body.category,
        image_url=body.image_url,
        max_attendees=body.max_attendees,
        created_by=current_user.id,
    )
    session.add(event)
    await session.flush()
    return EventResponse.from_orm_with_tz(event, body.timezone)


# ---------- Update / Delete (owner only – stub) ----------


@router.patch("/{event_id}", response_model=EventResponse)
async def update_event(
    event_id: UUID,
    body: EventUpdate,
    session: AsyncSession = Depends(get_async_session),
    current_user: User = Depends(get_current_user),
) -> EventResponse:
    """Update event (owner only)."""
    from fastapi import HTTPException
    stmt = select(Event).where(Event.id == event_id)
    result = await session.execute(stmt)
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    if event.created_by != current_user.id:
        raise HTTPException(status_code=403, detail="Not the event owner")
    update_data = body.model_dump(exclude_unset=True)
    if "start_local" in update_data or "end_local" in update_data:
        tz = normalize_timezone(update_data.get("timezone") or event.timezone)
        if "start_local" in update_data:
            from app.core.utils.timezone import to_utc
            update_data["start_utc"] = to_utc(update_data.pop("start_local"), tz)
        if "end_local" in update_data:
            from app.core.utils.timezone import to_utc
            update_data["end_utc"] = to_utc(update_data.pop("end_local"), tz)
    for key, value in update_data.items():
        if hasattr(event, key):
            setattr(event, key, value)
    await session.flush()
    return EventResponse.from_orm_with_tz(event, event.timezone)


@router.delete("/{event_id}", status_code=204)
async def delete_event(
    event_id: UUID,
    session: AsyncSession = Depends(get_async_session),
    current_user: User = Depends(get_current_user),
) -> None:
    """Delete event (owner only)."""
    from fastapi import HTTPException
    stmt = select(Event).where(Event.id == event_id)
    result = await session.execute(stmt)
    event = result.scalar_one_or_none()
    if not event:
        raise HTTPException(status_code=404, detail="Event not found")
    if event.created_by != current_user.id:
        raise HTTPException(status_code=403, detail="Not the event owner")
    await session.delete(event)
