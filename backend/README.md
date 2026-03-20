# Global Gather API

## Render: empty database after rebuild

A **new** or **wiped** Postgres has no rows. The API only creates **tables** on startup, not demo data.

### Option A — Automatic demo data (recommended)

In the Render **Web Service → Environment**, add:

| Key | Value |
|-----|--------|
| `SEED_ON_EMPTY` | `true` |

On each deploy, if the `events` table has **zero** rows, the app will load demo events, nearby events, chats, and the `ghost@gmail.com` test user (`ghost123`) in one pass.

Leave `SEED_ON_EMPTY` unset or `false` in production if you do not want this behavior.

### Option B — Manual (local shell with production `DATABASE_URL`)

From the `backend` folder:

```bash
set DATABASE_URL=postgresql+asyncpg://...
python -c "import asyncio; from app.auto_seed import seed_database_if_empty; asyncio.run(seed_database_if_empty())"
```

Or run individual scripts under `scripts/`.

### Required env vars on Render

- `DATABASE_URL` — `postgresql+asyncpg://...` (from Render Postgres)
- `SECRET_KEY` — strong random string for JWT

### `GET /api/events/trending` returns `[]`

The handler first returns **approved events that have not ended** (`end_utc >= now`), ordered by popularity. If that set is empty, it **falls back** to the same sort over all approved events (including past ones)—so stale demo data still shows up.

If the response is still empty, the `events` table has **no approved rows**. Enable `SEED_ON_EMPTY=true` on a fresh DB or run the seed scripts manually (see above).

### Live API still empty after seeding locally?

Your laptop seeds whatever Postgres URL is in **local** `.env`. The **Render Web Service** uses **its own** environment variables.

1. **Call `GET /api/health`** on the live site. Check `database_driver` and `events_count`:
   - **`database_driver: "sqlite"`** → The service is **not** using Render Postgres (missing or wrong `DATABASE_URL`). It defaults to SQLite on the server disk, which is **empty** and not the DB you seeded. Fix: set **`DATABASE_URL`** on the Web Service to the **Internal Database URL** from your Render Postgres (format `postgresql+asyncpg://...`), then **redeploy**.
   - **`postgresql`** but **`events_count: 0`** → The Web service points at a **different** Postgres than the one you seeded, or another empty database. Copy the **same** Internal URL from the Postgres **attached to this Web Service** into your local `.env` and run `python scripts/seed_all_demo.py` again—or seed from Render Shell with that service’s `DATABASE_URL`.
   - **`events_count` > 0** but `/api/events/trending` is `[]` → Rare; redeploy latest API (trending fallback) or check `is_approved` / time filters in code.

2. **Connection string shape:** Value must be **`postgresql+asyncpg://...`** (async driver), not `postgresql://` plain, for this codebase.
