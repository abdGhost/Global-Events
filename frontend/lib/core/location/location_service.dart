import 'package:geolocator/geolocator.dart';

/// Helper for requesting permission and reading the user's current location.
class LocationService {
  LocationService._();

  /// Requests permission (this is what shows the browser prompt on web)
  /// and returns the current position, or null if not available.
  static Future<Position?> requestAndGetCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // OS / browser location services are disabled.
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // This triggers the native / browser permission dialog.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied.
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}


