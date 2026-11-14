import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_web/app/bootstrap.dart';
import 'package:eventhub_web/app/providers.dart';
import 'package:eventhub_web/app/router.dart';
import 'package:eventhub_web/screens/auth/role_rejection_screen.dart';
import 'package:eventhub_web/screens/auth/sign_in_screen.dart';
import 'package:eventhub_web/screens/events/club_events_screen.dart';
import 'package:eventhub_web/screens/shell/app_shell.dart';
import 'package:eventhub_web/services/web_contracts.dart';

import 'support/fake_web_services.dart';

void main() {
  group(
    'Stage 1 — Bootstrap, Web Auth, Role Rejection Gate & Session Isolation',
    () {
      testWidgets(
        'WebFirebaseAppBootstrap shows error state when unconfigured and recovers on retry',
        (tester) async {
          var shouldSucceed = false;
          await tester.pumpWidget(
            WebFirebaseAppBootstrap(
              initializer: () async => shouldSucceed,
              readyChild: MaterialApp(
                theme: EventHubTheme.lightTheme,
                home: const Scaffold(body: Text('Web Ready')),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(AppErrorState), findsOneWidget);
          expect(find.text('Chưa kết nối được EventHub Web'), findsOneWidget);

          shouldSucceed = true;
          await tester.tap(find.text('Thử lại'));
          await tester.pumpAndSettle();

          expect(find.text('Web Ready'), findsOneWidget);
        },
      );

      testWidgets('SignInScreen renders login button and branding', (
        tester,
      ) async {
        final fakeAuth = FakeWebAuthService();
        await tester.pumpWidget(
          ProviderScope(
            overrides: [webAuthServiceProvider.overrideWithValue(fakeAuth)],
            child: MaterialApp(
              theme: EventHubTheme.lightTheme,
              home: const SignInScreen(),
            ),
          ),
        );

        expect(find.text('EventHub'), findsOneWidget);
        expect(find.text('Đăng nhập tài khoản'), findsOneWidget);
        expect(find.text('Đăng nhập bằng Google'), findsOneWidget);
      });

      testWidgets(
        'Role Rejection Gate rejects role == "user" with clear explanation',
        (tester) async {
          final fakeAuth = FakeWebAuthService()
            ..nextSignInUser = const WebUserProfile(
              uid: 'student_123',
              email: 'student@fpt.edu.vn',
              displayName: 'Sinh Vien FPTU',
              role: 'user',
            );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [webAuthServiceProvider.overrideWithValue(fakeAuth)],
              child: MaterialApp(
                theme: EventHubTheme.lightTheme,
                home: const SignInScreen(),
              ),
            ),
          );

          await tester.tap(find.text('Đăng nhập bằng Google'));
          await tester.pumpAndSettle();

          expect(find.byType(RoleRejectionScreen), findsOneWidget);
          expect(find.text('Từ chối quyền truy cập'), findsOneWidget);
          expect(find.textContaining('Người tham gia'), findsOneWidget);
          expect(find.text('Đăng xuất / Đổi tài khoản khác'), findsOneWidget);

          await tester.ensureVisible(
            find.text('Đăng xuất / Đổi tài khoản khác'),
          );
          await tester.tap(find.text('Đăng xuất / Đổi tài khoản khác'));
          await tester.pumpAndSettle();

          expect(find.byType(RoleRejectionScreen), findsNothing);
          expect(find.text('Đăng nhập bằng Google'), findsOneWidget);
        },
      );

      testWidgets(
        'Role Rejection Gate rejects role == "staff" without clubId',
        (tester) async {
          final fakeAuth = FakeWebAuthService()
            ..nextSignInUser = const WebUserProfile(
              uid: 'staff_no_club',
              email: 'staff_unassigned@fpt.edu.vn',
              displayName: 'Staff No Club',
              role: 'staff',
              clubId: null,
            );

          await tester.pumpWidget(
            ProviderScope(
              overrides: [webAuthServiceProvider.overrideWithValue(fakeAuth)],
              child: MaterialApp(
                theme: EventHubTheme.lightTheme,
                home: const SignInScreen(),
              ),
            ),
          );

          await tester.tap(find.text('Đăng nhập bằng Google'));
          await tester.pumpAndSettle();

          expect(find.byType(RoleRejectionScreen), findsOneWidget);
          expect(
            find.textContaining('chưa được Quản trị viên phân công'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'Staff with valid clubId enters AppShell and switching staff accounts isolates club data',
        (tester) async {
          tester.view.physicalSize = const Size(1280, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final fakeAuth = FakeWebAuthService()
            ..nextSignInUser = const WebUserProfile(
              uid: 'staff_it',
              email: 'leader.it@fpt.edu.vn',
              displayName: 'Trưởng CLB IT',
              role: 'staff',
              clubId: 'club_it',
              clubName: 'Câu lạc bộ IT FPTU',
            );

          final fakeClub = FakeClubService(
            initialEvents: [
              Event(
                id: 'ev_it_1',
                title: 'Sự kiện riêng CLB IT',
                clubName: 'CLB IT',
                location: 'Phòng Alpha',
                startsAt: DateTime.now().add(const Duration(days: 2)),
                endsAt: DateTime.now().add(const Duration(days: 2, hours: 2)),
                status: 'published',
                capacity: 40,
                clubId: 'club_it',
              ),
              Event(
                id: 'ev_music_1',
                title: 'Đêm nhạc Acoustic CLB Music',
                clubName: 'CLB Music',
                location: 'Sân khấu ngoài trời',
                startsAt: DateTime.now().add(const Duration(days: 3)),
                endsAt: DateTime.now().add(const Duration(days: 3, hours: 3)),
                status: 'published',
                capacity: 120,
                clubId: 'club_music',
              ),
            ],
          );

          final fakeAnalytics = FakeWebAnalyticsService();

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                webAuthServiceProvider.overrideWithValue(fakeAuth),
                clubServiceProvider.overrideWithValue(fakeClub),
                webAnalyticsServiceProvider.overrideWithValue(fakeAnalytics),
              ],
              child: const _ConsumerRouterApp(),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Đăng nhập bằng Google'), findsOneWidget);

          await tester.tap(find.text('Đăng nhập bằng Google'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          expect(find.byType(AppShell), findsOneWidget);
          expect(find.text('Cổng Trưởng CLB'), findsOneWidget);
          expect(find.text('Quản lý sự kiện'), findsOneWidget);

          // Navigate to /events and verify only club_it event is shown
          await tester.tap(find.text('Quản lý sự kiện'));
          await tester.pumpAndSettle();

          expect(find.byType(ClubEventsScreen), findsOneWidget);
          expect(find.text('Sự kiện riêng CLB IT'), findsOneWidget);
          expect(find.text('Đêm nhạc Acoustic CLB Music'), findsNothing);

          // Switch session to Staff B (club_music) and verify zero data leak from club_it
          fakeAuth.emitUser(
            const WebUserProfile(
              uid: 'staff_music',
              email: 'leader.music@fpt.edu.vn',
              displayName: 'Trưởng CLB Âm Nhạc',
              role: 'staff',
              clubId: 'club_music',
              clubName: 'CLB Âm Nhạc',
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Đêm nhạc Acoustic CLB Music'), findsOneWidget);
          expect(find.text('Sự kiện riêng CLB IT'), findsNothing);
        },
      );
    },
  );
}

class _ConsumerRouterApp extends ConsumerWidget {
  const _ConsumerRouterApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(webRouterProvider);
    return MaterialApp.router(
      theme: EventHubTheme.lightTheme,
      routerConfig: router,
    );
  }
}
