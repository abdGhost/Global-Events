import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/endpoints.dart';
import '../core/data/dummy_events.dart';
import '../models/event.dart';
import 'api_client_provider.dart';

/// Search params for GET /api/events/search.
class SearchParams {
  final String? query;
  final String? category;
  final DateTime? startAfter;
  final DateTime? endBefore;
  final String? country;
  final bool? isVirtual;
  final String sort; // 'popular' | 'date'
  final int page;
  final int pageSize;

  const SearchParams({
    this.query,
    this.category,
    this.startAfter,
    this.endBefore,
    this.country,
    this.isVirtual,
    this.sort = 'popular',
    this.page = 1,
    this.pageSize = 20,
  });
}

/// Family provider: search events by [SearchParams]. Uses dummy data when [useDummyData] is true.
final searchEventsProvider = FutureProvider.autoDispose.family<List<EventListItem>, SearchParams>((ref, params) async {
  if (useDummyData) {
    var list = List<EventListItem>.from(dummyEventListItems);
    if (params.query != null && params.query!.isNotEmpty) {
      final q = params.query!.toLowerCase();
      list = list.where((e) => e.title.toLowerCase().contains(q) || (e.category?.toLowerCase().contains(q) ?? false)).toList();
    }
    if (params.category != null && params.category!.isNotEmpty) {
      list = list.where((e) => e.category == params.category).toList();
    }
    if (params.isVirtual != null) {
      list = list.where((e) => e.isVirtual == params.isVirtual).toList();
    }
    return list;
  }
  final client = ref.watch(apiClientProvider);
  final queryParams = <String, dynamic>{
    'page': params.page,
    'page_size': params.pageSize,
    'sort': params.sort,
  };
  if (params.query != null && params.query!.isNotEmpty) queryParams['query'] = params.query;
  if (params.category != null) queryParams['category'] = params.category;
  if (params.startAfter != null) queryParams['start_after'] = params.startAfter!.toUtc().toIso8601String();
  if (params.endBefore != null) queryParams['end_before'] = params.endBefore!.toUtc().toIso8601String();
  if (params.country != null) queryParams['country'] = params.country;
  if (params.isVirtual != null) queryParams['is_virtual'] = params.isVirtual;

  final response = await client.get<List<dynamic>>(Endpoints.eventsSearch, queryParameters: queryParams);
  final list = response.data;
  if (list == null) return [];
  return list
      .map((e) => EventListItem.fromJson(e as Map<String, dynamic>))
      .toList();
});
