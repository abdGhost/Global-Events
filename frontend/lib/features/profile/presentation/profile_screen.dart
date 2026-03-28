import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/current_user_provider.dart';
import '../../../providers/my_events_providers.dart';
import '../../../providers/saved_events_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Display name from email (part before @) or fallback.
  static String displayNameFromEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 0) return 'User';
    final name = email.substring(0, at).trim();
    return name.isEmpty ? 'User' : name;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(currentUserProvider, (prev, next) {
      next.whenData(
        (u) => ref.read(savedEventsProvider.notifier).setUserEmail(u.email),
      );
    });

    final pad = Responsive.horizontalPadding(context);
    final isCompact = Responsive.isCompact(context);
    const darkBg = Color(0xFF121214);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(color: darkBg),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    pad,
                    Responsive.spacing(context, 10),
                    pad,
                    Responsive.spacing(context, 10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize:
                                  Responsive.fontSize(context, isCompact ? 20 : 22),
                              color: Colors.white,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        iconSize: Responsive.iconSize(context, 18),
                        icon: const FaIcon(
                          FontAwesomeIcons.plus,
                          color: Colors.white,
                        ),
                        onPressed: () => context.push('/create-event'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: userAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.white54,
                            ),
                            SizedBox(height: Responsive.spacing(context, 12)),
                            Text(
                              'Could not load profile',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                            SizedBox(height: Responsive.spacing(context, 16)),
                            FilledButton.icon(
                              onPressed: () =>
                                  ref.invalidate(currentUserProvider),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (user) {
                      final createdAsync = ref.watch(myCreatedEventsProvider);
                      final rsvpedAsync = ref.watch(myRsvpedEventsProvider);
                      final createdCount = createdAsync.maybeWhen(
                        data: (l) => l.length.toString(),
                        orElse: () => '…',
                      );
                      final rsvpedCount = rsvpedAsync.maybeWhen(
                        data: (l) => l.length.toString(),
                        orElse: () => '…',
                      );
                      return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        pad,
                        0,
                        pad,
                        Responsive.spacing(context, 24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: Responsive.value(context, 40),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.18),
                            child: FaIcon(
                              FontAwesomeIcons.user,
                              size: Responsive.iconSize(context, 32),
                              color: AppColors.primaryDark,
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 14)),
                          Text(
                            displayNameFromEmail(user.email),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: Responsive.fontSize(
                                      context, isCompact ? 18 : 20),
                                  color: Colors.white,
                                ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 4)),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: Responsive.fontSize(
                                      context, isCompact ? 12 : 13),
                                ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 20)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StatChip(label: 'Created', value: createdCount),
                              SizedBox(width: Responsive.spacing(context, 24)),
                              _StatChip(label: 'RSVPed', value: rsvpedCount),
                            ],
                          ),
                          SizedBox(height: Responsive.spacing(context, 24)),
                          Container(
                            padding: EdgeInsets.all(Responsive.spacing(context, 12)),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(
                                  Responsive.value(context, 16)),
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.04),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _ProfileChip(
                                  icon: FontAwesomeIcons.calendarDays,
                                  label: 'Created',
                                  onTap: () => context.push('/profile/created'),
                                ),
                                SizedBox(width: Responsive.spacing(context, 8)),
                                _ProfileChip(
                                  icon: FontAwesomeIcons.ticket,
                                  label: 'RSVPed',
                                  onTap: () => context.push('/profile/rsvped'),
                                ),
                                SizedBox(width: Responsive.spacing(context, 8)),
                                _ProfileChip(
                                  icon: FontAwesomeIcons.bookmark,
                                  label: 'Saved',
                                  onTap: () => context.push('/profile/saved'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 20)),
                          Text(
                            'Your events and RSVPs will appear here',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 24)),
                          _SettingsList(
                            onLogout: () => _logout(context, ref),
                            onSettingsTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Coming soon')),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _logout(BuildContext context, WidgetRef ref) async {
    ref.read(savedEventsProvider.notifier).onLogout();
    ref.read(authTokenProvider.notifier).state = null;
    ref.invalidate(currentUserProvider);
    ref.invalidate(myCreatedEventsProvider);
    ref.invalidate(myRsvpedEventsProvider);
    await AppStorage.saveToken(null);
    if (context.mounted) context.go('/login');
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({
    required this.onLogout,
    required this.onSettingsTap,
  });

  final VoidCallback onLogout;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius:
            BorderRadius.circular(Responsive.value(context, 16)),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.palette,
              color: AppColors.primary,
              size: Responsive.iconSize(context, 16),
            ),
            title: Text(
              'Theme',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: Colors.white70,
            ),
            onTap: onSettingsTap,
          ),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.bell,
              color: AppColors.primary,
              size: Responsive.iconSize(context, 16),
            ),
            title: Text(
              'Notifications',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: Colors.white70,
            ),
            onTap: onSettingsTap,
          ),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.clock,
              color: AppColors.primary,
              size: Responsive.iconSize(context, 16),
            ),
            title: Text(
              'Timezone',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
            ),
            trailing: const FaIcon(
              FontAwesomeIcons.chevronRight,
              size: 16,
              color: Colors.white70,
            ),
            onTap: onSettingsTap,
          ),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),
          ListTile(
            leading: FaIcon(
              FontAwesomeIcons.rightFromBracket,
              color: Colors.red.shade500,
              size: Responsive.iconSize(context, 16),
            ),
            title: Text(
              'Log out',
              style: TextStyle(color: Colors.red.shade500),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: AppColors.primary)),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey)),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    final radius = Responsive.value(context, compact ? 18 : 20);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.value(context, compact ? 12 : 16),
            vertical: Responsive.value(context, compact ? 6 : 8),
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                size: Responsive.iconSize(context, compact ? 12 : 14),
                color: AppColors.primary,
              ),
              SizedBox(width: Responsive.spacing(context, 6)),
              Text(
                label,
                style: TextStyle(
                  fontSize:
                      Responsive.fontSize(context, compact ? 12 : 13),
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
