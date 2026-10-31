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
  String get destination => registrationId?.isNotEmpty == true
      ? '/registrations/$registrationId'
      : '/events/$eventId';
}
