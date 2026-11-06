import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_web/app/providers.dart';
import 'package:eventhub_web/app/router.dart';
import 'package:eventhub_web/screens/auth/sign_in_screen.dart';
import 'package:eventhub_web/screens/auth/role_rejection_screen.dart';
import 'package:eventhub_web/screens/shell/app_shell.dart';
import 'package:eventhub_web/services/fake_web_services.dart';
import 'package:eventhub_web/services/web_contracts.dart';

void main() {
  group('Stage 1 — Web Auth & Role Rejection Gate', () {
    testWidgets('SignInScreen renders login button and branding',
        (tester) async {
      final fakeAuth = FakeWebAuthService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
          ],
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
      final fakeAuth = FakeWebAuthService();
      fakeAuth.nextSignInUser = const WebUserProfile(
        uid: 'student_123',
        email: 'student@fpt.edu.vn',
        displayName: 'Sinh Vien FPTU',
        role: 'user',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const SignInScreen(),
          ),
        ),
      );

      // Tap Google Sign-In
      await tester.tap(find.text('Đăng nhập bằng Google'));
      await tester.pumpAndSettle();

      // Expect RoleRejectionScreen is displayed
      expect(find.byType(RoleRejectionScreen), findsOneWidget);
      expect(find.text('Từ chối quyền truy cập'), findsOneWidget);
      expect(find.textContaining('Người tham gia'), findsOneWidget);
      expect(find.text('Đăng xuất / Đổi tài khoản khác'), findsOneWidget);

      // Tap Logout
      await tester.tap(find.text('Đăng xuất / Đổi tài khoản khác'));
      await tester.pumpAndSettle();

      // Returns to SignInScreen
      expect(find.byType(RoleRejectionScreen), findsNothing);
      expect(find.text('Đăng nhập bằng Google'), findsOneWidget);
    });

    testWidgets(
        'Role Rejection Gate rejects role == "staff" without clubId',
        (tester) async {
      final fakeAuth = FakeWebAuthService();
      fakeAuth.nextSignInUser = const WebUserProfile(
        uid: 'staff_no_club',
        email: 'staff_unassigned@fpt.edu.vn',
        displayName: 'Staff No Club',
        role: 'staff',
        clubId: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const SignInScreen(),
          ),
        ),
      );

      await tester.tap(find.text('Đăng nhập bằng Google'));
      await tester.pumpAndSettle();

      expect(find.byType(RoleRejectionScreen), findsOneWidget);
      expect(find.textContaining('chưa được Quản trị viên phân công'), findsOneWidget);
    });

    testWidgets(
        'Staff with valid clubId successfully enters and AppShell renders desktop sidebar',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAuth = FakeWebAuthService();
      final fakeClub = FakeClubService();

      fakeAuth.nextSignInUser = const WebUserProfile(
        uid: 'staff_ok',
        email: 'leader@fpt.edu.vn',
        displayName: 'Trưởng CLB IT',
        role: 'staff',
        clubId: 'club_it',
        clubName: 'Câu lạc bộ IT FPTU',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
            clubServiceProvider.overrideWithValue(fakeClub),
          ],
          child: const ConsumerRouterApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Currently at login
      expect(find.text('Đăng nhập bằng Google'), findsOneWidget);

      // Click sign in
      await tester.tap(find.text('Đăng nhập bằng Google'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Expect to be inside AppShell on desktop
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.text('Cổng Trưởng CLB'), findsOneWidget);
      expect(find.text('Bảng điều khiển'), findsOneWidget);
      expect(find.text('Quản lý sự kiện'), findsOneWidget);
      expect(find.text('Duyệt đăng ký'), findsOneWidget);
      expect(find.text('Thông báo CLB'), findsOneWidget);
      expect(find.text('Trưởng CLB'), findsOneWidget);
    });
  });
}

class ConsumerRouterApp extends ConsumerWidget {
  const ConsumerRouterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(webRouterProvider);
    return MaterialApp.router(
      theme: EventHubTheme.lightTheme,
      routerConfig: router,
    );
  }
}
