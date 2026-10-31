import '../screens/account/profile_edit_screen.dart';
import '../screens/account/cloud_tools_screen.dart';
import '../screens/account/export_screen.dart';
import 'cloud_providers.dart';
import '../screens/events/scanner_screen.dart';
import '../screens/auth/auth_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/account/account_tab_screen.dart';
import '../screens/dev/component_preview_screen.dart';
import '../screens/events/event_list_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/events/registration_form_screen.dart';
import '../screens/events/registration_detail_screen.dart';
import '../screens/events/live_schedule_screen.dart';
import '../screens/notifications/notifications_tab_screen.dart';

import '../screens/shell/main_shell_screen.dart';
import '../widgets/app_loading_state.dart';
import 'providers.dart';
import 'development.dart';
import 'auth_redirect.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// App Router configured according to docs/design-traceability.md
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionViewModelProvider, (_, _) => refresh.value++);
  final development = ref.watch(developmentUiProvider);
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/discover',
    debugLogDiagnostics: development,
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(
      ref.read(sessionViewModelProvider),
      state.uri,
      development,
    ),
    routes: [
      GoRoute(
        path: '/session',
        builder: (context, state) =>
            const Scaffold(body: Center(child: AppLoadingState())),
      ),
      // 4 Main Shell Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Discover (A02)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const EventListScreen(),
              ),
            ],
          ),
          // Branch 1: Schedule (A07)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                builder: (context, state) => const LiveScheduleScreen(),
              ),
            ],
          ),
          // Branch 2: Notifications (A09)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsTabScreen(),
              ),
            ],
          ),
          // Branch 3: Account (A10)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountTabScreen(),
              ),
            ],
          ),
        ],
      ),

      // Auth Flow routes (A01a - A01d)
      GoRoute(
        path: '/auth/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(mode: 'login'),
      ),
      GoRoute(
        path: '/auth/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(mode: 'register'),
      ),
      GoRoute(
        path: '/auth/verify-email',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(mode: 'verify'),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(mode: 'reset'),
      ),

      GoRoute(
        path: '/auth/change-email',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(mode: 'change-email'),
      ),
      // F1 Flow routes: Search, Detail, Register, Success
      GoRoute(
        path: '/discover/search',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => EventListScreen(
          search: true,
          initialQuery: state.uri.queryParameters['q'] ?? '',
        ),
      ),
      GoRoute(
        path: '/events/:eventId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? 'unknown';
          return EventDetailScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/events/:eventId/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? 'unknown';
          return RegistrationFormScreen(eventId: eventId);
        },
      ),
      GoRoute(
        path: '/registrations/:registrationId/success',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final regId = state.pathParameters['registrationId'] ?? 'unknown';
          return RegistrationDetailScreen(id: regId, success: true);
        },
      ),

      // F2 Flow routes: Registration Detail
      GoRoute(
        path: '/registrations/:registrationId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final regId = state.pathParameters['registrationId'] ?? 'unknown';
          return RegistrationDetailScreen(id: regId);
        },
      ),

      // Account sub-routes
      GoRoute(
        path: '/account/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileEditScreen(),
      ),

      // F4A Flow routes: Scanner & Result
      GoRoute(
        path: '/registrations/:registrationId/scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final regId = state.pathParameters['registrationId'] ?? 'unknown';
          return ScannerScreen(registrationId: regId);
        },
      ),
      GoRoute(
        path: '/registrations/:registrationId/check-in',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final regId = state.pathParameters['registrationId'] ?? 'unknown';
          return RegistrationDetailScreen(id: regId, checkInResult: true);
        },
      ),

      // Lab 3 Additional Screens
      GoRoute(
        path: '/account/firebase-demo',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CloudToolsScreen(),
      ),
      GoRoute(
        path: '/account/export',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ExportScreen(),
      ),

      // Development Component Preview Screen
      if (development)
        GoRoute(
          path: '/dev/components',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ComponentPreviewScreen(),
        ),
    ],
  );
  void trackRoute() {
    final path = router.routeInformationProvider.value.uri.path;
    final code = path.endsWith('/register')
        ? 'A05'
        : path.endsWith('/success')
        ? 'A06'
        : path.endsWith('/check-in')
        ? 'A12'
        : path.startsWith('/registrations/')
        ? 'A08'
        : path.startsWith('/events/')
        ? 'A04'
        : path == '/discover'
        ? 'A02'
        : path == '/discover/search'
        ? 'A03'
        : path == '/schedule'
        ? 'A07'
        : path == '/notifications'
        ? 'A09'
        : path.startsWith('/account')
        ? 'A10'
        : 'A01';
    track(ref, 'view_screen', {'screen_code': code});
    if (code == 'A04') track(ref, 'view_event_detail', {'screen_code': code});
    if (code == 'A08') {
      track(ref, 'view_registration_detail', {'screen_code': code});
    }
    if (code == 'A12') track(ref, 'view_checkin_result', {'screen_code': code});
  }

  router.routeInformationProvider.addListener(trackRoute);
  ref.onDispose(() {
    router.routeInformationProvider.removeListener(trackRoute);
    router.dispose();
    refresh.dispose();
  });
  return router;
});
