import '../../models/event.dart';

abstract interface class EventService {
  Stream<List<Event>> watchEvents();
  Stream<Event?> watchEvent(String id);
  Stream<List<Registration>> watchRegistrations(String uid);
  Stream<Registration?> watchRegistration(String id);
  Future<BookingResult> execute(Map<String, dynamic> command);
  Future<BookingResult> recover(String operationId);
}

abstract interface class PendingBookingStore {
  Future<Map<String, dynamic>?> read(String uid);
  Future<void> write(String uid, Map<String, dynamic> command);
  Future<void> clear(String uid);
}

abstract interface class CheckinSessionService {
  Stream<bool> watchCheckinSession(String eventId);
}
