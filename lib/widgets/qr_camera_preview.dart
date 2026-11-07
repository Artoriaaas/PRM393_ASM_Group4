import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Presentation-only SDK surface. Device operations belong to ScannerViewModel.
class QrCameraPreview extends StatelessWidget {
  const QrCameraPreview({
    super.key,
    required this.handle,
    required this.onDetected,
  });
  final Object handle;
  final ValueChanged<String> onDetected;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Vùng camera quét mã QR',
    child: MobileScanner(
      controller: handle as MobileScannerController,
      onDetect: (capture) {
        final token = capture.barcodes
            .map((b) => b.rawValue)
            .whereType<String>()
            .firstOrNull;
        if (token != null) onDetected(token);
      },
      errorBuilder: (_, error) => const Center(
        child: Text(
          'Chưa mở được camera. Kiểm tra quyền camera trong Cài đặt.',
        ),
      ),
    ),
  );
}
