import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/auth_state.dart';
import '../../services/initial_auth_service.dart';
import '../../utils/app_failure.dart';

/// All fixtures and mutations in this file are local UI simulations only.
enum DemoScenario {
  normal('Mặc định'),
  loading('Đang tải'),
  empty('Rỗng'),
  error('Lỗi mạng'),
  unknown('Chưa rõ kết quả'),
  full('Hết chỗ'),
  expired('Hết hạn'),
  cancelled('CLB hủy sự kiện'),
  closed('Phiên điểm danh đóng'),
  ended('Sự kiện đã kết thúc'),
  cameraDenied('Chưa cấp camera'),
  wrongQr('QR sai sự kiện');

  const DemoScenario(this.label);
  final String label;
}

class DemoEvent {
  const DemoEvent({
    required this.id,
    required this.title,
    required this.club,
    required this.time,
    required this.place,
    this.free = false,
  });
  final String id, title, club, time, place;
  final bool free;
}

const demoWorkshop = DemoEvent(
  id: 'workshop',
  title: 'Workshop Thiết kế trải nghiệm người dùng',
  club: 'CLB Thiết kế FPTU',
  time: '14:00–16:30 · 24/10/2026',
  place: 'Phòng 204 · Campus TP.HCM',
);
const demoAcoustic = DemoEvent(
  id: 'acoustic',
  title: 'Đêm nhạc Acoustic Campus',
  club: 'CLB Âm nhạc F-Guitar',
  time: '18:30–21:00 · 22/11/2026',
  place: 'Sảnh Beta · Campus TP.HCM',
  free: true,
);

class DemoParticipant {
  const DemoParticipant({
    this.name = 'Minh Anh',
    this.email = 'minhanh@example.com',
    this.student = true,
    this.school = 'K18',
    this.phone = '',
  });
  final String name, email, school, phone;
  final bool student;
  String get group => student
      ? 'Sinh viên FPTU · $school (tự khai)'
      : 'Khách ngoài trường${school.isEmpty ? '' : ' · $school'}';
}

class PrototypeState {
  const PrototypeState({
    this.scenario = DemoScenario.normal,
    this.registered = false,
    this.cancelled = false,
    this.checkedIn = false,
    this.busy = false,
    this.participant = const DemoParticipant(),
    this.message,
    this.readNotifications = false,
    this.profileName = 'Minh Anh',
    this.profileEmail = 'minhanh@example.com',
    this.pendingEmail,
  });
  final DemoScenario scenario;
  final bool registered, cancelled, checkedIn, busy, readNotifications;
  final DemoParticipant participant;
  final String? message, pendingEmail;
  final String profileName, profileEmail;
  PrototypeState copy({
    DemoScenario? scenario,
    bool? registered,
    bool? cancelled,
    bool? checkedIn,
    bool? busy,
    DemoParticipant? participant,
    String? message,
    bool? readNotifications,
    String? profileName,
    String? profileEmail,
    String? pendingEmail,
  }) => PrototypeState(
    scenario: scenario ?? this.scenario,
    registered: registered ?? this.registered,
    cancelled: cancelled ?? this.cancelled,
    checkedIn: checkedIn ?? this.checkedIn,
    busy: busy ?? this.busy,
    participant: participant ?? this.participant,
    message: message,
    readNotifications: readNotifications ?? this.readNotifications,
    profileName: profileName ?? this.profileName,
    profileEmail: profileEmail ?? this.profileEmail,
    pendingEmail: pendingEmail ?? this.pendingEmail,
  );
}

final prototypeProvider = NotifierProvider<PrototypeViewModel, PrototypeState>(
  PrototypeViewModel.new,
);

class PrototypeViewModel extends Notifier<PrototypeState> {
  @override
  PrototypeState build() => const PrototypeState();
  void scenario(DemoScenario value) {
    state = state.copy(scenario: value);
  }

  void reset() {
    state = const PrototypeState();
  }

  void presetRegistration({bool checkedIn = false}) {
    state = state.copy(
      registered: true,
      cancelled: false,
      checkedIn: checkedIn,
      scenario: DemoScenario.normal,
    );
  }

  void markRead() {
    state = state.copy(readNotifications: true);
  }

  Map<String, String> validate(DemoParticipant p) => {
    if (p.name.trim().isEmpty) 'name': 'Vui lòng nhập họ và tên.',
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(p.email.trim()))
      'email': 'Vui lòng nhập email đúng định dạng.',
    if (p.student && p.school.trim().isEmpty) 'school': 'Vui lòng nhập khóa K.',
  };
  Future<bool> act(
    String action, {
    DemoParticipant? participant,
    bool recover = false,
  }) async {
    if (state.busy) return false;
    if (participant != null && validate(participant).isNotEmpty) return false;
    if (action == 'register' && state.registered && !state.cancelled) {
      return true;
    }
    if (action == 'cancel' &&
        (state.checkedIn ||
            !state.registered ||
            state.scenario == DemoScenario.cancelled)) {
      return false;
    }
    if (action == 'checkin' && (!state.registered || state.cancelled)) {
      state = state.copy(message: 'Cần đăng ký hợp lệ trước khi điểm danh.');
      return false;
    }
    state = state.copy(busy: true, participant: participant);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!ref.mounted) return false;
    if (state.scenario == DemoScenario.error) {
      state = state.copy(
        busy: false,
        message: 'Không thể kết nối. Dữ liệu đã nhập được giữ nguyên.',
      );
      return false;
    }
    if (state.scenario == DemoScenario.unknown && !recover) {
      state = state.copy(
        busy: false,
        message: 'Chưa xác nhận được kết quả. Kiểm tra trạng thái trước khi gửi lại.',
      );
      return false;
    }
    final blocked = switch (action) {
      'register' => [
        DemoScenario.full,
        DemoScenario.expired,
        DemoScenario.cancelled,
        DemoScenario.ended,
      ],
      'cancel' => [DemoScenario.cancelled, DemoScenario.ended],
      _ => [
        DemoScenario.cancelled,
        DemoScenario.closed,
        DemoScenario.ended,
        DemoScenario.wrongQr,
        DemoScenario.cameraDenied,
      ],
    };
    if (blocked.contains(state.scenario)) {
      state = state.copy(busy: false, message: state.scenario.label);
      return false;
    }
    state = state.copy(
      busy: false,
      scenario: DemoScenario.normal,
      registered: action == 'register' ? true : null,
      cancelled: action == 'cancel'
          ? true
          : action == 'register'
          ? false
          : null,
      checkedIn: action == 'checkin'
          ? true
          : action == 'register'
          ? false
          : null,
    );
    return true;
  }

  bool saveProfile(String name, String email) {
    if (name.trim().isEmpty ||
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
      state = state.copy(message: 'Vui lòng nhập họ tên và email hợp lệ.');
      return false;
    }
    if (state.scenario == DemoScenario.error) {
      state = state.copy(
        message: 'Chưa thể lưu. Thông tin đã nhập được giữ nguyên.',
      );
      return false;
    }
    state = state.copy(
      profileName: name.trim(),
      pendingEmail: email != state.profileEmail ? email.trim() : null,
    );
    return true;
  }

  void verifyContact() {
    state = PrototypeState(
      scenario: state.scenario,
      registered: state.registered,
      cancelled: state.cancelled,
      checkedIn: state.checkedIn,
      participant: state.participant,
      profileName: state.profileName,
      profileEmail: state.pendingEmail ?? state.profileEmail,
      readNotifications: state.readNotifications,
    );
  }
}

/// Never injected by main.dart. Only the explicit debug prototype entrypoint uses it.
class PrototypeAuthService extends InitialAuthService {
  PrototypeAuthService(this.scenario);
  final DemoScenario Function() scenario;
  final _events = StreamController<AuthState>.broadcast();
  AuthState _session = const AuthState.signedOut();
  String _name = 'Minh Anh', _email = 'minhanh@example.com';
  @override
  AuthState get currentAuthState => _session;
  @override
  Stream<AuthState> get authStateChanges => _events.stream;
  void setSession(AuthState value) {
    _session = value;
    _events.add(value);
  }

  Future<void> _wait() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (scenario() == DemoScenario.error) {
      throw const AppFailure(
        code: 'demo-network',
        message: 'Mô phỏng lỗi mạng. Dữ liệu đã nhập được giữ nguyên.',
      );
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _wait();
    _email = email;
    setSession(
      AuthState.signedIn(uid: 'ui-demo', email: email, displayName: _name),
    );
  }

  @override
  Future<void> signInWithGoogle() async {
    await _wait();
    if (scenario() == DemoScenario.cameraDenied) {
      throw const AppFailure(
        code: 'demo-cancel',
        message: 'Mô phỏng: đã hủy đăng nhập Google.',
      );
    }
    setSession(
      AuthState.signedIn(uid: 'ui-demo', email: _email, displayName: _name),
    );
  }

  @override
  Future<void> register(String name, String email, String password) async {
    await _wait();
    _name = name;
    _email = email;
    setSession(AuthState.unverified(uid: 'ui-demo', email: email));
  }

  @override
  Future<void> sendVerification() => _wait();
  @override
  Future<void> resetPassword(String email) => _wait();
  @override
  Future<void> reloadUser() async {
    await _wait();
    setSession(
      AuthState.signedIn(uid: 'ui-demo', email: _email, displayName: _name),
    );
  }

  @override
  Future<void> changeEmail(String email, String password) async {
    await _wait();
    _email = email;
  }

  @override
  Future<void> signOut() async {
    setSession(const AuthState.signedOut());
  }

  @override
  void dispose() {
    _events.close();
    super.dispose();
  }
}
