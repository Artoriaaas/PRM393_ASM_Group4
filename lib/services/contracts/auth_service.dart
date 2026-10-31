import '../../models/auth_state.dart';

/// Contract interface for authentication operations (to be implemented with Firebase Auth in step 4)
abstract interface class AuthService {
  Stream<AuthState> get authStateChanges;
  AuthState get currentAuthState;
  Future<void> signOut();
  bool get canChangeEmail;
  Future<void> updateName(String name);
  Future<void> signIn(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> register(String name, String email, String password);
  Future<void> sendVerification();
  Future<void> reloadUser();
  Future<void> resetPassword(String email);
  Future<void> changeEmail(String email, String password);
}
