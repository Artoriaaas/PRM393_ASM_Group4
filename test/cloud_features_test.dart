import 'package:eventhub/utils/push_destination.dart';

import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:eventhub/app/providers.dart';
import 'package:eventhub/app/cloud_providers.dart';
import 'package:eventhub/app/report_providers.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/models/report_row.dart';
import 'package:eventhub/models/cloud_settings.dart';
import 'package:eventhub/services/contracts/cloud_services.dart';
import 'package:eventhub/services/contracts/report_services.dart';
import 'package:eventhub/services/report/pdf_report_service.dart';
import 'package:eventhub/viewmodels/cloud_tools_viewmodel.dart';
import 'package:eventhub/viewmodels/export_viewmodel.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Session extends SessionViewModel {
  @override
  AuthState build() => const AuthState.signedIn(uid: 'u', email: 'a@b.c');
  void change(String uid) =>
      state = AuthState.signedIn(uid: uid, email: 'a@b.c');
}

class _Cloud extends UnavailableCloudServices {
  bool fail = false;
  final events = <String>[];
  @override
  Future<CloudSettings> fetchSettings() async {
    if (fail) throw StateError('offline');
    return const CloudSettings(
      recommendationLimit: 3,
      showRecommendations: false,
    );
  }

  @override
  Future<void> event(String name, Map<String, Object> p) async {
    events.add(name);
  }
}

class _Report implements ReportService {
  @override
  Future<Uint8List> generate(List<ReportRow> rows) async =>
      Uint8List.fromList([37, 80, 68, 70]);
}

class _Storage implements ReportStorageService {
  final completed = Completer<String>();
  int count = 0;
  @override
  Future<String> upload(
    String uid,
    String id,
    Uint8List bytes,
    void Function(double) onProgress,
  ) {
    count++;
    onProgress(.5);
    return completed.future;
  }

  @override
  Future<void> copyLink(String link) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const row = ReportRow(
    title: 'Thiết kế trải nghiệm người dùng',
    club: 'CLB Thiết kế FPTU',
    when: '14:00–16:30 · 24/10/2026',
    location: 'Phòng 204',
    status: 'Đã đăng ký',
  );
  test('Remote Config keeps last good values after a fetch failure', () async {
    final service = _Cloud();
    final c = ProviderContainer(
      overrides: [
        sessionViewModelProvider.overrideWith(_Session.new),
        cloudServicesProvider.overrideWithValue(service),
      ],
    );
    addTearDown(c.dispose);
    final vm = c.read(cloudToolsProvider.notifier);
    await vm.refresh();
    expect(c.read(cloudToolsProvider).settings.recommendationLimit, 3);
    service.fail = true;
    await vm.refresh();
    expect(c.read(cloudToolsProvider).settings.recommendationLimit, 3);
    expect(c.read(cloudToolsProvider).message, contains('Giữ giá trị'));
  });
  test(
    'export blocks duplicate taps and drops URL after UID changes',
    () async {
      final storage = _Storage();
      final c = ProviderContainer(
        overrides: [
          sessionViewModelProvider.overrideWith(_Session.new),
          reportServiceProvider.overrideWithValue(_Report()),
          reportStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(c.dispose);
      final vm = c.read(exportProvider.notifier);
      final pending = vm.upload([row]);
      await Future<void>.delayed(Duration.zero);
      await vm.upload([row]);
      expect(storage.count, 1);
      (c.read(sessionViewModelProvider.notifier) as _Session).change('another');
      expect(c.read(exportProvider).url, isNull);
      storage.completed.complete('https://example.com/private.pdf');
      await pending;
      expect(c.read(exportProvider).url, isNull);
    },
  );
  test(
    'PDF uses local Vietnamese fonts and generates multiple pages',
    () async {
      final bytes = await PdfReportService().generate(List.filled(70, row));
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
      expect(bytes.length, greaterThan(10000));
      final file = File('build/pdf-test/report.pdf');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
    },
  );

  test(
    'push empty registration ID falls back to event and ignores another UID',
    () {
      expect(
        pushDestination(
          {'uid': 'u', 'registrationId': '', 'eventId': 'e'},
          'u',
          opened: true,
        )?.path,
        '/events/e',
      );
      expect(
        pushDestination({'uid': 'another', 'eventId': 'e'}, 'u', opened: true),
        isNull,
      );
      expect(
        pushDestination({'eventId': 'https://evil'}, 'u', opened: true)?.path,
        '/notifications',
      );
    },
  );
}
