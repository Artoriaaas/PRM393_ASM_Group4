import 'package:eventhub_web/screens/events/mobile_preview_card.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget preview({bool free = false, double scale = 1}) => MaterialApp(
    theme: EventHubTheme.lightTheme,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: Scaffold(
      body: Center(
        child: MobilePreviewCard(
          title: 'Workshop thiết kế',
          clubName: 'CLB Thiết kế',
          location: 'Phòng 204',
          startsAt: DateTime.utc(2027, 1, 24, 7),
          endsAt: DateTime.utc(2027, 1, 24, 9, 30),
          deadline: DateTime.utc(2027, 1, 23, 11),
          registrationMode: free ? 'free' : 'required',
          capacity: 30,
          activeCount: 4,
          description: 'Nội dung do CLB nhập.',
          topic: 'Thiết kế',
          audience: 'Sinh viên quan tâm thiết kế',
          preparation: 'Mang laptop',
          activities: ['Phỏng vấn người dùng', 'Phác thảo prototype'],
        ),
      ),
    ),
  );

  testWidgets(
    'A04 uses separate cover, facts, live availability and pinned CTA',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(preview());
      expect(find.text('Chi tiết sự kiện'), findsOneWidget);
      expect(find.text('Còn 26 chỗ'), findsOneWidget);
      expect(find.text('14:00–16:30 · 24/01/2027'), findsOneWidget);
      expect(find.text('18:00 · 23/01/2027'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      final cta = tester.getRect(find.text('Đăng ký sự kiện'));
      await tester.drag(
        find.byKey(const ValueKey('mobile-preview-content')),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sinh viên quan tâm thiết kế'), findsOneWidget);
      expect(find.text('Mang laptop'), findsOneWidget);
      expect(tester.getRect(find.text('Đăng ký sự kiện')), cta);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'free event hides registration CTA/deadline/capacity at large text',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(preview(free: true, scale: 1.5));
      expect(find.text('Tham gia tự do'), findsOneWidget);
      expect(find.text('Đăng ký sự kiện'), findsNothing);
      expect(find.text('Hạn đăng ký'), findsNothing);
      expect(find.textContaining('Còn 26'), findsNothing);
      await tester.drag(
        find.byKey(const ValueKey('mobile-preview-content')),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
