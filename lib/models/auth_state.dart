/// Core authentication session states described in architecture.md section 6
sealed class AuthState {
  const AuthState();

  const factory AuthState.restoring() = AuthStateRestoring;
  const factory AuthState.signedOut() = AuthStateSignedOut;
  const factory AuthState.unverified({
    required String uid,
    required String email,
  }) = AuthStateUnverified;
  const factory AuthState.signedIn({
    required String uid,
    required String email,
    String? displayName,
  }) = AuthStateSignedIn;

  bool get isSignedIn => this is AuthStateSignedIn;
  bool get isSignedOut => this is AuthStateSignedOut;
  bool get isRestoring => this is AuthStateRestoring;
  bool get isUnverified => this is AuthStateUnverified;
}

final class AuthStateRestoring extends AuthState {
  const AuthStateRestoring();
}

final class AuthStateSignedOut extends AuthState {
  const AuthStateSignedOut();
}

final class AuthStateUnverified extends AuthState {
  const AuthStateUnverified({required this.uid, required this.email});

  final String uid;
  final String email;
}

final class AuthStateSignedIn extends AuthState {
  const AuthStateSignedIn({
    required this.uid,
    required this.email,
    this.displayName,
  });

  final String uid;
  final String email;
  final String? displayName;
}
