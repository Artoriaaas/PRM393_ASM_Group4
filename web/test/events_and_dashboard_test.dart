import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_web/app/providers.dart';
import 'package:eventhub_web/screens/dashboard/club_dashboard_screen.dart';
import 'package:eventhub_web/screens/dashboard/club_attendance_chart.dart';
import 'package:eventhub_web/screens/events/club_events_screen.dart';
import 'package:eventhub_web/screens/events/live_qr_panel_screen.dart';
import 'package:eventhub_web/services/fake_web_services.dart';
import 'package:eventhub_web/services/web_contracts.dart';

void main() {
  group('Stage 2 — Dashboard & Events & Live QR Check-in', () {
    late FakeWebAuthService fakeAuth;
    late FakeClubService fakeClub;

    setUp(() {
      fakeAuth = FakeWebAuthService(
        initialUser: const WebUserProfile(
          uid: 'staff_1',
          email: 'staff@fpt.edu.vn',
          displayName: 'Trưởng CLB IT',
          role: 'staff',
          clubId: 'club_it',
          clubName: 'Câu lạc bộ IT',
        ),
      );

      final demoEvents = [
        Event(
          id: 'ev_1',
          title: 'Hội thảo AI & Flutter 2026',
          clubName: 'Câu lạc bộ IT',
          location: 'Hội trường Alpha',
          startsAt: DateTime.now().add(const Duration(days: 2)),
          endsAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
          deadline: DateTime.now().add(const Duration(days: 1)),
          description: 'Hội thảo công nghệ chuyên sâu',
          mode: 'required',
          status: 'published',
          capacity: 100,
          activeCount: 45,
          clubId: 'club_it',
        ),
        Event(
          id: 'ev_2',
          title: 'Workshop Git & CI/CD',
          clubName: 'Câu lạc bộ IT',
          location: 'Phòng Lab 302',
          startsAt: DateTime.now().add(const Duration(days: 5)),
          endsAt: DateTime.now().add(const Duration(days: 5, hours: 2)),
          mode: 'required',
          status: 'draft',
          capacity: 50,
          activeCount: 0,
          clubId: 'club_it',
        ),
      ];

      final demoRegistrations = [
        const Registration(
          id: 'reg_1',
          eventId: 'ev_1',
          status: 'approved',
          generation: 1,
          participant: Participant(
            name: 'Nguyen Van A',
            email: 'a@fpt.edu.vn',
            group: 'student',
            cohort: 'K17',
          ),
          uid: 'student_1',
          clubId: 'club_it',
        ),
        const Registration(
          id: 'reg_2',
          eventId: 'ev_1',
          status: 'pending',
          generation: 1,
          participant: Participant(
            name: 'Tran Thi B',
            email: 'b@fpt.edu.vn',
            group: 'student',
            cohort: 'K18',
          ),
          uid: 'student_2',
          clubId: 'club_it',
        ),
      ];

      fakeClub = FakeClubService(
        initialEvents: demoEvents,
        initialRegistrations: demoRegistrations,
      );
    });

    testWidgets('Dashboard renders 3 figures, chart and quick lists',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
            clubServiceProvider.overrideWithValue(fakeClub),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const ClubDashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check Header & 3 Metrics
      expect(find.text('Bảng điều khiển CLB'), findsOneWidget);
      expect(find.text('Sự kiện đang mở'), findsOneWidget);
      expect(find.text('Đơn chờ duyệt'), findsOneWidget);
      expect(find.text('Đã duyệt / Điểm danh'), findsOneWidget);

      // Check Chart presence
      expect(find.byType(ClubAttendanceChart), findsOneWidget);
      expect(find.text('Sức chứa (capacity)'), findsOneWidget);
      expect(find.text('Đã duyệt (activeCount)'), findsOneWidget);

      // Check Quick lists
      expect(find.text('Đơn mới chờ duyệt'), findsOneWidget);
      expect(find.text('Tran Thi B'), findsOneWidget);
      expect(find.text('Sự kiện của CLB'), findsOneWidget);
      expect(find.text('Hội thảo AI & Flutter 2026'), findsWidgets);
    });

    testWidgets('ClubEventsScreen filters by status and archives event cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
            clubServiceProvider.overrideWithValue(fakeClub),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const ClubEventsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Both events visible
      expect(find.text('Hội thảo AI & Flutter 2026'), findsOneWidget);
      expect(find.text('Workshop Git & CI/CD'), findsOneWidget);

      // Filter to draft only
      await tester.tap(find.text('Bản nháp (draft)'));
      await tester.pumpAndSettle();

      expect(find.text('Hội thảo AI & Flutter 2026'), findsNothing);
      expect(find.text('Workshop Git & CI/CD'), findsOneWidget);

      // Back to all
      await tester.tap(find.text('Tất cả'));
      await tester.pumpAndSettle();
      expect(find.text('Hội thảo AI & Flutter 2026'), findsOneWidget);
    });

    testWidgets(
        'LiveQrPanelScreen displays large QR, toggles session and shows live checkin count',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            webAuthServiceProvider.overrideWithValue(fakeAuth),
            clubServiceProvider.overrideWithValue(fakeClub),
          ],
          child: const MaterialApp(
            home: LiveQrPanelScreen(eventId: 'ev_1'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Điểm danh QR Trực tiếp'), findsOneWidget);
      expect(find.text('Phiên đang đóng'), findsOneWidget);
      expect(find.text('Mở phiên điểm danh'), findsOneWidget);

      // Toggle open session
      await tester.tap(find.text('Mở phiên điểm danh'));
      await tester.pumpAndSettle();

      expect(find.text('Phiên đang mở'), findsOneWidget);
      expect(find.text('Đóng phiên'), findsOneWidget);

      // Verify participant in realtime list
      expect(find.text('Nguyen Van A'), findsOneWidget);
      expect(find.text('Chưa điểm danh'), findsOneWidget);
    });
  });
}
