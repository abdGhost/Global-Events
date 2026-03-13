import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/data/dummy_events.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/event.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Simple center over Europe / Atlantic so dummy events look ok.
  final _mapController = MapController();
  final _center = const LatLng(20.0, 0.0);
  double _zoom = 2.5;
  int _selectedFilterIndex = 0;

  List<Event> _applyFilter(List<Event> all) {
    switch (_selectedFilterIndex) {
      case 1: // Today
        final today = DateTime.now();
        return all.where((e) {
          final d = e.displayStart;
          return d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
        }).toList();
      case 2: // This week
        final now = DateTime.now();
        final startOfWeek =
            now.subtract(Duration(days: now.weekday - 1)); // Monday
        final endOfWeek = startOfWeek.add(const Duration(days: 7));
        return all.where((e) {
          final d = e.displayStart;
          return d.isAfter(startOfWeek) && d.isBefore(endOfWeek);
        }).toList();
      case 3: // Near me (for now: non-virtual events only)
        return all.where((e) => !e.isVirtual).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);
    final baseEvents =
        dummyEventsFull.where((e) => e.lat != null && e.lng != null).toList();
    final events = _applyFilter(baseEvents);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: _zoom,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.globalevents.app',
                ),
                MarkerLayer(
                  markers: [
                    for (var i = 0; i < events.length; i++)
                      Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(
                          events[i].lat!,
                          events[i].lng!,
                        ),
                        child: _EventMarker(label: events[i].city ?? 'Unknown'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Top app bar overlay
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
                  Container(
                    padding: EdgeInsets.all(
                        Responsive.value(context, 7)),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(
                          Responsive.value(context, 12)),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.locationDot,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: Responsive.spacing(context, 10)),
                  Text(
                    'Explore events on map',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(
                          Responsive.value(context, 999)),
                    ),
                    child: IconButton(
                      iconSize: Responsive.iconSize(context, 18),
                      icon: const FaIcon(
                        FontAwesomeIcons.locationCrosshairs,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          _mapController.move(_center, _zoom),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom sheet with events
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(Responsive.value(context, 22)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  pad,
                  Responsive.spacing(context, 10),
                  pad,
                  Responsive.spacing(context, 14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(context, 10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Events on map',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${events.length} found',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.spacing(context, 8)),
                    _FilterChipsRow(
                      selectedIndex: _selectedFilterIndex,
                      onSelected: (index) {
                        setState(() {
                          _selectedFilterIndex = index;
                        });
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, 8)),
                    SizedBox(
                      height: Responsive.value(context, 120),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: events.length,
                        separatorBuilder: (_, __) => SizedBox(
                          width: Responsive.spacing(context, 10),
                        ),
                        itemBuilder: (_, i) => _MapEventChip(
                          item: EventListItem(
                            id: events[i].id,
                            title: events[i].title,
                            startUtc: events[i].startUtc,
                            endUtc: events[i].endUtc,
                            timezone: events[i].timezone,
                            city: events[i].city,
                            countryCode: events[i].countryCode,
                            isVirtual: events[i].isVirtual,
                            category: events[i].category,
                            imageUrl: events[i].imageUrl,
                            rsvpCount: events[i].rsvpCount,
                            viewsCount: events[i].viewsCount,
                          ),
                        ),
                      ),
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

class _EventMarker extends StatelessWidget {
  const _EventMarker({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Icon(
          Icons.location_on,
          color: AppColors.primaryDark,
          size: 24,
        ),
      ],
    );
  }
}

class _MapEventChip extends StatelessWidget {
  const _MapEventChip({required this.item});

  final EventListItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Responsive.value(context, 220),
      padding: EdgeInsets.all(Responsive.spacing(context, 10)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius:
            BorderRadius.circular(Responsive.value(context, 16)),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            item.city ?? 'Unknown location',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(
                Icons.people_alt_rounded,
                size: 14,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: 4),
              Text(
                '${item.rsvpCount} going',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryDark,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = ['All', 'Today', 'This week', 'Near me'];
    final isCompact = Responsive.isCompact(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: EdgeInsets.only(
                right: Responsive.spacing(context, 6),
              ),
              child: _FilterChip(
                label: labels[i],
                selected: selectedIndex == i,
                onTap: () => onSelected(i),
                compact: isCompact,
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = Responsive.value(context, compact ? 16 : 18);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.value(context, compact ? 10 : 14),
            vertical: Responsive.value(context, compact ? 5 : 7),
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryDark
                : AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: selected
                  ? AppColors.primaryDark
                  : AppColors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: Responsive.fontSize(context, compact ? 11 : 12),
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? Colors.white : AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
