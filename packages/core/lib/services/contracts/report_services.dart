import 'dart:typed_data';

import '../../models/report_row.dart';

abstract interface class ReportService {
  Future<Uint8List> generate(List<ReportRow> rows);
}

abstract interface class ReportFileService {
  Future<String> save(String uid, String fileId, Uint8List bytes);
  Future<void> share(String path);
  Future<void> remove(String path);
  Future<void> clearUser(String uid);
}

abstract interface class ReportMetadataService {
  Future<void> record(String uid, String fileId, int byteCount, int rowCount);
}
