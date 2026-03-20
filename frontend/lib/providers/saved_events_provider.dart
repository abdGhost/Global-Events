import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/app_storage.dart';
import '../models/event.dart';

class SavedEventsNotifier extends StateNotifier<List<EventListItem>> {
  SavedEventsNotifier() : super([]);

  bool _loaded = false;
  String? _userEmail;

  /// Call when /auth/me resolves or on logout.
  void setUserEmail(String? email) {
    final n = email?.toLowerCase().trim();
    if (_userEmail == n) return;
    _userEmail = n;
    _loaded = false;
    state = [];
    loadFromStorage();
  }

  void onLogout() {
    _userEmail = null;
    _loaded = false;
    state = [];
  }

  Future<void> loadFromStorage() async {
    if (_loaded) return;
    state = await AppStorage.getSavedEvents(userEmail: _userEmail);
    _loaded = true;
  }

  /// Re-read disk (e.g. when opening Saved tab).
  Future<void> refreshFromStorage() async {
    state = await AppStorage.getSavedEvents(userEmail: _userEmail);
    _loaded = true;
  }

  Future<void> addEvent(Event event) async {
    final item = eventToListItem(event);
    if (state.any((e) => e.id == item.id)) return;
    state = [item, ...state];
    await AppStorage.addSavedEvent(item, userEmail: _userEmail);
  }

  Future<void> removeEventById(String eventId) async {
    state = state.where((e) => e.id != eventId).toList();
    await AppStorage.removeSavedEvent(eventId, userEmail: _userEmail);
  }

  bool isSaved(String eventId) => state.any((e) => e.id == eventId);
}

final savedEventsProvider =
    StateNotifierProvider<SavedEventsNotifier, List<EventListItem>>((ref) {
  return SavedEventsNotifier();
});
