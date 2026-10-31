import 'package:eventhub/app/providers.dart';
import 'package:eventhub/app/event_providers.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/models/event.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:eventhub/screens/events/event_list_screen.dart';
import 'package:eventhub/screens/events/event_detail_screen.dart';
import 'package:eventhub/screens/events/registration_form_screen.dart';
import 'package:eventhub/screens/events/registration_detail_screen.dart';
import 'package:eventhub/screens/events/live_schedule_screen.dart';
import 'package:eventhub/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_event_service.dart';

class _Session extends SessionViewModel {
  @override
  AuthState build() => const AuthState.signedIn(
    uid: 'u',
    email: 'private@example.com',
    displayName: 'Nguyễn Minh Anh',
  );
}

void main() {
  final e = Event(
    id: 'e1',
    title: 'Workshop Thiết kế trải nghiệm người dùng',
    clubName: 'CLB Thiết kế FPTU',
    location: 'Phòng 204 · Campus TP.HCM',
    startsAt: DateTime.utc(2027, 1, 1, 7),
    endsAt: DateTime.utc(2027, 1, 1, 9, 30),
    deadline: DateTime.utc(2026, 12, 31, 11),
    capacity: 24,
    activeCount: 1,
    coverKey: 'ux-workshop',
    activities: ['Phỏng vấn và tổng hợp insight'],
  );
  final r = Registration(
    id: 'r1',
    eventId: 'e1',
    status: 'active',
    generation: 1,
    participant: const Participant(
      name: 'Nguyễn Minh Anh',
      email: 'private@example.com',
      cohort: 'K18',
      phone: '0900000000',
    ),
    checkInAt: DateTime.utc(2027, 1, 1, 7, 5),
  );
  Future<void> show(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionViewModelProvider.overrideWith(_Session.new),
          eventServiceProvider.overrideWithValue(
            FakeEventService(events: [e], registrations: [r]),
          ),
          pendingBookingStoreProvider.overrideWithValue(MemoryPendingStore()),
        ],
        child: MaterialApp(
          theme: EventHubTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: screen,
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  for (final width in [360.0, 412.0]) {
    testWidgets('live F1/F2/A12 layouts at $width dp and 150% text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final screen in [
        const EventListScreen(),
        const EventListScreen(search: true),
        const EventDetailScreen(eventId: 'e1'),
        const RegistrationFormScreen(eventId: 'e1'),
        const RegistrationDetailScreen(id: 'r1', success: true),
        const RegistrationDetailScreen(id: 'r1'),
        const LiveScheduleScreen(),
        const RegistrationDetailScreen(id: 'r1', checkInResult: true),
      ]) {
        await show(tester, screen);
        expect(
          tester.takeException(),
          isNull,
          reason: screen.runtimeType.toString(),
        );
        if (screen is RegistrationDetailScreen && screen.checkInResult) {
          expect(find.text('private@example.com'), findsNothing);
          expect(find.textContaining('0900000000'), findsNothing);
        }
        final list = find.byType(Scrollable);
        expect(list, findsWidgets, reason: screen.runtimeType.toString());
        await tester.drag(list.first, const Offset(0, -650));
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          tester.takeException(),
          isNull,
          reason: 'Scrolled ${screen.runtimeType}',
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      }
    });
  }
  testWidgets('guest registration removes required cohort field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await show(tester, const RegistrationFormScreen(eventId: 'e1'));
    final chip = find.ancestor(
      of: find.text('Khách ngoài trường'),
      matching: find.byType(ChoiceChip),
    );
    await Scrollable.ensureVisible(tester.element(chip), alignment: 0.3);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pump();
    expect(find.text('Khóa K'), findsNothing);
    expect(find.text('Trường / tổ chức (tùy chọn)'), findsOneWidget);
  });
}
