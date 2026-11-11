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

class UnconfiguredAdminService implements IAdminService {
  const UnconfiguredAdminService();

  static const _unconfiguredFailure = AppFailure(
    code: 'firebase_unconfigured',
    message: 'Firebase Web chưa được cấu hình.',
  );

  @override
  Stream<List<WebUserProfile>> streamAllUsers() => Stream.value(const []);

  @override
  Future<Result<void>> updateUserRole({
    required String targetUid,
    required String newRole,
    String? clubId,
    String? clubName,
  }) async =>
      Result.failure(_unconfiguredFailure);

  @override
  Stream<List<Club>> streamAllClubs() => Stream.value(const []);

  @override
  Future<Result<String>> createClub({
    required String name,
    String shortName = '',
    String description = '',
  }) async =>
      Result.failure(_unconfiguredFailure);

  @override
  Future<Result<void>> updateClub(Club club) async =>
      Result.failure(_unconfiguredFailure);

  @override
  Future<Result<void>> archiveClub(String clubId) async =>
      Result.failure(_unconfiguredFailure);

  @override
  Stream<List<Event>> streamAllEvents() => Stream.value(const []);

  @override
  Future<Result<void>> adminApproveEvent(String eventId) async =>
      Result.failure(_unconfiguredFailure);

  @override
  Future<Result<void>> adminRejectEvent(String eventId, {required String reason}) async =>
      Result.failure(_unconfiguredFailure);

  @override
  Future<Result<void>> adminCancelEvent(String eventId) async =>
      Result.failure(_unconfiguredFailure);

  @override
  Future<Result<void>> adminArchiveEvent(String eventId) async =>
      Result.failure(_unconfiguredFailure);

  @override
  Future<int> countSystemPendingEvents() async => 0;

  @override
  Stream<List<Registration>> streamAllPendingRegistrations() =>
      Stream.value(const []);

  @override
  Future<int> countSystemPublishedEvents() async => 0;

  @override
  Future<int> countSystemPendingRegistrations() async => 0;

  @override
  Future<int> countSystemApprovedRegistrations() async => 0;

  @override
  Future<int> countUsersByRole(String role) async => 0;

  @override
  Future<int> countActiveClubs() async => 0;

  @override
  Future<List<Map<String, Object>>> getClubEventStats() async => const [];

  @override
  Stream<List<Announcement>> streamAllAnnouncements() => Stream.value(const []);
}

