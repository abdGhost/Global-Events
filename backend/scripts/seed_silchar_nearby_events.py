"""
Seed nearby events around Silchar, India area.

Target center:
  lat=24.8179211, lng=92.8148178

Usage:
  python scripts/seed_silchar_nearby_events.py
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
from app.models.user import User


@dataclass(frozen=True)
class LocalEventSeed:
    title: str
    description: str
    day_offset: int
    duration_hours: int
    lat: float
    lng: float
    address: str
    city: str
    category: str
    image_url: str
    max_attendees: int


SEED_USER_PASSWORD = "SeedEvents123!"
SEED_USER_EMAILS = [
    "silchar.host1@globalgather.app",
    "silchar.host2@globalgather.app",
    "silchar.host3@globalgather.app",
    "silchar.host4@globalgather.app",
]
TZ = "Asia/Kolkata"

EVENTS: list[LocalEventSeed] = [
    LocalEventSeed(
        title="Silchar Tech Community Meetup",
        description="Developer talks on Flutter, APIs, and startup product building in Barak Valley.",
        day_offset=6,
        duration_hours=3,
        lat=24.8333,
        lng=92.7789,
        address="NIT Silchar Seminar Hall",
        city="Silchar",
        category="Technology",
        image_url="https://images.unsplash.com/photo-1519389950473-47ba0277781c",
        max_attendees=260,
    ),
    LocalEventSeed(
        title="Silchar Entrepreneurs Networking Night",
        description="Founders, freelancers, and business owners connect and share growth ideas.",
        day_offset=8,
        duration_hours=3,
        lat=24.8245,
        lng=92.7993,
        address="Club Road Convention Center",
        city="Silchar",
        category="Business",
        image_url="https://images.unsplash.com/photo-1552664730-d307ca884978",
        max_attendees=220,
    ),
    LocalEventSeed(
        title="Assam Tea & Food Festival - Silchar",
        description="Regional tea tasting, food stalls, and local chef showcases.",
        day_offset=10,
        duration_hours=5,
        lat=24.8110,
        lng=92.8032,
        address="Police Parade Ground",
        city="Silchar",
        category="Food",
        image_url="https://images.unsplash.com/photo-1504674900247-0877df9cc836",
        max_attendees=900,
    ),
    LocalEventSeed(
        title="Barak Valley Music Evening",
        description="Live performances from local bands and acoustic artists.",
        day_offset=12,
        duration_hours=4,
        lat=24.8238,
        lng=92.7912,
        address="District Library Open Stage",
        city="Silchar",
        category="Music",
        image_url="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f",
        max_attendees=600,
    ),
    LocalEventSeed(
        title="Karimganj Youth Sports Carnival",
        description="Track events, football mini-games, and community fitness activities.",
        day_offset=14,
        duration_hours=4,
        lat=24.8696,
        lng=92.3554,
        address="Karimganj Sports Complex",
        city="Karimganj",
        category="Sports",
        image_url="https://images.unsplash.com/photo-1546519638-68e109498ffc",
        max_attendees=500,
    ),
    LocalEventSeed(
        title="Hailakandi Creative Design Workshop",
        description="Hands-on visual design workshop with portfolio feedback sessions.",
        day_offset=16,
        duration_hours=3,
        lat=24.6826,
        lng=92.5636,
        address="Hailakandi Town Hall",
        city="Hailakandi",
        category="Design",
        image_url="https://images.unsplash.com/photo-1521791136064-7986c2920216",
        max_attendees=180,
    ),
    LocalEventSeed(
        title="Badarpur Travel Creators Meetup",
        description="Travel reels, destination storytelling, and collaboration networking.",
        day_offset=18,
        duration_hours=3,
        lat=24.8689,
        lng=92.5961,
        address="Badarpur Community Center",
        city="Badarpur",
        category="Travel",
        image_url="https://images.unsplash.com/photo-1467269204594-9661b134dd2b",
        max_attendees=150,
    ),
    LocalEventSeed(
        title="Silchar Marketing Masterclass",
        description="Digital marketing strategy, ad creatives, and analytics basics for local brands.",
        day_offset=20,
        duration_hours=3,
        lat=24.8169,
        lng=92.7858,
        address="NS Avenue Business Hub",
        city="Silchar",
        category="Marketing",
        image_url="https://images.unsplash.com/photo-1460925895917-afdab827c52f",
        max_attendees=210,
    ),
    LocalEventSeed(
        title="Sonai Cultural Arts Expo",
        description="Community art display, performances, and interactive art corners.",
        day_offset=22,
        duration_hours=5,
        lat=24.7304,
        lng=92.8915,
        address="Sonai Cultural Ground",
        city="Sonai",
        category="Art",
        image_url="https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b",
        max_attendees=420,
    ),
    LocalEventSeed(
        title="Silchar Career & Education Fair",
        description="Colleges, training institutes, and hiring partners meet students and graduates.",
        day_offset=24,
        duration_hours=6,
        lat=24.8282,
        lng=92.8011,
        address="Gurucharan College Campus",
        city="Silchar",
        category="Education",
        image_url="https://images.unsplash.com/photo-1523050854058-8df90110c9f1",
        max_attendees=1000,
    ),
]


async def seed() -> None:
    async with async_session_maker() as session:
        users: list[User] = []
        for email in SEED_USER_EMAILS:
            u = await session.execute(select(User).where(User.email == email))
            user = u.scalar_one_or_none()
            if user is None:
                user = User(
                    email=email,
                    hashed_password=hash_password(SEED_USER_PASSWORD),
                    is_active=True,
                    is_verified=True,
                    timezone="UTC",
                )
                session.add(user)
                await session.flush()
            users.append(user)

        inserted = 0
        now = datetime.now(timezone.utc)
        base = now.replace(hour=10, minute=0, second=0, microsecond=0)

        reassigned = 0
        for idx, item in enumerate(EVENTS):
            start_utc = base + timedelta(days=item.day_offset)
            end_utc = start_utc + timedelta(hours=item.duration_hours)
            owner = users[idx % len(users)]
            exists = await session.execute(
                select(Event).where(Event.title == item.title, Event.start_utc == start_utc)
            )
            existing_event = exists.scalar_one_or_none()
            if existing_event:
                if existing_event.created_by != owner.id:
                    existing_event.created_by = owner.id
                    reassigned += 1
                continue
            session.add(
                Event(
                    title=item.title,
                    description=item.description,
                    start_utc=start_utc,
                    end_utc=end_utc,
                    timezone=TZ,
                    lat=item.lat,
                    lng=item.lng,
                    address=item.address,
                    city=item.city,
                    country_code="IN",
                    is_virtual=False,
                    category=item.category,
                    image_url=item.image_url,
                    max_attendees=item.max_attendees,
                    is_approved=True,
                    created_by=owner.id,
                    views_count=180,
                    rsvp_count=65,
                )
            )
            inserted += 1

        # Also reassign any existing Silchar-area events by title, in case timestamps changed.
        for idx, item in enumerate(EVENTS):
            owner = users[idx % len(users)]
            by_title = await session.execute(select(Event).where(Event.title == item.title))
            for event in by_title.scalars().all():
                if event.created_by != owner.id:
                    event.created_by = owner.id
                    reassigned += 1

        await session.commit()
        print(
            "Silchar-area nearby seed complete. "
            f"Inserted {inserted} events, reassigned {reassigned} events to different users."
        )


if __name__ == "__main__":
    asyncio.run(seed())
