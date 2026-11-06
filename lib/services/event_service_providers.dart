import 'contracts/notification_service.dart';
import 'firebase/firestore_notification_service.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'contracts/event_service.dart';
import 'firebase/firestore_event_service.dart';
import 'device/secure_pending_booking_store.dart';
import 'auth_providers.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  if (!ref.watch(firebaseReadyProvider)) {
    throw StateError('Firebase chưa được cấu hình.');
  }
  return FirestoreEventService(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});
final pendingBookingStoreProvider = Provider<PendingBookingStore>(
  (ref) => const SecurePendingBookingStore(FlutterSecureStorage()),
);
final notificationServiceProvider = Provider<NotificationService>((ref) {
  if (!ref.watch(firebaseReadyProvider)) {
    throw StateError('Firebase not configured');
  }
  return FirestoreNotificationService(FirebaseFirestore.instance);
});
