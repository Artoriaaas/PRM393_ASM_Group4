import '../services/contracts/notification_service.dart';
import '../services/firebase/firestore_notification_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_state.dart';
import '../models/event.dart';
import '../services/contracts/event_service.dart';
import '../services/firebase/firestore_event_service.dart';
import '../services/device/secure_pending_booking_store.dart';
import 'providers.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  if (!ref.watch(firebaseReadyProvider)) {
    throw StateError('Firebase chưa được cấu hình.');
  }
  return FirestoreEventService(
    FirebaseFirestore.instance,
    FirebaseFunctions.instanceFor(region: 'asia-southeast1'),
  );
});
final pendingBookingStoreProvider = Provider<PendingBookingStore>(
  (ref) => const SecurePendingBookingStore(FlutterSecureStorage()),
);
final signedInUidProvider = Provider<String?>((ref) {
  final auth = ref.watch(sessionViewModelProvider);
  return auth is AuthStateSignedIn ? auth.uid : null;
});
final eventsProvider = StreamProvider.autoDispose<List<Event>>((ref) {
  if (ref.watch(signedInUidProvider) == null) return Stream.value([]);
  return ref.watch(eventServiceProvider).watchEvents();
});
final eventProvider = StreamProvider.autoDispose.family<Event?, String>((
  ref,
  id,
) {
  if (ref.watch(signedInUidProvider) == null) return Stream.value(null);
  return ref.watch(eventServiceProvider).watchEvent(id);
});
final registrationsProvider = StreamProvider.autoDispose<List<Registration>>((
  ref,
) {
  final uid = ref.watch(signedInUidProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(eventServiceProvider).watchRegistrations(uid);
});
final registrationProvider = StreamProvider.autoDispose
    .family<Registration?, String>((ref, id) {
      if (ref.watch(signedInUidProvider) == null) return Stream.value(null);
      return ref.watch(eventServiceProvider).watchRegistration(id);
    });

final notificationServiceProvider = Provider<NotificationService>((ref) {
  if (!ref.watch(firebaseReadyProvider)) {
    throw StateError('Firebase not configured');
  }
  return FirestoreNotificationService(FirebaseFirestore.instance);
});
