import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/endpoints.dart';
import '../core/data/dummy_events.dart';
import '../models/event.dart';
import 'api_client_provider.dart';

/// Fetches GET /api/events/trending. Uses dummy data when [useDummyData] is true.
final trendingEventsProvider = FutureProvider.autoDispose<List<EventListItem>>((ref) async {
  if (useDummyData) return dummyEventListItems;
  final client = ref.watch(apiClientProvider);
  final response = await client.get<List<dynamic>>(
    Endpoints.eventsTrending,
    queryParameters: {'limit': 20, 'offset': 0},
  );
  final list = response.data;
  if (list == null) return [];
  return list
      .map((e) => EventListItem.fromJson(e as Map<String, dynamic>))
      .toList();
});
