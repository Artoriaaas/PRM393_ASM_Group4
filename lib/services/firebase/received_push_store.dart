import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Receipt history only. It never changes registration or attendance state.
Future<void> saveReceivedPush(
  FirebaseFirestore db,
  String uid,
  RemoteMessage message,
) async {
  if (message.data['uid'] != null && message.data['uid'] != uid) return;
  final id = sha256
      .convert(
        utf8.encode(
          message.messageId ??
              jsonEncode({
                'data': message.data,
                'title': message.notification?.title,
                'body': message.notification?.body,
                'sent': message.sentTime?.toIso8601String(),
              }),
        ),
      )
      .toString();
  final ref = db.doc('users/$uid/notifications/push_$id');
  await db.runTransaction((tx) async {
    if ((await tx.get(ref)).exists) return;
    tx.set(ref, {
      'title': (message.notification?.title ?? 'Thông báo').substring(
        0,
        (message.notification?.title ?? 'Thông báo').length.clamp(0, 200),
      ),
      'body': (message.notification?.body ?? '').substring(
        0,
        (message.notification?.body ?? '').length.clamp(0, 4000),
      ),
      'eventId':
          message.data['eventId'] is String &&
              RegExp(r'^[\w-]+$').hasMatch(message.data['eventId'])
          ? message.data['eventId']
          : '',
      if (message.data['registrationId'] is String &&
          RegExp(r'^[\w-]+$').hasMatch(message.data['registrationId']) &&
          message.data['registrationId'].length <= 200)
        'registrationId': message.data['registrationId'],
      'type': 'push_received',
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': null,
    });
  });
}
