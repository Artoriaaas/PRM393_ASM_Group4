
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:eventhub_core/eventhub_core.dart';

class PdfReportService implements ReportService {
  @override
  Future<Uint8List> generate(List<ReportRow> rows) async {
    final regular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'),
    );
    final bold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/BeVietnamPro-Bold.ttf'),
    );
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (_) => [
          pw.Header(level: 0, child: pw.Text('EventHub — Lịch tham gia')),
          pw.Text(
            'Báo cáo đăng ký của tài khoản hiện tại. Tổng cộng: ${rows.length} sự kiện.',
          ),
          pw.SizedBox(height: 16),
          for (final row in rows)
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    row.title,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(row.club),
                  pw.Text(row.when),
                  pw.Text(row.location),
                  pw.Text(row.status),
                ],
              ),
            ),
        ],
      ),
    );
    return doc.save();
  }
}
