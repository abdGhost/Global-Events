"""
Timezone conversion and IANA validation for global event times.
All event times are stored in UTC; this module converts to/from user/local timezone.
"""
from datetime import datetime
from zoneinfo import ZoneInfo

# Default when timezone is missing or invalid
DEFAULT_TZ = "UTC"


def normalize_timezone(tz: str | None) -> str:
    """Return IANA timezone string or DEFAULT_TZ if invalid/missing."""
    if not tz or not tz.strip():
        return DEFAULT_TZ
    tz = tz.strip()
    try:
        ZoneInfo(tz)
        return tz
    except Exception:
        return DEFAULT_TZ


def to_utc(naive_dt: datetime, tz_name: str) -> datetime:
    """
    Convert a naive datetime in the given timezone to UTC.
    If naive_dt is already timezone-aware, it is converted to UTC; tz_name is ignored.
    """
    if naive_dt.tzinfo is not None:
        return naive_dt.astimezone(ZoneInfo("UTC"))
    tz = ZoneInfo(normalize_timezone(tz_name))
    return naive_dt.replace(tzinfo=tz).astimezone(ZoneInfo("UTC"))


def to_local(utc_dt: datetime, tz_name: str) -> datetime:
    """
    Convert a UTC datetime to the given timezone.
    If utc_dt is naive, it is assumed to be UTC.
    """
    tz = ZoneInfo(normalize_timezone(tz_name))
    if utc_dt.tzinfo is None:
        utc_dt = utc_dt.replace(tzinfo=ZoneInfo("UTC"))
    return utc_dt.astimezone(tz)


def format_in_tz(utc_dt: datetime, tz_name: str, fmt: str = "%Y-%m-%d %H:%M %Z") -> str:
    """Format a UTC datetime in the given timezone for display."""
    local = to_local(utc_dt, tz_name)
    return local.strftime(fmt)
