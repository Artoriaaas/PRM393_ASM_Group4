import 'dart:async';

import '../contracts/qr_camera.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';

// Platform adapter: only this file knows the camera SDK and OS permissions.
class QrCameraService implements QrCamera {
  final controller = MobileScannerController(
    autoStart: false,
    formats: [BarcodeFormat.qrCode],
  );
  final _errors = StreamController<String>.broadcast();
  bool _disposed = false;
  @override
  Object get previewHandle => controller;
  @override
  Stream<String> get errors => _errors.stream;
  @override
  Future<void> start() async {
    if (_disposed) return;
    try {
      await controller.start();
    } catch (_) {
      if (!_disposed) {
        _errors.add(
          'Không mở được camera. Cho phép quyền camera hoặc mở Cài đặt rồi quay lại.',
        );
      }
    }
  }

  @override
  Future<void> stop() async {
    if (!_disposed) {
      try {
        await controller.stop();
      } catch (_) {
        /* Camera may already be stopped by the operating system. */
      }
    }
  }

  @override
  Future<void> openSettings() async {
    try {
      await const MethodChannel('eventhub/device')
          .invokeMethod<void>('openAppSettings');
    } catch (_) {
      if (!_disposed) {
        _errors.add(
          'Chưa mở được Cài đặt. Mở Cài đặt Android và cho phép camera cho EventHub.',
        );
      }
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await controller.dispose();
    await _errors.close();
  }
}
