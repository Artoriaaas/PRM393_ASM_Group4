import 'package:eventhub/viewmodels/event_data_providers.dart';

import 'support/fake_event_service.dart';

import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots into Discover tab and navigates tabs successfully', (
    tester,
  ) async {
    // Simulate Android's three-button navigation bar in edge-to-edge mode.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(412, 850);
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionViewModelProvider.overrideWith(TestSession.new),
          eventServiceProvider.overrideWithValue(FakeEventService()),
          pendingBookingStoreProvider.overrideWithValue(MemoryPendingStore()),
        ],
        child: const EventHubApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final rootNavigator = find.byType(Navigator).first;
    expect(tester.getRect(rootNavigator).bottom, 802);
    final screenContext = tester.element(find.byType(AppBar).first);
    expect(MediaQuery.paddingOf(screenContext).bottom, 0);

    // Verify initial screen is Discover tab (A02)
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Khám phá')),
      findsOneWidget,
    );
    expect(find.text('Khám phá'), findsNWidgets(2));
    expect(find.text('Lịch'), findsOneWidget);
    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.text('Tài khoản'), findsOneWidget);

    // Switch to Schedule tab
    await tester.tap(find.text('Lịch'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Lịch tham gia'),
      ),
      findsOneWidget,
    );

    // Switch to Notifications tab
    await tester.tap(find.text('Thông báo'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Thông báo'),
      ),
      findsOneWidget,
    );

    // Switch to Account tab
    await tester.tap(find.text('Tài khoản'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Tài khoản'),
      ),
      findsOneWidget,
    );

    expect(find.text('Dịch vụ Firebase'), findsOneWidget);
    expect(find.text('Email đã xác nhận'), findsNothing);
    expect(find.textContaining('Xác nhận email chỉ'), findsNothing);
    expect(find.text('Xem thử Component UI (360/412dp)'), findsNothing);
    expect(tester.getRect(rootNavigator).bottom, 802);
    expect(tester.takeException(), isNull);
  });
}

class TestSession extends SessionViewModel {
  @override
  AuthState build() =>
      const AuthState.signedIn(uid: "test", email: "test@example.com");
}
