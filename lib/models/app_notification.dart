class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.eventId,
    required this.type,
    this.registrationId,
    this.createdAt,
    this.readAt,
  });
  final String id, title, body, eventId, type;
  final String? registrationId;
  final DateTime? createdAt, readAt;
  String get destination {
    bool valid(String? value) => value != null && RegExp(r'^[\w-]+$').hasMatch(value);
    if (valid(registrationId)) return '/registrations/$registrationId';
    if (valid(eventId)) return '/events/$eventId';
    return '/notifications';
  }
}
