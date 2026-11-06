import '../../models/app_notification.dart';

abstract interface class NotificationService {
  Stream<List<AppNotification>> watch(String uid);
  Future<void> markRead(String uid, String id);
}
