import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cloud_settings.dart';
import '../services/cloud_service_provider.dart';
import 'session_viewmodel.dart';
export '../services/cloud_service_provider.dart';

Future<void> track(
  Ref ref,
  String name, [
  Map<String, Object> values = const {},
]) async {
  try {
    await ref
        .read(cloudServicesProvider)
        .event(name, values)
        .timeout(const Duration(seconds: 2));
  } catch (_) {
    /* Instrumentation never changes the business result. */
  }
}

Future<void> diagnose(Ref ref, String code, StackTrace stack) async {
  try {
    await ref
        .read(cloudServicesProvider)
        .report(code, stack)
        .timeout(const Duration(seconds: 2));
  } catch (_) {
    /* Offline diagnostics must not break recovery. */
  }
}

final cloudInitializationProvider = FutureProvider<void>((ref) async {
  if (!ref.watch(firebaseReadyProvider)) return;
  final service = ref.watch(cloudServicesProvider);
  await service.initialize();
  if (!ref.mounted) return;
  ref.listen(signedInUidProvider, (_, uid) {
    unawaited(service.user(uid).catchError((_) {}));
  }, fireImmediately: true);
});
final pushTargetsProvider = StreamProvider.autoDispose<PushTarget>(
  (ref) => ref.watch(cloudServicesProvider).pushTargets,
);
