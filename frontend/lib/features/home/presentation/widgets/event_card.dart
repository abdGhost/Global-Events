import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/event.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.heroTag,
    this.size = EventCardSize.medium,
    this.showGoingButton = true,
  });

  final EventListItem event;
  final String? heroTag;
  final EventCardSize size;
  final bool showGoingButton;

  String get _locationLabel => event.isVirtual
      ? 'Virtual'
      : (event.city ?? event.address ?? event.countryCode ?? 'Location to be announced');
  String get _timeLabel {
    final local = event.startUtc.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(local.year, local.month, local.day);
    final diff = eventDay.difference(today).inDays;
    String dayLabel = DateFormat.MMMd().format(local);
    if (diff == 0) dayLabel = 'Today';
    if (diff == 1) dayLabel = 'Tomorrow';
    return '$dayLabel • ${DateFormat.jm().format(local)}';
  }

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    final isLarge = size == EventCardSize.large;
    // Medium cards are used in "This week" list; keep them shorter like the trending card.
    final aspectRatio = isLarge
        ? 16 / 9
        : (size == EventCardSize.medium ? 16 / 9 : 4 / 3);
    final imageUrl = event.imageUrl;
    final r = Responsive.value(context, 20);
    final iconS = Responsive.iconSize(context, compact ? 13 : 14);
    final smallTextS = Responsive.fontSize(context, compact ? (isLarge ? 11 : 10) : (isLarge ? 12 : 11));
    final titleTextS = Responsive.fontSize(
      context,
      compact ? (isLarge ? 14 : 13) : (isLarge ? 15 : 14),
    );

    Widget buildMedia({required bool fillHeight, required bool showTrendingBadge}) {
      final media = Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl.isNotEmpty)
            CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)
          else
            Container(
              color: AppColors.primary.withValues(alpha: 0.3),
              child: FaIcon(
                FontAwesomeIcons.calendarDays,
                size: Responsive.iconSize(context, 48),
                color: Colors.white54,
              ),
            ),
          if (showTrendingBadge)
            Positioned(
              top: Responsive.value(context, 8),
              left: Responsive.value(context, 8),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.value(context, 8),
                  vertical: Responsive.value(context, 4),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(Responsive.value(context, 8)),
                ),
                child: Text(
                  'Trending',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: smallTextS,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
          Align(
            alignment: Alignment.bottomCenter,
            child: _OverlayMeta(
              title: event.title,
              timeLabel: _timeLabel,
              locationLabel: _locationLabel,
              rsvpCount: event.rsvpCount,
              // Near-you (small) cards: show only title + going count.
              showActions: showGoingButton && !isLarge && size != EventCardSize.small,
              showTimeLocation: size != EventCardSize.small,
              showGoingCount: true,
              titleSize: titleTextS,
              iconSize: iconS,
              smallTextSize: smallTextS,
              // Only treat small cards as "compact".
              isCompactCard: size == EventCardSize.small,
              // Split time (left) and location (right) for large + medium cards.
              splitMeta: isLarge || size == EventCardSize.medium,
            ),
          ),
        ],
      );

      final clipped = ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(r)),
        child: media,
      );

      if (fillHeight) return clipped;
      return AspectRatio(aspectRatio: aspectRatio, child: clipped);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedHeight = constraints.hasBoundedHeight && constraints.maxHeight.isFinite;
        final fillCardHeight = hasBoundedHeight && (isLarge || size == EventCardSize.small);

        // Cards used inside fixed-height parents (carousel / near-you row) should fill height.
        final mediaWidget = fillCardHeight
            ? Expanded(child: buildMedia(fillHeight: true, showTrendingBadge: isLarge))
            : buildMedia(fillHeight: false, showTrendingBadge: isLarge);

        return Card(
          elevation: 0,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/event/${event.id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: fillCardHeight ? MainAxisSize.max : MainAxisSize.min,
              children: [
                mediaWidget,
              ],
            ),
          ),
        );
      },
    );
  }
}

enum EventCardSize { small, medium, large }

class _OverlayMeta extends StatelessWidget {
  const _OverlayMeta({
    required this.title,
    required this.timeLabel,
    required this.locationLabel,
    required this.rsvpCount,
    required this.showActions,
    required this.showTimeLocation,
    required this.showGoingCount,
    required this.titleSize,
    required this.iconSize,
    required this.smallTextSize,
    this.isCompactCard = false,
    this.splitMeta = false,
  });

  final String title;
  final String timeLabel;
  final String locationLabel;
  final int rsvpCount;
  final bool showActions;
  final bool showTimeLocation;
  final bool showGoingCount;
  final double titleSize;
  final double iconSize;
  final double smallTextSize;
  final bool isCompactCard;
  final bool splitMeta;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.value(context, isCompactCard ? 10 : 12);
    final metaGap = Responsive.spacing(context, 10);
    final actionSize = Responsive.value(context, isCompactCard ? 32 : 34);
    final goingIconSize = Responsive.iconSize(context, isCompactCard ? 13 : 14);

    return Container(
      width: double.infinity,
      // Keep a subtle fade for readability, but put all text/actions inside one dark panel.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
        ),
      ),
      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.value(context, 12),
          vertical: Responsive.value(context, 10),
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(Responsive.value(context, 16)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: titleSize,
                height: 1.1,
              ),
            ),
            if (showTimeLocation) ...[
              SizedBox(height: Responsive.spacing(context, 4)),
              // Large + medium: keep time on left, location pinned to far right.
              if (splitMeta && !isCompactCard)
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.clock, size: iconSize, color: Colors.white70),
                          SizedBox(width: Responsive.spacing(context, 4)),
                          Expanded(
                            child: Text(
                              timeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white70, fontSize: smallTextSize, height: 1.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: metaGap),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          FaIcon(FontAwesomeIcons.locationDot, size: iconSize, color: Colors.white70),
                          SizedBox(width: Responsive.spacing(context, 4)),
                          Flexible(
                            child: Text(
                              locationLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(color: Colors.white70, fontSize: smallTextSize, height: 1.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    FaIcon(FontAwesomeIcons.clock, size: iconSize, color: Colors.white70),
                    SizedBox(width: Responsive.spacing(context, 4)),
                    Expanded(
                      child: Text(
                        timeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white70, fontSize: smallTextSize, height: 1.1),
                      ),
                    ),
                    SizedBox(width: metaGap),
                    FaIcon(FontAwesomeIcons.locationDot, size: iconSize, color: Colors.white70),
                    SizedBox(width: Responsive.spacing(context, 4)),
                    Flexible(
                      child: Text(
                        locationLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white70, fontSize: smallTextSize, height: 1.1),
                      ),
                    ),
                  ],
                ),
            ],
            if (showGoingCount) ...[
              SizedBox(height: Responsive.spacing(context, showTimeLocation ? 8 : 6)),
              Row(
                children: [
                  FaIcon(FontAwesomeIcons.userGroup, size: goingIconSize, color: Colors.white70),
                  SizedBox(width: Responsive.spacing(context, 6)),
                  Text(
                    '$rsvpCount going',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: smallTextSize,
                      height: 1.0,
                    ),
                  ),
                  if (showActions) ...[
                    const Spacer(),
                    SizedBox(
                      height: actionSize,
                      child: FilledButton(
                        onPressed: () => context.push('/event/${_eventIdFromContext(context)}'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.16),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: Responsive.value(context, isCompactCard ? 10 : 12)),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Responsive.value(context, 12)),
                          ),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.check,
                          size: Responsive.iconSize(context, isCompactCard ? 14 : 16),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // We can't access the Event object here; read the route from surrounding InkWell tap.
  // The icon button should navigate to the event detail; we infer it from the parent route params.
  // Fallback: do nothing (kept simple). Caller should wrap the whole card with navigation anyway.
  String _eventIdFromContext(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    // If already on /event/:id, keep id.
    final match = RegExp(r'/event/([^/]+)').firstMatch(location);
    return match?.group(1) ?? '';
  }
}
