import '../../models/auth_state.dart';

/// Contract interface for authentication operations (to be implemented with Firebase Auth in step 4)
abstract interface class AuthService {
  Stream<AuthState> get authStateChanges;
  AuthState get currentAuthState;
  Future<void> signOut();
}
