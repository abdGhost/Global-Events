"""
Async SQLAlchemy 2.0 engine and session.
"""
from collections.abc import AsyncGenerator

from sqlalchemy.engine import make_url
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.config import settings


class Base(DeclarativeBase):
    pass


_url = make_url(settings.database_url)
_engine_kwargs: dict = {"echo": settings.sql_echo}

# SQLite (aiosqlite) doesn't support pool_size/max_overflow arguments; use default NullPool.
if _url.get_backend_name().startswith("sqlite"):
    engine = create_async_engine(settings.database_url, **_engine_kwargs)
else:
    engine = create_async_engine(
        settings.database_url,
        pool_size=10,
        max_overflow=20,
        pool_recycle=3600,
        **_engine_kwargs,
    )

async_session_maker = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autocommit=False,
    autoflush=False,
)


async def get_async_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
