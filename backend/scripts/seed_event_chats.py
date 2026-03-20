"""
Seed chat messages for existing events.

Usage:
  python scripts/seed_event_chats.py
"""
from __future__ import annotations

import asyncio
import os
import sys
from datetime import datetime, timezone

from sqlalchemy import func, select

ROOT_DIR = os.path.dirname(os.path.dirname(__file__))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

from app.core.security import hash_password
from app.database import async_session_maker
from app.models.chat_message import ChatMessage
from app.models.event import Event
from app.models.user import User


SEED_CHAT_USERS: list[tuple[str, str]] = [
    ("nora.travels@globalgather.app", "Nora"),
    ("liam.dev@globalgather.app", "Liam"),
    ("sofia.music@globalgather.app", "Sofia"),
    ("alex.sports@globalgather.app", "Alex"),
]

CHAT_LINES: list[str] = [
    "Anyone else attending from out of town?",
    "Is there a recommended schedule for first-time attendees?",
    "I just RSVPed, really excited for this one.",
    "Will there be networking after the main sessions?",
    "If someone is going solo, we can form a small meetup group.",
    "Thanks for sharing updates here, super helpful.",
    "Do we know when check-in opens at the venue?",
    "I saw the speaker lineup, looks amazing.",
]


async def _get_or_create_user(email: str) -> User:
    async with async_session_maker() as session:
        existing = await session.execute(select(User).where(User.email == email))
        user = existing.scalar_one_or_none()
        if user:
            return user
        user = User(
            email=email,
            hashed_password=hash_password("SeedChat123!"),
            is_active=True,
            is_verified=True,
            timezone="UTC",
        )
        session.add(user)
        await session.commit()
        await session.refresh(user)
        return user


async def seed_event_chats() -> None:
    users: list[User] = []
    for email, _name in SEED_CHAT_USERS:
        users.append(await _get_or_create_user(email))

    async with async_session_maker() as session:
        # Seed chats for up to 20 upcoming events.
        events_result = await session.execute(
            select(Event)
            .where(Event.end_utc >= datetime.now(timezone.utc))
            .order_by(Event.start_utc.asc())
            .limit(20)
        )
        events = events_result.scalars().all()

        if not events:
            print("No upcoming events found. Seed events first.")
            return

        inserted = 0
        for idx, event in enumerate(events):
            count_result = await session.execute(
                select(func.count(ChatMessage.id)).where(ChatMessage.event_id == event.id)
            )
            existing_count = count_result.scalar_one()
            # Keep idempotent: if already has enough seeded-like chatter, skip.
            if existing_count >= 4:
                continue

            # Add 4 messages per event.
            for msg_i in range(4):
                user = users[(idx + msg_i) % len(users)]
                content = CHAT_LINES[(idx * 2 + msg_i) % len(CHAT_LINES)]
                session.add(
                    ChatMessage(
                        event_id=event.id,
                        user_id=user.id,
                        content=content,
                    )
                )
                inserted += 1

        await session.commit()
        print(f"Chat seed complete. Inserted {inserted} messages across {len(events)} events.")


if __name__ == "__main__":
    asyncio.run(seed_event_chats())
