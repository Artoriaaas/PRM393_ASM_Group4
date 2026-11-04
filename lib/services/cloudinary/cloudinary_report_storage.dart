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
    http.Client? client,
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final String cloudName;
  final String uploadPreset;
  final http.Client _client;
  final bool _ownsClient;

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
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: '$fileId.pdf'),
      );
    try {
      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(
          'Cloudinary HTTP ${response.statusCode}: ${response.body}',
        );
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final link = Uri.tryParse(data['secure_url'] as String? ?? '');
      if (link == null ||
          link.scheme != 'https' ||
          link.host != 'res.cloudinary.com' ||
          !link.pathSegments.contains(cloudName)) {
        throw const FormatException(
          'Cloudinary không trả về liên kết PDF hợp lệ.',
        );
      }
      onProgress(1);
      return link.toString();
    } finally {
      if (_ownsClient) _client.close();
    }
  }

  @override
  Future<void> copyLink(String link) =>
      Clipboard.setData(ClipboardData(text: link));
}
