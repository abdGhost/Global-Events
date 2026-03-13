"""
User schemas for auth and /auth/me.
"""
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    email: str
    is_active: bool
    is_verified: bool
    timezone: str
    created_at: datetime


class UserUpdateTimezone(BaseModel):
    timezone: str = Field(..., max_length=64)


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
