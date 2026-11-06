// Explicit UI evidence capture tool. Fixtures are NOT cloud validation evidence.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub/app/app.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:eventhub/viewmodels/event_data_providers.dart';
import 'package:eventhub/app/router.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/models/event.dart';

import '../test/support/fake_event_service.dart';

class _Session extends SessionViewModel {
  @override
  AuthState build() => const AuthState.signedIn(
    uid: 'evidence-fixture',
    email: 'minhanh@example.com',
    displayName: 'Minh Anh',
  );
}

void main() {
  testWidgets('capture production widgets with explicit UI-only fixtures', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final fonts = FontLoader('Be Vietnam Pro');
      for (final name in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
        fonts.addFont(rootBundle.load('assets/fonts/BeVietnamPro-$name.ttf'));
      }
      await fonts.load();
    });
    final e = Event(
      id: 'evidence',
      title: 'Workshop Thiết kế trải nghiệm người dùng',
      clubName: 'CLB Thiết kế FPTU',
      location: 'Phòng 204 · Campus TP.HCM',
      startsAt: DateTime.utc(2026, 10, 24, 7),
      endsAt: DateTime.utc(2026, 10, 24, 9, 30),
      deadline: DateTime.utc(2026, 10, 23, 11),
      capacity: 24,
      activeCount: 0,
      coverKey: 'ux-workshop',
    );
    final store = MemoryPendingStore();
    store.entries['evidence-fixture'] = {
      'operationId': 'evidence-not-sent-to-server',
      'eventId': 'evidence',
      'action': 'register',
      'participant': const Participant(
        name: 'Minh Anh',
        email: 'minhanh@example.com',
        cohort: 'K18',
      ).toJson(),
    };
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: ProviderScope(
          overrides: [
            sessionViewModelProvider.overrideWith(_Session.new),
            eventServiceProvider.overrideWithValue(
              FakeEventService(events: [e]),
            ),
            pendingBookingStoreProvider.overrideWithValue(store),
          ],
          child: const EventHubApp(),
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    final container = ProviderScope.containerOf(
      tester.element(find.byType(EventHubApp)),
    );
    Future<void> capture(String route, String path) async {
      container.read(appRouterProvider).go(route);
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(tester.takeException(), isNull);
      await tester.runAsync(() async {
        final render =
            boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        final image = await render.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(path);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }

    await capture(
      '/account',
      'evidence/design-changes/D03-firebase-tools/after-account-ui-fixture.png',
    );
    await capture(
      '/account/firebase-demo',
      'evidence/design-changes/D03-firebase-tools/after-tools-ui-fixture.png',
    );
    await capture(
      '/events/evidence/register',
      'evidence/design-changes/D08-network-recovery/after-ui-fixture.png',
    );
  });
}
