import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'contracts/report_services.dart';
import 'report/pdf_report_service.dart';
import 'device/local_report_file_service.dart';

import 'package:eventhub_core/services/firebase/firestore_report_metadata_service.dart';

final reportServiceProvider = Provider<ReportService>(
  (ref) => PdfReportService(),
);
final reportFileServiceProvider = Provider<ReportFileService>(
  (ref) => LocalReportFileService(),
);
final reportMetadataProvider = Provider<ReportMetadataService>(
  (ref) => FirestoreReportMetadataService(FirebaseFirestore.instance),
);
