import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../models/event.dart';
import '../contracts/event_service.dart';

class FirestoreEventService implements EventService {
  FirestoreEventService(this.db, this.functions);
  final FirebaseFirestore db;
  final FirebaseFunctions functions;
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
    try {
      final response = await functions
          .httpsCallable(
            'bookingCommand',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 25)),
          )
          .call(command);
      return BookingResult.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on FirebaseFunctionsException catch (error) {
      // These statuses are explicit server rejections, never a network inference.
      if ([
        'invalid-argument',
        'unauthenticated',
        'permission-denied',
        'already-exists',
      ].contains(error.code)) {
        return BookingResult(status: 'rejected', code: error.message);
      }
      rethrow;
    }
  }

  @override
  Future<BookingResult> recover(String operationId) async =>
      BookingResult.fromJson(
        Map<String, dynamic>.from(
          (await functions.httpsCallable('bookingStatus').call({
                'operationId': operationId,
              })).data
              as Map,
        ),
      );
}
