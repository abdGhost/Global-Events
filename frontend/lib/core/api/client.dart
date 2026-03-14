import 'package:dio/dio.dart';

import '../constants.dart';
import '../timezone_service.dart';

/// Global Dio instance with base URL and X-Timezone header.
Dio createApiClient({String? authToken}) {
  // Render free tier cold-starts can take 30–60s; use longer timeouts for mobile.
  final dio = Dio(BaseOptions(
    baseUrl: kApiBaseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-Timezone': TimezoneService.instance.deviceTimezone,
    },
  ));

  if (authToken != null && authToken.isNotEmpty) {
    dio.options.headers['Authorization'] = 'Bearer $authToken';
  }

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      // Ensure X-Timezone is always current (e.g. after app resume)
      options.headers['X-Timezone'] = TimezoneService.instance.deviceTimezone;
      handler.next(options);
    },
  ));

  return dio;
}
