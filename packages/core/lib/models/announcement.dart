class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    this.scope = 'club',
    this.clubId = '',
    this.clubName = '',
    this.eventId,
    this.authorUid = '',
    this.authorRole = 'staff',
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String scope; // 'club' | 'event' | 'global'
  final String clubId;
  final String clubName;
  final String? eventId;
  final String authorUid;
  final String authorRole;
  final DateTime? createdAt;

  factory Announcement.fromJson(String id, Map<String, dynamic> data) =>
      Announcement(
        id: id,
        title: data['title'] as String? ?? '',
        body: data['body'] as String? ?? '',
        scope: data['scope'] as String? ?? 'club',
        clubId: data['clubId'] as String? ?? '',
        clubName: data['clubName'] as String? ?? '',
        eventId: data['eventId'] as String?,
        authorUid: data['authorUid'] as String? ?? '',
        authorRole: data['authorRole'] as String? ?? 'staff',
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] is DateTime
                  ? data['createdAt'] as DateTime
                  : DateTime.tryParse(data['createdAt'].toString()))
            : null,
      );

  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'body': body.trim(),
    'scope': scope,
    'clubId': clubId,
    'clubName': clubName,
    if (eventId != null && eventId!.isNotEmpty) 'eventId': eventId,
    'authorUid': authorUid,
    'authorRole': authorRole,
  };
}
