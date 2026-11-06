import 'dart:async';

import '../app/cloud_providers.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/event_providers.dart';
import 'package:eventhub_core/eventhub_core.dart';

final notificationsProvider = StreamProvider.autoDispose<List<AppNotification>>(
  (ref) {
    final uid = ref.watch(signedInUidProvider);
    if (uid == null) return Stream.value([]);
    return ref.watch(notificationServiceProvider).watch(uid);
  },
);
final notificationsActionProvider =
    NotifierProvider.autoDispose<NotificationsViewModel, String?>(
      NotificationsViewModel.new,
    );

class NotificationsViewModel extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(signedInUidProvider);
    return null;
  }

  Future<String> open(AppNotification notification) async {
    final uid = ref.read(signedInUidProvider);
    if (uid == null) return '/auth/login';
    unawaited(track(ref, 'notification_open', {'source': 'in_app'}));
    try {
      if (notification.readAt == null) {
        await ref
            .read(notificationServiceProvider)
            .markRead(uid, notification.id);
      }
    } catch (_) {
      if (ref.mounted && ref.read(signedInUidProvider) == uid) {
        state =
            'Chưa đánh dấu đã đọc được. Bạn vẫn có thể xem nội dung hiện tại.';
      }
    }
    return ref.mounted && ref.read(signedInUidProvider) == uid
        ? notification.destination
        : '/auth/login';
  }
}
