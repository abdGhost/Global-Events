"""
Create one real user, create events for that user, and add RSVPs.

This is useful for profile screens that currently show:
- 0 created
- 0 RSVPed

Usage:
  python scripts/seed_profile_real_user.py
"""
from __future__ import annotations

import asyncio
import os
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

from sqlalchemy import select

ROOT_DIR = os.path.dirname(os.path.dirname(__file__))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

from app.core.security import hash_password
from app.database import async_session_maker
from app.models.event import Event
from app.models.rsvp import Rsvp
from app.models.user import User


USER_EMAIL = "real.user.silchar@globalgather.app"
USER_PASSWORD = "RealUser123!"
USER_TIMEZONE = "Asia/Kolkata"
LAT = 24.8179211
LNG = 92.8148178
CITY = "Silchar"
COUNTRY = "IN"


@dataclass(frozen=True)
class MyEventSeed:
    title: str
    description: str
    day_offset: int
    duration_hours: int
    category: str
    image_url: str
    address: str
    max_attendees: int


MY_EVENTS: list[MyEventSeed] = [
    MyEventSeed(
        title="Silchar Local Founder Meetup",
        description="Small networking meetup for founders, students, and builders in Silchar.",
        day_offset=5,
        duration_hours=3,
        category="Business",
        image_url="https://images.unsplash.com/photo-1552664730-d307ca884978",
        address="Ambicapatty Community Hall, Silchar",
        max_attendees=140,
    ),
    MyEventSeed(
        title="Barak Valley Dev Circle",
        description="Community session on Flutter apps, backend APIs, and interview prep.",
        day_offset=9,
        duration_hours=3,
        category="Technology",
        image_url="https://images.unsplash.com/photo-1519389950473-47ba0277781c",
        address="NS Avenue Learning Hub, Silchar",
        max_attendees=180,
    ),
    MyEventSeed(
        title="Silchar Weekend Music & Open Mic",
        description="Open mic evening with local performers and acoustic sets.",
        day_offset=13,
        duration_hours=4,
        category="Music",
        image_url="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f",
        address="Tarapur Open Stage, Silchar",
        max_attendees=220,
    ),
]


async def seed() -> None:
    async with async_session_maker() as session:
        # 1) Create or reuse user
        user_result = await session.execute(select(User).where(User.email == USER_EMAIL))
        user = user_result.scalar_one_or_none()
        if user is None:
            user = User(
                email=USER_EMAIL,
                hashed_password=hash_password(USER_PASSWORD),
                is_active=True,
                is_verified=True,
                timezone=USER_TIMEZONE,
            )
            session.add(user)
            await session.flush()

        now = datetime.now(timezone.utc).replace(minute=0, second=0, microsecond=0)

        # 2) Create events for this user
        created_inserted = 0
        for seed_event in MY_EVENTS:
            start_utc = now + timedelta(days=seed_event.day_offset)
            end_utc = start_utc + timedelta(hours=seed_event.duration_hours)

            existing = await session.execute(
                select(Event).where(
                    Event.title == seed_event.title,
                    Event.created_by == user.id,
                )
            )
            event = existing.scalar_one_or_none()
            if event is None:
                session.add(
                    Event(
                        title=seed_event.title,
                        description=seed_event.description,
                        start_utc=start_utc,
                        end_utc=end_utc,
                        timezone=USER_TIMEZONE,
                        lat=LAT,
                        lng=LNG,
                        address=seed_event.address,
                        city=CITY,
                        country_code=COUNTRY,
                        is_virtual=False,
                        category=seed_event.category,
                        image_url=seed_event.image_url,
                        max_attendees=seed_event.max_attendees,
                        is_approved=True,
                        created_by=user.id,
                        views_count=120,
                        rsvp_count=0,
                    )
                )
                created_inserted += 1

        await session.flush()

        # 3) RSVP this user to other events (not created by this user)
        candidate_result = await session.execute(
            select(Event)
            .where(Event.created_by != user.id, Event.end_utc >= now)
            .order_by(Event.start_utc.asc())
            .limit(5)
        )
        candidates = candidate_result.scalars().all()

        rsvp_inserted = 0
        for event in candidates:
            existing_rsvp = await session.execute(
                select(Rsvp).where(Rsvp.event_id == event.id, Rsvp.user_id == user.id)
            )
            if existing_rsvp.scalar_one_or_none() is not None:
                continue
            session.add(Rsvp(event_id=event.id, user_id=user.id))
            event.rsvp_count += 1
            rsvp_inserted += 1

        await session.commit()

        # 4) Output final counts for this user
        created_count_result = await session.execute(
            select(Event).where(Event.created_by == user.id)
        )
        created_count = len(created_count_result.scalars().all())

        rsvped_count_result = await session.execute(
            select(Rsvp).where(Rsvp.user_id == user.id)
        )
        rsvped_count = len(rsvped_count_result.scalars().all())

        print("Profile seed complete.")
        print(f"User: {USER_EMAIL} / {USER_PASSWORD}")
        print(f"Created events: {created_count} (inserted now: {created_inserted})")
        print(f"RSVPed events: {rsvped_count} (inserted now: {rsvp_inserted})")


if __name__ == "__main__":
    asyncio.run(seed())
