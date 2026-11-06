import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eventhub_core/eventhub_core.dart';
import '../services/report/pdf_report_service.dart';
import '../services/cloudinary/cloudinary_report_storage.dart';

final reportServiceProvider = Provider<ReportService>(
  (ref) => PdfReportService(),
);
final reportStorageProvider = Provider<ReportStorageService>((ref) {
  return CloudinaryReportStorage(
    cloudName: const String.fromEnvironment('CLOUDINARY_CLOUD_NAME'),
    uploadPreset: const String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET'),
  );
});
