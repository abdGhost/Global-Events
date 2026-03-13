import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple user-selected location used for "Near you" and map centering.
/// This does NOT read device GPS; it is set when the user picks a
/// location on the map.
typedef UserLocation = ({double lat, double lng});

final userLocationProvider = StateProvider<UserLocation?>((ref) => null);

