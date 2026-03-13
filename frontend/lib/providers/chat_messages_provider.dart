import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/endpoints.dart';
import '../models/chat_message.dart';
import 'api_client_provider.dart';

/// Load latest chat messages for an event.
final chatMessagesProvider =
    FutureProvider.autoDispose.family<List<ChatMessage>, String>((ref, eventId) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get<List<dynamic>>(
    Endpoints.eventChatMessages(eventId),
    queryParameters: const {'limit': 50},
  );
  final data = response.data;
  if (data == null) return const [];
  return data
      .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
      .toList();
});

