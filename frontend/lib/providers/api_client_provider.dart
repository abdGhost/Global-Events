import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/client.dart';

/// API client. Optionally depend on auth token provider when auth is wired.
final apiClientProvider = Provider<Dio>((ref) {
  // final token = ref.watch(authTokenProvider);
  return createApiClient(/* authToken: token */);
});
