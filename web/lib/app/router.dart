import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/dashboard/club_dashboard_screen.dart';
import '../screens/events/club_events_screen.dart';
import '../screens/events/live_qr_panel_screen.dart';
import '../screens/reviews/review_queue_screen.dart';
import '../screens/announcements/club_announcements_screen.dart';
import '../viewmodels/web_auth_viewmodel.dart';

final webRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(webAuthViewModelProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.uri.path == '/login';

      if (authState is WebAuthSuccess) {
        if (isLoggingIn) return '/dashboard';
        return null;
      }

      if (authState is WebAuthRejected) {
        return '/login';
      }

      if (authState is! WebAuthSuccess && !isLoggingIn) {
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
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const ClubDashboardScreen(),
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
});
