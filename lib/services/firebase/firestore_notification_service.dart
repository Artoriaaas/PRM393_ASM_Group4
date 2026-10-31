import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_notification.dart';
import '../contracts/notification_service.dart';

class FirestoreNotificationService implements NotificationService {
  FirestoreNotificationService(this.db);
  final FirebaseFirestore db;
  @override
  Stream<List<AppNotification>> watch(String uid) => db
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .snapshots()
      .map(
        (s) =>
            s.docs.map((doc) {
              final d = doc.data();
              return AppNotification(
                id: doc.id,
                title: d['title'] as String? ?? '',
                body: d['body'] as String? ?? '',
                eventId: d['eventId'] as String? ?? '',
                registrationId: d['registrationId'] as String?,
                type: d['type'] as String? ?? '',
                createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
                readAt: (d['readAt'] as Timestamp?)?.toDate(),
              );
            }).toList()..sort(
              (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
                a.createdAt ?? DateTime(1970),
              ),
            ),
      );
  @override
  Future<void> markRead(String uid, String id) => db
      .collection('users')
      .doc(uid)
      .collection('notifications')
      .doc(id)
      .update({'readAt': FieldValue.serverTimestamp()});
}
