"""
Seed additional location-based events to improve Nearby results.

Usage:
  python scripts/seed_nearby_events.py
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
class NearbySeedEvent:
    title: str
    description: str
    day_offset: int
    duration_hours: int
    timezone_name: str
    lat: float
    lng: float
    address: str
    city: str
    country_code: str
    category: str
    image_url: str


SEED_USER_EMAIL = "seed-events@globalgather.app"
SEED_USER_PASSWORD = "SeedEvents123!"

NEARBY_EVENTS: list[NearbySeedEvent] = [
    NearbySeedEvent(
        title="Baghdad Tech Meetup",
        description="Developer talks on Flutter, backend APIs, and startup product building.",
        day_offset=7,
        duration_hours=3,
        timezone_name="Asia/Baghdad",
        lat=33.3152,
        lng=44.3661,
        address="Bab Al-Muadham Cultural Center",
        city="Baghdad",
        country_code="IQ",
        category="Technology",
        image_url="https://images.unsplash.com/photo-1519389950473-47ba0277781c",
    ),
    NearbySeedEvent(
        title="Erbil Startup Founder Night",
        description="Networking event for founders, operators, and early-stage investors.",
        day_offset=9,
        duration_hours=3,
        timezone_name="Asia/Baghdad",
        lat=36.1911,
        lng=44.0090,
        address="Erbil International Hotel",
        city="Erbil",
        country_code="IQ",
        category="Business",
        image_url="https://images.unsplash.com/photo-1552664730-d307ca884978",
    ),
    NearbySeedEvent(
        title="Basra Waterfront Music Evening",
        description="Live bands and local artists at an open-air community stage.",
        day_offset=12,
        duration_hours=4,
        timezone_name="Asia/Baghdad",
        lat=30.5085,
        lng=47.7804,
        address="Shatt al-Arab Corniche",
        city="Basra",
        country_code="IQ",
        category="Music",
        image_url="https://images.unsplash.com/photo-1501386761578-eac5c94b800a",
    ),
    NearbySeedEvent(
        title="Amman Design & Creator Expo",
        description="Design showcases, workshops, and portfolio reviews for creators.",
        day_offset=11,
        duration_hours=5,
        timezone_name="Asia/Amman",
        lat=31.9539,
        lng=35.9106,
        address="Zara Expo Hall",
        city="Amman",
        country_code="JO",
        category="Design",
        image_url="https://images.unsplash.com/photo-1521791136064-7986c2920216",
    ),
    NearbySeedEvent(
        title="Dubai AI Builders Circle",
        description="Practical sessions on AI features, cloud deployment, and product growth.",
        day_offset=8,
        duration_hours=4,
        timezone_name="Asia/Dubai",
        lat=25.2048,
        lng=55.2708,
        address="Dubai Internet City Conference Hall",
        city="Dubai",
        country_code="AE",
        category="Technology",
        image_url="https://images.unsplash.com/photo-1451187580459-43490279c0fa",
    ),
    NearbySeedEvent(
        title="Riyadh Sports Community Run",
        description="5K city run with hydration stations and post-run meetup.",
        day_offset=14,
        duration_hours=2,
        timezone_name="Asia/Riyadh",
        lat=24.7136,
        lng=46.6753,
        address="King Abdullah Park",
        city="Riyadh",
        country_code="SA",
        category="Sports",
        image_url="https://images.unsplash.com/photo-1571008887538-b36bb32f4571",
    ),
    NearbySeedEvent(
        title="Istanbul Cultural Food Festival",
        description="Street food, chef demonstrations, and regional cuisine showcases.",
        day_offset=16,
        duration_hours=6,
        timezone_name="Europe/Istanbul",
        lat=41.0082,
        lng=28.9784,
        address="Yenikapi Event Area",
        city="Istanbul",
        country_code="TR",
        category="Food",
        image_url="https://images.unsplash.com/photo-1555939594-58d7cb561ad1",
    ),
    NearbySeedEvent(
        title="Cairo Open Air Cinema Night",
        description="International films screening with audience Q&A and networking.",
        day_offset=13,
        duration_hours=4,
        timezone_name="Africa/Cairo",
        lat=30.0444,
        lng=31.2357,
        address="Cairo Opera Grounds",
        city="Cairo",
        country_code="EG",
        category="Art",
        image_url="https://images.unsplash.com/photo-1489599849927-2ee91cede3ba",
    ),
    NearbySeedEvent(
        title="Doha Business Leadership Forum",
        description="Executive talks on regional markets, innovation, and partnerships.",
        day_offset=10,
        duration_hours=5,
        timezone_name="Asia/Qatar",
        lat=25.2854,
        lng=51.5310,
        address="Doha Exhibition & Convention Center",
        city="Doha",
        country_code="QA",
        category="Business",
        image_url="https://images.unsplash.com/photo-1556761175-4b46a572b786",
    ),
    NearbySeedEvent(
        title="Kuwait City Marketing Summit",
        description="Brand strategy, creator campaigns, and analytics for growth teams.",
        day_offset=18,
        duration_hours=4,
        timezone_name="Asia/Kuwait",
        lat=29.3759,
        lng=47.9774,
        address="Kuwait International Fairground",
        city="Kuwait City",
        country_code="KW",
        category="Marketing",
        image_url="https://images.unsplash.com/photo-1460925895917-afdab827c52f",
    ),
    NearbySeedEvent(
        title="Muscat Travel Creator Meetup",
        description="Travel storytellers and tourism teams share content and partnerships.",
        day_offset=20,
        duration_hours=3,
        timezone_name="Asia/Muscat",
        lat=23.5880,
        lng=58.3829,
        address="Oman Convention Center",
        city="Muscat",
        country_code="OM",
        category="Travel",
        image_url="https://images.unsplash.com/photo-1467269204594-9661b134dd2b",
    ),
    NearbySeedEvent(
        title="Beirut Community Jazz Session",
        description="Live jazz evening with local and regional musicians.",
        day_offset=15,
        duration_hours=3,
        timezone_name="Asia/Beirut",
        lat=33.8938,
        lng=35.5018,
        address="Waterfront District Stage",
        city="Beirut",
        country_code="LB",
        category="Music",
        image_url="https://images.unsplash.com/photo-1511379938547-c1f69419868d",
    ),
]


async def seed_nearby_events() -> None:
    async with async_session_maker() as session:
        user_result = await session.execute(select(User).where(User.email == SEED_USER_EMAIL))
        user = user_result.scalar_one_or_none()
        if user is None:
            user = User(
                email=SEED_USER_EMAIL,
                hashed_password=hash_password(SEED_USER_PASSWORD),
                is_active=True,
                is_verified=True,
                timezone="UTC",
            )
            session.add(user)
            await session.flush()

        now = datetime.now(timezone.utc)
        base = now.replace(hour=17, minute=0, second=0, microsecond=0)
        inserted = 0

        for item in NEARBY_EVENTS:
            start_utc = base + timedelta(days=item.day_offset)
            end_utc = start_utc + timedelta(hours=item.duration_hours)

            existing = await session.execute(
                select(Event).where(Event.title == item.title, Event.start_utc == start_utc)
            )
            if existing.scalar_one_or_none():
                continue

            session.add(
                Event(
                    title=item.title,
                    description=item.description,
                    start_utc=start_utc,
                    end_utc=end_utc,
                    timezone=item.timezone_name,
                    lat=item.lat,
                    lng=item.lng,
                    address=item.address,
                    city=item.city,
                    country_code=item.country_code,
                    is_virtual=False,
                    category=item.category,
                    image_url=item.image_url,
                    max_attendees=600,
                    is_approved=True,
                    created_by=user.id,
                    views_count=220,
                    rsvp_count=80,
                )
            )
            inserted += 1

        await session.commit()
        print(f"Nearby seed complete. Inserted {inserted} events.")


if __name__ == "__main__":
    asyncio.run(seed_nearby_events())
