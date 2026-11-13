import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'contracts/cloud_services.dart';
import 'firebase/firebase_cloud_services.dart';
import 'auth_providers.dart';

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
