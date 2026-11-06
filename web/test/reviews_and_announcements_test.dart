import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_web/app/providers.dart';
import 'package:eventhub_web/screens/announcements/club_announcements_screen.dart';
import 'package:eventhub_web/screens/reviews/reject_reason_dialog.dart';
import 'package:eventhub_web/screens/reviews/review_queue_screen.dart';
import 'package:eventhub_web/services/web_contracts.dart';
import 'support/fake_web_services.dart';

void main() {
  group('Stage 3 — Review Queue Atomic Guards & Announcements', () {
    late FakeWebAuthService fakeAuth;
    late FakeClubService fakeClub;
    late FakeWebAnalyticsService fakeAnalytics;

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
      fakeAnalytics = FakeWebAnalyticsService();

      final demoEvents = [
        Event(
          id: 'ev_ai_2026',
          title: 'Hội thảo AI 2026',
          clubName: 'Câu lạc bộ IT',
          location: 'Hội trường Alpha',
          startsAt: DateTime.now().add(const Duration(days: 2)),
          endsAt: DateTime.now().add(const Duration(days: 2, hours: 3)),
          mode: 'required',
          status: 'published',
          capacity: 11,
          activeCount: 10,
          clubId: 'club_it',
        ),
      ];

      final demoRegistrations = [
        const Registration(
          id: 'student_c_ev_ai_2026',
          eventId: 'ev_ai_2026',
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
        const Registration(
          id: 'student_d_ev_ai_2026',
          eventId: 'ev_ai_2026',
          status: 'pending',
          generation: 1,
          participant: Participant(
            name: 'Le Thi D',
            email: 'd@fpt.edu.vn',
            group: 'student',
            cohort: 'K19',
          ),
          uid: 'student_d',
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

    testWidgets(
      'ReviewQueueScreen approves last available seat and blocks over-capacity approval',
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
              webAnalyticsServiceProvider.overrideWithValue(fakeAnalytics),
            ],
            child: MaterialApp(
              theme: EventHubTheme.lightTheme,
              home: const ReviewQueueScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Dang Van C'), findsOneWidget);
        expect(find.text('Le Thi D'), findsOneWidget);

        // Approve Dang Van C -> fills seat 11/11
        await tester.tap(find.text('Duyệt (Approve)').first);
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(AppButton, 'Phê duyệt'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Đã phê duyệt đơn của'), findsOneWidget);
        expect(fakeClub.sentNotifications.last['eventId'], 'ev_ai_2026');

        // Attempt to approve Le Thi D when event is now full (11/11)
        await tester.tap(find.text('Duyệt (Approve)').first);
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(AppButton, 'Phê duyệt'));
        await tester.pumpAndSettle();

        expect(
          find.text('Sự kiện đã hết chỗ, không thể duyệt thêm.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Reject flow validates >= 3 chars and preserves underscored eventId in student notification',
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
              webAnalyticsServiceProvider.overrideWithValue(fakeAnalytics),
            ],
            child: MaterialApp(
              theme: EventHubTheme.lightTheme,
              home: const ReviewQueueScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Từ chối (Reject)').first);
        await tester.pumpAndSettle();

        expect(find.byType(RejectReasonDialog), findsOneWidget);

        // Submit empty -> validation error
        await tester.tap(find.text('Xác nhận từ chối'));
        await tester.pumpAndSettle();
        expect(
          find.text('Lý do từ chối bắt buộc có tối thiểu 3 ký tự.'),
          findsOneWidget,
        );

        // Enter valid reason -> sends notification with intact 'ev_ai_2026'
        await tester.enterText(
          find.descendant(
            of: find.byType(RejectReasonDialog),
            matching: find.byType(TextFormField),
          ),
          'Chưa đáp ứng điều kiện tiên quyết của hội thảo.',
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Xác nhận từ chối'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Đã từ chối đơn của'), findsOneWidget);
        expect(
          fakeClub.sentNotifications.last['type'],
          'registration_rejected',
        );
        expect(fakeClub.sentNotifications.last['eventId'], 'ev_ai_2026');
      },
    );

    testWidgets(
      'ClubAnnouncementsScreen composes, previews, and publishes new announcement',
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
              webAnalyticsServiceProvider.overrideWithValue(fakeAnalytics),
            ],
            child: MaterialApp(
              theme: EventHubTheme.lightTheme,
              home: const ClubAnnouncementsScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Chào đón tân sinh viên K20'), findsOneWidget);

        await tester.enterText(
          find.byKey(const Key('announcement_title_field')),
          'Thông báo dời lịch sinh hoạt tuần này',
        );
        await tester.enterText(
          find.byKey(const Key('announcement_body_field')),
          'Buổi sinh hoạt sẽ chuyển sang thứ Bảy tuần tới lúc 14h tại Lab 3.',
        );
        await tester.pumpAndSettle();

        // Live preview shows typed title before publishing
        expect(
          find.text('Thông báo dời lịch sinh hoạt tuần này'),
          findsNWidgets(2),
        );

        await tester.tap(find.text('Phát hành thông báo'));
        await tester.pumpAndSettle();

        expect(
          find.text('Đã phát hành thông báo thành công!'),
          findsOneWidget,
        );
        expect(
          find.text('Thông báo dời lịch sinh hoạt tuần này'),
          findsOneWidget,
        );
      },
    );
  });
}
