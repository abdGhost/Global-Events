import 'package:shared_preferences/shared_preferences.dart';

/// Persists auth token and onboarding state so refresh keeps user logged in.
class AppStorage {
  AppStorage._();

  static const _keyAuthToken = 'auth_token';
  static const _keyOnboardingCompleted = 'onboarding_completed';
   static const _keyUserLat = 'user_lat';
   static const _keyUserLng = 'user_lng';

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
}
