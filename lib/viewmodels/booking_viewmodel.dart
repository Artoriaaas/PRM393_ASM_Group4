import 'dart:async';

import '../app/cloud_providers.dart';

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/event_providers.dart';
import 'package:eventhub_core/eventhub_core.dart';

class BookingState {
  const BookingState({
    this.busy = false,
    this.pending,
    this.result,
    this.message,
    this.errors = const {},
  });
  final bool busy;
  final Map<String, dynamic>? pending;
  final BookingResult? result;
  final String? message;
  final Map<String, String> errors;
  bool get unresolved => pending != null;
}

final bookingProvider = NotifierProvider<BookingViewModel, BookingState>(
  BookingViewModel.new,
);

class BookingViewModel extends Notifier<BookingState> {
  int _epoch = 0;
  bool _current(String uid, int epoch) =>
      ref.mounted && epoch == _epoch && ref.read(signedInUidProvider) == uid;
  @override
  BookingState build() {
    ref.watch(signedInUidProvider);
    _epoch++;
    return const BookingState();
  }

  String _id() => List.generate(
    24,
    (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  Future<void> restore() async {
    if (state.busy || state.pending != null) return;
    final uid = ref.read(signedInUidProvider);
    if (uid == null) return;
    final epoch = _epoch;
    try {
      final c = await ref.read(pendingBookingStoreProvider).read(uid);
      if (_current(uid, epoch) && c != null) {
        state = BookingState(
          pending: c,
          message: 'Có thao tác chưa rõ kết quả. Kiểm tra trạng thái trước khi gửi tiếp.',
        );
      }
    } catch (_) {
      if (_current(uid, epoch)) {
        state = const BookingState(
          message: 'Không đọc được thao tác đang chờ. Thử lại trước khi gửi.',
        );
      }
    }
  }

  Future<void> submit(String eventId, Participant p) async {
    if (state.busy || state.unresolved) return;
    final errors = p.validate();
    if (errors.isNotEmpty) {
      state = BookingState(errors: errors);
      return;
    }
    await _start({
      'action': 'register',
      'eventId': eventId,
      'participant': p.toJson(),
      'operationId': _id(),
    });
  }

  Future<void> cancel(Registration r) async {
    if (state.busy || state.unresolved) return;
    await _start({
      'action': 'cancel',
      'eventId': r.eventId,
      'generation': r.generation,
      'operationId': _id(),
    });
  }

  Future<void> checkIn(Registration r, String token) async {
    if (state.busy || state.unresolved) return;
    await _start({
      'action': 'checkin',
      'eventId': r.eventId,
      'generation': r.generation,
      'qrToken': token,
      'operationId': _id(),
    });
  }

  Future<void> _start(Map<String, dynamic> c) async {
    final uid = ref.read(signedInUidProvider);
    if (uid == null) return;
    final epoch = _epoch;
    state = const BookingState(busy: true);
    unawaited(track(ref, 'booking_submit', {'action': c['action'] as String}));
    try {
      final existing = await ref.read(pendingBookingStoreProvider).read(uid);
      if (!_current(uid, epoch)) return;
      if (existing != null) {
        state = BookingState(
          pending: existing,
          message: 'Kiểm tra thao tác đang chờ trước.',
        );
        return;
      }
      await ref.read(pendingBookingStoreProvider).write(uid, c);
      if (!_current(uid, epoch)) return;
      state = BookingState(pending: c);
      await _execute(c, uid, epoch);
    } catch (_) {
      if (_current(uid, epoch)) {
        state = BookingState(
          pending: state.pending,
          message: 'Chưa thể lưu thao tác an toàn. Không gửi thêm; hãy kiểm tra trạng thái.',
        );
      }
    }
  }

  Future<void> _accept(
    BookingResult result,
    Map<String, dynamic> c,
    String uid,
    int epoch,
  ) async {
    if (!_current(uid, epoch)) return;
    unawaited(
      track(ref, 'booking_result', {
        'action': c['action'] as String,
        'result': result.status,
      }),
    );
    if (!_current(uid, epoch)) return;
    if (result.terminal) {
      await ref.read(pendingBookingStoreProvider).clear(uid);
      if (!_current(uid, epoch)) return;
      state = BookingState(
        result: result,
        message: result.status == 'rejected'
            ? bookingMessage(result.code)
            : null,
      );
    } else {
      state = BookingState(
        pending: c,
        message:
            'Chưa xác định kết quả. Không gửi yêu cầu mới; hãy kiểm tra lại.',
      );
    }
  }

  Future<void> _execute(Map<String, dynamic> c, String uid, int epoch) async {
    if (!_current(uid, epoch)) return;
    state = BookingState(busy: true, pending: c);
    try {
      await _accept(
        await ref.read(eventServiceProvider).execute(c),
        c,
        uid,
        epoch,
      );
    } catch (_, stack) {
      unawaited(diagnose(ref, 'booking_transport_failed', stack));
      if (_current(uid, epoch)) {
        state = BookingState(
          pending: c,
          message: 'Kết nối gián đoạn hoặc dịch vụ chưa sẵn sàng. Chưa biết kết quả; hãy kiểm tra trạng thái.',
        );
      }
    }
  }

  Future<void> recover() async {
    if (state.busy) return;
    unawaited(
      track(ref, 'booking_recover', {
        'action': state.pending?['action'] as String? ?? 'unknown',
      }),
    );
    await restore();
    final c = state.pending;
    final uid = ref.read(signedInUidProvider);
    if (c == null || uid == null) return;
    final epoch = _epoch;
    state = BookingState(busy: true, pending: c);
    try {
      await _accept(
        await ref
            .read(eventServiceProvider)
            .recover(c['operationId'] as String),
        c,
        uid,
        epoch,
      );
    } catch (_) {
      if (_current(uid, epoch)) {
        state = BookingState(
          pending: c,
          message:
              'Chưa kiểm tra được kết quả. Dữ liệu đã giữ; thử kiểm tra lại.',
        );
      }
    }
  }

  // Replays the exact encrypted command and operation ID. Backend makes this idempotent.
  Future<void> retryPending() async {
    if (state.busy) return;
    final c = state.pending;
    final uid = ref.read(signedInUidProvider);
    if (c != null && uid != null) await _execute(c, uid, _epoch);
  }

  void clearResult() {
    if (!state.busy && !state.unresolved) state = const BookingState();
  }
}
