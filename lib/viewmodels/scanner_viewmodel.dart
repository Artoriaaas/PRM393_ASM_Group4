import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/qr_camera_provider.dart';
import 'booking_viewmodel.dart';
import 'event_data_providers.dart';

enum ScannerPhase { loading, ready, error, completed }

class ScannerState {
  const ScannerState(
    this.previewHandle, {
    this.phase = ScannerPhase.loading,
    this.message,
  });
  final Object previewHandle;
  final ScannerPhase phase;
  final String? message;
}

final scannerProvider = NotifierProvider.autoDispose
    .family<ScannerViewModel, ScannerState, String>(ScannerViewModel.new);

class ScannerViewModel extends Notifier<ScannerState> {
  ScannerViewModel(this.registrationId);
  final String registrationId;
  bool _foreground = true, _armed = false;

  @override
  ScannerState build() {
    final camera = ref.watch(qrCameraProvider);
    final errors = camera.errors.listen((message) {
      if (ref.mounted) {
        state = ScannerState(
          camera.previewHandle,
          phase: ScannerPhase.error,
          message: message,
        );
      }
    });
    ref.onDispose(() => unawaited(errors.cancel()));
    return ScannerState(camera.previewHandle);
  }

  Future<void> initialize() async {
    await ref.read(bookingProvider.notifier).restore();
    if (!ref.mounted) return;
    await resume();
  }

  Future<void> resume() async {
    _foreground = true;
    try {
      final r = await ref.read(registrationProvider(registrationId).future);
      if (!ref.mounted || !_foreground) return;
      final booking = ref.read(bookingProvider);
      if (r?.active != true || booking.busy || booking.unresolved) return;
      if (r!.checkInAt != null) {
        state = ScannerState(
          state.previewHandle,
          phase: ScannerPhase.completed,
        );
        return;
      }
      _armed = true;
      state = ScannerState(state.previewHandle, phase: ScannerPhase.ready);
      await ref.read(qrCameraProvider).start();
    } catch (_) {
      if (ref.mounted) {
        state = ScannerState(
          state.previewHandle,
          phase: ScannerPhase.error,
          message: 'Chưa tải được đăng ký. Thử tải lại trước khi quét.',
        );
      }
    }
  }

  Future<void> pause() async {
    _foreground = false;
    _armed = false;
    await ref.read(qrCameraProvider).stop();
  }

  Future<void> detected(String token) async {
    if (!_armed || !_foreground) return;
    _armed = false;
    await ref.read(qrCameraProvider).stop();
    if (!ref.mounted) return;
    final r = ref.read(registrationProvider(registrationId)).asData?.value;
    if (r != null) await ref.read(bookingProvider.notifier).checkIn(r, token);
  }

  Future<void> retry() async {
    ref.read(bookingProvider.notifier).clearResult();
    await resume();
  }

  Future<void> openSettings() => ref.read(qrCameraProvider).openSettings();
}
