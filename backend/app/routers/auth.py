"""
Auth: register, login, GET /auth/me (returns user.timezone), PATCH me for timezone.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import create_access_token, hash_password, verify_password
from app.core.utils.timezone import normalize_timezone
from app.core.deps import get_current_user
from app.database import get_async_session
from app.models.user import User
from app.schemas.user import TokenResponse, UserCreate, UserLogin, UserResponse, UserUpdateTimezone

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse)
async def register(
    body: UserCreate,
    session: AsyncSession = Depends(get_async_session),
) -> TokenResponse:
    """Register; returns access token. Set timezone from device on first login (PATCH /auth/me)."""
    result = await session.execute(select(User).where(User.email == body.email))
    if result.scalar_one_or_none():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email already registered")
    user = User(
        email=body.email,
        hashed_password=hash_password(body.password),
    )
    session.add(user)
    await session.flush()
    return TokenResponse(access_token=create_access_token(user.id))


@router.post("/login", response_model=TokenResponse)
async def login(
    body: UserLogin,
    session: AsyncSession = Depends(get_async_session),
) -> TokenResponse:
    """Login; returns access token."""
    result = await session.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()
    if not user or not verify_password(body.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid email or password")
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account disabled")
    return TokenResponse(access_token=create_access_token(user.id))


@router.get("/me", response_model=UserResponse)
async def me(current_user: User = Depends(get_current_user)) -> UserResponse:
    """Return current user; includes timezone (set from device on first login via PATCH)."""
    return UserResponse.model_validate(current_user)


@router.patch("/me", response_model=UserResponse)
async def update_me_timezone(
    body: UserUpdateTimezone,
    current_user: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_async_session),
) -> UserResponse:
    """Update current user timezone (e.g. from device on first login)."""
    current_user.timezone = normalize_timezone(body.timezone)
    await session.flush()
    return UserResponse.model_validate(current_user)
