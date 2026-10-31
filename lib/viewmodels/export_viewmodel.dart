import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/event_providers.dart';
import '../app/cloud_providers.dart';
import '../app/report_providers.dart';
import '../models/report_row.dart';
import '../utils/event_formatters.dart' show eventWhen;

final reportRowsProvider = FutureProvider.autoDispose<List<ReportRow>>((
  ref,
) async {
  final registrations = await ref.watch(registrationsProvider.future);
  final rows = <ReportRow>[];
  for (final r in registrations) {
    final e = await ref.watch(eventProvider(r.eventId).future);
    if (e == null) continue;
    rows.add(
      ReportRow(
        title: e.title,
        club: e.clubName,
        when: eventWhen(e),
        location: e.location,
        status: !r.active
            ? 'Đã hủy đăng ký'
            : e.status == 'cancelled'
            ? 'Sự kiện đã hủy'
            : r.checkInAt != null
            ? 'Đã điểm danh'
            : 'Đã đăng ký',
      ),
    );
  }
  return rows;
});

class ExportState {
  const ExportState({
    this.busy = false,
    this.progress = 0,
    this.url,
    this.message,
  });
  final bool busy;
  final double progress;
  final String? url, message;
}

final exportProvider = NotifierProvider<ExportViewModel, ExportState>(
  ExportViewModel.new,
);

class ExportViewModel extends Notifier<ExportState> {
  int _epoch = 0;
  bool _current(String uid, int epoch) =>
      ref.mounted && epoch == _epoch && ref.read(signedInUidProvider) == uid;
  @override
  ExportState build() {
    ref.watch(signedInUidProvider);
    _epoch++;
    return const ExportState();
  }

  Future<void> upload(List<ReportRow> rows) async {
    if (state.busy) return;
    final uid = ref.read(signedInUidProvider);
    if (uid == null) return;
    final epoch = _epoch;
    state = const ExportState(busy: true);
    try {
      final bytes = await ref
          .read(reportServiceProvider)
          .generate(List.unmodifiable(rows));
      unawaited(track(ref, 'export_generate', {'row_count': rows.length}));
      if (!_current(uid, epoch)) return;
      final id =
          'report-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 30)}';
      final url = await ref.read(reportStorageProvider).upload(uid, id, bytes, (
        p,
      ) {
        if (_current(uid, epoch)) state = ExportState(busy: true, progress: p);
      });
      if (!_current(uid, epoch)) return;
      state = ExportState(
        progress: 1,
        url: url,
        message: 'Đã tạo và tải PDF lên Cloud Storage.',
      );
      unawaited(track(ref, 'export_upload', {'byte_count': bytes.length}));
    } catch (_, stack) {
      if (_current(uid, epoch)) {
        state = const ExportState(
          message: 'Chưa hoàn tất xuất/upload. Kiểm tra kết nối, Storage và quyền truy cập rồi thử lại.',
        );
      }
      unawaited(diagnose(ref, 'report_upload_failed', stack));
    }
  }

  Future<void> copy() async {
    final url = state.url;
    if (url != null) await ref.read(reportStorageProvider).copyLink(url);
  }
}
