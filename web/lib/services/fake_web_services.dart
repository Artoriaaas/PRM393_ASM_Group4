import 'dart:async';
import 'package:eventhub_core/eventhub_core.dart';
import 'web_contracts.dart';

class FakeWebAuthService implements IWebAuthService {
  FakeWebAuthService({WebUserProfile? initialUser}) {
    _currentUser = initialUser;
    _controller = StreamController<WebUserProfile?>.broadcast(
      onListen: () => _controller.add(_currentUser),
    );
  }

  WebUserProfile? _currentUser;
  late final StreamController<WebUserProfile?> _controller;

  WebUserProfile? nextSignInUser;
  bool shouldFailSignIn = false;
  String? signInErrorMessage;

  @override
  WebUserProfile? get currentUser => _currentUser;

  @override
  Stream<WebUserProfile?> authStateChanges() => _controller.stream;

  @override
  Future<WebUserProfile?> fetchProfile(String uid) async {
    if (_currentUser?.uid == uid) return _currentUser;
    return null;
  }

  @override
  Future<Result<WebUserProfile>> signInWithGoogle() async {
    if (shouldFailSignIn) {
      return Result.failure(
        AppFailure(
          code: 'sign_in_failed',
          message: signInErrorMessage ?? 'Đăng nhập Google thất bại.',
        ),
      );
    }
    final user = nextSignInUser ??
        const WebUserProfile(
          uid: 'staff_1',
          email: 'staff@fpt.edu.vn',
          displayName: 'Trưởng CLB IT',
          role: 'staff',
          clubId: 'club_it',
          clubName: 'Câu lạc bộ IT',
        );
    _currentUser = user;
    _controller.add(user);
    return Result.success(user);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  void emitUser(WebUserProfile? user) {
    _currentUser = user;
    _controller.add(user);
  }
}

class FakeClubService implements IClubService {
  FakeClubService({
    List<Event>? initialEvents,
    List<Registration>? initialRegistrations,
    List<Announcement>? initialAnnouncements,
  }) {
    _events = initialEvents ?? [];
    _registrations = initialRegistrations ?? [];
    _announcements = initialAnnouncements ?? [];
    _eventsController = StreamController<List<Event>>.broadcast(
      onListen: () => _eventsController.add(_events),
    );
    _registrationsController = StreamController<List<Registration>>.broadcast(
      onListen: () => _registrationsController.add(_registrations),
    );
    _announcementsController = StreamController<List<Announcement>>.broadcast(
      onListen: () => _announcementsController.add(_announcements),
    );
  }

  late List<Event> _events;
  late List<Registration> _registrations;
  late List<Announcement> _announcements;
  final Map<String, CheckinSession> _sessions = {};
  final Map<String, StreamController<CheckinSession?>> _sessionControllers = {};

  late final StreamController<List<Event>> _eventsController;
  late final StreamController<List<Registration>> _registrationsController;
  late final StreamController<List<Announcement>> _announcementsController;

  @override
  Future<Club?> getClub(String clubId) async {
    return const Club(
      id: 'club_it',
      name: 'Câu lạc bộ IT FPTU',
      shortName: 'IT Club',
      description: 'CLB Học thuật CNTT hàng đầu',
    );
  }

  @override
  Stream<List<Event>> streamClubEvents(String clubId) =>
      _eventsController.stream.map(
        (list) => list.where((e) => e.clubId == clubId).toList(),
      );

  @override
  Future<Result<String>> createEvent(Event event) async {
    _events.add(event);
    _eventsController.add(List.from(_events));
    return Result.success(event.id);
  }

  @override
  Future<Result<void>> updateEvent(Event event) async {
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx != -1) {
      _events[idx] = event;
      _eventsController.add(List.from(_events));
    }
    return Result.success(null);
  }

  @override
  Future<Result<void>> archiveEvent(String eventId) async {
    final idx = _events.indexWhere((e) => e.id == eventId);
    if (idx != -1) {
      final old = _events[idx];
      _events[idx] = Event(
        id: old.id,
        title: old.title,
        clubName: old.clubName,
        location: old.location,
        startsAt: old.startsAt,
        endsAt: old.endsAt,
        deadline: old.deadline,
        description: old.description,
        coverKey: old.coverKey,
        topic: old.topic,
        audience: old.audience,
        preparation: old.preparation,
        activities: old.activities,
        mode: old.mode,
        status: 'archived',
        capacity: old.capacity,
        activeCount: old.activeCount,
        clubId: old.clubId,
        visibility: old.visibility,
        updatedAt: DateTime.now(),
      );
      _eventsController.add(List.from(_events));
    }
    return Result.success(null);
  }

  @override
  Future<Result<void>> cancelEvent(String eventId) async {
    final idx = _events.indexWhere((e) => e.id == eventId);
    if (idx != -1) {
      final old = _events[idx];
      _events[idx] = Event(
        id: old.id,
        title: old.title,
        clubName: old.clubName,
        location: old.location,
        startsAt: old.startsAt,
        endsAt: old.endsAt,
        deadline: old.deadline,
        description: old.description,
        coverKey: old.coverKey,
        topic: old.topic,
        audience: old.audience,
        preparation: old.preparation,
        activities: old.activities,
        mode: old.mode,
        status: 'cancelled',
        capacity: old.capacity,
        activeCount: old.activeCount,
        clubId: old.clubId,
        visibility: old.visibility,
        updatedAt: DateTime.now(),
      );
      _eventsController.add(List.from(_events));
    }
    return Result.success(null);
  }

  @override
  Stream<CheckinSession?> streamCheckinSession(String eventId) {
    _sessionControllers.putIfAbsent(
      eventId,
      () => StreamController<CheckinSession?>.broadcast(
        onListen: () => _sessionControllers[eventId]?.add(_sessions[eventId]),
      ),
    );
    return _sessionControllers[eventId]!.stream;
  }

  @override
  Future<Result<void>> toggleCheckinSession({
    required String eventId,
    required String clubId,
    required bool open,
    required String staffUid,
  }) async {
    final session = CheckinSession(
      eventId: eventId,
      clubId: clubId,
      open: open,
      updatedBy: staffUid,
      updatedAt: DateTime.now(),
    );
    _sessions[eventId] = session;
    _sessionControllers[eventId]?.add(session);
    return Result.success(null);
  }

  @override
  Future<Result<String>> generateAndRotateQrToken({
    required String eventId,
    required String clubId,
    required String staffUid,
  }) async {
    final token =
        'EVT_${eventId}_${DateTime.now().millisecondsSinceEpoch}_SECURE_TOKEN_RANDOM';
    return Result.success(token);
  }

  @override
  Stream<List<Registration>> streamEventRegistrations(String eventId) =>
      _registrationsController.stream.map(
        (list) => list.where((r) => r.eventId == eventId).toList(),
      );

  @override
  Stream<List<Registration>> streamClubPendingRegistrations(String clubId) =>
      _registrationsController.stream.map(
        (list) =>
            list.where((r) => r.clubId == clubId && r.isPending).toList(),
      );

  @override
  Stream<List<Registration>> streamAllClubRegistrations(String clubId) =>
      _registrationsController.stream.map(
        (list) => list.where((r) => r.clubId == clubId).toList(),
      );

  @override
  Future<Result<void>> approveRegistration({
    required String registrationId,
    required String eventId,
    required String studentUid,
    required String staffUid,
    String? note,
  }) async {
    final evIdx = _events.indexWhere((e) => e.id == eventId);
    if (evIdx != -1) {
      final ev = _events[evIdx];
      if (ev.activeCount >= ev.capacity) {
        return Result.failure(
          const AppFailure(
            code: 'event_full',
            message: 'Sự kiện đã đầy chỗ, không thể duyệt thêm.',
          ),
        );
      }
      _events[evIdx] = Event(
        id: ev.id,
        title: ev.title,
        clubName: ev.clubName,
        location: ev.location,
        startsAt: ev.startsAt,
        endsAt: ev.endsAt,
        deadline: ev.deadline,
        description: ev.description,
        coverKey: ev.coverKey,
        topic: ev.topic,
        audience: ev.audience,
        preparation: ev.preparation,
        activities: ev.activities,
        mode: ev.mode,
        status: ev.status,
        capacity: ev.capacity,
        activeCount: ev.activeCount + 1,
        clubId: ev.clubId,
        visibility: ev.visibility,
        updatedAt: DateTime.now(),
      );
      _eventsController.add(List.from(_events));
    }

    final regIdx = _registrations.indexWhere((r) => r.id == registrationId);
    if (regIdx != -1) {
      final old = _registrations[regIdx];
      _registrations[regIdx] = Registration(
        id: old.id,
        eventId: old.eventId,
        status: 'approved',
        generation: old.generation,
        participant: old.participant,
        uid: old.uid,
        clubId: old.clubId,
        checkInAt: old.checkInAt,
        createdAt: old.createdAt,
        reason: note,
        reviewedBy: staffUid,
        reviewedAt: DateTime.now(),
        qrHash: old.qrHash,
        lastOperationId: old.lastOperationId,
      );
      _registrationsController.add(List.from(_registrations));
    }
    return Result.success(null);
  }

  @override
  Future<Result<void>> rejectRegistration({
    required String registrationId,
    required String studentUid,
    required String staffUid,
    required String reason,
  }) async {
    if (reason.trim().length < 3) {
      return Result.failure(
        const AppFailure(
          code: 'invalid_reason',
          message: 'Lý do từ chối phải có tối thiểu 3 ký tự.',
        ),
      );
    }
    final regIdx = _registrations.indexWhere((r) => r.id == registrationId);
    if (regIdx != -1) {
      final old = _registrations[regIdx];
      _registrations[regIdx] = Registration(
        id: old.id,
        eventId: old.eventId,
        status: 'rejected',
        generation: old.generation,
        participant: old.participant,
        uid: old.uid,
        clubId: old.clubId,
        checkInAt: old.checkInAt,
        createdAt: old.createdAt,
        reason: reason.trim(),
        reviewedBy: staffUid,
        reviewedAt: DateTime.now(),
        qrHash: old.qrHash,
        lastOperationId: old.lastOperationId,
      );
      _registrationsController.add(List.from(_registrations));
    }
    return Result.success(null);
  }

  @override
  Future<int> countPublishedEvents(String clubId) async {
    return _events.where((e) => e.clubId == clubId && e.status == 'published').length;
  }

  @override
  Future<int> countPendingRegistrations(String clubId) async {
    return _registrations
        .where((r) => r.clubId == clubId && r.status == 'pending')
        .length;
  }

  @override
  Future<int> countApprovedRegistrations(String clubId) async {
    return _registrations
        .where((r) => r.clubId == clubId && r.status == 'approved')
        .length;
  }

  @override
  Future<int> countCheckedInRegistrations(String clubId) async {
    return _registrations
        .where((r) => r.clubId == clubId && r.checkInAt != null)
        .length;
  }

  @override
  Stream<List<Announcement>> streamClubAnnouncements(String clubId) =>
      _announcementsController.stream.map(
        (list) => list.where((a) => a.clubId == clubId).toList(),
      );

  @override
  Future<Result<String>> publishAnnouncement(Announcement announcement) async {
    _announcements.insert(0, announcement);
    _announcementsController.add(List.from(_announcements));
    return Result.success(announcement.id);
  }
}

class FakeWebAnalyticsService implements IWebAnalyticsService {
  final List<String> loggedEvents = [];

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    loggedEvents.add(name);
  }
}
