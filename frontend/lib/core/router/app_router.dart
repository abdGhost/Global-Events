import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../core/theme/app_colors.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/chat/presentation/chat_inbox_screen.dart';
import '../../features/chat/presentation/event_chat_screen.dart';
import '../../features/create_event/presentation/create_event_screen.dart';
import '../../features/event_detail/presentation/event_detail_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/map/presentation/location_picker_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/presentation/profile_events_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/splash/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => _MainShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (_, __) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (_, __) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (_, __) => const ChatInboxScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/event/:id',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/event/:id/chat',
        builder: (_, state) {
          final id = state.pathParameters['id']!;
          return EventChatScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/profile/created',
        builder: (_, __) => const ProfileEventsScreen(type: ProfileEventsType.created),
      ),
      GoRoute(
        path: '/profile/rsvped',
        builder: (_, __) => const ProfileEventsScreen(type: ProfileEventsType.rsvped),
      ),
      GoRoute(
        path: '/profile/saved',
        builder: (_, __) => const ProfileEventsScreen(type: ProfileEventsType.saved),
      ),
      GoRoute(
        path: '/create-event',
        builder: (_, __) => const CreateEventScreen(),
      ),
      GoRoute(
        path: '/pick-location',
        builder: (_, __) => const LocationPickerScreen(),
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  const _MainShell({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: GNav(
                  selectedIndex: shell.currentIndex,
                  onTabChange: shell.goBranch,
                  gap: 8,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  tabBorderRadius: 14,
                  haptic: true,
                  tabBackgroundColor: AppColors.primary.withValues(alpha: 0.14),
                  activeColor: AppColors.primary,
                  color: Colors.grey,
                  tabs: const [
                    GButton(icon: FontAwesomeIcons.house, text: 'Home'),
                    GButton(icon: FontAwesomeIcons.magnifyingGlass, text: 'Search'),
                    GButton(icon: FontAwesomeIcons.mapLocationDot, text: 'Map'),
                    GButton(icon: FontAwesomeIcons.comments, text: 'Chat'),
                    GButton(icon: FontAwesomeIcons.user, text: 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}