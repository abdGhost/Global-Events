import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/user_location_provider.dart';
import '../../../core/storage/app_storage.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _mapController = MapController();
  LatLng _center = const LatLng(20.0, 0.0);
  LatLng? _picked;
  String? _address;
  String? _city;
  String? _countryCode;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    // If the app already has a user location (from Enable location),
    // center the picker map there and pre-select that point so users
    // can easily fine-tune it.
    final loc = ref.read(userLocationProvider);
    if (loc != null) {
      _center = LatLng(loc.lat, loc.lng);
      _picked = _center;
      // Move the map after the first frame so the controller is ready.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_center, 13);
        _reverseGeocode(_center);
      });
    }
  }

  Future<void> _reverseGeocode(LatLng latLng) async {
    setState(() {
      _isLoadingAddress = true;
      _address = null;
    });
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/reverse',
        {
          'format': 'jsonv2',
          'lat': latLng.latitude.toString(),
          'lon': latLng.longitude.toString(),
        },
      );
      final resp = await http.get(
        uri,
        headers: {
          'User-Agent': 'GlobalEventsApp/0.1 (contact: example@example.com)',
        },
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final displayName = data['display_name'] as String?;
        final addr = data['address'] as Map<String, dynamic>?;
        final city = addr?['city'] ??
            addr?['town'] ??
            addr?['village'] ??
            addr?['hamlet'] ??
            addr?['suburb'];
        final countryCode = (addr?['country_code'] as String?)?.toUpperCase();
        setState(() {
          _address = displayName ?? 'Selected location';
          _city = city as String?;
          _countryCode = countryCode;
        });
      } else {
        setState(() {
          _address = 'Selected location';
          _city = null;
          _countryCode = null;
        });
      }
    } catch (_) {
      setState(() {
        _address = 'Selected location';
        _city = null;
        _countryCode = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 3.0,
                onTap: (tapPosition, latLng) {
                  setState(() {
                    _picked = latLng;
                  });
                  _reverseGeocode(latLng);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.globalevents.app',
                ),
                if (_picked != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: _picked!,
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primaryDark,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                pad,
                Responsive.spacing(context, 10),
                pad,
                0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: Responsive.spacing(context, 8)),
                  Text(
                    'Tap on map to pick location',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Responsive.value(context, 20)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  pad,
                  Responsive.spacing(context, 12),
                  pad,
                  Responsive.spacing(context, 14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _picked == null
                                ? 'Tap anywhere on the map'
                                : (_isLoadingAddress
                                    ? 'Finding address...'
                                    : _address ?? 'Selected location'),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey.shade800,
                                ),
                          ),
                          if (_picked != null && !_isLoadingAddress)
                            Text(
                              'Use this address for your event',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, 10)),
                    FilledButton(
                      onPressed: _picked == null || _isLoadingAddress
                          ? null
                          : () {
                              final loc =
                                  (lat: _picked!.latitude, lng: _picked!.longitude);
                              ref.read(userLocationProvider.notifier).state = loc;
                              // Persist picked location for future sessions.
                              AppStorage.saveUserLocation(loc.lat, loc.lng);
                              Navigator.of(context).pop({
                                'lat': loc.lat,
                                'lng': loc.lng,
                                'address': _address,
                                'city': _city,
                                'countryCode': _countryCode,
                              });
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.value(context, 18),
                          vertical: Responsive.value(context, 10),
                        ),
                      ),
                      child: const Text('Use location'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

