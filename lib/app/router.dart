import '../screens/auth/auth_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/account/account_tab_screen.dart';
import '../screens/dev/component_preview_screen.dart';
import '../screens/discover/discover_tab_screen.dart';
import '../screens/notifications/notifications_tab_screen.dart';
import '../screens/placeholder_screen.dart';
import '../screens/schedule/schedule_tab_screen.dart';
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
                builder: (context, state) => const DiscoverTabScreen(),
              ),
            ],
          ),
          // Branch 1: Schedule (A07)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/schedule',
                builder: (context, state) => const ScheduleTabScreen(),
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
        builder: (context, state) => const PlaceholderScreen(
          screenCode: 'A03',
          title: 'Kết quả tìm kiếm & Bộ lọc',
          routePath: '/discover/search',
          figmaNode: '179:599',
          expectedViewModel: 'SearchViewModel',
          expectedService: 'EventService',
        ),
      ),
      GoRoute(
        path: '/events/:eventId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? 'unknown';
          return PlaceholderScreen(
            screenCode: 'A04',
            title: 'Chi tiết sự kiện ($eventId)',
            routePath: '/events/$eventId',
            figmaNode: '164:336 / 214:1681',
            expectedViewModel: 'EventDetailViewModel',
            expectedService: 'EventService, RegistrationService',
          );
        },
      ),
      GoRoute(
        path: '/events/:eventId/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final eventId = state.pathParameters['eventId'] ?? 'unknown';
          return PlaceholderScreen(
            screenCode: 'A05',
            title: 'Form đăng ký sự kiện ($eventId)',
            routePath: '/events/$eventId/register',
            figmaNode: '179:965',
            expectedViewModel: 'RegistrationFormViewModel',
            expectedService: 'RegistrationService, ProfileService',
          );
        },
      ),
      GoRoute(
        path: '/registrations/:registrationId/success',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final regId = state.pathParameters['registrationId'] ?? 'unknown';
          return PlaceholderScreen(
            screenCode: 'A06',
            title: 'Xác nhận đăng ký thành công',
            routePath: '/registrations/$regId/success',
            figmaNode: '179:1538',
            expectedViewModel: 'RegistrationDetailViewModel',
            expectedService: 'RegistrationService',
          );
        },
      ),

      // F2 Flow routes: Registration Detail
      GoRoute(
        path: '/registrations/:registrationId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final regId = state.pathParameters['registrationId'] ?? 'unknown';
          return PlaceholderScreen(
            screenCode: 'A08',
            title: 'Chi tiết lượt đăng ký ($regId)',
            routePath: '/registrations/$regId',
            figmaNode: '181:1345',
            expectedViewModel: 'RegistrationDetailViewModel',
            expectedService:
                'RegistrationService, EventService, CheckInService',
          );
        },
      ),

      // Account sub-routes
      GoRoute(
        path: '/account/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(
          screenCode: 'A10-edit',
          title: 'Chỉnh sửa hồ sơ',
          routePath: '/account/edit',
          figmaNode: '181:2030',
          expectedViewModel: 'AccountViewModel',
          expectedService: 'ProfileService, AuthService',
        ),
      ),

      // F4A Flow routes: Scanner & Result
      GoRoute(
        path: '/registrations/:registrationId/scan',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final regId = state.pathParameters['registrationId'] ?? 'unknown';
          return PlaceholderScreen(
            screenCode: 'A11',
            title: 'Quét mã QR điểm danh',
            routePath: '/registrations/$regId/scan',
            figmaNode: '182:1804',
            expectedViewModel: 'ScannerViewModel',
            expectedService: 'CameraService, CheckInService',
          );
        },
      ),
      GoRoute(
        path: '/registrations/:registrationId/check-in',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final regId = state.pathParameters['registrationId'] ?? 'unknown';
          return PlaceholderScreen(
            screenCode: 'A12',
            title: 'Kết quả điểm danh',
            routePath: '/registrations/$regId/check-in',
            figmaNode: '182:1995',
            expectedViewModel: 'CheckInResultViewModel',
            expectedService: 'CheckInService, EventService',
          );
        },
      ),

      // Lab 3 Additional Screens
      GoRoute(
        path: '/account/firebase-demo',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(
          screenCode: 'L3-01',
          title: 'Khu Demo Firebase Services',
          routePath: '/account/firebase-demo',
          expectedViewModel: 'FirebaseDemoViewModel',
          expectedService:
              'ConfigService, DiagnosticsService, NotificationService',
        ),
      ),
      GoRoute(
        path: '/account/export',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PlaceholderScreen(
          screenCode: 'L3-02',
          title: 'Xuất PDF & Upload Cloud Storage',
          routePath: '/account/export',
          expectedViewModel: 'ExportViewModel',
          expectedService: 'RegistrationService, EventService, ReportService, StorageService',
        ),
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
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
