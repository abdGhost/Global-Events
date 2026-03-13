import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/timezone_service.dart';

final timezoneServiceProvider = Provider<TimezoneService>((ref) {
  return TimezoneService.instance;
});

/// Device timezone string to send as X-Timezone or ?tz= to API.
final deviceTimezoneProvider = Provider<String>((ref) {
  return TimezoneService.instance.deviceTimezone;
});
