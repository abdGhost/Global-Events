from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class RsvpResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    event_id: UUID
    user_id: UUID
    created_at: datetime


class RsvpStatus(BaseModel):
    event_id: UUID
    count: int
    is_going: bool


