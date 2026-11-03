import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';

import 'dart:convert';

import '../../models/event.dart';
import '../contracts/event_service.dart';

class FirestoreEventService implements EventService {
  FirestoreEventService(this.db, this.auth);
  final FirebaseFirestore db;
  final FirebaseAuth auth;
  DateTime? _date(dynamic v) => v is Timestamp ? v.toDate().toUtc() : null;
  Event _event(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Event(
      id: doc.id,
      title: d['title'] as String? ?? '',
      coverKey: d['coverKey'] as String? ?? '',
      clubName: d['clubName'] as String? ?? '',
      location: d['location'] as String? ?? '',
      startsAt: _date(d['startsAt'])!,
      endsAt: _date(d['endsAt'])!,
      deadline: _date(d['deadline']),
      description: d['description'] as String? ?? '',
      topic: d['topic'] as String? ?? '',
      audience: d['audience'] as String? ?? '',
      preparation: d['preparation'] as String? ?? '',
      activities: List<String>.from(d['activities'] ?? []),
      mode: d['registrationMode'] as String? ?? 'required',
      status: d['status'] as String? ?? 'published',
      capacity: (d['capacity'] as num?)?.toInt() ?? 0,
      activeCount: (d['activeCount'] as num?)?.toInt() ?? 0,
    );
  }

  Registration _registration(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Registration(
      id: doc.id,
      eventId: d['eventId'] as String,
      status: d['status'] as String,
      generation: (d['generation'] as num).toInt(),
      participant: Participant.fromJson(
        Map<String, dynamic>.from(d['participant'] as Map),
      ),
      checkInAt: _date(d['checkInAt']),
      createdAt: _date(d['createdAt']),
    );
  }

  @override
  Stream<List<Event>> watchEvents() => db
      .collection('events')
      .where('visibility', isEqualTo: 'public')
      .limit(100)
      .snapshots()
      .map(
        (s) =>
            s.docs.map(_event).toList()
              ..sort((a, b) => a.startsAt.compareTo(b.startsAt)),
      );
  @override
  Stream<Event?> watchEvent(String id) => db
      .collection('events')
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? _event(s) : null);
  @override
  Stream<List<Registration>> watchRegistrations(String uid) => db
      .collection('registrations')
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map(
        (s) => s.docs.map(_registration).toList()
          ..sort(
            (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
              a.createdAt ?? DateTime(1970),
            ),
          ),
      );
  @override
  Stream<Registration?> watchRegistration(String id) => db
      .collection('registrations')
      .doc(id)
      .snapshots()
      .map((s) => s.exists ? _registration(s) : null);
  @override
  Future<BookingResult> execute(Map<String, dynamic> command) async {
    final user = auth.currentUser;
    if (user == null || !user.emailVerified) {
      return const BookingResult(status: 'rejected', code: 'unauthenticated');
    }
    final eventId = command['eventId'] as String?;
    final operationId = command['operationId'] as String?;
    final action = command['action'] as String?;
    if (eventId == null ||
        operationId == null ||
        !RegExp(r'^[a-f0-9]{48}$').hasMatch(operationId)) {
      return const BookingResult(status: 'rejected', code: 'invalid-command');
    }
    final registrationId = '${user.uid}_$eventId';
    final registrationRef = db.collection('registrations').doc(registrationId);
    final eventRef = db.collection('events').doc(eventId);
    try {
      return await db.runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventRef);
        final registrationSnapshot = await transaction.get(registrationRef);
        final event = eventSnapshot.data();
        final registration = registrationSnapshot.data();
        if (event == null) {
          return const BookingResult(
            status: 'rejected',
            code: 'event-not-found',
          );
        }
        if (registration?['lastOperationId'] == operationId) {
          return BookingResult(
            status: switch (action) {
              'register' => 'confirmed',
              'cancel' => 'cancelled',
              'checkin' => 'checked-in',
              _ => 'unknown',
            },
            registrationId: registrationId,
          );
        }
        final now = DateTime.now().toUtc();
        final startsAt = (event['startsAt'] as Timestamp).toDate().toUtc();
        if (action == 'register') {
          if (registration?['status'] == 'active') {
            return BookingResult(
              status: 'existing',
              registrationId: registrationId,
            );
          }
          if (event['status'] != 'published') {
            return const BookingResult(
              status: 'rejected',
              code: 'event-cancelled',
            );
          }
          if (event['registrationMode'] == 'free') {
            return const BookingResult(status: 'rejected', code: 'free-entry');
          }
          final deadline = (event['deadline'] as Timestamp?)?.toDate().toUtc();
          if (!now.isBefore(startsAt) ||
              deadline == null ||
              !now.isBefore(deadline)) {
            return const BookingResult(
              status: 'rejected',
              code: 'registration-expired',
            );
          }
          final count = (event['activeCount'] as num?)?.toInt() ?? 0;
          final capacity = (event['capacity'] as num?)?.toInt() ?? 0;
          if (count >= capacity) {
            return const BookingResult(status: 'rejected', code: 'event-full');
          }
          final participant = Participant.fromJson(
            Map<String, dynamic>.from(command['participant'] as Map? ?? {}),
          );
          if (participant.validate().isNotEmpty) {
            return const BookingResult(
              status: 'rejected',
              code: 'invalid-participant',
            );
          }
          final data = {
            'uid': user.uid,
            'eventId': eventId,
            'status': 'active',
            'generation':
                ((registration?['generation'] as num?)?.toInt() ?? 0) + 1,
            'participant': participant.toJson(),
            'checkInAt': null,
            'createdAt': FieldValue.serverTimestamp(),
            'lastOperationId': operationId,
          };
          transaction.set(registrationRef, data);
          transaction.update(eventRef, {'activeCount': count + 1});
          return BookingResult(
            status: 'confirmed',
            registrationId: registrationId,
          );
        }
        if (registration == null || registration['status'] != 'active') {
          return const BookingResult(
            status: 'rejected',
            code: 'registration-inactive',
          );
        }
        if (registration['generation'] != command['generation']) {
          return const BookingResult(
            status: 'rejected',
            code: 'stale-generation',
          );
        }
        if (action == 'cancel') {
          if (!now.isBefore(startsAt) ||
              registration['checkInAt'] != null ||
              event['status'] != 'published') {
            return const BookingResult(
              status: 'rejected',
              code: 'cannot-cancel',
            );
          }
          transaction.update(registrationRef, {
            'status': 'cancelled',
            'lastOperationId': operationId,
          });
          transaction.update(eventRef, {
            'activeCount': (event['activeCount'] as num).toInt() - 1,
          });
          return BookingResult(
            status: 'cancelled',
            registrationId: registrationId,
          );
        }
        if (action == 'checkin') {
          if (registration['checkInAt'] != null) {
            return BookingResult(
              status: 'checked-in',
              registrationId: registrationId,
            );
          }
          final token = command['qrToken'] as String? ?? '';
          if (token.length < 32 || token.length > 4096) {
            return const BookingResult(status: 'rejected', code: 'invalid-qr');
          }
          final hash = sha256.convert(utf8.encode(token)).toString();
          transaction.update(registrationRef, {
            'checkInAt': FieldValue.serverTimestamp(),
            'qrHash': hash,
            'lastOperationId': operationId,
          });
          return BookingResult(
            status: 'checked-in',
            registrationId: registrationId,
          );
        }
        return const BookingResult(status: 'rejected', code: 'invalid-command');
      });
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied' ||
          error.code == 'invalid-argument') {
        return BookingResult(
          status: 'rejected',
          code: action == 'checkin' ? 'invalid-qr' : error.code,
        );
      }
      rethrow;
    }
  }

  @override
  Future<BookingResult> recover(String operationId) async {
    final user = auth.currentUser;
    if (user == null) return const BookingResult(status: 'unknown');
    final matches = await db
        .collection('registrations')
        .where('uid', isEqualTo: user.uid)
        .where('lastOperationId', isEqualTo: operationId)
        .limit(1)
        .get(const GetOptions(source: Source.server));
    if (matches.docs.isEmpty) return const BookingResult(status: 'unknown');
    final data = matches.docs.first.data();
    return BookingResult(
      status: data['status'] == 'cancelled'
          ? 'cancelled'
          : data['checkInAt'] != null
          ? 'checked-in'
          : 'confirmed',
      registrationId: matches.docs.first.id,
    );
  }
}
