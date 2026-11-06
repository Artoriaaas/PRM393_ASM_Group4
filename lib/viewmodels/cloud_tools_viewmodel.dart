import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/cloud_state.dart';
import '../viewmodels/event_data_providers.dart';
import '../models/cloud_settings.dart';

class CloudToolsState {
  const CloudToolsState({
    this.busy = false,
    this.settings = const CloudSettings(),
    this.message,
  });
  final bool busy;
  final CloudSettings settings;
  final String? message;
}

final cloudToolsProvider =
    NotifierProvider<CloudToolsViewModel, CloudToolsState>(
      CloudToolsViewModel.new,
    );

class CloudToolsViewModel extends Notifier<CloudToolsState> {
  int _epoch = 0;
  @override
  CloudToolsState build() {
    ref.watch(signedInUidProvider);
    _epoch++;
    return const CloudToolsState();
  }

  Future<void> refresh() async {
    if (state.busy) return;
    final epoch = _epoch;
    final uid = ref.read(signedInUidProvider);
    final previous = state.settings;
    state = CloudToolsState(busy: true, settings: previous);
    try {
      final settings = await ref.read(cloudServicesProvider).fetchSettings();
      if (ref.mounted && epoch == _epoch) {
        state = CloudToolsState(
          settings: settings,
          message: 'Đã nhận và kích hoạt cấu hình.',
        );
      }
      if (ref.mounted &&
          epoch == _epoch &&
          ref.read(signedInUidProvider) == uid) {
        await track(ref, 'remote_config_fetch', {'result': 'success'});
      }
    } catch (_) {
      if (ref.mounted && epoch == _epoch) {
        state = CloudToolsState(
          settings: previous,
          message: 'Chưa lấy được cấu hình mới. Giữ giá trị đang dùng.',
        );
      }
      if (ref.mounted &&
          epoch == _epoch &&
          ref.read(signedInUidProvider) == uid) {
        await track(ref, 'remote_config_fetch', {'result': 'error'});
      }
    }
  }

  Future<void> enablePush() async {
    if (state.busy) return;
    final uid = ref.read(signedInUidProvider);
    if (uid == null) return;
    final settings = state.settings;
    state = CloudToolsState(busy: true, settings: settings);
    try {
      final message = await ref.read(cloudServicesProvider).enablePush(uid);
      if (ref.mounted && ref.read(signedInUidProvider) == uid) {
        state = CloudToolsState(settings: settings, message: message);
      }
    } catch (_) {
      if (ref.mounted && ref.read(signedInUidProvider) == uid) {
        state = CloudToolsState(
          settings: settings,
          message:
              'Chưa đăng ký thông báo được. Kiểm tra quyền/kết nối và thử lại.',
        );
      }
    }
  }

  Future<void> nonFatal() async {
    final epoch = _epoch;
    final uid = ref.read(signedInUidProvider);
    try {
      await ref
          .read(cloudServicesProvider)
          .report('manual_non_fatal_test', StackTrace.current);
      if (ref.mounted &&
          epoch == _epoch &&
          ref.read(signedInUidProvider) == uid) {
        state = CloudToolsState(
          settings: state.settings,
          message: 'Đã gọi ghi lỗi non-fatal. Cần xác minh trên dashboard.',
        );
      }
    } catch (_) {
      if (ref.mounted &&
          epoch == _epoch &&
          ref.read(signedInUidProvider) == uid) {
        state = CloudToolsState(
          settings: state.settings,
          message: 'Chưa gửi được lỗi thử nghiệm.',
        );
      }
    }
  }

  void crash() => ref.read(cloudServicesProvider).crash();
}
