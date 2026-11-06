import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../services/firebase/firebase_auth_service.dart';

import 'package:eventhub_core/eventhub_core.dart';
import '../services/initial_auth_service.dart';
import '../viewmodels/session_viewmodel.dart';

/// Injected AuthService contract
final firebaseReadyProvider = Provider<bool>((ref) => false);


final authServiceProvider = Provider<AuthService>((ref) {
  if (ref.watch(firebaseReadyProvider)) {
    return FirebaseAuthService(
      firebase.FirebaseAuth.instance,
      FirebaseFirestore.instance,
    );
  }
  final service = InitialAuthService();
  ref.onDispose(service.dispose);
  return service;
});

/// Root session state provider managed by SessionViewModel
final sessionViewModelProvider = NotifierProvider<SessionViewModel, AuthState>(
  SessionViewModel.new,
);
