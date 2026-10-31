import 'dart:async';

import '../models/auth_state.dart';
import 'contracts/auth_service.dart';

/// Baseline authentication service before Firebase setup in Step 4.
/// Represents a non-authenticated session state; does not produce fake user logins.
class InitialAuthService implements AuthService {
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
