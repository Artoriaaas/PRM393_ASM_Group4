import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contracts/qr_camera.dart';
import 'device/qr_camera_service.dart';

final qrCameraProvider = Provider.autoDispose<QrCamera>((ref) {
  final camera = QrCameraService();
  ref.onDispose(() => unawaited(camera.dispose()));
  return camera;
});
