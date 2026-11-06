import '../models/cloud_settings.dart';

PushTarget? pushDestination(
  Map<String, dynamic> data,
  String? currentUid, {
  required bool opened,
}) {
  if (currentUid == null ||
      (data['uid'] != null && data['uid'] != currentUid)) {
    return null;
  }
  String? valid(dynamic value) =>
      value is String && RegExp(r'^[\w-]+$').hasMatch(value) ? value : null;
  final registration = valid(data['registrationId']),
      event = valid(data['eventId']);
  return PushTarget(
    path: registration != null
        ? '/registrations/$registration'
        : event != null
        ? '/events/$event'
        : '/notifications',
    uid: currentUid,
    opened: opened,
  );
}
