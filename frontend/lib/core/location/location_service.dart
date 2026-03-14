import 'package:geolocator/geolocator.dart';

/// Helper for requesting permission and reading the user's current location.
class LocationService {
  LocationService._();

  /// Requests permission (shows the system "Allow location?" dialog on device)
  /// and returns the current position, or null if not available.
  static Future<Position?> requestAndGetCurrentPosition() async {
    // Request app permission first so the user sees the Allow/Deny dialog.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Then check if device location service (GPS) is on.
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}


