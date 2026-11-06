import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventhub_core/eventhub_core.dart';

class FirestoreNotificationService implements NotificationService {
  FirestoreNotificationService(this.db);
  final FirebaseFirestore db;
  final Map<String, Map<String, DateTime>> _readAnnouncementsByUid = {};
  final StreamController<String> _localReadUpdates =
      StreamController<String>.broadcast();

  static const String announcementPrefix = 'ann_';

  @override
  Stream<List<AppNotification>> watch(String uid) {
    late StreamController<List<AppNotification>> controller;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? personalSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? announcementSub;
    StreamSubscription<String>? localReadSub;

    List<AppNotification>? latestPersonal;
    List<QueryDocumentSnapshot<Map<String, dynamic>>>? latestAnnouncements;

    void emitMerged() {
      if (controller.isClosed || latestPersonal == null) return;
      final readMap = _readAnnouncementsByUid[uid] ?? const {};
      final announcementItems = (latestAnnouncements ?? const []).map((doc) {
        final d = doc.data();
        final clubName = (d['clubName'] as String? ?? '').trim();
        final rawTitle = (d['title'] as String? ?? '').trim();
        final formattedTitle = clubName.isNotEmpty
            ? '[$clubName] $rawTitle'
            : rawTitle;
        final id = '$announcementPrefix${doc.id}';
        return AppNotification(
          id: id,
          title: formattedTitle,
          body: d['body'] as String? ?? '',
          eventId: d['eventId'] as String? ?? '',
          registrationId: null,
          type: 'announcement',
          createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
          readAt: readMap[id],
        );
      });

      final merged = <AppNotification>[
        ...latestPersonal!,
        ...announcementItems,
      ]..sort(
        (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
          a.createdAt ?? DateTime(1970),
        ),
      );
      controller.add(merged);
    }

    controller = StreamController<List<AppNotification>>(
      onListen: () {
        personalSub = db
            .collection('users')
            .doc(uid)
            .collection('notifications')
            .snapshots()
            .listen((snap) {
              latestPersonal = snap.docs.map((doc) {
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
              }).toList();
              emitMerged();
            }, onError: controller.addError);

        announcementSub = db
            .collection('announcements')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots()
            .listen(
              (snap) {
                latestAnnouncements = snap.docs;
                emitMerged();
              },
              onError: (_) {
                latestAnnouncements ??= const [];
                emitMerged();
              },
            );

        localReadSub = _localReadUpdates.stream.listen((changedUid) {
          if (changedUid == uid) emitMerged();
        });
      },
      onCancel: () async {
        await personalSub?.cancel();
        await announcementSub?.cancel();
        await localReadSub?.cancel();
      },
    );

    return controller.stream;
  }

  @override
  Future<void> markRead(String uid, String id) async {
    if (id.startsWith(announcementPrefix)) {
      final userReads = _readAnnouncementsByUid.putIfAbsent(uid, () => {});
      userReads[id] = DateTime.now().toUtc();
      _localReadUpdates.add(uid);
      return;
    }
    await db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(id)
        .update({'readAt': FieldValue.serverTimestamp()});
  }
}
