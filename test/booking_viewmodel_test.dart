import 'package:eventhub/app/providers.dart';
import 'package:eventhub/app/event_providers.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub/viewmodels/booking_viewmodel.dart';
import 'package:eventhub/viewmodels/event_viewmodels.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_event_service.dart';

class Session extends SessionViewModel {
  @override
  AuthState build() =>
      const AuthState.signedIn(uid: 'u1', email: 'test@example.com');
  void change(String uid) =>
      state = AuthState.signedIn(uid: uid, email: 'test@example.com');
}

void main() {
  late ProviderContainer container;
  late FakeEventService service;
  late MemoryPendingStore store;
  const p = Participant(
    name: 'Minh Anh',
    email: 'test@example.com',
    cohort: 'K18',
  );
  setUp(() {
    service = FakeEventService();
    store = MemoryPendingStore();
    container = ProviderContainer(
      overrides: [
        sessionViewModelProvider.overrideWith(Session.new),
        eventServiceProvider.overrideWithValue(service),
        pendingBookingStoreProvider.overrideWithValue(store),
      ],
    );
  });
  tearDown(() => container.dispose());
  test('validates student K and accepts guest without K', () async {
    final vm = container.read(bookingProvider.notifier);
    await vm.submit('e1', const Participant(name: 'A', email: 'a@b.c'));
    expect(service.commands, isEmpty);
    expect(container.read(bookingProvider).errors, contains('cohort'));
    await vm.submit(
      'e1',
      const Participant(name: 'A', email: 'a@b.c', group: 'guest'),
    );
    expect(service.commands, hasLength(1));
    expect(store.entries, isEmpty);
  });
  test('rapid taps submit only one command', () async {
    final vm = container.read(bookingProvider.notifier);
    await Future.wait([vm.submit('e1', p), vm.submit('e1', p)]);
    expect(service.commands, hasLength(1));
  });
  test(
    'unknown retains encrypted-store command and exact operation across retry',
    () async {
      service.fail = true;
      final vm = container.read(bookingProvider.notifier);
      await vm.submit('e1', p);
      final original = service.commands.single;
      expect(container.read(bookingProvider).unresolved, true);
      await vm.submit('e2', p);
      expect(service.commands, hasLength(1));
      service.fail = false;
      service.result = const BookingResult(status: 'unknown');
      await vm.recover();
      expect(container.read(bookingProvider).unresolved, true);
      service.result = const BookingResult(
        status: 'confirmed',
        registrationId: 'r1',
      );
      await vm.retryPending();
      expect(service.commands.last, original);
      expect(container.read(bookingProvider).unresolved, false);
      expect(store.entries, isEmpty);
    },
  );
  test('restores same-user pending operation without sending it', () async {
    store.entries['u1'] = {
      'action': 'register',
      'eventId': 'e1',
      'operationId': 'same-operation-id',
    };
    await container.read(bookingProvider.notifier).restore();
    expect(container.read(bookingProvider).pending?['eventId'], 'e1');
    expect(service.commands, isEmpty);
  });
  test(
    'session change clears previous UI and cannot expose another UID pending',
    () async {
      service.fail = true;
      await container.read(bookingProvider.notifier).submit('e1', p);
      (container.read(sessionViewModelProvider.notifier) as Session).change(
        'u2',
      );
      expect(container.read(bookingProvider).pending, isNull);
      await container.read(bookingProvider.notifier).restore();
      expect(container.read(bookingProvider).pending, isNull);
    },
  );
  test('terminal backend rejection never reports success', () async {
    service.result = const BookingResult(
      status: 'rejected',
      code: 'event-full',
    );
    await container.read(bookingProvider.notifier).submit('e1', p);
    expect(container.read(bookingProvider).result!.successful, false);
    expect(container.read(bookingProvider).message, contains('hết chỗ'));
    expect(store.entries, isEmpty);
  });
  test('filter uses Vietnam day and combines keyword/topic/club', () {
    final e = Event(
      id: 'e1',
      title: 'Thiết kế',
      clubName: 'FPTU',
      location: 'A',
      topic: 'UX',
      startsAt: DateTime.utc(2026, 11, 1, 1),
      endsAt: DateTime.utc(2026, 11, 1, 3),
    );
    expect(
      filterEvents(
        [e],
        const EventFilter(
          query: 'thiết',
          topic: 'UX',
          club: 'FPTU',
          today: true,
        ),
        DateTime.utc(2026, 10, 31, 18),
      ),
      hasLength(1),
    );
    expect(
      filterEvents([e], const EventFilter(query: 'music'), DateTime.utc(2026)),
      isEmpty,
    );
  });
  test('schedule distinguishes self-cancel and ended events', () {
    final e = Event(
      id: 'e1',
      title: 'T',
      clubName: 'C',
      location: 'A',
      startsAt: DateTime.utc(2026),
      endsAt: DateTime.utc(2026, 1, 1, 1),
    );
    const r = Registration(
      id: 'r',
      eventId: 'e1',
      status: 'cancelled',
      generation: 1,
      participant: p,
    );
    expect(scheduleBucket(r, e, DateTime.utc(2027)), 2);
  });
}
