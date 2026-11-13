import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_providers.dart';
export '../services/auth_providers.dart';
import '../models/auth_state.dart';

class SessionViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    final authService = ref.watch(authServiceProvider);
    final subscription = authService.authStateChanges.listen((newState) {
      state = newState;
    });
    ref.onDispose(subscription.cancel);
    return authService.currentAuthState;
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }
}

final sessionViewModelProvider = NotifierProvider<SessionViewModel, AuthState>(
  SessionViewModel.new,
);
final signedInUidProvider = Provider<String?>((ref) {
  final auth = ref.watch(sessionViewModelProvider);
  return auth is AuthStateSignedIn && auth.isUser ? auth.uid : null;
});
