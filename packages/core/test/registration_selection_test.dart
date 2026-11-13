import 'package:eventhub_core/eventhub_core.dart';
import 'package:flutter_test/flutter_test.dart';

Registration row(String id, String status, int generation, int day) =>
    Registration(
      id: id,
      eventId: 'event',
      status: status,
      generation: generation,
      createdAt: DateTime(2030, 1, day),
      participant: const Participant(name: 'Test', email: 'test@example.org'),
    );

void main() {
  test('canonical cancellation overrides an approved legacy duplicate regardless of order', () {
    final old = row('legacy', 'approved', 9, 3);
    final current = row('alice_event', 'cancelled', 1, 1);
    for (final input in [
      [old, current],
      [current, old],
    ]) {
      expect(
        currentRegistrations(input, uid: 'alice').single.id,
        'alice_event',
      );
    }
  });
  test(
    'legacy duplicates use newest generation then time, not favourable status',
    () {
      final old = row('old', 'approved', 1, 1);
      final cancelled = row('new', 'cancelled', 2, 2);
      expect(currentRegistrations([old, cancelled]).single.status, 'cancelled');
      final later = row('latest', 'rejected', 2, 3);
      expect(currentRegistrations([later, old, cancelled]).single.id, 'latest');
    },
  );
  test('sending a proposal preserves its existing cover and content', () {
    final original = Event(
      id: 'event',
      title: 'Workshop',
      clubName: 'Club',
      location: 'Room',
      startsAt: DateTime(2030),
      endsAt: DateTime(2030, 1, 2),
      coverKey: 'design',
      coverUrl: 'https://example.org/cover.jpg',
      clubId: 'club',
      status: 'draft',
      capacity: 8,
    );
    final proposal = original.copyWith(status: 'pending_approval');
    expect(proposal.status, 'pending_approval');
    expect(proposal.coverKey, 'design');
    expect(proposal.coverUrl, original.coverUrl);
    expect(proposal.clubId, original.clubId);
    expect(proposal.capacity, original.capacity);
  });
}
