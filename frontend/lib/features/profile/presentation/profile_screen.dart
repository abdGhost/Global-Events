import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/responsive.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = Responsive.horizontalPadding(context);
    final isCompact = Responsive.isCompact(context);
    const darkBg = Color(0xFF121214);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: darkBg,
              ),
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
                      IconButton(
                        iconSize: Responsive.iconSize(context, 18),
                        icon: const FaIcon(
                          FontAwesomeIcons.gear,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
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
                          'User Name',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    Responsive.fontSize(context, isCompact ? 18 : 20),
                                color: Colors.white,
                              ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 4)),
                        Text(
                          '@username',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.7),
                                fontSize:
                                    Responsive.fontSize(context, isCompact ? 12 : 13),
                              ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 8)),
                        Text(
                          'Short bio here.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                        ),
                        SizedBox(height: Responsive.spacing(context, 20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _StatChip(label: 'Followers', value: '128'),
                            SizedBox(width: Responsive.spacing(context, 24)),
                            _StatChip(label: 'Following', value: '64'),
                          ],
                        ),
                        SizedBox(height: Responsive.spacing(context, 24)),
                        Container(
                          padding: EdgeInsets.all(Responsive.spacing(context, 12)),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                            borderRadius:
                                BorderRadius.circular(Responsive.value(context, 16)),
                            border: Border.all(
                              color: Colors.black.withValues(alpha: 0.04),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _ProfileChip(
                                  icon: FontAwesomeIcons.calendarDays,
                                  label: 'Created'),
                              SizedBox(width: Responsive.spacing(context, 8)),
                              _ProfileChip(
                                  icon: FontAwesomeIcons.ticket, label: 'RSVPed'),
                              SizedBox(width: Responsive.spacing(context, 8)),
                              _ProfileChip(
                                  icon: FontAwesomeIcons.bookmark, label: 'Saved'),
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
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.03),
                            borderRadius:
                                BorderRadius.circular(Responsive.value(context, 16)),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                            ),
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
                                onTap: () {},
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
                                onTap: () {},
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
                                onTap: () {},
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
                                onTap: () => context.go('/login'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    final radius = Responsive.value(context, compact ? 18 : 20);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: () {},
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
