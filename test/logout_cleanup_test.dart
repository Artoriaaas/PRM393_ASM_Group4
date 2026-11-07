import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/services/initial_auth_service.dart';
import 'package:eventhub/services/auth_providers.dart';
import 'package:eventhub/services/event_service_providers.dart';
import 'package:eventhub/viewmodels/auth_viewmodel.dart';
import 'package:eventhub/viewmodels/booking_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_event_service.dart';

class SignedInAuth extends InitialAuthService {
  int signOutCalls = 0;
  @override
  AuthState get currentAuthState =>
      const AuthState.signedIn(uid: 'u', email: 'test@example.com');
  @override
  Future<void> signOut() async {
    signOutCalls++;
    await super.signOut();
  }
}

class FailingStore extends MemoryPendingStore {
  @override
  Future<void> clear(String uid) async =>
      throw StateError('secure storage unavailable');
}

class BusyBooking extends BookingViewModel {
  @override
  BookingState build() => const BookingState(busy: true);
}

void main() {
  test('logout cannot race an in-flight booking write', () async {
    final auth = SignedInAuth();
    final store = MemoryPendingStore();
    store.entries['u'] = {'operationId': 'in-flight'};
    final c = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        pendingBookingStoreProvider.overrideWithValue(store),
        bookingProvider.overrideWith(BusyBooking.new),
      ],
    );
    expect(
      await c.read(authViewModelProvider.notifier).submit('logout'),
      false,
    );
    expect(auth.signOutCalls, 0);
    expect(store.entries['u'], isNotNull);
    expect(c.read(authViewModelProvider).message, contains('Đang xử lý'));
    c.dispose();
    auth.dispose();
  });
  test('logout removes only the current account pending command', () async {
    final auth = SignedInAuth();
    final store = MemoryPendingStore();
    store.entries.addAll({
      'u': {'operationId': 'pending'},
      'other': {'operationId': 'other'},
    });
    final c = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        pendingBookingStoreProvider.overrideWithValue(store),
      ],
    );
    expect(await c.read(authViewModelProvider.notifier).submit('logout'), true);
    expect(auth.signOutCalls, 1);
    expect(store.entries.containsKey('u'), false);
    expect(store.entries.containsKey('other'), true);
    expect(c.read(authViewModelProvider).email, isEmpty);
    c.dispose();
    auth.dispose();
  });
  test(
    'cleanup failure is visible and does not claim successful logout',
    () async {
      final auth = SignedInAuth();
      final c = ProviderContainer(
        overrides: [
          authServiceProvider.overrideWithValue(auth),
          pendingBookingStoreProvider.overrideWithValue(FailingStore()),
        ],
      );
      expect(
        await c.read(authViewModelProvider.notifier).submit('logout'),
        false,
      );
      expect(auth.signOutCalls, 0);
      expect(c.read(authViewModelProvider).message, isNotNull);
      expect(c.read(authViewModelProvider).busy, false);
      c.dispose();
      auth.dispose();
    },
  );
}
