import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/endpoints.dart';
import '../providers/api_client_provider.dart';

class CurrentUser {
  final String id;
  final String email;

  const CurrentUser({required this.id, required this.email});

  factory CurrentUser.fromJson(Map<String, dynamic> json) {
    return CurrentUser(
      id: json['id'] as String,
      email: json['email'] as String,
    );
  }
}

final currentUserProvider = FutureProvider<CurrentUser>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get<Map<String, dynamic>>(Endpoints.authMe);
  final data = response.data;
  if (data == null) {
    throw Exception('Empty /auth/me response');
  }
  return CurrentUser.fromJson(data);
});

