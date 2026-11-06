import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../contracts/report_services.dart';

/// Unsigned uploads are limited to non-confidential reports. The Cloudinary
/// preset must restrict formats to PDF and cap upload size in the console.
class CloudinaryReportStorage implements ReportStorageService {
  CloudinaryReportStorage({
    required this.cloudName,
    required this.uploadPreset,
    this.client,
    this.timeout = const Duration(seconds: 60),
  });

  final String cloudName;
  final String uploadPreset;
  final http.Client? client;
  final Duration timeout;

  @override
  Future<String> upload(
    String uid,
    String fileId,
    Uint8List bytes,
    void Function(double) onProgress,
  ) async {
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(cloudName) ||
        !RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(uploadPreset)) {
      throw StateError('Chưa cấu hình Cloudinary cloud name/upload preset.');
    }
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw ArgumentError('PDF phải có dung lượng từ 1 byte đến 5 MB.');
    }
    if (bytes.length < 5 ||
        ascii.decode(bytes.sublist(0, 5), allowInvalid: true) != '%PDF-') {
      throw ArgumentError('Nội dung tải lên phải là PDF.');
    }
    final uri = Uri.https('api.cloudinary.com', '/v1_1/$cloudName/raw/upload');
    final request = _ProgressRequest(uri, onProgress)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: '$fileId.pdf'),
      );
    final requestClient = client ?? http.Client();
    try {
      final response = await (() async {
        final streamed = await requestClient.send(request);
        return http.Response.fromStream(streamed);
      })().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError('Cloudinary HTTP ${response.statusCode}');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final link = Uri.tryParse(data['secure_url'] as String? ?? '');
      if (link == null ||
          link.scheme != 'https' ||
          link.host != 'res.cloudinary.com' ||
          link.pathSegments.isEmpty ||
          link.pathSegments.first != cloudName ||
          link.userInfo.isNotEmpty ||
          link.hasPort) {
        throw const FormatException(
          'Cloudinary không trả về liên kết PDF hợp lệ.',
        );
      }
      onProgress(1);
      return link.toString();
    } finally {
      if (client == null) requestClient.close();
    }
  }

  @override
  Future<void> copyLink(String link) =>
      Clipboard.setData(ClipboardData(text: link));
}

/// Transport progress stays below 100% until the server validates the upload.
class _ProgressRequest extends http.MultipartRequest {
  _ProgressRequest(Uri uri, this.onProgress) : super('POST', uri);
  final void Function(double) onProgress;

  @override
  http.ByteStream finalize() {
    final stream = super.finalize();
    final total = contentLength;
    var sent = 0;
    return http.ByteStream(
      stream.map((chunk) {
        sent += chunk.length;
        if (total > 0) onProgress((sent / total).clamp(0.0, 0.99));
        return chunk;
      }),
    );
  }
}
