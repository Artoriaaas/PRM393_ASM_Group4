import 'package:eventhub/app/providers.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/services/initial_auth_service.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:eventhub/viewmodels/profile_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Session extends SessionViewModel {
  @override
  AuthState build() => const AuthState.signedIn(uid: 'u', email: 'a@b.c');
}

class _Auth extends InitialAuthService {
  bool fail = false, allowEmail = false;
  String? lastName;
  @override
  bool get canChangeEmail => allowEmail;
  @override
  Future<void> updateName(String name) async {
    if (fail) throw StateError('offline');
    lastName = name;
  }

  @override
  Future<void> changeEmail(String email, String password) async {
    if (fail) throw StateError('offline');
  }
}

void main() {
  test('profile saves name and keeps Google email managed', () async {
    final auth = _Auth();
    addTearDown(auth.dispose);
    final c = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        sessionViewModelProvider.overrideWith(_Session.new),
      ],
    );
    addTearDown(c.dispose);
    final vm = c.read(profileProvider.notifier);
    await vm.save(
      name: 'Minh Anh',
      currentEmail: 'a@b.c',
      email: 'a@b.c',
      password: '',
    );
    expect(c.read(profileProvider).saved, true);
    expect(auth.lastName, 'Minh Anh');
    await vm.save(
      name: 'Minh Anh',
      currentEmail: 'a@b.c',
      email: 'new@b.c',
      password: 'abc',
    );
    expect(c.read(profileProvider).errors, contains('email'));
    expect(c.read(profileProvider).saved, false);
  });
  test('profile network failure is not marked saved', () async {
    final auth = _Auth()..fail = true;
    addTearDown(auth.dispose);
    final c = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        sessionViewModelProvider.overrideWith(_Session.new),
      ],
    );
    addTearDown(c.dispose);
    await c
        .read(profileProvider.notifier)
        .save(
          name: 'Minh Anh',
          currentEmail: 'a@b.c',
          email: 'a@b.c',
          password: '',
        );
    expect(c.read(profileProvider).saved, false);
    expect(c.read(profileProvider).message, contains('Chưa lưu'));
  });
}
