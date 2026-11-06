import 'package:eventhub_core/eventhub_core.dart';
import 'event_providers.dart';

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase/firebase_cloud_services.dart';
import 'providers.dart';

final cloudServicesProvider = Provider<CloudServices>((ref) {
  if (!ref.watch(firebaseReadyProvider)) return UnavailableCloudServices();
  final service = FirebaseCloudServices(
    analytics: FirebaseAnalytics.instance,
    crashlytics: FirebaseCrashlytics.instance,
    messaging: FirebaseMessaging.instance,
    config: FirebaseRemoteConfig.instance,
    db: FirebaseFirestore.instance,
  );
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});
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
