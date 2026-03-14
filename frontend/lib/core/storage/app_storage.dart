import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/event.dart';

/// Persists auth token and onboarding state so refresh keeps user logged in.
class AppStorage {
  AppStorage._();

  static const _keyAuthToken = 'auth_token';
  static const _keyOnboardingCompleted = 'onboarding_completed';
  static const _keyUserLat = 'user_lat';
  static const _keyUserLng = 'user_lng';
  static const _keySavedEvents = 'saved_events';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<String?> getStoredToken() async {
    final prefs = await _prefs;
    return prefs.getString(_keyAuthToken);
  }

  static Future<void> saveToken(String? token) async {
    final prefs = await _prefs;
    if (token == null || token.isEmpty) {
      await prefs.remove(_keyAuthToken);
    } else {
      await prefs.setString(_keyAuthToken, token);
    }
  }

  static Future<bool> getOnboardingCompleted() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  static Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyOnboardingCompleted, value);
  }

  /// Persist the last known user location (for "Near you" and map centering).
  static Future<void> saveUserLocation(double? lat, double? lng) async {
    final prefs = await _prefs;
    if (lat == null || lng == null) {
      await prefs.remove(_keyUserLat);
      await prefs.remove(_keyUserLng);
    } else {
      await prefs.setDouble(_keyUserLat, lat);
      await prefs.setDouble(_keyUserLng, lng);
    }
  }

  /// Load the last stored user location, if any.
  static Future<({double lat, double lng})?> getStoredUserLocation() async {
    final prefs = await _prefs;
    final lat = prefs.getDouble(_keyUserLat);
    final lng = prefs.getDouble(_keyUserLng);
    if (lat == null || lng == null) return null;
    return (lat: lat, lng: lng);
  }

  /// Saved events (bookmarks). Stored as JSON array of EventListItem maps.
  static Future<List<EventListItem>> getSavedEvents() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_keySavedEvents);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>?;
      if (list == null) return [];
      return list
          .map((e) => EventListItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> setSavedEvents(List<EventListItem> items) async {
    final prefs = await _prefs;
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(_keySavedEvents, jsonEncode(list));
  }

  static Future<void> addSavedEvent(EventListItem item) async {
    final list = await getSavedEvents();
    if (list.any((e) => e.id == item.id)) return;
    list.insert(0, item);
    await setSavedEvents(list);
  }

  static Future<void> removeSavedEvent(String eventId) async {
    final list = await getSavedEvents();
    list.removeWhere((e) => e.id == eventId);
    await setSavedEvents(list);
  }
}
