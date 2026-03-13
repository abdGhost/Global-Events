import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/dummy_events.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';

enum _ChatFilter { all, unread }

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  _ChatFilter _filter = _ChatFilter.all;

  List<_ChatItem> _buildItems() {
    final base = dummyEventsFull
        .map(
          (e) => _ChatItem(
            eventId: e.id,
            title: e.title,
            subtitle: 'Tap to join the live chat',
            unread: e.rsvpCount > 0 ? (e.rsvpCount % 5) : 0,
            timeLabel: 'Today',
          ),
        )
        .toList();

    if (_filter == _ChatFilter.unread) {
      return base.where((e) => e.unread > 0).toList();
    }
    return base;
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.spacing(context, 20),
              vertical: Responsive.spacing(context, 14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter chats',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: Responsive.spacing(context, 12)),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('All chats'),
                  trailing: _filter == _ChatFilter.all
                      ? const Icon(Icons.check_rounded, size: 18)
                      : null,
                  onTap: () {
                    setState(() => _filter = _ChatFilter.all);
                    Navigator.of(ctx).pop();
                  },
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Unread only'),
                  trailing: _filter == _ChatFilter.unread
                      ? const Icon(Icons.check_rounded, size: 18)
                      : null,
                  onTap: () {
                    setState(() => _filter = _ChatFilter.unread);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);
    final items = _buildItems();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    pad,
                    Responsive.spacing(context, 10),
                    pad,
                    Responsive.spacing(context, 10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Chats',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize:
                                  Responsive.fontSize(context, 20), // smaller
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: Responsive.iconSize(context, 18),
                        icon: FaIcon(
                          FontAwesomeIcons.sliders,
                          color: AppColors.primaryDark,
                        ),
                        onPressed: () => _showFilterSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    pad,
                    0,
                    pad,
                    Responsive.spacing(context, 20),
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => Padding(
                    padding: EdgeInsets.only(
                      bottom: Responsive.spacing(context, 10),
                    ),
                    child: _ChatInboxTile(item: items[i]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatItem {
  final String eventId;
  final String title;
  final String subtitle;
  final String timeLabel;
  final int unread;

  const _ChatItem({
    required this.eventId,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.unread,
  });
}

class _ChatInboxTile extends StatelessWidget {
  const _ChatInboxTile({required this.item});

  final _ChatItem item;

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isCompact(context);
    final radius = Responsive.value(context, 16);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () => context.push('/event/${item.eventId}/chat'),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
          ),
          child: Padding(
            padding: EdgeInsets.all(Responsive.value(context, 12)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: Responsive.value(context, 18),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                  child: Text(
                    item.title.isNotEmpty ? item.title[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, 10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: Responsive.spacing(context, 4)),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: Responsive.fontSize(
                                  context, isCompact ? 11 : 12),
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: Responsive.spacing(context, 8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.timeLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade500,
                            fontSize: Responsive.fontSize(
                                context, isCompact ? 11 : 12),
                          ),
                    ),
                    if (item.unread > 0) ...[
                      SizedBox(height: Responsive.spacing(context, 6)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.value(context, 8),
                          vertical: Responsive.value(context, 4),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius:
                              BorderRadius.circular(Responsive.value(context, 999)),
                        ),
                        child: Text(
                          '${item.unread}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: Responsive.fontSize(
                                        context, isCompact ? 11 : 12),
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

