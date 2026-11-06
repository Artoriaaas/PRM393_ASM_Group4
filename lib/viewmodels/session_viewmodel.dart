import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import 'package:eventhub_core/eventhub_core.dart';

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
