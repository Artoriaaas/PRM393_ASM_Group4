import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../services/web_contracts.dart';
import '../services/fake_web_services.dart';

final webAuthServiceProvider = Provider<IWebAuthService>((ref) {
  return FakeWebAuthService();
});

final clubServiceProvider = Provider<IClubService>((ref) {
  return FakeClubService();
});

final webAnalyticsServiceProvider = Provider<IWebAnalyticsService>((ref) {
  return FakeWebAnalyticsService();
});

final webAuthStateChangesProvider = StreamProvider<WebUserProfile?>((ref) {
  final authService = ref.watch(webAuthServiceProvider);
  return authService.authStateChanges();
});

final activeClubProvider = FutureProvider.family<Club?, String>((ref, clubId) async {
  if (clubId.isEmpty) return null;
  final service = ref.watch(clubServiceProvider);
  return service.getClub(clubId);
});

final clubPendingRegistrationsStreamProvider =
    StreamProvider.family<List<Registration>, String>((ref, clubId) {
  if (clubId.isEmpty) return const Stream.empty();
  final service = ref.watch(clubServiceProvider);
  return service.streamClubPendingRegistrations(clubId);
});

final pendingRegistrationsBadgeCountProvider =
    Provider.family<int, String>((ref, clubId) {
  final asyncVal = ref.watch(clubPendingRegistrationsStreamProvider(clubId));
  return asyncVal.value?.length ?? 0;
});
