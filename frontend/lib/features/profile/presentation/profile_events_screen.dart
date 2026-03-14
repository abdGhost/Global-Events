import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/event.dart';
import '../../../providers/my_events_providers.dart';
import '../../../providers/saved_events_provider.dart';
import '../../home/presentation/widgets/event_card.dart';

enum ProfileEventsType { created, rsvped, saved }

class ProfileEventsScreen extends ConsumerWidget {
  const ProfileEventsScreen({
    super.key,
    required this.type,
  });

  final ProfileEventsType type;

  String get _title {
    switch (type) {
      case ProfileEventsType.created:
        return 'Created';
      case ProfileEventsType.rsvped:
        return 'RSVPed';
      case ProfileEventsType.saved:
        return 'Saved';
    }
  }

  IconData get _emptyIcon {
    switch (type) {
      case ProfileEventsType.created:
        return FontAwesomeIcons.calendarPlus;
      case ProfileEventsType.rsvped:
        return FontAwesomeIcons.ticket;
      case ProfileEventsType.saved:
        return FontAwesomeIcons.bookmark;
    }
  }

  String get _emptyMessage {
    switch (type) {
      case ProfileEventsType.created:
        return 'Events you create will appear here.\nTap + on the profile screen to create one.';
      case ProfileEventsType.rsvped:
        return 'Events you RSVP to will appear here.\nTap "I\'m going" on an event to add it.';
      case ProfileEventsType.saved:
        return 'Tap the bookmark icon on an event to save it here.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = Responsive.horizontalPadding(context);
    final isCompact = Responsive.isCompact(context);

    if (type == ProfileEventsType.saved) {
      ref.read(savedEventsProvider.notifier).loadFromStorage();
      final savedList = ref.watch(savedEventsProvider);
      return _buildScaffold(
        context,
        title: _title,
        pad: pad,
        body: savedList.isEmpty
            ? _buildEmptyState(
                context,
                icon: _emptyIcon,
                message: _emptyMessage,
              )
            : _buildSavedList(
                context,
                ref: ref,
                events: savedList,
                isCompact: isCompact,
                pad: pad,
              ),
      );
    }

    final provider = type == ProfileEventsType.created
        ? myCreatedEventsProvider
        : myRsvpedEventsProvider;
    final eventsAsync = ref.watch(provider);

    return _buildScaffold(
      context,
      title: _title,
      pad: pad,
      body: eventsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(pad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.white54),
                SizedBox(height: Responsive.spacing(context, 12)),
                Text(
                  'Could not load events',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                SizedBox(height: Responsive.spacing(context, 16)),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(provider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
        data: (events) {
          if (events.isEmpty) {
            return _buildEmptyState(
              context,
              icon: _emptyIcon,
              message: _emptyMessage,
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              pad,
              Responsive.spacing(context, 8),
              pad,
              Responsive.spacing(context, 24),
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Padding(
                padding: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
                child: EventCard(
                  event: event,
                  size: isCompact ? EventCardSize.small : EventCardSize.medium,
                  showGoingButton: type == ProfileEventsType.rsvped,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    required String title,
    required double pad,
    required Widget body,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
        ),
      ),
      body: body,
    );
  }

  Widget _buildSavedList(
    BuildContext context, {
    required WidgetRef ref,
    required List<EventListItem> events,
    required bool isCompact,
    required double pad,
  }) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        pad,
        Responsive.spacing(context, 8),
        pad,
        Responsive.spacing(context, 24),
      ),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Padding(
          padding: EdgeInsets.only(bottom: Responsive.spacing(context, 12)),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              EventCard(
                event: event,
                size: isCompact ? EventCardSize.small : EventCardSize.medium,
                showGoingButton: false,
              ),
              Padding(
                padding: EdgeInsets.all(Responsive.value(context, 8)),
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  child: IconButton(
                    icon: const Icon(Icons.bookmark_remove, color: Colors.white),
                    onPressed: () async {
                      await ref
                          .read(savedEventsProvider.notifier)
                          .removeEventById(event.id);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    final pad = Responsive.horizontalPadding(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(pad * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 56,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
            SizedBox(height: Responsive.spacing(context, 20)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
