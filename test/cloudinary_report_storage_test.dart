import 'dart:typed_data';

import 'package:eventhub/services/cloudinary/cloudinary_report_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final pdf = Uint8List.fromList('%PDF-1.4\n%%EOF'.codeUnits);

  test('uploads a PDF through a restricted unsigned preset', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(
        request.url.toString(),
        'https://api.cloudinary.com/v1_1/eventhubgroup4/raw/upload',
      );
      expect(request.body, contains('lab3_pdf_only'));
      expect(request.body, contains('report-1.pdf'));
      return http.Response(
        '{"secure_url":"https://res.cloudinary.com/eventhubgroup4/raw/upload/v1/report-1.pdf"}',
        200,
      );
    });
    final storage = CloudinaryReportStorage(
      cloudName: 'eventhubgroup4',
      uploadPreset: 'lab3_pdf_only',
      client: client,
    );
    var progress = 0.0;
    expect(
      await storage.upload('uid', 'report-1', pdf, (value) => progress = value),
      contains('report-1.pdf'),
    );
    expect(progress, 1);
    client.close();
  });

  test('rejects unconfigured uploads and non-PDF content', () async {
    final storage = CloudinaryReportStorage(
      cloudName: '',
      uploadPreset: '',
      client: MockClient((_) async => throw StateError('should not send')),
    );
    await expectLater(storage.upload('u', 'f', pdf, (_) {}), throwsStateError);
    final configured = CloudinaryReportStorage(
      cloudName: 'eventhubgroup4',
      uploadPreset: 'lab3_pdf_only',
      client: MockClient((_) async => throw StateError('should not send')),
    );
    await expectLater(
      configured.upload('u', 'f', Uint8List.fromList([1, 2, 3]), (_) {}),
      throwsArgumentError,
    );
  });
}
