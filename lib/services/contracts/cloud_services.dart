import '../../models/cloud_settings.dart';

abstract interface class CloudServices {
  Future<void> initialize();
  Future<void> user(String? uid);
  Future<void> event(String name, Map<String, Object> parameters);
  Future<void> report(String code, StackTrace stack, {bool fatal = false});
  Future<CloudSettings> fetchSettings();
  Future<String> enablePush(String uid);
  Future<void> disablePush(String uid);
  Stream<PushTarget> get pushTargets;
  void crash();
  Future<void> dispose();
}

// Missing configuration/tests: no fake analytics success, no network SDK calls.
class UnavailableCloudServices implements CloudServices {
  @override
  Future<void> initialize() async {}
  @override
  Future<void> user(String? uid) async {}
  @override
  Future<void> event(String name, Map<String, Object> parameters) async {}
  @override
  Future<void> report(
    String code,
    StackTrace stack, {
    bool fatal = false,
  }) async {}
  @override
  Future<CloudSettings> fetchSettings() async =>
      throw StateError('Cloud services not configured');
  @override
  Future<String> enablePush(String uid) async =>
      throw StateError('Cloud services not configured');
  @override
  Future<void> disablePush(String uid) async {}
  @override
  Stream<PushTarget> get pushTargets => const Stream.empty();
  @override
  void crash() => throw StateError('Cloud services not configured');
  @override
  Future<void> dispose() async {}
}
