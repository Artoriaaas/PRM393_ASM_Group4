import 'dart:async';
import 'package:eventhub_core/eventhub_core.dart';
import 'web_contracts.dart';

/// Non-mock fallback used only when Firebase has not initialized yet.
/// Never returns fabricated club/event/registration data.
class UnconfiguredWebAuthService implements IWebAuthService {
  @override
  WebUserProfile? get currentUser => null;

  @override
  Stream<WebUserProfile?> authStateChanges() => Stream<WebUserProfile?>.value(null);

  @override
  Future<Result<WebUserProfile>> fetchProfile(String uid) async {
    return Result.failure(
      const AppFailure(
        code: 'firebase_unconfigured',
        message: 'Firebase Web chưa được cấu hình.',
      ),
    );
  }

  @override
  Future<Result<WebUserProfile>> signInWithGoogle() async {
    return Result.failure(
      const AppFailure(
        code: 'firebase_unconfigured',
        message: 'Firebase Web chưa được cấu hình. Hãy truyền --dart-define cho dự án.',
        isRetryable: true,
      ),
    );
  }

  @override
  Future<void> signOut() async {}
}

class NoopWebAnalyticsService implements IWebAnalyticsService {
  const NoopWebAnalyticsService();

  @override
  Future<void> setUserId(String? uid) async {}

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {}
}

class NoopWebRemoteConfigService implements IWebRemoteConfigService {
  const NoopWebRemoteConfigService();

  @override
  Future<void> initialize() async {}

  @override
  bool getBool(String key, {bool defaultValue = false}) => defaultValue;

  @override
  int getInt(String key, {int defaultValue = 0}) => defaultValue;

  @override
  String getString(String key, {String defaultValue = ''}) => defaultValue;
}
