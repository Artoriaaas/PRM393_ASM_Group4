import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/event_data_providers.dart';
import '../viewmodels/cloud_state.dart';
import '../services/report_providers.dart';
import '../models/report_row.dart';
import '../models/event.dart';
import '../utils/event_formatters.dart' show eventWhen;

final reportRowsProvider = FutureProvider.autoDispose<List<ReportRow>>((
  ref,
) async {
  final registrations = await ref.watch(registrationsProvider.future);
  final rows = <ReportRow>[];
  for (final r in currentRegistrations(
    registrations,
    uid: ref.watch(signedInUidProvider),
  )) {
    final e = await ref.watch(eventProvider(r.eventId).future);
    if (e == null) {
      throw StateError('Registration event unavailable');
    }
    rows.add(
      ReportRow(
        title: e.title,
        club: e.clubName,
        when: eventWhen(e),
        location: e.location,
        status: e.status == 'cancelled' ? 'Sự kiện đã hủy' : r.statusLabel,
      ),
    );
  }
  return rows;
});

class ExportState {
  const ExportState({
    this.busy = false,
    this.path,
    this.fileId,
    this.byteCount = 0,
    this.rowCount = 0,
    this.recorded = false,
    this.message,
  });
  final bool busy, recorded;
  final String? path, fileId, message;
  final int byteCount, rowCount;
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

  Future<void> generate(List<ReportRow> rows) async {
    if (state.busy || rows.isEmpty) return;
    final uid = ref.read(signedInUidProvider);
    if (uid == null) return;
    final epoch = _epoch;
    final files = ref.read(reportFileServiceProvider);
    state = const ExportState(busy: true);
    String? path;
    try {
      final bytes = await ref
          .read(reportServiceProvider)
          .generate(List.unmodifiable(rows));
      if (!_current(uid, epoch)) return;
      final id =
          'report-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 30)}';
      path = await files.save(uid, id, bytes);
      if (!_current(uid, epoch)) {
        await files.remove(path);
        return;
      }
      state = ExportState(
        path: path,
        fileId: id,
        byteCount: bytes.length,
        rowCount: rows.length,
      );
      unawaited(track(ref, 'export_generate', {'row_count': rows.length}));
      await recordMetadata();
    } catch (_, stack) {
      if (_current(uid, epoch)) {
        state = ExportState(
          path: path,
          message:
              'Chưa tạo được PDF. Kiểm tra dung lượng thiết bị rồi thử lại.',
        );
      }
      unawaited(diagnose(ref, 'report_generate_failed', stack));
    }
  }

  Future<void> recordMetadata() async {
    if (state.busy || state.path == null || state.fileId == null) return;
    final uid = ref.read(signedInUidProvider);
    if (uid == null) return;
    final epoch = _epoch, previous = state;
    state = ExportState(
      busy: true,
      path: previous.path,
      fileId: previous.fileId,
      byteCount: previous.byteCount,
      rowCount: previous.rowCount,
    );
    try {
      await ref
          .read(reportMetadataProvider)
          .record(uid, previous.fileId!, previous.byteCount, previous.rowCount);
      if (_current(uid, epoch)) {
        state = ExportState(
          path: previous.path,
          fileId: previous.fileId,
          byteCount: previous.byteCount,
          rowCount: previous.rowCount,
          recorded: true,
          message:
              'Đã lưu PDF trên thiết bị và thông tin báo cáo trên Firestore.',
        );
      }
    } catch (_) {
      if (_current(uid, epoch)) {
        state = ExportState(
          path: previous.path,
          fileId: previous.fileId,
          byteCount: previous.byteCount,
          rowCount: previous.rowCount,
          message: 'PDF đã lưu trên thiết bị. Chưa lưu được metadata; kiểm tra mạng rồi thử lại.',
        );
      }
    }
  }

  Future<void> share() async {
    if (state.busy || state.path == null) return;
    final uid = ref.read(signedInUidProvider);
    if (uid == null) return;
    final epoch = _epoch, previous = state;
    state = ExportState(
      busy: true,
      path: previous.path,
      fileId: previous.fileId,
      recorded: previous.recorded,
      byteCount: previous.byteCount,
      rowCount: previous.rowCount,
    );
    try {
      await ref.read(reportFileServiceProvider).share(previous.path!);
      if (_current(uid, epoch)) {
        state = previous;
        unawaited(track(ref, 'export_share', {'row_count': previous.rowCount}));
      }
    } catch (_) {
      if (_current(uid, epoch)) {
        state = ExportState(
          path: previous.path,
          fileId: previous.fileId,
          recorded: previous.recorded,
          byteCount: previous.byteCount,
          rowCount: previous.rowCount,
          message: 'Chưa chia sẻ được PDF. Hãy thử lại.',
        );
      }
    }
  }
}
