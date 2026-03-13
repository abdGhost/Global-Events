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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NearbyParams &&
        other.lat == lat &&
        other.lng == lng &&
        other.radiusKm == radiusKm &&
        other.limit == limit;
  }

  @override
  int get hashCode => Object.hash(lat, lng, radiusKm, limit);
}

/// Family provider: nearby events by [NearbyParams]. Uses dummy data when [useDummyData] is true.
final nearbyEventsProvider = FutureProvider.autoDispose.family<List<EventListItem>, NearbyParams>((ref, params) async {
  if (useDummyData) return dummyEventListItems;
  final client = ref.watch(apiClientProvider);
  try {
    // Debug: log nearby query parameters.
    // ignore: avoid_print
    print(
        'Fetching nearby events: lat=${params.lat}, lng=${params.lng}, radius_km=${params.radiusKm}, limit=${params.limit}');
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
    final items = list
        .map((e) => EventListItem.fromJson(e as Map<String, dynamic>))
        .toList();
    // ignore: avoid_print
    print('Nearby events count: ${items.length}');
    return items;
  } catch (e) {
    // Log the error so we can see backend issues in console,
    // but let Riverpod surface it to the UI.
    // ignore: avoid_print
    print('Error fetching nearby events: $e');
    rethrow;
  }
});
