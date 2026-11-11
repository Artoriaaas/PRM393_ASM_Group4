import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/main_mock.dart';
import 'package:eventhub/app/app.dart';
import 'package:eventhub/services/auth_providers.dart';
import 'package:eventhub/services/event_service_providers.dart';
import 'package:eventhub/services/contracts/cloud_services.dart';
import 'package:eventhub/viewmodels/cloud_state.dart';

void main() {
  testWidgets('main_mock boots, navigates, and supports event interactions', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final mockAuth = MockAuthService();
    final mockEvent = MockEventService();
    final mockNotif = MockNotificationService();
    final mockStore = MemoryPendingStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseReadyProvider.overrideWithValue(true),
          authServiceProvider.overrideWithValue(mockAuth),
          eventServiceProvider.overrideWithValue(mockEvent),
          notificationServiceProvider.overrideWithValue(mockNotif),
          pendingBookingStoreProvider.overrideWithValue(mockStore),
          cloudServicesProvider.overrideWithValue(UnavailableCloudServices()),
        ],
        child: const EventHubApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 300));

    // 1. Discover tab displays events
    expect(find.text('Khám phá'), findsWidgets);
    final eventCard = find.text('Workshop Thiết kế trải nghiệm người dùng');
    expect(eventCard, findsOneWidget);

    // 2. Open Event Detail
    await tester.tap(eventCard);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Chi tiết sự kiện'), findsOneWidget);
    expect(find.textContaining('Trang bị kiến thức nền tảng về tư duy UX'), findsOneWidget);

    // Back to Discover
    await tester.tap(find.bySemanticsLabel('Quay lại'));
    await tester.pump(const Duration(milliseconds: 300));

    // 3. Schedule tab displays registered ticket
    await tester.tap(find.text('Lịch'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Lịch tham gia'), findsWidgets);
    expect(find.text('Workshop Thiết kế trải nghiệm người dùng'), findsOneWidget);

    // 4. Notifications tab displays mock notification
    await tester.tap(find.text('Thông báo'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Đăng ký vé thành công'), findsOneWidget);

    // 5. Account tab displays user profile
    await tester.tap(find.text('Tài khoản'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Nguyễn Minh Anh'), findsOneWidget);
    expect(find.text('minhanh@example.com'), findsOneWidget);
  });
}
