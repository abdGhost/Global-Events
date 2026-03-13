from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class ChatMessageCreate(BaseModel):
    content: str = Field(..., min_length=1, max_length=2000)


class ChatMessageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    event_id: UUID
    user_id: UUID
    content: str
    created_at: datetime

