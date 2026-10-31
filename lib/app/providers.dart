import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../services/firebase/firebase_auth_service.dart';

import '../models/auth_state.dart';
import '../services/contracts/auth_service.dart';
import '../services/initial_auth_service.dart';
import '../viewmodels/session_viewmodel.dart';

/// Injected AuthService contract
final firebaseReadyProvider = Provider<bool>((ref) => false);
final isUiPrototypeProvider = Provider<bool>((ref) => false);

final authServiceProvider = Provider<AuthService>((ref) {
  if (ref.watch(firebaseReadyProvider)) {
    return FirebaseAuthService(firebase.FirebaseAuth.instance);
  }
  final service = InitialAuthService();
  ref.onDispose(service.dispose);
  return service;
});

/// Root session state provider managed by SessionViewModel
final sessionViewModelProvider = NotifierProvider<SessionViewModel, AuthState>(
  SessionViewModel.new,
);
