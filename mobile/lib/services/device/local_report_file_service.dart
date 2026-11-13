import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../contracts/report_services.dart';

class LocalReportFileService implements ReportFileService {
  LocalReportFileService({
    Future<Directory> Function()? documentsDirectory,
    this.shareFile,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory;
  final Future<Directory> Function() _documentsDirectory;
  final Future<void> Function(String)? shareFile;
  Future<Directory> _folder(String uid) async {
    final base = await _documentsDirectory();
    return Directory(
      '${base.path}/reports/${sha256.convert(utf8.encode(uid))}',
    );
  }

  @override
  Future<String> save(String uid, String fileId, Uint8List bytes) async {
    if (!RegExp(r'^report-[a-z0-9-]+$').hasMatch(fileId) ||
        bytes.length < 5 ||
        String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw ArgumentError('Invalid PDF');
    }
    final folder = await _folder(uid);
    await folder.create(recursive: true);
    final file = File('${folder.path}/$fileId.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<void> share(String path) async {
    if (!await File(path).exists()) throw StateError('File no longer exists');
    final share = shareFile;
    if (share != null) {
      await share(path);
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'application/pdf')],
        title: 'EventHub — Lịch tham gia',
      ),
    );
  }

  @override
  Future<void> remove(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> clearUser(String uid) async {
    final folder = await _folder(uid);
    if (await folder.exists()) await folder.delete(recursive: true);
  }
}
