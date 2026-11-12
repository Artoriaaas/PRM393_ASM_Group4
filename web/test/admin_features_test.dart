import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_web/app/providers.dart';
import 'package:eventhub_web/screens/admin/admin_dashboard_screen.dart';
import 'package:eventhub_web/screens/clubs/admin_clubs_screen.dart';
import 'package:eventhub_web/screens/users/admin_users_screen.dart';
import 'package:eventhub_web/screens/shell/app_shell.dart';
import 'package:eventhub_web/screens/reviews/review_queue_screen.dart';
import 'package:eventhub_web/screens/events/club_events_screen.dart';
import 'package:eventhub_web/screens/events/live_qr_panel_screen.dart';
import 'package:eventhub_web/services/web_contracts.dart';
import 'package:eventhub_web/viewmodels/admin_clubs_viewmodel.dart';
import 'package:eventhub_web/viewmodels/admin_dashboard_viewmodel.dart';
import 'package:eventhub_web/viewmodels/admin_users_viewmodel.dart';
import 'package:eventhub_web/viewmodels/web_auth_viewmodel.dart';
import 'support/fake_web_services.dart';

void main() {
  const adminUser = WebUserProfile(
    uid: 'admin_1',
    email: 'admin@fpt.edu.vn',
    displayName: 'Quản trị viên Hệ thống',
    role: 'admin',
  );

  const sampleUsers = [
    WebUserProfile(
      uid: 'u_1',
      email: 'sinhvien1@fpt.edu.vn',
      displayName: 'Nguyen Van A',
      role: 'user',
    ),
    WebUserProfile(
      uid: 'u_2',
      email: 'lead_fcode@fpt.edu.vn',
      displayName: 'Tran Van B',
      role: 'staff',
      clubId: 'c_fcode',
      clubName: 'CLB F-Code',
    ),
    WebUserProfile(
      uid: 'admin_1',
      email: 'admin@fpt.edu.vn',
      displayName: 'Quản trị viên Hệ thống',
      role: 'admin',
    ),
  ];

  const sampleClubs = [
    Club(
      id: 'c_fcode',
      name: 'Câu lạc bộ F-Code',
      shortName: 'F-Code',
      description: 'CLB Lập trình sinh viên',
      status: 'active',
    ),
    Club(
      id: 'c_fuda',
      name: 'CLB Mỹ thuật FUDA',
      shortName: 'FUDA',
      description: 'CLB Thiết kế & Đồ họa',
      status: 'active',
    ),
  ];

  group('Admin Features - User Management', () {
    testWidgets('AdminUsersScreen renders user list and allows role filtering', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeWebAuthService(initialUser: adminUser);
      final fakeAdmin = FakeAdminService(
        initialUsers: sampleUsers,
        initialClubs: sampleClubs,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
            adminServiceProvider.overrideWithValue(fakeAdmin),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const AdminUsersScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quản lý Người dùng & Phân quyền'), findsOneWidget);
      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(find.text('Tran Van B'), findsOneWidget);

      // Filter by staff
      await tester.tap(find.text('Trưởng CLB (staff)'));
      await tester.pumpAndSettle();

      expect(find.text('Tran Van B'), findsOneWidget);
      expect(find.text('Nguyen Van A'), findsNothing);
    });

    test('AdminUsersViewModel updateUserRole modifies user list', () async {
      final fakeAdmin = FakeAdminService(
        initialUsers: sampleUsers,
        initialClubs: sampleClubs,
      );
      final fakeAuth = FakeWebAuthService(initialUser: adminUser);

      final container = ProviderContainer(
        overrides: [
          webAuthServiceProvider.overrideWithValue(fakeAuth),
          adminServiceProvider.overrideWithValue(fakeAdmin),
        ],
      );
      addTearDown(container.dispose);

      // Listen to build
      container.read(adminUsersViewModelProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final vm = container.read(adminUsersViewModelProvider.notifier);
      final res = await vm.updateUserRole(
        targetUid: 'u_1',
        newRole: 'staff',
        clubId: 'c_fuda',
        clubName: 'CLB Mỹ thuật FUDA',
      );

      expect(res.isSuccess, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final updatedState = container.read(adminUsersViewModelProvider);
      final u1 = updatedState.allUsers.firstWhere((u) => u.uid == 'u_1');
      expect(u1.role, 'staff');
      expect(u1.clubId, 'c_fuda');
    });

    testWidgets('AdminUsersScreen displays club name for staff and excludes assigned clubs in role dialog', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeWebAuthService(initialUser: adminUser);
      final fakeAdmin = FakeAdminService(
        initialUsers: sampleUsers,
        initialClubs: sampleClubs,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
            adminServiceProvider.overrideWithValue(fakeAdmin),
          ],
          child: const MaterialApp(
            home: AdminUsersScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tran Van B is staff of c_fcode ('CLB F-Code')
      expect(find.text('Trưởng CLB: CLB F-Code'), findsOneWidget);

      // Open role dialog for first user (Nguyen Van A)
      await tester.tap(find.text('Phân quyền').first);
      await tester.pumpAndSettle();

      expect(find.text('Phân quyền người dùng'), findsOneWidget);

      // Switch role to staff
      await tester.tap(find.text('Sinh viên / Người tham gia (user)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trưởng CLB (staff)').last);
      await tester.pumpAndSettle();

      // Club c_fcode already has a leader (Tran Van B), so only c_fuda should be available!
      expect(find.text('CLB Mỹ thuật FUDA'), findsOneWidget);

      // Open club dropdown
      await tester.tap(find.text('CLB Mỹ thuật FUDA'));
      await tester.pumpAndSettle();

      // 'Câu lạc bộ F-Code' must NOT be in the dropdown items because it already has a leader!
      expect(find.text('Câu lạc bộ F-Code'), findsNothing);
    });
  });
  group('Admin Features - Club Directory Management', () {
    testWidgets('AdminClubsScreen renders clubs and allows searching', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeWebAuthService(initialUser: adminUser);
      final fakeAdmin = FakeAdminService(initialClubs: sampleClubs);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
            adminServiceProvider.overrideWithValue(fakeAdmin),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const AdminClubsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Danh mục Câu lạc bộ'), findsOneWidget);
      expect(find.text('Câu lạc bộ F-Code'), findsOneWidget);
      expect(find.text('CLB Mỹ thuật FUDA'), findsOneWidget);

      // Search
      await tester.enterText(find.byType(TextField).first, 'FUDA');
      await tester.pumpAndSettle();

      expect(find.text('CLB Mỹ thuật FUDA'), findsOneWidget);
      expect(find.text('Câu lạc bộ F-Code'), findsNothing);
    });

    test('AdminClubsViewModel creates and archives club', () async {
      final fakeAdmin = FakeAdminService(initialClubs: sampleClubs);
      final fakeAuth = FakeWebAuthService(initialUser: adminUser);

      final container = ProviderContainer(
        overrides: [
          webAuthServiceProvider.overrideWithValue(fakeAuth),
          adminServiceProvider.overrideWithValue(fakeAdmin),
        ],
      );
      addTearDown(container.dispose);

      container.read(adminClubsViewModelProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final vm = container.read(adminClubsViewModelProvider.notifier);
      final res = await vm.createClub(
        name: 'Câu lạc bộ Âm nhạc F-Beats',
        shortName: 'F-Beats',
        description: 'CLB Âm nhạc sinh viên',
      );
      expect(res.isSuccess, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = container.read(adminClubsViewModelProvider);
      expect(state.allClubs.length, 3);

      await vm.archiveClub('c_fcode');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final archivedClub =
          container.read(adminClubsViewModelProvider).allClubs.firstWhere((c) => c.id == 'c_fcode');
      expect(archivedClub.status, 'archived');
    });
  });

  group('Admin Features - System Dashboard & AppShell', () {
    testWidgets('AdminDashboardScreen displays system metrics', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeWebAuthService(initialUser: adminUser);
      final fakeAdmin = FakeAdminService(
        initialUsers: sampleUsers,
        initialClubs: sampleClubs,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
            adminServiceProvider.overrideWithValue(fakeAdmin),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const AdminDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bảng điều khiển Toàn hệ thống'), findsOneWidget);
      expect(find.text('Sự kiện đang mở'), findsOneWidget);
      expect(find.text('Đề xuất sự kiện chờ duyệt'), findsOneWidget);
      expect(find.text('CLB đang hoạt động'), findsOneWidget);
    });

    testWidgets('AppShell renders Admin sidebar when user is admin', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeWebAuthService(initialUser: adminUser);
      final fakeAdmin = FakeAdminService(
        initialUsers: sampleUsers,
        initialClubs: sampleClubs,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
            adminServiceProvider.overrideWithValue(fakeAdmin),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const AppShell(
              currentLocation: '/admin-dashboard',
              child: Text('Content Placeholder'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cổng Quản trị viên'), findsOneWidget);
      expect(find.text('Người dùng'), findsOneWidget);
      expect(find.text('Câu lạc bộ'), findsOneWidget);
      expect(find.text('Giám sát & Duyệt sự kiện'), findsOneWidget);
      expect(find.text('Duyệt đăng ký'), findsNothing);
      expect(find.text('Thông báo hệ thống'), findsOneWidget);
    });

    test('AdminService approves and rejects event proposals', () async {
      final testEvent = Event(
        id: 'ev_proposal_1',
        title: 'Workshop Flutter Advanced',
        clubName: 'CLB F-Code',
        location: 'Lab 101',
        startsAt: DateTime.now().add(const Duration(days: 5)),
        endsAt: DateTime.now().add(const Duration(days: 5, hours: 2)),
        status: 'pending_approval',
        clubId: 'c_fcode',
      );

      final fakeAdmin = FakeAdminService(
        initialUsers: sampleUsers,
        initialClubs: sampleClubs,
        initialEvents: [testEvent],
      );

      expect(await fakeAdmin.countSystemPendingEvents(), 1);

      // Approve
      await fakeAdmin.adminApproveEvent('ev_proposal_1');
      final approvedEvents = await fakeAdmin.streamAllEvents().first;
      expect(approvedEvents.first.status, 'published');
      expect(await fakeAdmin.countSystemPendingEvents(), 0);

      // Reject
      await fakeAdmin.adminRejectEvent('ev_proposal_1', reason: 'Trùng lịch thi');
      final rejectedEvents = await fakeAdmin.streamAllEvents().first;
      expect(rejectedEvents.first.status, 'rejected');
    });

    testWidgets('ReviewQueueScreen displays role boundary notice when viewed by Admin',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = FakeWebAuthService(initialUser: adminUser);
      final fakeAdmin = FakeAdminService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
            adminServiceProvider.overrideWithValue(fakeAdmin),
          ],
          child: const MaterialApp(
            home: ReviewQueueScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Phân quyền Duyệt Đăng ký'), findsOneWidget);
      expect(find.text('Đến Giám sát & Phê duyệt Sự kiện'), findsOneWidget);
    });

    testWidgets(
      'ClubEventsScreen hides create button & QR check-in for Admin and allows approving proposals',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final testEvent = Event(
          id: 'ev_prop_1',
          title: 'Workshop AI Gen',
          clubName: 'CLB F-Code',
          location: 'Lab 201',
          startsAt: DateTime.now().add(const Duration(days: 3)),
          endsAt: DateTime.now().add(const Duration(days: 3, hours: 2)),
          status: 'pending_approval',
          clubId: 'c_fcode',
          mode: 'required',
          capacity: 50,
        );

        final fakeAuth = FakeWebAuthService(initialUser: adminUser);
        final fakeAdmin = FakeAdminService(
          initialUsers: sampleUsers,
          initialClubs: sampleClubs,
          initialEvents: [testEvent],
        );
        final fakeClub = FakeClubService(initialEvents: [testEvent]);
        final fakeAnalytics = FakeWebAnalyticsService();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              webAuthServiceProvider.overrideWithValue(fakeAuth),
              adminServiceProvider.overrideWithValue(fakeAdmin),
              clubServiceProvider.overrideWithValue(fakeClub),
              webAnalyticsServiceProvider.overrideWithValue(fakeAnalytics),
            ],
            child: MaterialApp(
              theme: EventHubTheme.lightTheme,
              home: const ClubEventsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Giám sát & Phê duyệt Sự kiện CLB'), findsOneWidget);
        // Admin does not create events
        expect(find.text('Tạo sự kiện mới'), findsNothing);
        // Admin does not manage QR check-in
        expect(find.text('Điểm danh QR'), findsNothing);

        // Pending proposal has Approve and Reject buttons
        expect(find.text('Phê duyệt'), findsOneWidget);
        expect(find.text('Từ chối'), findsOneWidget);

        // Tap Approve
        await tester.tap(find.text('Phê duyệt'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Phê duyệt đề xuất sự kiện'), findsOneWidget);
        await tester.tap(find.text('Phê duyệt sự kiện'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Still no QR check-in button for Admin even when published
        expect(find.text('Điểm danh QR'), findsNothing);
      },
    );

    testWidgets(
      'LiveQrPanelScreen displays role boundary notice when accessed by Admin',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final fakeAuth = FakeWebAuthService(initialUser: adminUser);
        final fakeAdmin = FakeAdminService();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              webAuthServiceProvider.overrideWithValue(fakeAuth),
              adminServiceProvider.overrideWithValue(fakeAdmin),
              clubServiceProvider.overrideWithValue(FakeClubService()),
            ],
            child: const MaterialApp(
              home: LiveQrPanelScreen(eventId: 'ev_prop_1'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Phân quyền Điểm danh QR'), findsOneWidget);
        expect(
          find.text('Quay lại Giám sát & Phê duyệt Sự kiện'),
          findsOneWidget,
        );
      },
    );
  });
}

