import 'dart:typed_data';

import 'package:eventhub/services/cloudinary/cloudinary_report_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final pdf = Uint8List.fromList('%PDF-1.4\n%%EOF'.codeUnits);

  test(
    'rejects another cloud even when expected name appears later in URL',
    () async {
      final storage = CloudinaryReportStorage(
        cloudName: 'expected',
        uploadPreset: 'preset',
        client: MockClient(
          (_) async => http.Response(
            '{"secure_url":"https://res.cloudinary.com/other/raw/upload/expected/file.pdf"}',
            200,
          ),
        ),
      );
      await expectLater(
        storage.upload('uid', 'file', pdf, (_) {}),
        throwsFormatException,
      );
    },
  );

  test(
    'reports transfer progress but not completion for rejected uploads',
    () async {
      final values = <double>[];
      final storage = CloudinaryReportStorage(
        cloudName: 'expected',
        uploadPreset: 'preset',
        client: MockClient(
          (_) async => http.Response('private server details', 400),
        ),
      );
      await expectLater(
        storage.upload('uid', 'file', pdf, values.add),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            'Cloudinary HTTP 400',
          ),
        ),
      );
      expect(values, isNotEmpty);
      expect(values.every((p) => p < 1), isTrue);
    },
  );

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
