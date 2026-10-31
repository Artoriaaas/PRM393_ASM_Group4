import 'package:eventhub/app/event_providers.dart';

import 'support/fake_event_service.dart';

import 'package:eventhub/app/providers.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:eventhub/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots into Discover tab and navigates tabs successfully', (
    tester,
  ) async {
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

    // Navigate to Dev Component Preview screen from Account tab
    final previewBtn = find.text('Xem thử Component UI (360/412dp)');
    await tester.scrollUntilVisible(
      previewBtn,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(previewBtn, findsOneWidget);
    await tester.ensureVisible(previewBtn);
    await tester.pumpAndSettle();
    await tester.tap(previewBtn);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Dev Component screen loaded
    expect(find.text('Xem thử Component (Development)'), findsOneWidget);

    // Test back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Tài khoản'),
      ),
      findsOneWidget,
    );
  });
}

class TestSession extends SessionViewModel {
  @override
  AuthState build() =>
      const AuthState.signedIn(uid: "test", email: "test@example.com");
}
