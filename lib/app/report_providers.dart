import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/contracts/report_services.dart';
import '../services/report/pdf_report_service.dart';
import '../services/firebase/firebase_report_storage.dart';
import 'providers.dart';

final reportServiceProvider = Provider<ReportService>(
  (ref) => PdfReportService(),
);
final reportStorageProvider = Provider<ReportStorageService>((ref) {
  if (!ref.watch(firebaseReadyProvider)) {
    throw StateError('Firebase not configured');
  }
  return FirebaseReportStorage(FirebaseStorage.instance);
});
