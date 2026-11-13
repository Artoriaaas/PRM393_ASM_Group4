import 'package:eventhub/models/event.dart';
import 'package:eventhub/viewmodels/event_viewmodels.dart';
import 'package:eventhub/viewmodels/event_data_providers.dart';
import 'package:flutter/material.dart';
import 'package:eventhub/app/app.dart';
import 'package:eventhub/app/router.dart';

import 'support/fake_event_service.dart';

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub/app/auth_redirect.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/models/report_row.dart';
import 'package:eventhub/services/contracts/report_services.dart';
import 'package:eventhub/services/device/local_report_file_service.dart';
import 'package:eventhub/services/report_providers.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:eventhub/viewmodels/export_viewmodel.dart';
import 'package:eventhub_core/services/firebase/firestore_notification_service.dart';

class _Session extends SessionViewModel {
  @override
  AuthState build() => const AuthState.signedIn(uid: 'alice', email: 'a@b.c');
}

class _Report implements ReportService {
  @override
  Future<Uint8List> generate(List<ReportRow> rows) async =>
      Uint8List.fromList('%PDF-test'.codeUnits);
}

class _Files implements ReportFileService {
  int saved = 0, shared = 0;
  @override
  Future<String> save(String uid, String id, Uint8List bytes) async {
    saved++;
    return '/private/$id.pdf';
  }

  @override
  Future<void> share(String path) async {
    shared++;
  }

  @override
  Future<void> remove(String path) async {}
  @override
  Future<void> clearUser(String uid) async {}
}

class _Metadata implements ReportMetadataService {
  bool fail = true;
  final ids = <String>[];
  @override
  Future<void> record(String uid, String id, int bytes, int rows) async {
    ids.add(id);
    if (fail) throw StateError('offline');
  }
}

void main() {
  test('ownerless legacy events explain the approval setup before opening the form', () async {
    final event = Event(
      id: 'e',
      title: 'Event',
      clubName: 'Club',
      location: 'Room',
      startsAt: DateTime(2031),
      endsAt: DateTime(2031, 1, 2),
      deadline: DateTime(2030, 12, 31),
      capacity: 2,
    );
    final c = ProviderContainer(
      overrides: [
        sessionViewModelProvider.overrideWith(_Session.new),
        eventServiceProvider.overrideWithValue(
          FakeEventService(events: [event]),
        ),
      ],
    );
    addTearDown(c.dispose);
    final subscription = c.listen(eventAvailabilityProvider('e'), (_, _) {});
    addTearDown(subscription.close);
    await c.read(eventProvider('e').future);
    expect(c.read(eventAvailabilityProvider('e')), contains('CLB phụ trách'));
  });

  test(
    'logout from role rejection returns to login rather than trapping the user',
    () {
      final target = authRedirect(
        const AuthState.signedOut(),
        Uri.parse('/auth/role-rejected'),
        false,
      );
      expect(Uri.parse(target!).path, '/auth/login');
    },
  );
  testWidgets(
    'live role change closes schedule and blocks private deep links',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          sessionViewModelProvider.overrideWith(_SwitchRole.new),
          eventServiceProvider.overrideWithValue(FakeEventService()),
          pendingBookingStoreProvider.overrideWithValue(MemoryPendingStore()),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const EventHubApp(),
        ),
      );
      await tester.pumpAndSettle();
      container.read(appRouterProvider).go('/schedule');
      await tester.pumpAndSettle();
      expect(find.text('Lịch tham gia'), findsOneWidget);
      (container.read(sessionViewModelProvider.notifier) as _SwitchRole).change(
        'staff',
      );
      await tester.pumpAndSettle();
      expect(find.text('Tài khoản này dành cho web'), findsOneWidget);
      expect(container.read(signedInUidProvider), isNull);
      container.read(appRouterProvider).go('/events/e1/register');
      await tester.pumpAndSettle();
      expect(find.text('Tài khoản này dành cho web'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  test(
    'staff admin and unverified role cannot enter mobile private routes',
    () {
      for (final role in ['staff', 'admin', 'unknown', 'unavailable']) {
        final auth = AuthState.signedIn(uid: 'u', email: 'a@b.c', role: role);
        expect(
          authRedirect(auth, Uri.parse('/schedule'), false),
          '/auth/role-rejected',
        );
        expect(
          authRedirect(auth, Uri.parse('/auth/role-rejected'), false),
          isNull,
        );
      }
      expect(
        authRedirect(
          const AuthState.signedIn(uid: 'u', email: 'a@b.c'),
          Uri.parse('/schedule'),
          false,
        ),
        isNull,
      );
    },
  );
  test('staff identity does not expose user-scoped providers', () {
    final c = ProviderContainer(
      overrides: [sessionViewModelProvider.overrideWith(_StaffSession.new)],
    );
    addTearDown(c.dispose);
    expect(c.read(signedInUidProvider), isNull);
  });
  test('announcements select global and current club/event participation', () {
    final regs = [
      {'status': 'pending', 'clubId': 'c1', 'eventId': 'e1'},
      {'status': 'cancelled', 'clubId': 'c2', 'eventId': 'e2'},
    ];
    expect(announcementApplies({'scope': 'global'}, []), isTrue);
    expect(
      announcementApplies({'scope': 'club', 'clubId': 'c1'}, regs),
      isTrue,
    );
    expect(
      announcementApplies({'scope': 'event', 'eventId': 'e1'}, regs),
      isTrue,
    );
    expect(
      announcementApplies({'scope': 'event', 'eventId': 'e2'}, regs),
      isFalse,
    );
    expect(
      announcementApplies({'scope': 'club', 'clubId': 'c2'}, regs),
      isFalse,
    );
    expect(announcementApplies({'scope': 'invalid'}, regs), isFalse);
  });
  test(
    'local PDF is isolated by UID and shared only on explicit call',
    () async {
      final dir = await Directory.systemTemp.createTemp('eventhub-pdf-');
      addTearDown(() => dir.delete(recursive: true));
      final shared = <String>[];
      final service = LocalReportFileService(
        documentsDirectory: () async => dir,
        shareFile: (p) async {
          shared.add(p);
        },
      );
      final pdf = Uint8List.fromList('%PDF-test'.codeUnits);
      final alice = await service.save('alice', 'report-1-abc', pdf);
      final bob = await service.save('bob', 'report-1-abc', pdf);
      expect(alice, isNot(bob));
      expect(await File(alice).readAsBytes(), pdf);
      expect(shared, isEmpty);
      await service.share(alice);
      expect(shared, [alice]);
      await service.clearUser('alice');
      expect(await File(alice).exists(), isFalse);
      expect(await File(bob).exists(), isTrue);
      await expectLater(
        service.save('alice', '../escape', pdf),
        throwsArgumentError,
      );
      await expectLater(
        service.save('alice', 'report-bad', Uint8List(1)),
        throwsArgumentError,
      );
    },
  );
  test('metadata failure preserves local PDF and retry uses same file id without resharing', () async {
    final files = _Files(), metadata = _Metadata();
    final c = ProviderContainer(
      overrides: [
        sessionViewModelProvider.overrideWith(_Session.new),
        reportServiceProvider.overrideWithValue(_Report()),
        reportFileServiceProvider.overrideWithValue(files),
        reportMetadataProvider.overrideWithValue(metadata),
      ],
    );
    addTearDown(c.dispose);
    final vm = c.read(exportProvider.notifier);
    await vm.generate([
      const ReportRow(
        title: 'Event',
        club: 'Club',
        when: 'Tomorrow',
        location: 'Room',
        status: 'Chờ duyệt',
      ),
    ]);
    expect(c.read(exportProvider).path, isNotNull);
    expect(c.read(exportProvider).recorded, isFalse);
    expect(files.shared, 0);
    metadata.fail = false;
    await vm.recordMetadata();
    expect(metadata.ids.toSet(), hasLength(1));
    expect(files.saved, 1);
    expect(c.read(exportProvider).recorded, isTrue);
    await vm.share();
    expect(files.shared, 1);
  });
}

class _StaffSession extends SessionViewModel {
  @override
  AuthState build() =>
      const AuthState.signedIn(uid: 'staff', email: 's@b.c', role: 'staff');
}

class _SwitchRole extends SessionViewModel {
  @override
  AuthState build() => const AuthState.signedIn(uid: 'u', email: 'a@b.c');
  void change(String role) =>
      state = AuthState.signedIn(uid: 'u', email: 'a@b.c', role: role);
}
