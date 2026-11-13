import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:eventhub/screens/events/live_schedule_screen.dart';
import 'package:eventhub/viewmodels/event_data_providers.dart';
import 'package:eventhub/theme/theme.dart';

import 'support/fake_event_service.dart';

class Session extends SessionViewModel {
  @override
  AuthState build() =>
      const AuthState.signedIn(uid: 'user', email: 'test@example.org');
}

void main() {
  for (final width in [360.0, 412.0]) {
    testWidgets('schedule tabs remain tappable at $width and large text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionViewModelProvider.overrideWith(Session.new),
            eventServiceProvider.overrideWithValue(FakeEventService()),
            pendingBookingStoreProvider.overrideWithValue(MemoryPendingStore()),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const LiveScheduleScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in ['Sắp tới', 'Đã kết thúc', 'Đã hủy / Từ chối']) {
        final tapTarget = find
            .ancestor(of: find.text(label), matching: find.byType(InkWell))
            .first;
        expect(tester.getSize(tapTarget).height, greaterThanOrEqualTo(48));
        await tester.tap(tapTarget);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}

