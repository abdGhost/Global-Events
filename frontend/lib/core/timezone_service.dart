import 'package:intl/intl.dart' as intl;

/// Service for device timezone and date/time formatting in user's locale.
/// For IANA name use package `flutter_timezone` or `iana_time_zone` and set [deviceTimezoneOverride].
class TimezoneService {
  TimezoneService._();
  static final TimezoneService instance = TimezoneService._();

  /// Override with IANA from flutter_timezone: FlutterTimezone.getLocalTimezone().
  static String? deviceTimezoneOverride;

  /// Current device timezone (IANA when override set; else offset-based fallback for API).
  String get deviceTimezone {
    if (deviceTimezoneOverride != null) return deviceTimezoneOverride!;
    return deviceTimezoneName;
  }

  /// Offset-based name (e.g. UTC+05:30) when IANA not available.
  String get deviceTimezoneName {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = offset.inHours;
    final minutes = offset.inMinutes.remainder(60).abs();
    if (hours == 0 && minutes == 0) return 'UTC';
    final sign = hours >= 0 ? '+' : '-';
    return 'UTC$sign${hours.abs.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Format [utc] in local device time for list/detail.
  String formatLocal(DateTime utc) {
    final local = utc.toLocal();
    return intl.DateFormat.yMMMd().add_jm().format(local);
  }

  /// Format date only (e.g. "Mar 12, 2025").
  String formatDate(DateTime dateTime) {
    return intl.DateFormat.yMMMd().format(dateTime.toLocal());
  }

  /// Format time only (e.g. "2:30 PM").
  String formatTime(DateTime dateTime) {
    return intl.DateFormat.jm().format(dateTime.toLocal());
  }

  /// Format for countdown or "in X days".
  String formatRelative(DateTime utc) {
    final now = DateTime.now().toUtc();
    final diff = utc.difference(now);
    if (diff.isNegative) return 'Past';
    if (diff.inDays > 0) return 'In ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
    if (diff.inHours > 0) return 'In ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}';
    if (diff.inMinutes > 0) return 'In ${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'}';
    return 'Soon';
  }

  /// Parse ISO string from API (UTC) and return as DateTime (UTC).
  DateTime? parseUtc(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso);
  }
}
