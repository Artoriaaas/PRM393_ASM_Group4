import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/crash_reports_service.dart';
import 'web_auth_viewmodel.dart';

final crashReportsServiceProvider = Provider.autoDispose((ref) {
  final service = CrashReportsService();
  ref.onDispose(service.dispose);
  return service;
});
final crashReportsProvider =
    AsyncNotifierProvider.autoDispose<CrashReportsViewModel, CrashReportPage?>(
      CrashReportsViewModel.new,
    );

class CrashReportsViewModel extends AsyncNotifier<CrashReportPage?> {
  @override
  FutureOr<CrashReportPage?> build() {
    ref.watch(crashReportsServiceProvider);
    ref.watch(currentStaffProfileProvider);
    return null;
  }

  Future<void> load({bool authorize = false, String? pageToken}) async {
    if (ref.read(currentStaffProfileProvider)?.isAdmin != true) {
      state = AsyncError(
        StateError('Chỉ Admin được xem báo cáo lỗi.'),
        StackTrace.current,
      );
      return;
    }
    final service = ref.read(crashReportsServiceProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (authorize) await service.authorize();
      return service.load(pageToken: pageToken);
    });
  }
}
