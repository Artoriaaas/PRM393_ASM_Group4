import 'received_push_store.dart';
import '../../utils/push_destination.dart';

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../models/cloud_settings.dart';
import '../contracts/cloud_services.dart';

class FirebaseCloudServices implements CloudServices {
  FirebaseCloudServices({
    required this.analytics,
    required this.crashlytics,
    required this.messaging,
    required this.config,
    required this.db,
  });
  final FirebaseAnalytics analytics;
  final FirebaseCrashlytics crashlytics;
  final FirebaseMessaging messaging;
  final FirebaseRemoteConfig config;
  final FirebaseFirestore db;
  final _targets = StreamController<PushTarget>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  String? _uid, _token;
  int _userEpoch = 0;
  RemoteMessage? _queuedMessage;
  bool _disposed = false;
  @override
  Stream<PushTarget> get pushTargets => _targets.stream;
  void _message(RemoteMessage message, bool opened) {
    if (_uid == null) {
      if (opened) _queuedMessage = message;
      return;
    }
    unawaited(saveReceivedPush(db, _uid!, message).catchError((_) {}));
    final target = pushDestination(message.data, _uid, opened: opened);
    if (!_disposed && target != null) _targets.add(target);
  }

  @override
  Future<void> initialize() async {
    await config.setDefaults({
      'recommendation_limit': 10,
      'show_recommendations': true,
    });
    await config.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 15),
        minimumFetchInterval: const Duration(minutes: 1),
      ),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((m) => _message(m, false)),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen((m) => _message(m, true)),
    );
    _subscriptions.add(
      messaging.onRegistered.listen((token) async {
        final uid = _uid;
        if (uid != null) {
          try {
            await _saveToken(uid, token);
          } catch (_) {
            /* Push registration is retryable from the demo area. */
          }
        }
      }),
    );
  }

  @override
  Future<void> user(String? uid) async {
    final epoch = ++_userEpoch;
    _uid = uid;
    await analytics.setUserId(id: uid);
    if (epoch != _userEpoch) return;
    await crashlytics.setUserIdentifier(uid ?? '');
    if (epoch != _userEpoch) return;
    await crashlytics.setCustomKey('app_flow', 'eventhub');
    if (uid != null) {
      final message = _queuedMessage ?? await messaging.getInitialMessage();
      _queuedMessage = null;
      if (epoch != _userEpoch) return;
      if (message != null) _message(message, true);
    }
  }

  @override
  Future<void> event(String name, Map<String, Object> parameters) =>
      analytics.logEvent(name: name, parameters: parameters);
  @override
  Future<void> report(String code, StackTrace stack, {bool fatal = false}) =>
      crashlytics.recordError(
        Exception(code),
        stack,
        reason: code,
        fatal: fatal,
      );
  @override
  Future<CloudSettings> fetchSettings() async {
    await config.fetchAndActivate();
    return CloudSettings(
      recommendationLimit: config.getInt('recommendation_limit').clamp(1, 100),
      showRecommendations: config.getBool('show_recommendations'),
    );
  }

  String _deviceId(String token) =>
      sha256.convert(utf8.encode(token)).toString();
  Future<void> _saveToken(String uid, String token) async {
    if (uid != _uid) return;
    await db.doc('users/$uid/devices/${_deviceId(token)}').set({
      'fid': token,
      'platform': 'android',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (uid == _uid) _token = token;
  }

  @override
  Future<String> enablePush(String uid) async {
    final permission = await messaging.requestPermission();
    if (permission.authorizationStatus == AuthorizationStatus.denied) {
      return 'Quyền thông báo bị từ chối. Thông báo trong app vẫn hoạt động.';
    }
    final registration = messaging.onRegistered.first.timeout(
      const Duration(seconds: 20),
    );
    await messaging.register();
    final token = await registration;
    await _saveToken(uid, token);
    return 'Đã cấp quyền và đăng ký thiết bị nhận thông báo.';
  }

  @override
  Future<void> disablePush(String uid) async {
    final token = _token;
    _token = null;
    _uid = null;
    _userEpoch++;
    try {
      await messaging.unregister();
    } finally {
      if (token != null) {
        await db.doc('users/$uid/devices/${_deviceId(token)}').delete();
      }
    }
  }

  @override
  void crash() => crashlytics.crash();
  @override
  Future<void> dispose() async {
    _disposed = true;
    for (final s in _subscriptions) {
      await s.cancel();
    }
    await _targets.close();
  }
}
