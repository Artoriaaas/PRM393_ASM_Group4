import 'package:eventhub_core/eventhub_core.dart';

class FakeEventService implements EventService {
  FakeEventService({this.events = const [], this.registrations = const []});
  final List<Event> events;
  final List<Registration> registrations;
  final commands = <Map<String, dynamic>>[];
  bool fail = false;
  BookingResult result = const BookingResult(
    status: 'confirmed',
    registrationId: 'r1',
  );
  @override
  Stream<List<Event>> watchEvents() => Stream.value(events);
  @override
  Stream<Event?> watchEvent(String id) =>
      Stream.value(events.where((e) => e.id == id).firstOrNull);
  @override
  Stream<List<Registration>> watchRegistrations(String uid) =>
      Stream.value(registrations);
  @override
  Stream<Registration?> watchRegistration(String id) =>
      Stream.value(registrations.where((r) => r.id == id).firstOrNull);
  @override
  Future<BookingResult> execute(Map<String, dynamic> c) async {
    commands.add(c);
    if (fail) throw StateError('offline');
    return result;
  }

  @override
  Future<BookingResult> recover(String operationId) async => result;
}

class MemoryPendingStore implements PendingBookingStore {
  final entries = <String, Map<String, dynamic>>{};
  @override
  Future<Map<String, dynamic>?> read(String uid) async => entries[uid];
  @override
  Future<void> write(String uid, Map<String, dynamic> c) async {
    entries[uid] = Map.from(c);
  }

  @override
  Future<void> clear(String uid) async {
    entries.remove(uid);
  }
}
