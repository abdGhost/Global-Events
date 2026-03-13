import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/endpoints.dart';
import '../core/data/dummy_events.dart';
import '../models/event.dart';
import 'api_client_provider.dart';

/// Params for GET /api/events/nearby.
class NearbyParams {
  final double lat;
  final double lng;
  final double radiusKm;
  final int limit;

  const NearbyParams({
    required this.lat,
    required this.lng,
    this.radiusKm = 50,
    this.limit = 20,
  });
}

/// Family provider: nearby events by [NearbyParams]. Uses dummy data when [useDummyData] is true.
final nearbyEventsProvider = FutureProvider.autoDispose.family<List<EventListItem>, NearbyParams>((ref, params) async {
  if (useDummyData) return dummyEventListItems;
  final client = ref.watch(apiClientProvider);
  final response = await client.get<List<dynamic>>(
    Endpoints.eventsNearby,
    queryParameters: {
      'lat': params.lat,
      'lng': params.lng,
      'radius_km': params.radiusKm,
      'limit': params.limit,
    },
  );
  final list = response.data;
  if (list == null) return [];
  return list
      .map((e) => EventListItem.fromJson(e as Map<String, dynamic>))
      .toList();
});
