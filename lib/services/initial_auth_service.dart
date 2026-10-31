import 'dart:async';

import '../models/auth_state.dart';
import 'contracts/auth_service.dart';

/// Baseline authentication service before Firebase setup in Step 4.
/// Represents a non-authenticated session state; does not produce fake user logins.
class InitialAuthService implements AuthService {
  Never _unavailable() => throw const AuthServiceUnavailable();
  @override
  Future<void> signIn(String email, String password) async => _unavailable();
  @override
  Future<void> signInWithGoogle() async => _unavailable();
  @override
  Future<void> register(String name, String email, String password) async =>
      _unavailable();
  @override
  Future<void> sendVerification() async => _unavailable();
  @override
  Future<void> reloadUser() async => _unavailable();
  @override
  Future<void> resetPassword(String email) async => _unavailable();
  @override
  Future<void> changeEmail(String email, String password) async =>
      _unavailable();
  InitialAuthService() {
    _controller = StreamController<AuthState>.broadcast();
  }

  late final StreamController<AuthState> _controller;
  AuthState _current = const AuthState.signedOut();

  @override
  Stream<AuthState> get authStateChanges => _controller.stream;

  @override
  AuthState get currentAuthState => _current;

  @override
  Future<void> signOut() async {
    _current = const AuthState.signedOut();
    _controller.add(_current);
  }

  void dispose() {
    _controller.close();
  }
}

class AuthServiceUnavailable implements Exception {
  const AuthServiceUnavailable();
}
