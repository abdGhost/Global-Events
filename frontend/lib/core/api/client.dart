import 'package:dio/dio.dart';

import '../constants.dart';
import '../timezone_service.dart';

/// Global Dio instance with base URL and X-Timezone header.
Dio createApiClient({String? authToken}) {
  final dio = Dio(BaseOptions(
    baseUrl: kApiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
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
