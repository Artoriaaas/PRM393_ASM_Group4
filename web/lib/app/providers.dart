import 'package:eventhub_core/services/firebase/club_assignments.dart';

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';

import '../services/firebase_web_services.dart';
import '../services/gemini_ai_service.dart';
import '../services/unconfigured_web_services.dart';
import '../services/web_contracts.dart';

/// True only after [initializeWebFirebase] succeeds in [WebFirebaseAppBootstrap].
final webFirebaseReadyProvider = Provider<bool>((ref) => false);

final webAuthServiceProvider = Provider<IWebAuthService>((ref) {
  if (ref.watch(webFirebaseReadyProvider)) {
    return FirebaseWebAuthService(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
  }
  return UnconfiguredWebAuthService();
});

final clubServiceProvider = Provider<IClubService>((ref) {
  if (!ref.watch(webFirebaseReadyProvider)) {
    throw StateError('Firebase Web chưa được khởi tạo.');
  }
  return FirestoreClubService(firestore: FirebaseFirestore.instance);
});

final webAnalyticsServiceProvider = Provider<IWebAnalyticsService>((ref) {
  if (!ref.watch(webFirebaseReadyProvider)) {
    return const NoopWebAnalyticsService();
  }
  return FirebaseWebAnalyticsService(analytics: FirebaseAnalytics.instance);
});

final webRemoteConfigServiceProvider = Provider<IWebRemoteConfigService>((ref) {
  if (!ref.watch(webFirebaseReadyProvider)) {
    return const NoopWebRemoteConfigService();
  }
  return FirebaseWebRemoteConfigService(
    remoteConfig: FirebaseRemoteConfig.instance,
  );
});

final webRemoteConfigInitProvider = FutureProvider<void>((ref) async {
  if (!ref.watch(webFirebaseReadyProvider)) return;
  final remoteConfig = ref.watch(webRemoteConfigServiceProvider);
  await remoteConfig.initialize();
  final analytics = ref.read(webAnalyticsServiceProvider);
  unawaited(analytics.logEvent('remote_config_fetch'));
});

final geminiAiServiceProvider = Provider<IAiEventAssistService>((ref) {
  final remoteConfig = ref.watch(webRemoteConfigServiceProvider);
  final analytics = ref.watch(webAnalyticsServiceProvider);
  return GeminiAiEventAssistService(
    remoteConfig: remoteConfig,
    analytics: analytics,
  );
});

final activeClubProvider = FutureProvider.autoDispose.family<Club?, String>((
  ref,
  clubId,
) async {
  if (clubId.isEmpty) return null;
  final service = ref.watch(clubServiceProvider);
  return service.getClub(clubId);
});

final clubPendingRegistrationsStreamProvider = StreamProvider.autoDispose
    .family<List<Registration>, String>((ref, clubId) {
      if (clubId.isEmpty) return Stream<List<Registration>>.value(const []);
      final service = ref.watch(clubServiceProvider);
      return service.streamClubPendingRegistrations(clubId);
    });

final pendingRegistrationsBadgeCountProvider = Provider.autoDispose
    .family<int, String>((ref, clubId) {
      final asyncVal = ref.watch(
        clubPendingRegistrationsStreamProvider(clubId),
      );
      return asyncVal.asData?.value.length ?? 0;
    });

final adminServiceProvider = Provider<IAdminService>((ref) {
  if (!ref.watch(webFirebaseReadyProvider)) {
    return const UnconfiguredAdminService();
  }
  return FirestoreAdminService(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
});

final allClubsStreamProvider = StreamProvider<List<Club>>((ref) {
  if (!ref.watch(webFirebaseReadyProvider)) return Stream.value(const []);
  final service = ref.watch(adminServiceProvider);
  return service.streamAllClubs();
});

/// Only presentation limits, never authorization or registration capacity.
final webDashboardSettingsProvider =
    Provider<({int recentLimit, int chartLimit})>((ref) {
      final initialized = ref.watch(webRemoteConfigInitProvider);
      if (!initialized.hasValue) return (recentLimit: 4, chartLimit: 5);
      final config = ref.watch(webRemoteConfigServiceProvider);
      return (
        recentLimit: config
            .getInt('web_dashboard_recent_limit', defaultValue: 4)
            .clamp(1, 20),
        chartLimit: config
            .getInt('web_dashboard_chart_limit', defaultValue: 5)
            .clamp(1, 10),
      );
    });

final clubAssignmentServiceProvider = Provider<IClubAssignmentService>(
  (ref) => FirestoreClubAssignmentService(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  ),
);
