"""
Event schemas with timezone-aware request/response.
All stored times are UTC; API can accept local times on create and return local times on read.
"""
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.core.utils.timezone import DEFAULT_TZ, normalize_timezone, to_local, to_utc


# ---------- Create (client sends local time + timezone) ----------


class EventCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: str | None = None
    start_local: datetime = Field(..., description="Start in event's local timezone (naive or aware)")
    end_local: datetime = Field(..., description="End in event's local timezone")
    timezone: str = Field(default=DEFAULT_TZ, max_length=64)
    lat: float | None = None
    lng: float | None = None
    address: str | None = None
    city: str | None = None
    country_code: str | None = Field(None, max_length=2)
    is_virtual: bool = False
    category: str | None = Field(None, max_length=64)
    image_url: str | None = Field(None, max_length=512)
    max_attendees: int | None = Field(None, ge=0)

    def to_utc_times(self) -> tuple[datetime, datetime]:
        """Return (start_utc, end_utc) for storage."""
        tz = normalize_timezone(self.timezone)
        return to_utc(self.start_local, tz), to_utc(self.end_local, tz)


# ---------- Update (partial) ----------


class EventUpdate(BaseModel):
    title: str | None = Field(None, min_length=1, max_length=255)
    description: str | None = None
    start_local: datetime | None = None
    end_local: datetime | None = None
    timezone: str | None = None
    lat: float | None = None
    lng: float | None = None
    address: str | None = None
    city: str | None = None
    country_code: str | None = None
    is_virtual: bool | None = None
    category: str | None = None
    image_url: str | None = None
    max_attendees: int | None = None


# ---------- Response (optionally in user's timezone) ----------


class EventResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    title: str
    description: str | None
    start_utc: datetime
    end_utc: datetime
    start_local: datetime | None = None  # set when ?tz= or X-Timezone provided
    end_local: datetime | None = None
    timezone: str
    lat: float | None
    lng: float | None
    address: str | None
    city: str | None
    country_code: str | None
    is_virtual: bool
    category: str | None
    image_url: str | None
    max_attendees: int | None
    is_approved: bool
    created_by: UUID
    created_at: datetime
    views_count: int
    rsvp_count: int

    @classmethod
    def from_orm_with_tz(cls, obj: object, tz: str | None) -> "EventResponse":
        """Build response with start_local/end_local in given timezone."""
        from app.core.utils.timezone import normalize_timezone

        data = cls.model_validate(obj)
        if tz:
            tz = normalize_timezone(tz)
            data.start_local = to_local(data.start_utc, tz)
            data.end_local = to_local(data.end_utc, tz)
        return data


# ---------- List item (summary) ----------


class EventListItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    title: str
    start_utc: datetime
    end_utc: datetime
    timezone: str
    lat: float | None
    lng: float | None
    address: str | None
    city: str | None
    country_code: str | None
    is_virtual: bool
    category: str | None
    image_url: str | None
    rsvp_count: int
    views_count: int
