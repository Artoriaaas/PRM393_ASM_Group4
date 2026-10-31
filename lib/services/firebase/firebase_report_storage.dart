
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

import '../contracts/report_services.dart';

class FirebaseReportStorage implements ReportStorageService {
  FirebaseReportStorage(this.storage);
  final FirebaseStorage storage;
  @override
  Future<String> upload(
    String uid,
    String fileId,
    Uint8List bytes,
    void Function(double) onProgress,
  ) async {
    final task = storage
        .ref('reports/$uid/$fileId.pdf')
        .putData(bytes, SettableMetadata(contentType: 'application/pdf'));
    final subscription = task.snapshotEvents.listen(
      (s) {
        if (s.totalBytes > 0) onProgress(s.bytesTransferred / s.totalBytes);
      },
      onError: (_) {
        /* The upload task below carries the typed failure. */
      },
    );
    try {
      final snapshot = await task;
      return await snapshot.ref.getDownloadURL();
    } finally {
      await subscription.cancel();
    }
  }

  @override
  Future<void> copyLink(String link) =>
      Clipboard.setData(ClipboardData(text: link));
}
