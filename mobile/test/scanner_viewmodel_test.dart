import 'dart:async';

import 'package:eventhub/models/event.dart';
import 'package:eventhub/services/contracts/qr_camera.dart';
import 'package:eventhub/services/qr_camera_provider.dart';
import 'package:eventhub/viewmodels/event_data_providers.dart';
import 'package:eventhub/viewmodels/scanner_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_event_service.dart';

class Camera implements QrCamera {
  int starts = 0, stops = 0;
  final failures = StreamController<String>.broadcast(sync: true);
  @override
  Object get previewHandle => this;
  @override
  Stream<String> get errors => failures.stream;
  @override
  Future<void> start() async {
    starts++;
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> openSettings() async {}
  @override
  Future<void> dispose() => failures.close();
}

void main() {
  test(
    'background while registration is loading never starts camera',
    () async {
      final camera = Camera();
      final registration = Completer<Registration?>();
      final c = ProviderContainer(
        overrides: [
          qrCameraProvider.overrideWithValue(camera),
          pendingBookingStoreProvider.overrideWithValue(MemoryPendingStore()),
          registrationProvider('r')
              .overrideWith((ref) => Stream.fromFuture(registration.future)),
        ],
      );
      final sub = c.listen(scannerProvider('r'), (_, _) {});
      final vm = c.read(scannerProvider('r').notifier);
      final opening = vm.resume();
      await vm.pause();
      registration.complete(null);
      await opening;
      expect(camera.starts, 0);
      expect(camera.stops, 1);
      sub.close();
      c.dispose();
      await camera.dispose();
    },
  );

  test('camera failure is explicit ViewModel error state', () async {
    final camera = Camera();
    final c = ProviderContainer(
      overrides: [qrCameraProvider.overrideWithValue(camera)],
    );
    final sub = c.listen(scannerProvider('r'), (_, _) {});
    camera.failures.add('Camera permission denied');
    expect(c.read(scannerProvider('r')).phase, ScannerPhase.error);
    expect(c.read(scannerProvider('r')).message, 'Camera permission denied');
    sub.close();
    c.dispose();
    await camera.dispose();
  });
}
