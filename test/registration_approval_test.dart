import 'package:eventhub/models/event.dart';
import 'package:eventhub/viewmodels/event_viewmodels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const participant = Participant(
    name: 'Anh',
    email: 'anh@example.com',
    cohort: 'K18',
  );
  Registration registration(String status) => Registration(
    id: 'u_e',
    eventId: 'e',
    status: status,
    generation: 1,
    participant: participant,
  );
  test(
    'pending is acknowledged without granting check-in or hiding the request',
    () {
      final pending = registration('pending');
      expect(pending.active, isFalse);
      expect(pending.hasRequest, isTrue);
      expect(pending.statusLabel, 'Chờ duyệt');
      expect(scheduleBucket(pending, null, DateTime(2026)), 0);
      final result = registrationOutcome('u_e', {'status': 'pending'});
      expect(result.terminal, isTrue);
      expect(result.successful, isTrue);
      expect(result.status, 'pending');
    },
  );
  test('only approved and legacy active requests qualify for check-in', () {
    expect(registration('approved').active, isTrue);
    expect(registration('active').active, isTrue);
    for (final status in ['pending', 'rejected', 'cancelled', 'unknown']) {
      expect(registration(status).active, isFalse);
    }
    expect(registration('rejected').statusLabel, 'Bị từ chối');
    expect(scheduleBucket(registration('rejected'), null, DateTime(2026)), 2);
  });
  test(
    'recovery uses current server review outcome, never invents confirmation',
    () {
      expect(
        registrationOutcome('u_e', {'status': 'approved'}).status,
        'confirmed',
      );
      expect(
        registrationOutcome('u_e', {
          'status': 'approved',
          'checkInAt': DateTime(2026),
        }).status,
        'checked-in',
      );
      expect(
        registrationOutcome('u_e', {'status': 'cancelled'}).status,
        'cancelled',
      );
      final rejected = registrationOutcome('u_e', {'status': 'rejected'});
      expect(rejected.successful, isFalse);
      expect(rejected.code, 'registration-rejected');
      expect(
        registrationOutcome('u_e', {'status': 'invalid'}).terminal,
        isFalse,
      );
    },
  );
}
