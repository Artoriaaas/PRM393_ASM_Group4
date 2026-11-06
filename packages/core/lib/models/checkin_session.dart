class CheckinSession {
  const CheckinSession({
    required this.eventId,
    required this.clubId,
    required this.open,
    this.updatedBy = '',
    this.updatedAt,
  });

  final String eventId;
  final String clubId;
  final bool open;
  final String updatedBy;
  final DateTime? updatedAt;

  factory CheckinSession.fromJson(String eventId, Map<String, dynamic> data) =>
      CheckinSession(
        eventId: eventId,
        clubId: data['clubId'] as String? ?? '',
        open: data['open'] as bool? ?? false,
        updatedBy: data['updatedBy'] as String? ?? '',
        updatedAt: data['updatedAt'] != null
            ? (data['updatedAt'] is DateTime
                ? data['updatedAt'] as DateTime
                : DateTime.tryParse(data['updatedAt'].toString()))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'clubId': clubId,
        'open': open,
        'updatedBy': updatedBy,
      };
}
