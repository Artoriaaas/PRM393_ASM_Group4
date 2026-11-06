import 'package:firebase_auth/firebase_auth.dart';
import 'received_push_store.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Android reads resources generated from the team's google-services.json.
/// Never installs a demo project or fabricates FirebaseOptions.
Future<void>? _coreInitialization;

Future<bool> initializeFirebase() async {
  try {
    _coreInitialization ??= Firebase.initializeApp().then((_) {});
    await _coreInitialization!.timeout(const Duration(seconds: 45));
    // Private participation records must not remain in a shared device disk cache.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessage);
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(
        FirebaseCrashlytics.instance
            .recordError(
              Exception('flutter_framework_error'),
              details.stack ?? StackTrace.current,
              fatal: true,
            )
            .catchError((_) {}),
      );
    };
    PlatformDispatcher.instance.onError = (_, stack) {
      unawaited(
        FirebaseCrashlytics.instance
            .recordError(
              Exception('unhandled_platform_error'),
              stack,
              fatal: true,
            )
            .catchError((_) {}),
      );
      return true;
    };
    return true;
  } catch (error) {
    if (error is! TimeoutException) _coreInitialization = null;
    if (kDebugMode) {
      debugPrint(
        'Firebase bootstrap failed: ${error is FirebaseException ? error.code : error.runtimeType}',
      );
    }
    return false;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) await saveReceivedPush(FirebaseFirestore.instance, uid, message);
}
