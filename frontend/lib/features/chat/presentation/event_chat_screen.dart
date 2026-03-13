import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../../../core/api/endpoints.dart';
import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/api_client_provider.dart';
import '../../../providers/chat_messages_provider.dart';
import '../../../providers/current_user_provider.dart';
import '../../../providers/event_detail_provider.dart';

class EventChatScreen extends ConsumerStatefulWidget {
  const EventChatScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventChatScreen> createState() => _EventChatScreenState();
}

class _EventChatScreenState extends ConsumerState<EventChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final next = _scrollController.hasClients && _scrollController.offset > 2;
      if (next == _isScrolled) return;
      setState(() => _isScrolled = next);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    () async {
      try {
        final client = ref.read(apiClientProvider);
        await client.post<Map<String, dynamic>>(
          Endpoints.eventChatMessages(widget.eventId),
          data: <String, dynamic>{'content': text},
        );
        _controller.clear();
        ref.invalidate(chatMessagesProvider(widget.eventId));
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
          ),
        );
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);
    const darkSurface = Color(0xFF121214);
    final title = ref.watch(eventDetailProvider(widget.eventId)).maybeWhen(
          data: (e) => e.title,
          orElse: () => 'Event chat',
        );
    final messagesAsync = ref.watch(chatMessagesProvider(widget.eventId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final peopleLabel = messagesAsync.maybeWhen(
      data: (history) {
        final participantIds = history.map((m) => m.userId).toSet();
        final count = participantIds.length;
        if (count == 0) return 'No messages yet';
        if (count == 1) return '1 person has chatted';
        return '$count people have chatted';
      },
      orElse: () => 'Live chat',
    );

    return Scaffold(
      body: Stack(
        children: [
          // Home-like soft gradient background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.fromLTRB(
                      pad,
                      Responsive.spacing(context, 10),
                      pad,
                      Responsive.spacing(context, 10)),
                  decoration: BoxDecoration(
                    color: _isScrolled ? darkSurface : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: _isScrolled
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _AppBarIcon(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => context.pop(),
                        filled: !_isScrolled,
                      ),
                      SizedBox(width: Responsive.spacing(context, 10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 2)),
                            Text(
                              peopleLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      _AppBarIcon(
                        icon: Icons.more_horiz_rounded,
                        onTap: () {},
                        filled: !_isScrolled,
                      ),
                    ],
                  ),
                ),
              ),
              // Typing indicator
              Padding(
                padding: EdgeInsets.fromLTRB(
                    pad,
                    Responsive.spacing(context, 8),
                    pad,
                    Responsive.spacing(context, 6)),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.value(context, 12),
                        vertical: Responsive.value(context, 7)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius:
                          BorderRadius.circular(Responsive.value(context, 16)),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: Responsive.value(context, 8),
                          height: Responsive.value(context, 8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: Responsive.spacing(context, 8)),
                        Text(
                          peopleLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: messagesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.horizontalPadding(context),
                      ),
                      child: Text(
                        'Could not load chat messages.\n$e',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                    ),
                  ),
                  data: (history) {
                    final meId = currentUserAsync.maybeWhen(
                      data: (u) => u.id,
                      orElse: () => null,
                    );
                    final all = history;
                    if (all.isEmpty) {
                      return Center(
                        child: Text(
                          'No messages yet.\nBe the first to say hi!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: EdgeInsets.fromLTRB(
                        pad,
                        Responsive.spacing(context, 6),
                        pad,
                        Responsive.spacing(context, 12),
                      ),
                      itemCount: all.length,
                      itemBuilder: (_, i) {
                        final m = all[all.length - 1 - i];
                        final isMe = meId != null && m.userId == meId;
                        return _ChatBubbleView(
                          bubble: _ChatBubble(
                            isMe: isMe,
                            name: isMe ? 'You' : 'Guest',
                            text: m.content,
                            time: '',
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              if (_showEmojiPicker)
                SizedBox(
                  height: Responsive.value(context, 260),
                  child: EmojiPicker(
                    textEditingController: _controller,
                    onEmojiSelected: (_, __) {},
                    onBackspacePressed: () {
                      setState(() => _showEmojiPicker = false);
                    },
                    config: Config(
                      height: Responsive.value(context, 260),
                      emojiViewConfig: EmojiViewConfig(
                        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      categoryViewConfig: CategoryViewConfig(
                        iconColor: Colors.grey.shade500,
                        iconColorSelected: AppColors.primaryDark,
                        indicatorColor: AppColors.primary,
                      ),
                      bottomActionBarConfig: const BottomActionBarConfig(
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              _Composer(
                controller: _controller,
                onSend: _handleSend,
                onEmojiTap: () {
                  setState(() => _showEmojiPicker = !_showEmojiPicker);
                  FocusScope.of(context).unfocus();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppBarIcon extends StatelessWidget {
  const _AppBarIcon({
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final s = Responsive.value(context, 40);
    return SizedBox(
      height: s,
      width: s,
      child: Material(
        color:
            filled ? Colors.white.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(Responsive.value(context, 12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(Responsive.value(context, 12)),
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              size: Responsive.iconSize(context, 18),
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBubble {
  final bool isMe;
  final String name;
  final String text;
  final String time;
  _ChatBubble(
      {required this.isMe,
      required this.name,
      required this.text,
      required this.time});
}

class _ChatBubbleView extends StatelessWidget {
  const _ChatBubbleView({required this.bubble});

  final _ChatBubble bubble;

  @override
  Widget build(BuildContext context) {
    final isCompact = Responsive.isCompact(context);
    final r = Responsive.value(context, 18);
    final metaSize = Responsive.fontSize(context, isCompact ? 10 : 11);
    final msgSize = Responsive.fontSize(context, isCompact ? 13 : 14);

    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(context, 10)),
      child: Row(
        mainAxisAlignment:
            bubble.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!bubble.isMe)
            CircleAvatar(
              radius: Responsive.value(context, 14),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              child: Text(
                bubble.name[0].toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          if (!bubble.isMe) SizedBox(width: Responsive.spacing(context, 8)),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: Responsive.value(context, 14),
                  vertical: Responsive.value(context, 10)),
              decoration: BoxDecoration(
                color: bubble.isMe
                    ? AppColors.primaryDark
                    : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(r),
                  topRight: Radius.circular(r),
                  bottomLeft: Radius.circular(
                      bubble.isMe ? r : Responsive.value(context, 6)),
                  bottomRight: Radius.circular(
                      bubble.isMe ? Responsive.value(context, 6) : r),
                ),
                border: bubble.isMe
                    ? null
                    : Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!bubble.isMe)
                    Text(
                      bubble.name,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70, fontWeight: FontWeight.w700),
                    ),
                  if (!bubble.isMe)
                    SizedBox(height: Responsive.spacing(context, 2)),
                  Text(
                    bubble.text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: bubble.isMe ? Colors.white : Colors.white,
                          fontSize: msgSize,
                          height: 1.25,
                        ),
                  ),
                  SizedBox(height: Responsive.spacing(context, 4)),
                  Text(
                    bubble.time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: bubble.isMe ? Colors.white70 : Colors.white54,
                          fontSize: metaSize,
                        ),
                  ),
                ],
              ),
            ),
          ),
          if (bubble.isMe) SizedBox(width: Responsive.spacing(context, 8)),
          if (bubble.isMe)
            CircleAvatar(
              radius: Responsive.value(context, 14),
              backgroundColor: AppColors.primary.withValues(alpha: 0.3),
              child: FaIcon(FontAwesomeIcons.user,
                  size: Responsive.iconSize(context, 14), color: Colors.white),
            ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.onEmojiTap,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onEmojiTap;

  @override
  Widget build(BuildContext context) {
    final pad = Responsive.horizontalPadding(context);
    final compact = Responsive.isCompact(context);
    final h = Responsive.buttonMinHeight(context);
    final chipBg = AppColors.primary.withValues(alpha: 0.10);
    final chipBorder = AppColors.primary.withValues(alpha: 0.25);
    final chipText = AppColors.primaryDark;

    return Container(
      padding: EdgeInsets.fromLTRB(pad, Responsive.spacing(context, 10), pad,
          Responsive.spacing(context, 10)),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: h,
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.value(context, 12)),
                decoration: BoxDecoration(
                  // Match Home search / chips.
                  color: chipBg,
                  borderRadius:
                      BorderRadius.circular(Responsive.value(context, 16)),
                  border: Border.all(color: chipBorder),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: onEmojiTap,
                      child: FaIcon(
                        FontAwesomeIcons.faceSmile,
                        size: Responsive.iconSize(context, 18),
                        color: chipText,
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, 8)),
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          focusColor: Colors.transparent,
                        ),
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Message',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            isDense: true,
                            filled: true,
                            fillColor: Colors.transparent,
                            hintStyle: TextStyle(
                              color: chipText.withValues(alpha: 0.7),
                              fontSize: Responsive.fontSize(
                                  context, compact ? 14 : 15),
                            ),
                          ),
                          style: TextStyle(
                            fontSize:
                                Responsive.fontSize(context, compact ? 14 : 15),
                            color: chipText,
                          ),
                          maxLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => onSend(),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(context, 8)),
                    GestureDetector(
                      onTap: () {},
                      child: FaIcon(
                        FontAwesomeIcons.paperclip,
                        size: Responsive.iconSize(context, 18),
                        color: chipText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: Responsive.spacing(context, 8)),
            SizedBox(
              height: h,
              width: h,
              child: FilledButton(
                onPressed: onSend,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Responsive.value(context, 16))),
                ),
                child: FaIcon(FontAwesomeIcons.paperPlane,
                    size: Responsive.iconSize(context, 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
