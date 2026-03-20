"""
Seed real-world events into the backend database.

Usage:
  python scripts/seed_real_events.py
"""
from __future__ import annotations

import asyncio
import os
import sys
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone

from sqlalchemy import select

# Ensure backend root is on sys.path when running this file directly.
ROOT_DIR = os.path.dirname(os.path.dirname(__file__))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

from app.core.security import hash_password
from app.database import Base, async_session_maker, engine
from app.models.event import Event
from app.models.user import User


@dataclass(frozen=True)
class SeedEvent:
    title: str
    description: str
    day_offset: int
    duration_hours: int
    timezone_name: str
    lat: float | None
    lng: float | None
    address: str | None
    city: str | None
    country_code: str | None
    is_virtual: bool
    category: str
    image_url: str
    max_attendees: int
    views_count: int
    rsvp_count: int


SEED_USER_EMAIL = "seed-events@globalgather.app"
SEED_USER_PASSWORD = "SeedEvents123!"

SEED_EVENTS: list[SeedEvent] = [
    SeedEvent(
        title="Web Summit 2026",
        description="Global tech conference featuring startup demos, AI tracks, and product launches.",
        day_offset=10,
        duration_hours=8,
        timezone_name="Europe/Lisbon",
        lat=38.7223,
        lng=-9.1393,
        address="Altice Arena, Rossio dos Olivais",
        city="Lisbon",
        country_code="PT",
        is_virtual=False,
        category="Technology",
        image_url="https://images.unsplash.com/photo-1511578314322-379afb476865",
        max_attendees=3500,
        views_count=1200,
        rsvp_count=820,
    ),
    SeedEvent(
        title="SXSW 2026 - Interactive Track",
        description="Sessions on digital culture, creators, product innovation, and media technology.",
        day_offset=14,
        duration_hours=7,
        timezone_name="America/Chicago",
        lat=30.2672,
        lng=-97.7431,
        address="Austin Convention Center",
        city="Austin",
        country_code="US",
        is_virtual=False,
        category="Technology",
        image_url="https://images.unsplash.com/photo-1540575467063-178a50c2df87",
        max_attendees=2800,
        views_count=980,
        rsvp_count=700,
    ),
    SeedEvent(
        title="Mobile World Congress 2026",
        description="5G, devices, telecom platforms, and mobile ecosystem keynote sessions.",
        day_offset=18,
        duration_hours=8,
        timezone_name="Europe/Madrid",
        lat=41.3851,
        lng=2.1734,
        address="Fira Barcelona Gran Via",
        city="Barcelona",
        country_code="ES",
        is_virtual=False,
        category="Technology",
        image_url="https://images.unsplash.com/photo-1498050108023-c5249f4df085",
        max_attendees=5000,
        views_count=1400,
        rsvp_count=950,
    ),
    SeedEvent(
        title="Google I/O Community Meetup 2026",
        description="Android, Flutter, and AI builder talks streamed with local community networking.",
        day_offset=22,
        duration_hours=3,
        timezone_name="America/Los_Angeles",
        lat=None,
        lng=None,
        address=None,
        city="Online",
        country_code="US",
        is_virtual=True,
        category="Technology",
        image_url="https://images.unsplash.com/photo-1521737604893-d14cc237f11d",
        max_attendees=1500,
        views_count=860,
        rsvp_count=640,
    ),
    SeedEvent(
        title="TEDxTokyo 2026",
        description="Ideas worth spreading with talks on design, science, culture, and society.",
        day_offset=12,
        duration_hours=6,
        timezone_name="Asia/Tokyo",
        lat=35.6762,
        lng=139.6503,
        address="Shibuya Cultural Hall",
        city="Tokyo",
        country_code="JP",
        is_virtual=False,
        category="Education",
        image_url="https://images.unsplash.com/photo-1475721027785-f74eccf877e2",
        max_attendees=1200,
        views_count=740,
        rsvp_count=510,
    ),
    SeedEvent(
        title="London Design Festival 2026",
        description="Design exhibitions, urban installations, and creative industry networking.",
        day_offset=26,
        duration_hours=6,
        timezone_name="Europe/London",
        lat=51.5074,
        lng=-0.1278,
        address="Somerset House",
        city="London",
        country_code="GB",
        is_virtual=False,
        category="Design",
        image_url="https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b",
        max_attendees=1800,
        views_count=690,
        rsvp_count=460,
    ),
    SeedEvent(
        title="Paris Fashion Week Highlights",
        description="Runway showcases, creator meetups, and talks from top fashion houses.",
        day_offset=20,
        duration_hours=5,
        timezone_name="Europe/Paris",
        lat=48.8566,
        lng=2.3522,
        address="Carrousel du Louvre",
        city="Paris",
        country_code="FR",
        is_virtual=False,
        category="Fashion",
        image_url="https://images.unsplash.com/photo-1483985988355-763728e1935b",
        max_attendees=900,
        views_count=870,
        rsvp_count=620,
    ),
    SeedEvent(
        title="Cannes Lions Community Session",
        description="Brand storytelling, marketing strategy, and creator economy case studies.",
        day_offset=30,
        duration_hours=4,
        timezone_name="Europe/Paris",
        lat=43.5528,
        lng=7.0174,
        address="Palais des Festivals",
        city="Cannes",
        country_code="FR",
        is_virtual=False,
        category="Marketing",
        image_url="https://images.unsplash.com/photo-1515169067868-5387ec356754",
        max_attendees=1100,
        views_count=630,
        rsvp_count=420,
    ),
    SeedEvent(
        title="Dubai FinTech Summit 2026",
        description="Payments, digital banking, and financial inclusion with regional fintech leaders.",
        day_offset=16,
        duration_hours=7,
        timezone_name="Asia/Dubai",
        lat=25.2048,
        lng=55.2708,
        address="Dubai World Trade Centre",
        city="Dubai",
        country_code="AE",
        is_virtual=False,
        category="Business",
        image_url="https://images.unsplash.com/photo-1556740749-887f6717d7e4",
        max_attendees=2200,
        views_count=920,
        rsvp_count=670,
    ),
    SeedEvent(
        title="World Travel Market Networking Night",
        description="Travel creators, tourism boards, and destination partners connect globally.",
        day_offset=28,
        duration_hours=4,
        timezone_name="Europe/London",
        lat=51.5007,
        lng=-0.1246,
        address="ExCeL London",
        city="London",
        country_code="GB",
        is_virtual=False,
        category="Travel",
        image_url="https://images.unsplash.com/photo-1488646953014-85cb44e25828",
        max_attendees=1300,
        views_count=580,
        rsvp_count=390,
    ),
    SeedEvent(
        title="NBA Global Fan Fest 2026",
        description="Basketball fan activities, skills zones, and athlete Q&A sessions.",
        day_offset=9,
        duration_hours=5,
        timezone_name="America/New_York",
        lat=40.7128,
        lng=-74.0060,
        address="Javits Center",
        city="New York",
        country_code="US",
        is_virtual=False,
        category="Sports",
        image_url="https://images.unsplash.com/photo-1546519638-68e109498ffc",
        max_attendees=2500,
        views_count=1010,
        rsvp_count=720,
    ),
    SeedEvent(
        title="Berlin Marathon Expo 2026",
        description="Runner expo with gear booths, training workshops, and community meetups.",
        day_offset=21,
        duration_hours=6,
        timezone_name="Europe/Berlin",
        lat=52.5200,
        lng=13.4050,
        address="Messe Berlin",
        city="Berlin",
        country_code="DE",
        is_virtual=False,
        category="Sports",
        image_url="https://images.unsplash.com/photo-1552674605-db6ffd4facb5",
        max_attendees=2000,
        views_count=640,
        rsvp_count=460,
    ),
    SeedEvent(
        title="Tomorrowland Winter 2026",
        description="Electronic music performances in alpine venues with global artist lineup.",
        day_offset=35,
        duration_hours=8,
        timezone_name="Europe/Brussels",
        lat=45.0922,
        lng=6.0683,
        address="Alpe d'Huez",
        city="Huez",
        country_code="FR",
        is_virtual=False,
        category="Music",
        image_url="https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f",
        max_attendees=3200,
        views_count=1350,
        rsvp_count=980,
    ),
    SeedEvent(
        title="Montreux Jazz Nights - Global Stream",
        description="Live and recorded sets from leading jazz artists around the world.",
        day_offset=24,
        duration_hours=3,
        timezone_name="Europe/Zurich",
        lat=None,
        lng=None,
        address=None,
        city="Online",
        country_code="CH",
        is_virtual=True,
        category="Music",
        image_url="https://images.unsplash.com/photo-1511192336575-5a79af67a629",
        max_attendees=1800,
        views_count=770,
        rsvp_count=590,
    ),
    SeedEvent(
        title="Foodex Japan Showcase",
        description="International food and beverage exhibition with tasting and supplier meetings.",
        day_offset=19,
        duration_hours=6,
        timezone_name="Asia/Tokyo",
        lat=35.6895,
        lng=139.6917,
        address="Tokyo Big Sight",
        city="Tokyo",
        country_code="JP",
        is_virtual=False,
        category="Food",
        image_url="https://images.unsplash.com/photo-1414235077428-338989a2e8c0",
        max_attendees=1600,
        views_count=560,
        rsvp_count=380,
    ),
    SeedEvent(
        title="Taste of Chicago 2026",
        description="City-wide food festival featuring chefs, street vendors, and live cooking.",
        day_offset=33,
        duration_hours=7,
        timezone_name="America/Chicago",
        lat=41.8781,
        lng=-87.6298,
        address="Grant Park",
        city="Chicago",
        country_code="US",
        is_virtual=False,
        category="Food",
        image_url="https://images.unsplash.com/photo-1504674900247-0877df9cc836",
        max_attendees=2900,
        views_count=890,
        rsvp_count=640,
    ),
    SeedEvent(
        title="UN Climate Youth Forum 2026",
        description="Youth-focused panels on sustainability, climate innovation, and policy action.",
        day_offset=15,
        duration_hours=5,
        timezone_name="Europe/Zurich",
        lat=46.2044,
        lng=6.1432,
        address="Palais des Nations",
        city="Geneva",
        country_code="CH",
        is_virtual=False,
        category="Environment",
        image_url="https://images.unsplash.com/photo-1472145246862-b24cf25c4a36",
        max_attendees=1400,
        views_count=620,
        rsvp_count=430,
    ),
    SeedEvent(
        title="COP Innovation Side Event",
        description="Climate-tech founders and NGOs discuss practical decarbonization projects.",
        day_offset=31,
        duration_hours=4,
        timezone_name="UTC",
        lat=None,
        lng=None,
        address=None,
        city="Online",
        country_code=None,
        is_virtual=True,
        category="Environment",
        image_url="https://images.unsplash.com/photo-1469474968028-56623f02e42e",
        max_attendees=2000,
        views_count=740,
        rsvp_count=560,
    ),
    SeedEvent(
        title="Art Basel Conversations 2026",
        description="Panels and artist talks on contemporary art trends and collecting.",
        day_offset=27,
        duration_hours=5,
        timezone_name="Europe/Zurich",
        lat=47.5596,
        lng=7.5886,
        address="Messe Basel",
        city="Basel",
        country_code="CH",
        is_virtual=False,
        category="Art",
        image_url="https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b",
        max_attendees=1200,
        views_count=670,
        rsvp_count=470,
    ),
    SeedEvent(
        title="Game Developers Conference Community Day",
        description="Talks on game design, graphics, monetization, and indie publishing.",
        day_offset=13,
        duration_hours=6,
        timezone_name="America/Los_Angeles",
        lat=37.7749,
        lng=-122.4194,
        address="Moscone Center",
        city="San Francisco",
        country_code="US",
        is_virtual=False,
        category="Gaming",
        image_url="https://images.unsplash.com/photo-1493711662062-fa541adb3fc8",
        max_attendees=2100,
        views_count=960,
        rsvp_count=700,
    ),
]


async def seed_real_events() -> None:
    # Ensure tables exist (useful for fresh local DBs).
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with async_session_maker() as session:
        result = await session.execute(select(User).where(User.email == SEED_USER_EMAIL))
        user = result.scalar_one_or_none()
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

        inserted = 0
        now_utc = datetime.now(timezone.utc)
        start_base = now_utc.replace(hour=16, minute=0, second=0, microsecond=0)

        for item in SEED_EVENTS:
            start_utc = start_base + timedelta(days=item.day_offset)
            end_utc = start_utc + timedelta(hours=item.duration_hours)

            existing = await session.execute(
                select(Event).where(Event.title == item.title, Event.start_utc == start_utc)
            )
            if existing.scalar_one_or_none():
                continue

            event = Event(
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
                is_virtual=item.is_virtual,
                category=item.category,
                image_url=item.image_url,
                max_attendees=item.max_attendees,
                is_approved=True,
                created_by=user.id,
                views_count=item.views_count,
                rsvp_count=item.rsvp_count,
            )
            session.add(event)
            inserted += 1

        await session.commit()
        total = await session.execute(select(Event))
        all_events = total.scalars().all()
        print(f"Seed complete. Inserted {inserted} events. Total events in DB: {len(all_events)}")
        print(f"Seed user: {SEED_USER_EMAIL} / {SEED_USER_PASSWORD}")


if __name__ == "__main__":
    asyncio.run(seed_real_events())
