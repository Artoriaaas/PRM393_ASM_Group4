// Test-only in-memory services. Never used by production entrypoints.
import 'dart:async';
import 'dart:convert' show utf8;

import 'package:crypto/crypto.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_web/services/web_contracts.dart';

class FakeWebAuthService implements IWebAuthService {
  FakeWebAuthService({WebUserProfile? initialUser}) {
    _currentUser = initialUser;
    _controller = StreamController<WebUserProfile?>.broadcast();
  }

  WebUserProfile? _currentUser;
  late final StreamController<WebUserProfile?> _controller;

  WebUserProfile? nextSignInUser;
  bool shouldFailSignIn = false;
  String? signInErrorMessage;

  @override
  WebUserProfile? get currentUser => _currentUser;

  @override
  Stream<WebUserProfile?> authStateChanges() {
    late StreamController<WebUserProfile?> controller;
    StreamSubscription<WebUserProfile?>? sub;
    controller = StreamController<WebUserProfile?>(
      onListen: () {
        controller.add(_currentUser);
        sub = _controller.stream.listen(
          controller.add,
          onError: controller.addError,
        );
      },
      onCancel: () => sub?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<Result<WebUserProfile>> fetchProfile(String uid) async {
    if (_currentUser?.uid == uid && _currentUser != null) {
      return Result.success(_currentUser!);
    }
    return Result.failure(
      const AppFailure(
        code: 'profile_not_found',
        message: 'Không tìm thấy hồ sơ người dùng.',
      ),
    );
  }

  @override
  Future<Result<WebUserProfile>> signInWithGoogle() async {
    if (shouldFailSignIn) {
      return Result.failure(
        AppFailure(
          code: 'sign_in_failed',
          message: signInErrorMessage ?? 'Đăng nhập Google thất bại.',
          isRetryable: true,
        ),
      );
    }
    final user =
        nextSignInUser ??
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

  Future<void> dispose() async {
    await _controller.close();
  }
}

class FakeClubService implements IClubService {
  FakeClubService({
    List<Event>? initialEvents,
    List<Registration>? initialRegistrations,
    List<Announcement>? initialAnnouncements,
    Map<String, Club>? clubs,
    this.shouldFailLoad = false,
    this.loadDelay = Duration.zero,
  }) {
    _events = List<Event>.from(initialEvents ?? const []);
    _registrations = List<Registration>.from(initialRegistrations ?? const []);
    _announcements = List<Announcement>.from(initialAnnouncements ?? const []);
    _clubs = Map<String, Club>.from(
      clubs ??
          const {
            'club_it': Club(
              id: 'club_it',
              name: 'Câu lạc bộ IT FPTU',
              shortName: 'IT Club',
              description: 'CLB Học thuật CNTT',
            ),
          },
    );
    _eventsController = StreamController<List<Event>>.broadcast();
    _registrationsController = StreamController<List<Registration>>.broadcast();
    _announcementsController = StreamController<List<Announcement>>.broadcast();
  }

  Stream<T> _replayStream<T>(T Function() snapshot, Stream<T> updates) {
    late StreamController<T> controller;
    StreamSubscription<T>? sub;
    controller = StreamController<T>(
      onListen: () {
        void emitInitial() {
          if (controller.isClosed) return;
          if (shouldFailLoad) {
            controller.addError(Exception('Lỗi kết nối Firestore giả lập.'));
          } else {
            controller.add(snapshot());
          }
        }

        if (loadDelay > Duration.zero) {
          Future<void>.delayed(loadDelay, emitInitial);
        } else {
          emitInitial();
        }
        sub = updates.listen(controller.add, onError: controller.addError);
      },
      onCancel: () => sub?.cancel(),
    );
    return controller.stream;
  }

  bool shouldFailLoad;
  Duration loadDelay;
  int _qrSequence = 0;

  late List<Event> _events;
  late List<Registration> _registrations;
  late List<Announcement> _announcements;
  late Map<String, Club> _clubs;
  final Map<String, CheckinSession> _sessions = {};
  final Map<String, StreamController<CheckinSession?>> _sessionControllers = {};
  final Map<String, QrCredential> qrCredentials = {};
  final List<Map<String, dynamic>> sentNotifications = [];

  late final StreamController<List<Event>> _eventsController;
  late final StreamController<List<Registration>> _registrationsController;
  late final StreamController<List<Announcement>> _announcementsController;

  void _checkFail() {
    if (shouldFailLoad) {
      throw Exception('Không thể kết nối máy chủ Firestore.');
    }
  }

  @override
  Future<Club?> getClub(String clubId) async {
    if (loadDelay > Duration.zero) await Future<void>.delayed(loadDelay);
    _checkFail();
    return _clubs[clubId] ??
        Club(id: clubId, name: 'CLB $clubId', shortName: clubId);
  }

  @override
  Stream<List<Event>> streamClubEvents(String clubId) => _replayStream(
    () => List<Event>.unmodifiable(_events),
    _eventsController.stream,
  ).map((list) => list.where((e) => e.clubId == clubId).toList());

  @override
  Stream<Event?> streamEvent(String eventId) => _replayStream(
    () => List<Event>.unmodifiable(_events),
    _eventsController.stream,
  ).map((list) => list.where((e) => e.id == eventId).firstOrNull);

  @override
  Future<Result<String>> createEvent(Event event) async {
    final generatedId = event.id.isEmpty
        ? 'ev_${_events.length + 1}'
        : event.id;
    final stored = Event(
      id: generatedId,
      title: event.title,
      clubName: event.clubName,
      location: event.location,
      startsAt: event.startsAt,
      endsAt: event.endsAt,
      deadline: event.deadline,
      description: event.description,
      coverKey: event.coverKey,
      topic: event.topic,
      audience: event.audience,
      preparation: event.preparation,
      activities: event.activities,
      mode: event.mode,
      status: event.status,
      capacity: event.capacity,
      activeCount: 0,
      clubId: event.clubId,
      visibility: event.visibility,
      updatedAt: DateTime.now(),
    );
    _events.add(stored);
    _eventsController.add(List<Event>.unmodifiable(_events));
    return Result.success(generatedId);
  }

  @override
  Future<Result<void>> updateEvent(Event event) async {
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx == -1) {
      return Result.failure(
        const AppFailure(
          code: 'event_not_found',
          message: 'Không tìm thấy sự kiện.',
        ),
      );
    }
    if (event.mode == 'required' && event.capacity < _events[idx].activeCount) {
      return Result.failure(
        const AppFailure(
          code: 'capacity_below_active',
          message: 'Sức chứa không được nhỏ hơn số lượng đã duyệt hiện tại.',
        ),
      );
    }
    _events[idx] = event;
    _eventsController.add(List<Event>.unmodifiable(_events));
    return const Success(null);
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
      _eventsController.add(List<Event>.unmodifiable(_events));
    }
    return const Success(null);
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
      _eventsController.add(List<Event>.unmodifiable(_events));
    }
    return const Success(null);
  }

  @override
  Stream<CheckinSession?> streamCheckinSession(String eventId) {
    final ctrl = _sessionControllers.putIfAbsent(
      eventId,
      StreamController<CheckinSession?>.broadcast,
    );
    return _replayStream(() => _sessions[eventId], ctrl.stream);
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
    return const Success(null);
  }

  @override
  Future<Result<QrTokenBundle>> generateAndRotateQrToken({
    required String eventId,
    required String clubId,
    required String staffUid,
    String? previousQrHash,
  }) async {
    // Disable previous QR credentials for this event on rotation
    if (previousQrHash != null && qrCredentials.containsKey(previousQrHash)) {
      final prev = qrCredentials[previousQrHash]!;
      qrCredentials[previousQrHash] = QrCredential(
        qrHash: prev.qrHash,
        eventId: prev.eventId,
        clubId: prev.clubId,
        enabled: false,
        createdBy: prev.createdBy,
        createdAt: prev.createdAt,
      );
    }
    for (final entry in qrCredentials.entries.toList()) {
      if (entry.value.eventId == eventId &&
          entry.value.clubId == clubId &&
          entry.value.enabled) {
        qrCredentials[entry.key] = QrCredential(
          qrHash: entry.key,
          eventId: entry.value.eventId,
          clubId: entry.value.clubId,
          enabled: false,
          createdBy: entry.value.createdBy,
          createdAt: entry.value.createdAt,
        );
      }
    }

    _qrSequence++;
    final rawToken =
        'EVT_${eventId}_${_qrSequence}_SECURE_RANDOM_TOKEN_32CHARS_MIN';
    final qrHash = sha256.convert(utf8.encode(rawToken)).toString();
    qrCredentials[qrHash] = QrCredential(
      qrHash: qrHash,
      eventId: eventId,
      clubId: clubId,
      enabled: true,
      createdBy: staffUid,
      createdAt: DateTime.now(),
    );
    return Result.success(QrTokenBundle(rawToken: rawToken, qrHash: qrHash));
  }

  @override
  Stream<List<Registration>> streamEventRegistrations(String eventId) =>
      _replayStream(
        () => List<Registration>.unmodifiable(_registrations),
        _registrationsController.stream,
      ).map((list) => list.where((r) => r.eventId == eventId).toList());

  @override
  Stream<List<Registration>> streamClubPendingRegistrations(String clubId) =>
      _replayStream(
        () => List<Registration>.unmodifiable(_registrations),
        _registrationsController.stream,
      ).map(
        (list) => list.where((r) => r.clubId == clubId && r.isPending).toList(),
      );

  @override
  Stream<List<Registration>> streamAllClubRegistrations(String clubId) =>
      _replayStream(
        () => List<Registration>.unmodifiable(_registrations),
        _registrationsController.stream,
      ).map((list) => list.where((r) => r.clubId == clubId).toList());

  @override
  Future<Result<void>> approveRegistration({
    required String registrationId,
    required String eventId,
    required String studentUid,
    required String staffUid,
    String? note,
  }) async {
    final evIdx = _events.indexWhere((e) => e.id == eventId);
    final regIdx = _registrations.indexWhere((r) => r.id == registrationId);
    if (evIdx == -1) {
      return Result.failure(
        const AppFailure(
          code: 'event_not_found',
          message: 'Không tìm thấy sự kiện.',
        ),
      );
    }
    if (regIdx == -1) {
      return Result.failure(
        const AppFailure(
          code: 'registration_not_found',
          message: 'Không tìm thấy đơn đăng ký.',
        ),
      );
    }
    final oldReg = _registrations[regIdx];
    if (!oldReg.isPending) {
      return Result.failure(
        const AppFailure(
          code: 'not_pending',
          message: 'Đơn đăng ký không ở trạng thái chờ duyệt.',
        ),
      );
    }
    final ev = _events[evIdx];
    if (ev.activeCount >= ev.capacity) {
      return Result.failure(
        const AppFailure(
          code: 'event_full',
          message: 'Sự kiện đã hết chỗ, không thể duyệt thêm.',
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
    _registrations[regIdx] = Registration(
      id: oldReg.id,
      eventId: oldReg.eventId,
      status: 'approved',
      generation: oldReg.generation,
      participant: oldReg.participant,
      uid: oldReg.uid,
      clubId: oldReg.clubId,
      checkInAt: oldReg.checkInAt,
      createdAt: oldReg.createdAt,
      reason: note,
      reviewedBy: staffUid,
      reviewedAt: DateTime.now(),
      qrHash: oldReg.qrHash,
      lastOperationId: oldReg.lastOperationId,
    );
    sentNotifications.add({
      'uid': studentUid,
      'type': 'registration_approved',
      'eventId': eventId,
      'registrationId': registrationId,
    });
    _eventsController.add(List<Event>.unmodifiable(_events));
    _registrationsController.add(
      List<Registration>.unmodifiable(_registrations),
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> rejectRegistration({
    required String registrationId,
    required String eventId,
    required String studentUid,
    required String staffUid,
    required String reason,
  }) async {
    final trimmed = reason.trim();
    if (trimmed.length < 3 || trimmed.length > 300) {
      return Result.failure(
        const AppFailure(
          code: 'invalid_reason',
          message: 'Lý do từ chối bắt buộc từ 3 đến 300 ký tự.',
        ),
      );
    }
    final regIdx = _registrations.indexWhere((r) => r.id == registrationId);
    if (regIdx == -1) {
      return Result.failure(
        const AppFailure(
          code: 'registration_not_found',
          message: 'Không tìm thấy đơn đăng ký.',
        ),
      );
    }
    final oldReg = _registrations[regIdx];
    if (!oldReg.isPending) {
      return Result.failure(
        const AppFailure(
          code: 'not_pending',
          message: 'Đơn đăng ký không ở trạng thái chờ duyệt.',
        ),
      );
    }

    _registrations[regIdx] = Registration(
      id: oldReg.id,
      eventId: oldReg.eventId,
      status: 'rejected',
      generation: oldReg.generation,
      participant: oldReg.participant,
      uid: oldReg.uid,
      clubId: oldReg.clubId,
      checkInAt: oldReg.checkInAt,
      createdAt: oldReg.createdAt,
      reason: trimmed,
      reviewedBy: staffUid,
      reviewedAt: DateTime.now(),
      qrHash: oldReg.qrHash,
      lastOperationId: oldReg.lastOperationId,
    );
    sentNotifications.add({
      'uid': studentUid,
      'type': 'registration_rejected',
      'eventId': eventId,
      'registrationId': registrationId,
      'body': trimmed,
    });
    _registrationsController.add(
      List<Registration>.unmodifiable(_registrations),
    );
    return const Success(null);
  }

  @override
  Future<int> countPublishedEvents(String clubId) async {
    if (loadDelay > Duration.zero) await Future<void>.delayed(loadDelay);
    _checkFail();
    return _events
        .where((e) => e.clubId == clubId && e.status == 'published')
        .length;
  }

  @override
  Future<int> countPendingRegistrations(String clubId) async {
    if (loadDelay > Duration.zero) await Future<void>.delayed(loadDelay);
    _checkFail();
    return _registrations
        .where((r) => r.clubId == clubId && r.status == 'pending')
        .length;
  }

  @override
  Future<int> countApprovedRegistrations(String clubId) async {
    if (loadDelay > Duration.zero) await Future<void>.delayed(loadDelay);
    _checkFail();
    return _registrations
        .where((r) => r.clubId == clubId && r.status == 'approved')
        .length;
  }

  @override
  Future<int> countCheckedInRegistrations(String clubId) async {
    if (loadDelay > Duration.zero) await Future<void>.delayed(loadDelay);
    _checkFail();
    return _registrations
        .where((r) => r.clubId == clubId && r.checkInAt != null)
        .length;
  }

  @override
  Stream<List<Announcement>> streamClubAnnouncements(String clubId) =>
      _replayStream(
        () => List<Announcement>.unmodifiable(_announcements),
        _announcementsController.stream,
      ).map((list) => list.where((a) => a.clubId == clubId).toList());

  @override
  Future<Result<String>> publishAnnouncement(Announcement announcement) async {
    final generatedId = announcement.id.isEmpty
        ? 'ann_${_announcements.length + 1}'
        : announcement.id;
    final stored = Announcement(
      id: generatedId,
      title: announcement.title,
      body: announcement.body,
      scope: announcement.scope,
      clubId: announcement.clubId,
      clubName: announcement.clubName,
      eventId: announcement.eventId,
      authorUid: announcement.authorUid,
      authorRole: announcement.authorRole,
      createdAt: announcement.createdAt ?? DateTime.now(),
    );
    _announcements.insert(0, stored);
    _announcementsController.add(
      List<Announcement>.unmodifiable(_announcements),
    );
    return Result.success(generatedId);
  }
}

class FakeWebAnalyticsService implements IWebAnalyticsService {
  final List<(String, Map<String, Object>?)> loggedEvents = [];
  String? currentUserId;

  @override
  Future<void> setUserId(String? uid) async {
    currentUserId = uid;
  }

  @override
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    // Enforce Firebase Analytics parameter type constraint in tests too!
    if (parameters != null) {
      for (final entry in parameters.entries) {
        if (entry.value is! String && entry.value is! num) {
          throw ArgumentError(
            'Analytics param "${entry.key}" must be String or num, got ${entry.value.runtimeType}',
          );
        }
      }
    }
    loggedEvents.add((name, parameters));
  }
}

class FakeAdminService implements IAdminService {
  FakeAdminService({
    List<WebUserProfile>? initialUsers,
    List<Club>? initialClubs,
    List<Event>? initialEvents,
    List<Registration>? initialRegistrations,
    List<Announcement>? initialAnnouncements,
  }) {
    if (initialUsers != null) _users.addAll(initialUsers);
    if (initialClubs != null) _clubs.addAll(initialClubs);
    if (initialEvents != null) _events.addAll(initialEvents);
    if (initialRegistrations != null) _regs.addAll(initialRegistrations);
    if (initialAnnouncements != null)
      _announcements.addAll(initialAnnouncements);

    _usersController = StreamController<List<WebUserProfile>>.broadcast();
    _clubsController = StreamController<List<Club>>.broadcast();
    _eventsController = StreamController<List<Event>>.broadcast();
    _regsController = StreamController<List<Registration>>.broadcast();
    _announcementsController = StreamController<List<Announcement>>.broadcast();
  }

  final List<WebUserProfile> _users = [];
  final List<Club> _clubs = [];
  final List<Event> _events = [];
  final List<Registration> _regs = [];
  final List<Announcement> _announcements = [];

  late final StreamController<List<WebUserProfile>> _usersController;
  late final StreamController<List<Club>> _clubsController;
  late final StreamController<List<Event>> _eventsController;
  late final StreamController<List<Registration>> _regsController;
  late final StreamController<List<Announcement>> _announcementsController;

  @override
  Stream<List<WebUserProfile>> streamAllUsers() {
    return _createStream(_usersController, () => List.unmodifiable(_users));
  }

  @override
  Future<Result<void>> updateUserRole({
    required String targetUid,
    required String newRole,
    String? clubId,
    String? clubName,
  }) async {
    final idx = _users.indexWhere((u) => u.uid == targetUid);
    if (idx != -1) {
      final old = _users[idx];
      _users[idx] = WebUserProfile(
        uid: old.uid,
        email: old.email,
        displayName: old.displayName,
        role: newRole,
        clubId: newRole == 'staff' ? clubId : null,
        clubName: newRole == 'staff' ? clubName : null,
      );
      _usersController.add(List.unmodifiable(_users));
    }
    return const Success(null);
  }

  @override
  Stream<List<Club>> streamAllClubs() {
    return _createStream(_clubsController, () => List.unmodifiable(_clubs));
  }

  @override
  Future<Result<String>> createClub({
    required String name,
    String shortName = '',
    String description = '',
  }) async {
    final id = 'club_${_clubs.length + 1}';
    final club = Club(
      id: id,
      name: name,
      shortName: shortName,
      description: description,
      status: 'active',
    );
    _clubs.add(club);
    _clubsController.add(List.unmodifiable(_clubs));
    return Result.success(id);
  }

  @override
  Future<Result<void>> updateClub(Club club) async {
    final idx = _clubs.indexWhere((c) => c.id == club.id);
    if (idx != -1) {
      _clubs[idx] = club;
      _clubsController.add(List.unmodifiable(_clubs));
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> archiveClub(String clubId) async {
    final idx = _clubs.indexWhere((c) => c.id == clubId);
    if (idx != -1) {
      final old = _clubs[idx];
      _clubs[idx] = Club(
        id: old.id,
        name: old.name,
        shortName: old.shortName,
        description: old.description,
        status: 'archived',
      );
      _clubsController.add(List.unmodifiable(_clubs));
    }
    return const Success(null);
  }

  @override
  Stream<List<Event>> streamAllEvents() {
    return _createStream(_eventsController, () => List.unmodifiable(_events));
  }

  @override
  Future<Result<void>> adminApproveEvent(String eventId) async {
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
        status: 'published',
        capacity: old.capacity,
        activeCount: old.activeCount,
        clubId: old.clubId,
        visibility: old.visibility,
        updatedAt: DateTime.now(),
      );
      _eventsController.add(List.unmodifiable(_events));
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> adminRejectEvent(
    String eventId, {
    required String reason,
  }) async {
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
        status: 'rejected',
        capacity: old.capacity,
        activeCount: old.activeCount,
        clubId: old.clubId,
        visibility: old.visibility,
        updatedAt: DateTime.now(),
      );
      _eventsController.add(List.unmodifiable(_events));
    }
    return const Success(null);
  }

  @override
  Future<int> countSystemPendingEvents() async {
    return _events.where((e) => e.status == 'pending_approval').length;
  }

  @override
  Future<Result<void>> adminCancelEvent(String eventId) async {
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
      _eventsController.add(List.unmodifiable(_events));
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> adminArchiveEvent(String eventId) async {
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
      _eventsController.add(List.unmodifiable(_events));
    }
    return const Success(null);
  }

  @override
  Stream<List<Registration>> streamAllPendingRegistrations() {
    return _createStream(
      _regsController,
      () => List.unmodifiable(_regs.where((r) => r.status == 'pending')),
    );
  }

  @override
  Future<int> countSystemPublishedEvents() async {
    return _events.where((e) => e.status == 'published').length;
  }

  @override
  Future<int> countSystemPendingRegistrations() async {
    return _regs.where((r) => r.status == 'pending').length;
  }

  @override
  Future<int> countSystemApprovedRegistrations() async {
    return _regs.where((r) => r.status == 'approved').length;
  }

  @override
  Future<int> countUsersByRole(String role) async {
    return _users.where((u) => u.role == role).length;
  }

  @override
  Future<int> countActiveClubs() async {
    return _clubs.where((c) => c.status == 'active').length;
  }

  @override
  Future<List<Map<String, Object>>> getClubEventStats() async {
    final Map<String, Map<String, Object>> map = {};
    for (final e in _events) {
      final clubName = e.clubName;
      if (!map.containsKey(clubName)) {
        map[clubName] = {
          'clubName': clubName,
          'published': 0,
          'approved': 0,
          'checkedIn': 0,
        };
      }
      if (e.status == 'published') {
        map[clubName]!['published'] = (map[clubName]!['published'] as int) + 1;
      }
    }
    return map.values.toList();
  }

  @override
  Stream<List<Announcement>> streamAllAnnouncements() {
    return _createStream(
      _announcementsController,
      () => List.unmodifiable(_announcements),
    );
  }

  Stream<T> _createStream<T>(
    StreamController<T> controller,
    T Function() initialValue,
  ) {
    late StreamController<T> sc;
    StreamSubscription<T>? sub;
    sc = StreamController<T>(
      onListen: () {
        sc.add(initialValue());
        sub = controller.stream.listen(sc.add, onError: sc.addError);
      },
      onCancel: () => sub?.cancel(),
    );
    return sc.stream;
  }
}
