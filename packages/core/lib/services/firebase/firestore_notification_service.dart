import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/app_notification.dart';
import '../contracts/notification_service.dart';

// Global announcements reach everyone. Club/event announcements reach users
// with a current request for that club/event; private notifications stay separate.
bool announcementApplies(
  Map<String, dynamic> a,
  Iterable<Map<String, dynamic>> registrations,
) {
  if (a['scope'] == 'global') return true;
  final current = registrations.where(
    (r) => ['pending', 'approved', 'active'].contains(r['status']),
  );
  return switch (a['scope']) {
    'event' => current.any((r) => r['eventId'] == a['eventId']),
    'club' => current.any((r) => r['clubId'] == a['clubId']),
    _ => false,
  };
}

class FirestoreNotificationService implements NotificationService {
  FirestoreNotificationService(this.db);
  final FirebaseFirestore db;
  @override
  Stream<List<AppNotification>> watch(String uid) => Stream.multi((sink) {
    QuerySnapshot<Map<String, dynamic>>? personal,
        announcements,
        registrations,
        reads;
    final subscriptions = <StreamSubscription<dynamic>>[];
    var disposed = false;
    void fail(Object error, StackTrace stack) {
      if (!disposed) sink.addError(error, stack);
    }

    DateTime? date(dynamic v) => v is Timestamp ? v.toDate() : null;
    void emit() {
      if (disposed) return;
      if (personal == null ||
          announcements == null ||
          registrations == null ||
          reads == null)
        return;
      final readMap = {
        for (final d in reads!.docs) d.id: date(d.data()['readAt']),
      };
      final rows =
          <AppNotification>[
            for (final doc in personal!.docs)
              AppNotification(
                id: doc.id,
                title: doc.data()['title'] as String? ?? '',
                body: doc.data()['body'] as String? ?? '',
                eventId: doc.data()['eventId'] as String? ?? '',
                registrationId: doc.data()['registrationId'] as String?,
                type: doc.data()['type'] as String? ?? '',
                createdAt: date(doc.data()['createdAt']),
                readAt: date(doc.data()['readAt']),
              ),
            for (final doc in announcements!.docs)
              if (announcementApplies(
                doc.data(),
                registrations!.docs.map((r) => r.data()),
              ))
                AppNotification(
                  id: 'announcement:${doc.id}',
                  title: doc.data()['title'] as String? ?? '',
                  body: doc.data()['body'] as String? ?? '',
                  eventId: doc.data()['eventId'] as String? ?? '',
                  type: 'announcement',
                  createdAt: date(doc.data()['createdAt']),
                  readAt: readMap[doc.id],
                ),
          ]..sort(
            (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
              a.createdAt ?? DateTime(1970),
            ),
          );
      sink.add(rows);
    }

    subscriptions.add(
      db
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .snapshots()
          .listen((s) {
            personal = s;
            emit();
          }, onError: fail),
    );
    subscriptions.add(
      db
          .collection('announcements')
          .orderBy('createdAt', descending: true)
          .limit(100)
          .snapshots()
          .listen((s) {
            announcements = s;
            emit();
          }, onError: fail),
    );
    subscriptions.add(
      db
          .collection('registrations')
          .where('uid', isEqualTo: uid)
          .snapshots()
          .listen((s) {
            registrations = s;
            emit();
          }, onError: fail),
    );
    subscriptions.add(
      db
          .collection('users')
          .doc(uid)
          .collection('announcementReads')
          .snapshots()
          .listen((s) {
            reads = s;
            emit();
          }, onError: fail),
    );
    sink.onCancel = () async {
      disposed = true;
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    };
  });
  @override
  Future<void> markRead(String uid, String id) {
    if (id.startsWith('announcement:')) {
      final announcementId = id.substring('announcement:'.length);
      return db.doc('users/$uid/announcementReads/$announcementId').set({
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    return db.doc('users/$uid/notifications/$id').update({
      'readAt': FieldValue.serverTimestamp(),
    });
  }
}
