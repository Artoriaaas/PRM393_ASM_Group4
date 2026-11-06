import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_web/app/providers.dart';
import 'package:eventhub_web/screens/reviews/review_queue_screen.dart';
import 'package:eventhub_web/screens/reviews/reject_reason_dialog.dart';
import 'package:eventhub_web/screens/announcements/club_announcements_screen.dart';
import 'package:eventhub_web/services/fake_web_services.dart';
import 'package:eventhub_web/services/web_contracts.dart';

void main() {
  group('Stage 3 — Review Queue & Announcements', () {
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
          title: 'Hội thảo AI 2026',
          clubName: 'Câu lạc bộ IT',
          location: 'Hội trường Alpha',
          startsAt: DateTime.now().add(const Duration(days: 2)),
          endsAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
          mode: 'required',
          status: 'published',
          capacity: 50,
          activeCount: 10,
          clubId: 'club_it',
        ),
      ];

      final demoRegistrations = [
        const Registration(
          id: 'reg_pending_1',
          eventId: 'ev_1',
          status: 'pending',
          generation: 1,
          participant: Participant(
            name: 'Dang Van C',
            email: 'c@fpt.edu.vn',
            group: 'student',
            cohort: 'K18',
          ),
          uid: 'student_c',
          clubId: 'club_it',
        ),
      ];

      final demoAnnouncements = [
        Announcement(
          id: 'ann_1',
          title: 'Chào đón tân sinh viên K20',
          body: 'Chào mừng các bạn đến với CLB IT!',
          scope: 'club',
          clubId: 'club_it',
          clubName: 'Câu lạc bộ IT',
          createdAt: DateTime.now(),
        ),
      ];

      fakeClub = FakeClubService(
        initialEvents: demoEvents,
        initialRegistrations: demoRegistrations,
        initialAnnouncements: demoAnnouncements,
      );
    });

    testWidgets('ReviewQueueScreen displays pending registration and can Approve',
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
            home: const ReviewQueueScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Hàng đợi Xét duyệt Đăng ký'), findsOneWidget);
      expect(find.text('Dang Van C'), findsOneWidget);
      expect(find.text('Duyệt (Approve)'), findsOneWidget);
      expect(find.text('Từ chối (Reject)'), findsOneWidget);

      // Tap Approve
      await tester.tap(find.text('Duyệt (Approve)'));
      await tester.pumpAndSettle();

      // Expect confirmation dialog
      expect(find.text('Phê duyệt đơn đăng ký'), findsOneWidget);
      await tester.tap(find.widgetWithText(AppButton, 'Phê duyệt'));
      await tester.pumpAndSettle();

      // Verified approved action message appears
      expect(find.textContaining('Đã phê duyệt đơn của Dang Van C'), findsOneWidget);
    });

    testWidgets(
        'Reject dialog validates required reason length >= 3 chars',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: EventHubTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => showDialog(
                  context: ctx,
                  builder: (_) => const RejectReasonDialog(
                    participantName: 'Dang Van C',
                  ),
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Từ chối đơn đăng ký'), findsOneWidget);
      expect(find.text('Xác nhận từ chối'), findsOneWidget);

      // Attempt submit without reason
      await tester.tap(find.text('Xác nhận từ chối'));
      await tester.pumpAndSettle();

      // Validation error shown
      expect(
          find.text('Lý do từ chối bắt buộc có tối thiểu 3 ký tự.'), findsOneWidget);

      // Enter valid reason
      await tester.enterText(
          find.byType(TextFormField), 'Khóa K không phù hợp với chủ đề hội thảo');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Xác nhận từ chối'));
      await tester.pumpAndSettle();

      // Dialog closed
      expect(find.text('Từ chối đơn đăng ký'), findsNothing);
    });

    testWidgets(
        'ClubAnnouncementsScreen composes and publishes new announcement',
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
            home: const ClubAnnouncementsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check Existing announcement in history
      expect(find.text('Chào đón tân sinh viên K20'), findsOneWidget);

      // Compose form fields
      await tester.enterText(
        find.byKey(const Key('announcement_title_field')),
        'Thông báo dời lịch sinh hoạt tuần này',
      );
      await tester.enterText(
        find.byKey(const Key('announcement_body_field')),
        'Buổi sinh hoạt sẽ chuyển sang thứ Bảy tuần tới lúc 14h tại Lab 3.',
      );
      await tester.pumpAndSettle();

      // Tap Publish
      await tester.tap(find.text('Phát hành thông báo'));
      await tester.pumpAndSettle();

      // Success feedback and new item in history
      expect(find.text('Đã phát hành thông báo thành công!'), findsOneWidget);
      expect(find.text('Thông báo dời lịch sinh hoạt tuần này'), findsOneWidget);
    });
  });
}
