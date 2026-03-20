"""
GlobalEvents API entrypoint.
"""
import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import func, select

from app.config import settings
from app.database import Base, async_session_maker, engine
from app.models.event import Event
from app.routers import auth, events, me_events, rsvps, chat

logger = logging.getLogger(__name__)

app = FastAPI(title="GlobalEvents API", version="0.1.0")


@app.get("/api/health")
async def health() -> dict:
    """Lightweight check + which DB driver is in use (no secrets). Helps debug empty APIs on Render."""
    url = settings.database_url.lower()
    if "postgresql" in url or "postgres" in url:
        driver = "postgresql"
    elif "sqlite" in url:
        driver = "sqlite"
    else:
        driver = "other"

    async with async_session_maker() as session:
        n = await session.scalar(select(func.count()).select_from(Event))

    return {
        "status": "ok",
        "database_driver": driver,
        "events_count": int(n or 0),
    }


@app.on_event("startup")
async def on_startup() -> None:
  """
  Ensure all database tables exist on startup.

  This is especially helpful on managed platforms like Render where we
  can't easily run Alembic migrations as a separate job on the free tier.
  For a brand‑new database this will create the same schema defined by
  SQLAlchemy models.
  """
  async with engine.begin() as conn:
    await conn.run_sync(Base.metadata.create_all)

  if settings.seed_on_empty:
    try:
      from app.auto_seed import seed_database_if_empty

      await seed_database_if_empty()
    except Exception:
      logger.exception("auto_seed: failed — check logs and DATABASE_URL")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(me_events.router)
app.include_router(events.router)
app.include_router(rsvps.router)
app.include_router(chat.router)
