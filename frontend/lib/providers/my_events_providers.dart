import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/endpoints.dart';
import '../models/event.dart';
import 'api_client_provider.dart';

/// Events created by the current user (GET /api/events/created). Requires auth.
final myCreatedEventsProvider =
    FutureProvider.autoDispose<List<EventListItem>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get<List<dynamic>>(
    Endpoints.eventsCreated,
    queryParameters: {'limit': 50, 'offset': 0},
  );
  final list = response.data;
  if (list == null) return [];
  return list
      .map((e) => EventListItem.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Events the current user has RSVPed to (GET /api/events/rsvped). Requires auth.
final myRsvpedEventsProvider =
    FutureProvider.autoDispose<List<EventListItem>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get<List<dynamic>>(
    Endpoints.eventsRsvped,
    queryParameters: {'limit': 50, 'offset': 0},
  );
  final list = response.data;
  if (list == null) return [];
  return list
      .map((e) => EventListItem.fromJson(e as Map<String, dynamic>))
      .toList();
});
