import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../services/event_service_providers.dart';
import 'session_viewmodel.dart';
export '../services/event_service_providers.dart';
export 'session_viewmodel.dart' show signedInUidProvider;

final eventsProvider = StreamProvider.autoDispose<List<Event>>((ref) {
  if (ref.watch(signedInUidProvider) == null) return Stream.value([]);
  return ref.watch(eventServiceProvider).watchEvents();
});
final eventProvider = StreamProvider.autoDispose.family<Event?, String>((
  ref,
  id,
) {
  if (ref.watch(signedInUidProvider) == null) return Stream.value(null);
  return ref.watch(eventServiceProvider).watchEvent(id);
});
final registrationsProvider = StreamProvider.autoDispose<List<Registration>>((
  ref,
) {
  final uid = ref.watch(signedInUidProvider);
  if (uid == null) return Stream.value([]);
  return ref.watch(eventServiceProvider).watchRegistrations(uid);
});
final registrationProvider = StreamProvider.autoDispose
    .family<Registration?, String>((ref, id) {
      if (ref.watch(signedInUidProvider) == null) return Stream.value(null);
      return ref.watch(eventServiceProvider).watchRegistration(id);
    });
