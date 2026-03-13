"""
Alembic env. Uses sync engine (psycopg2) for migrations.
Run: alembic upgrade head
"""
from logging.config import fileConfig

from alembic import context
from sqlalchemy import create_engine
from sqlalchemy.engine import Connection

from app.config import settings
from app.database import Base
from app.models import user, event, rsvp, chat_message  # noqa: F401 - ensure models are registered

config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)
# Sync URL for Alembic (strip async driver suffix like +aiosqlite or +asyncpg).
sync_url = settings.database_url
for suffix in ("+aiosqlite", "+asyncpg"):
    if suffix in sync_url:
        sync_url = sync_url.replace(suffix, "")
config.set_main_option("sqlalchemy.url", sync_url)

target_metadata = Base.metadata


def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()


def do_run_migrations(connection: Connection) -> None:
    context.configure(connection=connection, target_metadata=target_metadata)
    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    from sqlalchemy.pool import NullPool
    connectable = create_engine(config.get_main_option("sqlalchemy.url"), poolclass=NullPool)
    with connectable.connect() as connection:
        do_run_migrations(connection)


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
