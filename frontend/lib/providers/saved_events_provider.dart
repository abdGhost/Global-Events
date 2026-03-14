import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/app_storage.dart';
import '../models/event.dart';

class SavedEventsNotifier extends StateNotifier<List<EventListItem>> {
  SavedEventsNotifier() : super([]);

  bool _loaded = false;

  Future<void> loadFromStorage() async {
    if (_loaded) return;
    state = await AppStorage.getSavedEvents();
    _loaded = true;
  }

  Future<void> addEvent(Event event) async {
    final item = eventToListItem(event);
    if (state.any((e) => e.id == item.id)) return;
    state = [item, ...state];
    await AppStorage.addSavedEvent(item);
  }

  Future<void> removeEventById(String eventId) async {
    state = state.where((e) => e.id != eventId).toList();
    await AppStorage.removeSavedEvent(eventId);
  }

  bool isSaved(String eventId) => state.any((e) => e.id == eventId);
}

final savedEventsProvider =
    StateNotifierProvider<SavedEventsNotifier, List<EventListItem>>((ref) {
  return SavedEventsNotifier();
});
