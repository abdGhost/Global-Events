# GlobalEvents (WorldGather) – Project Plan

## Overview

**App name:** GlobalEvents (alias: WorldGather, EventSphere)  
**Goal:** Scalable mobile/web app for discovering, creating, RSVPing to, and real-time chatting in events **worldwide** (in-person, virtual, trending, nearby).

**Core value:** Help anyone find/join events anywhere.

---

## Tech Stack

| Layer | Stack |
|-------|--------|
| **Backend** | FastAPI (latest), async SQLAlchemy 2.0+, Alembic, PostgreSQL (PostGIS optional), Redis (cache + pub/sub for WS), fastapi-users[sqlalchemy] or manual JWT, Pydantic v2 |
| **Frontend** | Flutter 3.24+, Riverpod 2.5+ (annotation + generator), go_router, dio, google_maps_flutter + google_maps_webservice, web_socket_channel, cached_network_image, firebase_messaging, hive_flutter, flutter_secure_storage, intl (i18n + timezone) |

---

## Database Schema (Global)

### users
- `id`, `email`, `hashed_password`, `is_active`, `is_verified`, `created_at`, `updated_at`
- **+ timezone** (string, IANA e.g. `Asia/Kolkata`, default `UTC`)

### events
- `id`, `title`, `description`
- `start_utc` (timestamptz), `end_utc` (timestamptz)
- `timezone` (string, display reference for event location)
- `lat` (float nullable), `lng` (float nullable)
- `address`, `city`, `country_code` (ISO2)
- `is_virtual` (bool)
- `category`, `image_url`
- `max_attendees` (int nullable)
- `is_approved` (bool, default true or moderation flow)
- `created_by` (FK → users), `created_at`
- `views_count`, `rsvp_count` (denormalized for trending)

### rsvps
- `id`, `event_id`, `user_id`, `created_at`
- Unique (event_id, user_id)

### chat_messages
- `id`, `event_id`, `user_id`, `content`, `created_at`

---

## API Endpoints

### Auth
- `POST /auth/register`, `POST /auth/login`, `POST /auth/logout`, `GET /auth/me` (returns `user.timezone`; set from device on first login)

### Events
- `GET /events/trending?limit=20&offset=0` – high rsvp/views, recent
- `GET /events/search?query=...&category=...&start_after=...&end_before=...&country=US&is_virtual=true&sort=popular&page=...`
- `GET /events/nearby?lat=...&lng=...&radius_km=50&limit=...`
- `GET /events/{id}` – single event; return times in user’s timezone via header `X-Timezone: Asia/Tokyo` or query `?tz=Asia/Tokyo`
- `POST /events` – create; client sends start/end in user’s local time → backend converts to UTC
- `PATCH /events/{id}`, `DELETE /events/{id}` (owner only)

### RSVPs
- `POST /events/{id}/rsvp`, `DELETE /events/{id}/rsvp`, `GET /events/{id}/rsvps` (or via event detail)

### Chat
- `WS /ws/chat/{event_id}` – Redis pub/sub for broadcast

---

## Folder Trees

### Backend (FastAPI)

```
backend/
├── alembic/
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   ├── core/
│   │   ├── __init__.py
│   │   ├── security.py
│   │   └── utils/
│   │       ├── __init__.py
│   │       └── timezone.py          # UTC conversion, IANA validation
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── event.py
│   │   ├── rsvp.py
│   │   └── chat_message.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── event.py                 # timezone-aware request/response
│   │   └── common.py
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── events.py                # trending, search, nearby, CRUD
│   │   ├── rsvps.py
│   │   └── chat.py                  # WS /ws/chat/{event_id}
│   └── services/
│       ├── __init__.py
│       └── redis_pubsub.py          # chat broadcast
├── requirements.txt
└── alembic.ini
```

### Flutter (Frontend)

```
frontend/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── api/
│   │   │   ├── client.dart
│   │   │   └── endpoints.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── timezone_service.dart    # device TZ, conversion, intl
│   │   └── constants.dart
│   ├── models/
│   │   ├── user.dart
│   │   └── event.dart               # UTC + local display fields
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── trending_events_provider.dart
│   │   ├── search_events_provider.dart   # family
│   │   └── nearby_events_provider.dart   # family
│   ├── features/
│   │   ├── home/
│   │   │   ├── home_screen.dart      # Trending, Nearby, Search tabs
│   │   │   └── widgets/
│   │   ├── events/
│   │   │   ├── event_detail_screen.dart
│   │   │   ├── create_event_screen.dart  # Google Places → city/country/lat/lng
│   │   │   └── widgets/
│   │   ├── chat/
│   │   │   └── event_chat_screen.dart
│   │   └── auth/
│   └── shared/
│       └── widgets/
├── pubspec.yaml
└── ...
```

---

## Execution Phases

| Phase | Scope |
|-------|--------|
| **Phase 1** | Setup + Auth + Timezone basics (user.timezone, /auth/me, timezone utils) |
| **Phase 2** | Events CRUD with UTC storage + timezone conversion (POST/GET with tz) |
| **Phase 3** | Global search + trending (search, trending, nearby endpoints) |
| **Phase 4** | Home screen redesign (Trending horizontal, Nearby, Search bar/tabs) |
| **Phase 5** | Chat (WS + Redis pub/sub), offline (hive), notifications (FCM) |

---

## Timezone Handling (Summary)

- **Storage:** All event times in DB as `start_utc`, `end_utc` (timestamptz). User has `timezone` (IANA).
- **Create event:** Client sends `start_local`, `end_local` + `timezone` (or from Places) → backend converts to UTC and stores.
- **Read event:** `GET /events/{id}?tz=Asia/Tokyo` or header `X-Timezone` → response includes `start_local`, `end_local` in that TZ plus `timezone` label.
- **Flutter:** `intl` + `timezone` package; `TimezoneService` for device TZ and formatting.

---

## Next Steps After This Deliverable

1. Implement Phase 1: Auth router, user model with timezone, Alembic migration.
2. Wire events router to DB and add RSVP endpoints.
3. Flutter: Home screen with trending/nearby/search providers and UI.
4. WebSocket chat with Redis pub/sub.
