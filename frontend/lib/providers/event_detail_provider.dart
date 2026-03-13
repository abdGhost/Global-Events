import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/endpoints.dart';
import '../core/data/dummy_events.dart';
import '../models/event.dart';
import 'api_client_provider.dart';

/// Fetches GET /api/events/:id. Uses dummy data when [useDummyData] is true.
final eventDetailProvider = FutureProvider.autoDispose.family<Event, String>((ref, eventId) async {
  if (useDummyData) {
    final event = getDummyEventById(eventId);
    if (event == null) throw Exception('Event not found');
    return event;
  }
  final client = ref.watch(apiClientProvider);
  final response = await client.get<Map<String, dynamic>>(Endpoints.eventDetail(eventId));
  final data = response.data;
  if (data == null) throw Exception('Event not found');
  return Event.fromJson(data);
});
