import 'package:eventhub_core/eventhub_core.dart';

class WebUserProfile {
  const WebUserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.clubId,
    this.clubName,
  });

  final String uid;
  final String email;
  final String displayName;
  final String role; // 'user' | 'staff' | 'admin'
  final String? clubId;
  final String? clubName;

  bool get isStaff => role == 'staff' && clubId != null && clubId!.isNotEmpty;
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
  bool get isAuthorizedForWeb => isStaff || isAdmin;

  factory WebUserProfile.fromJson(String uid, Map<String, dynamic> data) =>
      WebUserProfile(
        uid: uid,
        email: data['email'] as String? ?? '',
        displayName: data['displayName'] as String? ?? '',
        role: data['role'] as String? ?? 'user',
        clubId: data['clubId'] as String?,
        clubName: data['clubName'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'displayName': displayName,
        'role': role,
        if (clubId != null) 'clubId': clubId,
        if (clubName != null) 'clubName': clubName,
      };
}
abstract class IWebAuthService {
  WebUserProfile? get currentUser;
  Stream<WebUserProfile?> authStateChanges();
  Future<Result<WebUserProfile>> signInWithGoogle();
  Future<void> signOut();
  Future<WebUserProfile?> fetchProfile(String uid);
}

abstract class IClubService {
  Future<Club?> getClub(String clubId);
  Stream<List<Event>> streamClubEvents(String clubId);
  Future<Result<String>> createEvent(Event event);
  Future<Result<void>> updateEvent(Event event);
  Future<Result<void>> archiveEvent(String eventId);
  Future<Result<void>> cancelEvent(String eventId);

  // Cross-Role Flow 2: Live QR & Session
  Stream<CheckinSession?> streamCheckinSession(String eventId);
  Future<Result<void>> toggleCheckinSession({
    required String eventId,
    required String clubId,
    required bool open,
    required String staffUid,
  });
  Future<Result<String>> generateAndRotateQrToken({
    required String eventId,
    required String clubId,
    required String staffUid,
  });
  Stream<List<Registration>> streamEventRegistrations(String eventId);

  // Cross-Role Flow 1: Review Queue
  Stream<List<Registration>> streamClubPendingRegistrations(String clubId);
  Stream<List<Registration>> streamAllClubRegistrations(String clubId);
  Future<Result<void>> approveRegistration({
    required String registrationId,
    required String eventId,
    required String studentUid,
    required String staffUid,
    String? note,
  });
  Future<Result<void>> rejectRegistration({
    required String registrationId,
    required String studentUid,
    required String staffUid,
    required String reason,
  });

  // Dashboard Aggregations
  Future<int> countPublishedEvents(String clubId);
  Future<int> countPendingRegistrations(String clubId);
  Future<int> countApprovedRegistrations(String clubId);
  Future<int> countCheckedInRegistrations(String clubId);

  // Announcements
  Stream<List<Announcement>> streamClubAnnouncements(String clubId);
  Future<Result<String>> publishAnnouncement(Announcement announcement);
}

abstract class IWebAnalyticsService {
  Future<void> logEvent(String name, [Map<String, Object>? parameters]);
}
