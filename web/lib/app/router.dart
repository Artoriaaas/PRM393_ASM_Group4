import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/dashboard/club_dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/crash_reports_screen.dart';
import '../screens/users/admin_users_screen.dart';
import '../screens/clubs/admin_clubs_screen.dart';
import '../screens/events/club_events_screen.dart';
import '../screens/events/live_qr_panel_screen.dart';
import '../screens/reviews/review_queue_screen.dart';
import '../screens/announcements/club_announcements_screen.dart';
import '../viewmodels/web_auth_viewmodel.dart';

class _RouterRefreshListenable extends ChangeNotifier {
  void notify() => notifyListeners();
}

final webRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshListenable();
  ref.onDispose(refreshNotifier.dispose);

  ref.listen<WebAuthUIState>(webAuthViewModelProvider, (_, next) {
    refreshNotifier.notify();
  });

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(webAuthViewModelProvider);
      final isLoggingIn = state.uri.path == '/login';

      if (authState is WebAuthSuccess) {
        if (isLoggingIn) {
          return authState.user.isAdmin ? '/admin-dashboard' : '/dashboard';
        }
        return null;
      }

      if (!isLoggingIn) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const SignInScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentLocation: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(path: '/crash-reports', builder: (context, state) => const CrashReportsScreen()),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const ClubDashboardScreen(),
          ),
          GoRoute(
            path: '/admin-dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
          GoRoute(
            path: '/clubs',
            builder: (context, state) => const AdminClubsScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const ClubEventsScreen(),
            routes: [
              GoRoute(
                path: ':id/checkin',
                builder: (context, state) => LiveQrPanelScreen(
                  eventId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/reviews',
            builder: (context, state) => const ReviewQueueScreen(),
          ),
          GoRoute(
            path: '/announcements',
            builder: (context, state) => const ClubAnnouncementsScreen(),
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
