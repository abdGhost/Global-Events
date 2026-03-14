import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/event.dart';
import '../../../providers/event_detail_provider.dart';
import '../../../providers/saved_events_provider.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvent = ref.watch(eventDetailProvider(eventId));
    final savedList = ref.watch(savedEventsProvider);

    return Scaffold(
      body: asyncEvent.when(
        data: (event) {
          final isSaved = savedList.any((e) => e.id == event.id);
          final onSaveToggle = () async {
            final notifier = ref.read(savedEventsProvider.notifier);
            if (notifier.isSaved(event.id)) {
              await notifier.removeEventById(event.id);
            } else {
              await notifier.addEvent(event);
            }
          };
          return _EventDetailBody(
            event: event,
            isSaved: isSaved,
            onSaveToggle: onSaveToggle,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $e', style: TextStyle(color: Colors.red.shade700)),
              const SizedBox(height: 16),
              FilledButton(
                  onPressed: () => context.pop(), child: const Text('Back')),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventDetailBody extends StatelessWidget {
  const _EventDetailBody({
    required this.event,
    required this.isSaved,
    required this.onSaveToggle,
  });

  final Event event;
  final bool isSaved;
  final VoidCallback onSaveToggle;

  @override
  Widget build(BuildContext context) {
    return _EventDetailScroll(
      event: event,
      isSaved: isSaved,
      onSaveToggle: onSaveToggle,
    );
  }
}

class _EventDetailScroll extends StatefulWidget {
  const _EventDetailScroll({
    required this.event,
    required this.isSaved,
    required this.onSaveToggle,
  });

  final Event event;
  final bool isSaved;
  final VoidCallback onSaveToggle;

  @override
  State<_EventDetailScroll> createState() => _EventDetailScrollState();
}

class _EventDetailScrollState extends State<_EventDetailScroll> {
  final _scroll = ScrollController();
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final next = _scroll.hasClients && _scroll.offset > 2;
      if (next == _scrolled) return;
      setState(() => _scrolled = next);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  static String _formatCountdown(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.event;
    final start = e.displayStart;
    final end = e.displayEnd;
    final now = DateTime.now().toUtc();
    final countdown = e.startUtc.difference(now);
    final pad = Responsive.horizontalPadding(context);

    final appBarBg =
        _scrolled ? Theme.of(context).colorScheme.surface : Colors.transparent;
    final appBarFg = _scrolled ? AppColors.primaryDark : Colors.white;

    return Stack(
      children: [
        // Home-like soft gradient background
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.06),
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor,
                ],
                stops: const [0.0, 0.22, 1.0],
              ),
            ),
          ),
        ),
        CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: appBarBg,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              iconTheme: IconThemeData(color: appBarFg),
              actionsIconTheme: IconThemeData(color: appBarFg),
              toolbarHeight: Responsive.value(
                  context, Responsive.isCompact(context) ? 60 : 64),
              expandedHeight: Responsive.detailAppBarExpandedHeight(context),
              leading: IconButton(
                icon: Container(
                  padding: EdgeInsets.all(Responsive.value(context, 8)),
                  decoration: BoxDecoration(
                    color: _scrolled
                        ? AppColors.primary.withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.18),
                    borderRadius:
                        BorderRadius.circular(Responsive.value(context, 12)),
                    border: Border.all(
                        color: Colors.white
                            .withValues(alpha: _scrolled ? 0.0 : 0.10)),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: Responsive.iconSize(context, 18),
                    color: appBarFg,
                  ),
                ),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(Responsive.value(context, 8)),
                    decoration: BoxDecoration(
                      color: _scrolled
                          ? AppColors.primary.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.18),
                      borderRadius:
                          BorderRadius.circular(Responsive.value(context, 12)),
                      border: Border.all(
                          color: Colors.white
                              .withValues(alpha: _scrolled ? 0.0 : 0.10)),
                    ),
                    child: Icon(
                      widget.isSaved
                          ? Icons.bookmark
                          : Icons.bookmark_border_outlined,
                      size: Responsive.iconSize(context, 18),
                      color: appBarFg,
                    ),
                  ),
                  onPressed: widget.onSaveToggle,
                ),
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(Responsive.value(context, 8)),
                    decoration: BoxDecoration(
                      color: _scrolled
                          ? AppColors.primary.withValues(alpha: 0.10)
                          : Colors.white.withValues(alpha: 0.18),
                      borderRadius:
                          BorderRadius.circular(Responsive.value(context, 12)),
                      border: Border.all(
                          color: Colors.white
                              .withValues(alpha: _scrolled ? 0.0 : 0.10)),
                    ),
                    child: Icon(
                      Icons.share_outlined,
                      size: Responsive.iconSize(context, 18),
                      color: appBarFg,
                    ),
                  ),
                  onPressed: () {},
                ),
                SizedBox(width: Responsive.spacing(context, 6)),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 1,
                  color: _scrolled
                      ? Colors.black.withValues(alpha: 0.06)
                      : Colors.transparent,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (e.imageUrl != null && e.imageUrl!.isNotEmpty)
                      CachedNetworkImage(
                          imageUrl: e.imageUrl!, fit: BoxFit.cover)
                    else
                      Container(
                        decoration:
                            BoxDecoration(gradient: AppColors.primaryGradient),
                        child: Center(
                          child: FaIcon(
                            FontAwesomeIcons.calendarDays,
                            size: Responsive.iconSize(context, 80),
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    // Fade for readability
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                    // Bottom info panel (home-card style)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                            pad, 0, pad, Responsive.spacing(context, 14)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.value(context, 14),
                            vertical: Responsive.value(context, 12),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(
                                Responsive.value(context, 16)),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      height: 1.08,
                                    ),
                              ),
                              SizedBox(height: Responsive.spacing(context, 8)),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        FaIcon(FontAwesomeIcons.clock,
                                            size: Responsive.iconSize(
                                                context, 14),
                                            color: Colors.white70),
                                        SizedBox(
                                            width:
                                                Responsive.spacing(context, 6)),
                                        Expanded(
                                          child: Text(
                                            '${DateFormat.MMMd().format(start)} • ${DateFormat.jm().format(start)}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: Colors.white70,
                                                    height: 1.1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width: Responsive.spacing(context, 12)),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        FaIcon(
                                            e.isVirtual
                                                ? FontAwesomeIcons.video
                                                : FontAwesomeIcons.locationDot,
                                            size: Responsive.iconSize(
                                                context, 14),
                                            color: Colors.white70),
                                        SizedBox(
                                            width:
                                                Responsive.spacing(context, 6)),
                                        Flexible(
                                          child: Text(
                                            e.isVirtual
                                                ? 'Virtual'
                                                : (e.city ??
                                                    e.countryCode ??
                                                    'TBD'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.right,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: Colors.white70,
                                                    height: 1.1),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Responsive.spacing(context, 10)),
                              Row(
                                children: [
                                  FaIcon(FontAwesomeIcons.userGroup,
                                      size: Responsive.iconSize(context, 14),
                                      color: Colors.white70),
                                  SizedBox(
                                      width: Responsive.spacing(context, 6)),
                                  Text(
                                    '${e.rsvpCount} going',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Colors.white
                                                .withValues(alpha: 0.92),
                                            height: 1.0),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal:
                                            Responsive.value(context, 10),
                                        vertical: Responsive.value(context, 6)),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(
                                          Responsive.value(context, 12)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FaIcon(FontAwesomeIcons.stopwatch,
                                            size: Responsive.iconSize(
                                                context, 14),
                                            color: Colors.white),
                                        SizedBox(
                                            width:
                                                Responsive.spacing(context, 6)),
                                        Text(
                                          countdown.isNegative
                                              ? 'Started'
                                              : 'Starts in ${_EventDetailScrollState._formatCountdown(countdown)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: Colors.white,
                                                  height: 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: SizedBox(height: Responsive.spacing(context, 16))),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: _InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RowIconText(
                        icon: FontAwesomeIcons.calendarDays,
                        title:
                            '${DateFormat.yMMMd().format(start)} • ${DateFormat.jm().format(start)} – ${DateFormat.jm().format(end)}',
                        subtitle:
                            e.timezone.isNotEmpty ? '(${e.timezone})' : null,
                      ),
                      SizedBox(height: Responsive.spacing(context, 10)),
                      _RowIconText(
                        icon: e.isVirtual
                            ? FontAwesomeIcons.video
                            : FontAwesomeIcons.locationDot,
                        title: e.isVirtual
                            ? 'Virtual'
                            : (e.address ??
                                '${e.city ?? ''} ${e.countryCode ?? ''}'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (e.description != null && e.description!.isNotEmpty) ...[
              SliverToBoxAdapter(
                  child: SizedBox(height: Responsive.spacing(context, 14))),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: _InfoCard(
                    title: 'About',
                    child: Text(
                      e.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
                child: SizedBox(height: Responsive.spacing(context, 14))),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: pad),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: Responsive.buttonMinHeight(context),
                        child: FilledButton.icon(
                          onPressed: () => context.push('/event/${e.id}/chat'),
                          icon: FaIcon(
                            FontAwesomeIcons.comments,
                            size: Responsive.iconSize(context, 18),
                            color: Colors.white,
                          ),
                          label: const Text('Live chat'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            minimumSize:
                                Size(0, Responsive.buttonMinHeight(context)),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.value(context, 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, 12)),
                    SizedBox(
                      height: Responsive.buttonMinHeight(context),
                      width: Responsive.buttonMinHeight(context),
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          minimumSize:
                              Size(0, Responsive.buttonMinHeight(context)),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.check,
                          size: Responsive.iconSize(context, 16),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: SizedBox(height: Responsive.spacing(context, 18))),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    pad, 0, pad, Responsive.spacing(context, 40)),
                child: _InfoCard(
                  title: 'Related',
                  child: Text(
                    'Related events coming soon',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final r = Responsive.value(context, 16);
    return Container(
      padding: EdgeInsets.all(Responsive.value(context, 14)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
            ),
            SizedBox(height: Responsive.spacing(context, 10)),
          ],
          child,
        ],
      ),
    );
  }
}

class _RowIconText extends StatelessWidget {
  const _RowIconText({required this.icon, required this.title, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: Responsive.value(context, 34),
          width: Responsive.value(context, 34),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(Responsive.value(context, 10)),
            border:
                Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          child: Center(
            child: FaIcon(icon,
                size: Responsive.iconSize(context, 16),
                color: AppColors.primaryDark),
          ),
        ),
        SizedBox(width: Responsive.spacing(context, 10)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              if (subtitle != null) ...[
                SizedBox(height: Responsive.spacing(context, 2)),
                Text(subtitle!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
