import 'dart:async';

import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:eventhub/services/initial_auth_service.dart';
import 'package:eventhub/utils/app_failure.dart';
import 'package:eventhub/viewmodels/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAuthService extends InitialAuthService {
  int calls = 0;
  Completer<void>? pending;
  Object? error;
  @override
  Future<void> signIn(String email, String password) async {
    calls++;
    if (pending != null) await pending!.future;
    if (error != null) throw error!;
  }

  @override
  Future<void> resetPassword(String email) async {
    calls++;
    if (error != null) throw error!;
  }

  @override
  Future<void> signInWithGoogle() async {
    throw const AppFailure(
      code: 'canceled',
      message: 'Bạn đã hủy đăng nhập Google.',
    );
  }
}

void main() {
  late TestAuthService service;
  late ProviderContainer container;
  setUp(() {
    service = TestAuthService();
    container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(service)],
    );
  });
  tearDown(() {
    container.dispose();
    service.dispose();
  });
  test('invalid form stays local with field errors', () async {
    final ok = await container
        .read(authViewModelProvider.notifier)
        .submit('register', email: 'wrong', password: '123');
    expect(ok, false);
    expect(
      container.read(authViewModelProvider).errors.keys,
      containsAll(['name', 'email', 'password']),
    );
    expect(service.calls, 0);
  });
  test(
    'blocks duplicate submit and retains email after network failure',
    () async {
      service.pending = Completer<void>();
      service.error = const AppFailure(code: 'network', message: 'Mất mạng');
      final vm = container.read(authViewModelProvider.notifier);
      final first = vm.submit(
        'login',
        email: 'a@example.com',
        password: 'secret',
      );
      expect(
        await vm.submit('login', email: 'a@example.com', password: 'secret'),
        false,
      );
      expect(service.calls, 1);
      service.pending!.complete();
      expect(await first, false);
      expect(container.read(authViewModelProvider).email, 'a@example.com');
      expect(container.read(authViewModelProvider).busy, false);
    },
  );
  test('reset only confirms request after service success', () async {
    final vm = container.read(authViewModelProvider.notifier);
    service.error = const AppFailure(code: 'network', message: 'Mất mạng');
    expect(await vm.submit('reset', email: 'a@example.com'), false);
    expect(container.read(authViewModelProvider).message, 'Mất mạng');
    service.error = null;
    expect(await vm.submit('reset', email: 'a@example.com'), true);
    expect(
      container.read(authViewModelProvider).message,
      contains('Nếu email có tài khoản'),
    );
  });
  test('canceled Google does not invent a session', () async {
    expect(
      await container.read(authViewModelProvider.notifier).submit('google'),
      false,
    );
    expect(
      container.read(authViewModelProvider).message,
      contains('hủy đăng nhập Google'),
    );
    expect(service.currentAuthState.isSignedOut, true);
  });
  test('unconfigured service reports configuration missing', () async {
    final unconfigured = ProviderContainer();
    addTearDown(unconfigured.dispose);
    expect(
      await unconfigured
          .read(authViewModelProvider.notifier)
          .submit('login', email: 'a@example.com', password: 'secret'),
      false,
    );
    expect(
      unconfigured.read(authViewModelProvider).message,
      contains('Chưa kết nối Firebase'),
    );
  });
}
