class QrCredential {
  const QrCredential({
    required this.qrHash,
    required this.eventId,
    required this.clubId,
    required this.enabled,
    this.createdBy = '',
    this.createdAt,
  });

  final String qrHash;
  final String eventId;
  final String clubId;
  final bool enabled;
  final String createdBy;
  final DateTime? createdAt;

  factory QrCredential.fromJson(String qrHash, Map<String, dynamic> data) =>
      QrCredential(
        qrHash: qrHash,
        eventId: data['eventId'] as String? ?? '',
        clubId: data['clubId'] as String? ?? '',
        enabled: data['enabled'] as bool? ?? true,
        createdBy: data['createdBy'] as String? ?? '',
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] is DateTime
                ? data['createdAt'] as DateTime
                : DateTime.tryParse(data['createdAt'].toString()))
            : null,
      );

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'clubId': clubId,
        'enabled': enabled,
        'createdBy': createdBy,
      };
}
