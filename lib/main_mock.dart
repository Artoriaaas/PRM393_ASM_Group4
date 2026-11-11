import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'models/app_notification.dart';
import 'models/auth_state.dart';
import 'models/event.dart';
import 'services/auth_providers.dart';
import 'services/contracts/auth_service.dart';
import 'services/contracts/cloud_services.dart';
import 'services/contracts/event_service.dart';
import 'services/contracts/notification_service.dart';
import 'services/event_service_providers.dart';
import 'services/cloud_service_provider.dart';

const String _bridgeUrl = 'http://127.0.0.1:8088';

/// Bộ dữ liệu Mock AuthService phục vụ kiểm thử giao diện
class MockAuthService implements AuthService {
  MockAuthService({AuthState? initial})
      : _current = initial ??
            const AuthState.signedIn(
              uid: 'user_mock_01',
              email: 'minhanh@example.com',
              displayName: 'Nguyễn Minh Anh',
              role: 'user',
            );

  final StreamController<AuthState> _controller =
      StreamController<AuthState>.broadcast();
  AuthState _current;

  @override
  Stream<AuthState> get authStateChanges async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  AuthState get currentAuthState => _current;

  @override
  bool get canChangeEmail => true;

  @override
  Future<void> updateName(String name) async {
    _current = AuthState.signedIn(
      uid: 'user_mock_01',
      email: (_current is AuthStateSignedIn)
          ? (_current as AuthStateSignedIn).email
          : 'minhanh@example.com',
      displayName: name.trim(),
      role: 'user',
    );
    _controller.add(_current);
  }

  @override
  Future<void> signOut() async {
    _current = const AuthState.signedOut();
    _controller.add(_current);
  }

  @override
  Future<void> signIn(String email, String password) async {
    _current = AuthState.signedIn(
      uid: 'user_mock_01',
      email: email.trim().isEmpty ? 'minhanh@example.com' : email.trim(),
      displayName: 'Nguyễn Minh Anh',
      role: 'user',
    );
    _controller.add(_current);
  }

  @override
  Future<void> signInWithGoogle() async {
    _current = const AuthState.signedIn(
      uid: 'user_mock_01',
      email: 'minhanh.fpt@gmail.com',
      displayName: 'Minh Anh (Google Test)',
      role: 'user',
    );
    _controller.add(_current);
  }

  @override
  Future<void> register(String name, String email, String password) async {
    _current = AuthState.signedIn(
      uid: 'user_mock_01',
      email: email.trim(),
      displayName: name.trim(),
      role: 'user',
    );
    _controller.add(_current);
  }

  @override
  Future<void> sendVerification() async {}

  @override
  Future<void> reloadUser() async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> changeEmail(String email, String password) async {
    _current = AuthState.signedIn(
      uid: 'user_mock_01',
      email: email.trim(),
      displayName: (_current is AuthStateSignedIn)
          ? (_current as AuthStateSignedIn).displayName
          : 'Nguyễn Minh Anh',
      role: 'user',
    );
    _controller.add(_current);
  }

  void dispose() {
    _controller.close();
  }
}

/// Dịch vụ Event: Tự động đồng bộ với Realtime Bridge Server khi enableBridgeSync == true
class MockEventService implements EventService {
  MockEventService({this.enableBridgeSync = false}) {
    _events = [
      Event(
        id: 'e_ux',
        title: 'Workshop Thiết kế trải nghiệm người dùng',
        clubName: 'Câu lạc bộ IT FPTU',
        clubId: 'club_it',
        location: 'Phòng 204 · Campus TP.HCM',
        startsAt: DateTime.now().add(const Duration(days: 3, hours: 8)),
        endsAt: DateTime.now().add(const Duration(days: 3, hours: 10, minutes: 30)),
        deadline: DateTime.now().add(const Duration(days: 2)),
        capacity: 30,
        activeCount: 18,
        coverKey: 'ux-design',
        topic: 'Thiết kế & Công nghệ',
        description:
            'Trang bị kiến thức nền tảng về tư duy UX, cách xây dựng User Persona và thực hành thiết kế luồng người dùng trên Figma cùng các chuyên gia hàng đầu.',
        activities: const [
          '08:00 - Đón tiếp sinh viên & check-in',
          '08:30 - Khái niệm UX căn bản & Case study',
          '09:30 - Thực hành thiết kế User Journey',
          '10:15 - Q&A, góp ý sản phẩm và bế mạc',
        ],
      ),
      Event(
        id: 'e_code',
        title: 'Coding Bootcamp: Flutter & Firebase',
        clubName: 'Câu lạc bộ IT FPTU',
        clubId: 'club_it',
        location: 'Lab 301 · Campus TP.HCM',
        startsAt: DateTime.now().add(const Duration(days: 5, hours: 13)),
        endsAt: DateTime.now().add(const Duration(days: 5, hours: 17)),
        deadline: DateTime.now().add(const Duration(days: 4)),
        capacity: 25,
        activeCount: 24,
        coverKey: 'career-connect',
        topic: 'Lập trình',
        description: 'Thực chiến lập trình di động Flutter.',
      ),
      Event(
        id: 'e_acoustic',
        title: 'Đêm nhạc Acoustic: Thanh âm sân trường',
        clubName: 'Câu lạc bộ IT FPTU',
        clubId: 'club_it',
        location: 'Sân khấu ngoài trời · Tòa nhà Alpha',
        startsAt: DateTime.now().add(const Duration(days: 7, hours: 18)),
        endsAt: DateTime.now().add(const Duration(days: 7, hours: 21)),
        deadline: DateTime.now().add(const Duration(days: 6)),
        capacity: 100,
        activeCount: 65,
        coverKey: 'acoustic-live',
        topic: 'Âm nhạc & Nghệ thuật',
        description: 'Giao lưu âm nhạc mộc mạc.',
      ),
    ];

    _registrations = [
      Registration(
        id: 'reg_mock_ux',
        eventId: 'e_ux',
        clubId: 'club_it',
        status: 'approved',
        generation: 1,
        participant: const Participant(
          name: 'Nguyễn Minh Anh',
          email: 'minhanh@example.com',
          group: 'student',
          cohort: 'K18',
          phone: '0901234567',
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    if (enableBridgeSync) {
      _startSyncTimer();
    }
  }

  final bool enableBridgeSync;
  late List<Event> _events;
  late List<Registration> _registrations;
  Timer? _syncTimer;

  final StreamController<List<Event>> _eventsController =
      StreamController<List<Event>>.broadcast();
  final StreamController<List<Registration>> _registrationsController =
      StreamController<List<Registration>>.broadcast();

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) async {
      try {
        final resEvents = await http
            .get(Uri.parse('$_bridgeUrl/api/events'))
            .timeout(const Duration(milliseconds: 900));
        if (resEvents.statusCode == 200) {
          final List list = jsonDecode(resEvents.body) as List;
          _events = list.map((d) {
            final map = d as Map<String, dynamic>;
            return Event(
              id: map['id'] as String? ?? '',
              title: map['title'] as String? ?? '',
              clubName: map['clubName'] as String? ?? '',
              clubId: map['clubId'] as String? ?? 'club_it',
              location: map['location'] as String? ?? '',
              startsAt: DateTime.tryParse(map['startsAt'] as String? ?? '') ??
                  DateTime.now(),
              endsAt: DateTime.tryParse(map['endsAt'] as String? ?? '') ??
                  DateTime.now(),
              deadline: map['deadline'] != null
                  ? DateTime.tryParse(map['deadline'] as String)
                  : null,
              capacity: (map['capacity'] as num?)?.toInt() ?? 0,
              activeCount: (map['activeCount'] as num?)?.toInt() ?? 0,
              coverKey: map['coverKey'] as String? ?? 'ux-design',
              description: map['description'] as String? ?? '',
              activities: List<String>.from(map['activities'] as List? ?? []),
              mode: map['mode'] as String? ?? 'required',
              status: map['status'] as String? ?? 'published',
            );
          }).toList();
          _eventsController.add(List.of(_events));
        }

        final resRegs = await http
            .get(Uri.parse('$_bridgeUrl/api/registrations'))
            .timeout(const Duration(milliseconds: 900));
        if (resRegs.statusCode == 200) {
          final List list = jsonDecode(resRegs.body) as List;
          _registrations = list.map((d) {
            final map = d as Map<String, dynamic>;
            return Registration(
              id: map['id'] as String? ?? '',
              eventId: map['eventId'] as String? ?? '',
              clubId: map['clubId'] as String? ?? 'club_it',
              status: map['status'] as String? ?? 'pending',
              generation: (map['generation'] as num?)?.toInt() ?? 1,
              participant: Participant.fromJson(
                Map<String, dynamic>.from(map['participant'] as Map? ?? {}),
              ),
              checkInAt: map['checkInAt'] != null
                  ? DateTime.tryParse(map['checkInAt'] as String)
                  : null,
              createdAt: map['createdAt'] != null
                  ? DateTime.tryParse(map['createdAt'] as String)
                  : null,
            );
          }).toList();
          _registrationsController.add(List.of(_registrations));
        }
      } catch (_) {
        // Fallback offline
      }
    });
  }

  @override
  Stream<List<Event>> watchEvents() async* {
    yield _events;
    yield* _eventsController.stream;
  }

  @override
  Stream<Event?> watchEvent(String id) async* {
    yield _events.where((e) => e.id == id).firstOrNull;
    yield* _eventsController.stream.map(
      (list) => list.where((e) => e.id == id).firstOrNull,
    );
  }

  @override
  Stream<List<Registration>> watchRegistrations(String uid) async* {
    yield _registrations;
    yield* _registrationsController.stream;
  }

  @override
  Stream<Registration?> watchRegistration(String id) async* {
    yield _registrations.where((r) => r.id == id).firstOrNull;
    yield* _registrationsController.stream.map(
      (list) => list.where((r) => r.id == id).firstOrNull,
    );
  }

  @override
  Future<BookingResult> execute(Map<String, dynamic> command) async {
    final action = command['action'] as String? ?? 'register';
    final eventId = command['eventId'] as String? ?? '';

    if (action == 'register') {
      final participantJson = command['participant'] as Map<String, dynamic>?;
      final participant = participantJson != null
          ? Participant.fromJson(participantJson)
          : const Participant(
              name: 'Nguyễn Minh Anh',
              email: 'minhanh@example.com',
            );

      final newRegId = 'reg_${DateTime.now().millisecondsSinceEpoch}';

      if (enableBridgeSync) {
        try {
          unawaited(http
              .post(
                Uri.parse('$_bridgeUrl/api/registrations'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'eventId': eventId,
                  'clubId': 'club_it',
                  'participant': participant.toJson(),
                }),
              )
              .timeout(const Duration(seconds: 2)));
        } catch (_) {}
      }

      final newReg = Registration(
        id: newRegId,
        eventId: eventId,
        clubId: 'club_it',
        status: 'pending',
        generation: 1,
        participant: participant,
        createdAt: DateTime.now(),
      );

      _registrations.insert(0, newReg);
      _registrationsController.add(List.of(_registrations));

      return BookingResult(status: 'confirmed', registrationId: newRegId);
    } else if (action == 'cancel') {
      _registrations.removeWhere((r) => r.eventId == eventId);
      _registrationsController.add(List.of(_registrations));
      return const BookingResult(status: 'cancelled');
    }

    return const BookingResult(status: 'confirmed');
  }

  @override
  Future<BookingResult> recover(String operationId) async =>
      const BookingResult(status: 'confirmed');

  void dispose() {
    _syncTimer?.cancel();
  }
}

/// Dịch vụ thông báo
class MockNotificationService implements NotificationService {
  MockNotificationService({this.enableBridgeSync = false}) {
    _notifications = [
      AppNotification(
        id: 'notif_01',
        title: 'Đăng ký vé thành công',
        body: 'Khám phá các sự kiện và đăng ký tham gia ngay hôm nay.',
        eventId: 'e_ux',
        type: 'welcome',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
    if (enableBridgeSync) {
      _startSyncTimer();
    }
  }

  final bool enableBridgeSync;
  late List<AppNotification> _notifications;
  Timer? _syncTimer;
  final StreamController<List<AppNotification>> _controller =
      StreamController<List<AppNotification>>.broadcast();

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) async {
      try {
        final res = await http
            .get(Uri.parse('$_bridgeUrl/api/notifications'))
            .timeout(const Duration(milliseconds: 900));
        if (res.statusCode == 200) {
          final List list = jsonDecode(res.body) as List;
          _notifications = list.map((d) {
            final map = d as Map<String, dynamic>;
            return AppNotification(
              id: map['id'] as String? ?? '',
              title: map['title'] as String? ?? '',
              body: map['body'] as String? ?? '',
              eventId: map['eventId'] as String? ?? '',
              registrationId: map['registrationId'] as String?,
              type: map['type'] as String? ?? 'info',
              createdAt: map['createdAt'] != null
                  ? DateTime.tryParse(map['createdAt'] as String)
                  : null,
              readAt: map['readAt'] != null
                  ? DateTime.tryParse(map['readAt'] as String)
                  : null,
            );
          }).toList();
          _controller.add(List.of(_notifications));
        }
      } catch (_) {}
    });
  }

  @override
  Stream<List<AppNotification>> watch(String uid) async* {
    yield _notifications;
    yield* _controller.stream;
  }

  @override
  Future<void> markRead(String uid, String id) async {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final old = _notifications[idx];
      _notifications[idx] = AppNotification(
        id: old.id,
        title: old.title,
        body: old.body,
        eventId: old.eventId,
        type: old.type,
        registrationId: old.registrationId,
        createdAt: old.createdAt,
        readAt: DateTime.now(),
      );
      _controller.add(List.of(_notifications));
    }
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}

/// Lưu trữ tạm trong bộ nhớ cho booking pending store
class MemoryPendingStore implements PendingBookingStore {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<Map<String, dynamic>?> read(String uid) async => _storage[uid];

  @override
  Future<void> write(String uid, Map<String, dynamic> c) async {
    _storage[uid] = Map.from(c);
  }

  @override
  Future<void> clear(String uid) async {
    _storage.remove(uid);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final mockAuth = MockAuthService();
  final mockEvent = MockEventService(enableBridgeSync: true);
  final mockNotif = MockNotificationService(enableBridgeSync: true);
  final mockStore = MemoryPendingStore();

  runApp(
    FirebaseAppBootstrap(
      initializer: () async => true,
      readyChild: ProviderScope(
        overrides: [
          firebaseReadyProvider.overrideWithValue(true),
          authServiceProvider.overrideWithValue(mockAuth),
          eventServiceProvider.overrideWithValue(mockEvent),
          notificationServiceProvider.overrideWithValue(mockNotif),
          pendingBookingStoreProvider.overrideWithValue(mockStore),
          cloudServicesProvider.overrideWithValue(UnavailableCloudServices()),
        ],
        child: const EventHubApp(),
      ),
    ),
  );
}
