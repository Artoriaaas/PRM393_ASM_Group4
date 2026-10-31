import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/services.dart';

// Platform adapter: only this file knows the camera SDK and OS permissions.
class QrCameraService {
  final controller = MobileScannerController(
    autoStart: false,
    formats: [BarcodeFormat.qrCode],
  );
  final _tokens = StreamController<String>.broadcast();
  final _errors = StreamController<String>.broadcast();
  bool _disposed = false, _armed = true;
  Stream<String> get tokens => _tokens.stream;
  Stream<String> get errors => _errors.stream;
  Future<void> start() async {
    if (_disposed) return;
    _armed = true;
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

  Future<void> stop() async {
    if (!_disposed) {
      try {
        await controller.stop();
      } catch (_) {
        /* Camera may already be stopped by the operating system. */
      }
    }
  }

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

  Widget preview() => MobileScanner(
    controller: controller,
    onDetect: (capture) {
      if (!_armed || _disposed) return;
      final token = capture.barcodes
          .map((b) => b.rawValue)
          .whereType<String>()
          .firstOrNull;
      if (token == null) return;
      _armed = false;
      _tokens.add(token);
      unawaited(stop());
    },
    errorBuilder: (_, error) => const Center(
      child: Text('Chưa mở được camera. Kiểm tra quyền camera trong Cài đặt.'),
    ),
  );
  Future<void> dispose() async {
    _disposed = true;
    await controller.dispose();
    await _tokens.close();
    await _errors.close();
  }
}
