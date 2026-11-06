import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'firebase/firebase_auth_service.dart';

import 'contracts/auth_service.dart';
import 'initial_auth_service.dart';

/// Injected AuthService contract
final firebaseReadyProvider = Provider<bool>((ref) => false);

final authServiceProvider = Provider<AuthService>((ref) {
  if (ref.watch(firebaseReadyProvider)) {
    return FirebaseAuthService(firebase.FirebaseAuth.instance);
  }
  final service = InitialAuthService();
  ref.onDispose(service.dispose);
  return service;
});
