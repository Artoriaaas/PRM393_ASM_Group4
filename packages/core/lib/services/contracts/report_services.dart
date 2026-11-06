import 'dart:typed_data';

import '../../models/report_row.dart';

abstract interface class ReportService {
  Future<Uint8List> generate(List<ReportRow> rows);
}

abstract interface class ReportStorageService {
  Future<String> upload(
    String uid,
    String fileId,
    Uint8List bytes,
    void Function(double) onProgress,
  );
  Future<void> copyLink(String link);
}
