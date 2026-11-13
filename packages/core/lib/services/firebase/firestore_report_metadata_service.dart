import 'package:cloud_firestore/cloud_firestore.dart';

import '../contracts/report_services.dart';

class FirestoreReportMetadataService implements ReportMetadataService {
  FirestoreReportMetadataService(this.db);
  final FirebaseFirestore db;
  @override
  Future<void> record(
    String uid,
    String fileId,
    int byteCount,
    int rowCount,
  ) async {
    final ref = db.doc('users/$uid/reports/$fileId');
    await db.runTransaction((tx) async {
      if ((await tx.get(ref)).exists) return;
      tx.set(ref, {
        'fileName': '$fileId.pdf',
        'mimeType': 'application/pdf',
        'byteCount': byteCount,
        'rowCount': rowCount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
