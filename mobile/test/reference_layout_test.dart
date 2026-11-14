import 'dart:io';
import 'dart:ui' as ui;

import 'package:eventhub/models/event.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:eventhub/viewmodels/event_data_providers.dart';
import 'package:eventhub/screens/events/event_detail_screen.dart';
import 'package:eventhub/screens/events/event_list_screen.dart';
import 'package:eventhub/screens/events/registration_form_screen.dart';
import 'package:eventhub/screens/events/registration_detail_screen.dart';
import 'package:eventhub/screens/events/live_schedule_screen.dart';
import 'package:eventhub/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_event_service.dart';

class PreviewSession extends SessionViewModel {
  @override
  AuthState build() =>
      const AuthState.signedIn(uid: 'u', email: 'test@example.com');
}

void main() {
  testWidgets('reference layouts render with device insets', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: 24);
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.reset);
    final fonts = FontLoader(AppTypography.fontFamily);
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      fonts.addFont(
        rootBundle.load(
          'packages/eventhub_core/assets/fonts/BeVietnamPro-$weight.ttf',
        ),
      );
    }
    await fonts.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    final event = Event(
      id: 'e',
      clubId: 'design',
      title: 'Workshop Thiết kế trải nghiệm người dùng',
      clubName: 'CLB Thiết kế FPTU',
      location: 'Phòng 204 · Campus TP.HCM',
      startsAt: DateTime(2027, 1, 24, 14),
      endsAt: DateTime(2027, 1, 24, 16, 30),
      deadline: DateTime(2027, 1, 23, 18),
      capacity: 24,
      activeCount: 1,
      coverKey: 'ux-workshop',
      description: 'Thực hành nghiên cứu nhu cầu, dựng prototype và kiểm thử nhanh cùng người dùng.',
      activities: [
        'Phỏng vấn và tổng hợp insight',
        'Phác thảo luồng trải nghiệm',
      ],
    );
    final registration = Registration(
      id: 'r',
      eventId: 'e',
      status: 'approved',
      generation: 1,
      participant: const Participant(
        name: 'Minh Anh',
        email: 'test@example.com',
        cohort: 'K18',
      ),
      checkInAt: DateTime(2027, 1, 24, 14, 5),
    );
    for (final (name, screen) in <(String, Widget)>[
      ('discover', const EventListScreen()),
      ('form', const RegistrationFormScreen(eventId: 'e')),
      ('detail', const EventDetailScreen(eventId: 'e')),
      ('registration', const RegistrationDetailScreen(id: 'r')),
      ('checkin', const RegistrationDetailScreen(id: 'r', checkInResult: true)),
      ('schedule', const LiveScheduleScreen()),
    ]) {
      final key = GlobalKey();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionViewModelProvider.overrideWith(PreviewSession.new),
            eventServiceProvider.overrideWithValue(
              FakeEventService(events: [event], registrations: [registration]),
            ),
            pendingBookingStoreProvider.overrideWithValue(MemoryPendingStore()),
          ],
          child: RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: EventHubTheme.lightTheme.copyWith(
                scaffoldBackgroundColor: Colors.white,
              ),
              builder: (context, child) => SafeArea(top: false, child: child!),
              home: screen,
            ),
          ),
        ),
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull, reason: name);
      if (const bool.fromEnvironment('CAPTURE_REFERENCE')) {
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final directory = Directory('../evidence/ui-reference/local-preview');
          await directory.create(recursive: true);
          await File('${directory.path}/$name.png')
              .writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.pumpWidget(const SizedBox());
    }
  });
}
