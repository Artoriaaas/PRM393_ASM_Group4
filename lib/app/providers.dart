import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_state.dart';
import '../services/contracts/auth_service.dart';
import '../services/initial_auth_service.dart';
import '../viewmodels/session_viewmodel.dart';

/// Injected AuthService contract
final authServiceProvider = Provider<AuthService>((ref) {
  final service = InitialAuthService();
  ref.onDispose(service.dispose);
  return service;
});

/// Root session state provider managed by SessionViewModel
final sessionViewModelProvider = NotifierProvider<SessionViewModel, AuthState>(
  SessionViewModel.new,
);
