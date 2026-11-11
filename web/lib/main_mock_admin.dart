import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'app/bootstrap.dart';
import 'app/providers.dart';
import 'services/web_contracts.dart';
import 'services/fake_web_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Danh sách người dùng mẫu toàn hệ thống cho Admin quản lý
  final sampleUsers = [
    const WebUserProfile(
      uid: 'u_1',
      email: 'minhanh@example.com',
      displayName: 'Nguyễn Minh Anh',
      role: 'user',
    ),
    const WebUserProfile(
      uid: 'u_2',
      email: 'an.nv@fpt.edu.vn',
      displayName: 'Nguyễn Văn An',
      role: 'user',
    ),
    const WebUserProfile(
      uid: 'u_3',
      email: 'binh.lt@fpt.edu.vn',
      displayName: 'Lê Thị Bình',
      role: 'user',
    ),
    const WebUserProfile(
      uid: 'staff_it',
      email: 'leader.it@fpt.edu.vn',
      displayName: 'Trần Hoàng Nam',
      role: 'staff',
      clubId: 'c_fcode',
      clubName: 'CLB F-Code',
    ),
    const WebUserProfile(
      uid: 'staff_dance',
      email: 'leader.fuda@fpt.edu.vn',
      displayName: 'Phạm Thu Trang',
      role: 'staff',
      clubId: 'c_fuda',
      clubName: 'CLB Mỹ thuật FUDA',
    ),
    const WebUserProfile(
      uid: 'admin_sys',
      email: 'admin.eventhub@fpt.edu.vn',
      displayName: 'Nguyễn Quản Trị (Admin)',
      role: 'admin',
    ),
  ];

  // Danh mục các CLB toàn trường cho Admin quản lý
  final sampleClubs = [
    const Club(
      id: 'c_fcode',
      name: 'Câu lạc bộ Lập trình F-Code',
      shortName: 'F-Code',
      description: 'CLB Học thuật và Công nghệ thông tin',
      status: 'active',
    ),
    const Club(
      id: 'c_fuda',
      name: 'CLB Mỹ thuật & Thiết kế FUDA',
      shortName: 'FUDA',
      description: 'CLB Nghệ thuật, Đồ họa và Sáng tạo số',
      status: 'active',
    ),
    const Club(
      id: 'c_music',
      name: 'CLB Âm nhạc FPT Music Club',
      shortName: 'FMC',
      description: 'CLB Ca hát và Nhạc cụ sân trường',
      status: 'active',
    ),
    const Club(
      id: 'c_sports',
      name: 'CLB Thể thao & Cầu lông',
      shortName: 'FPT Sport',
      description: 'CLB Thể thao rèn luyện sức khỏe sinh viên',
      status: 'archived',
    ),
  ];

  final initialEvents = [
    Event(
      id: 'e_ux',
      title: 'Workshop Thiết kế trải nghiệm người dùng',
      clubName: 'CLB Mỹ thuật & Thiết kế FUDA',
      location: 'Phòng 204 · Campus TP.HCM',
      startsAt: DateTime.now().add(const Duration(days: 3, hours: 8)),
      endsAt: DateTime.now().add(const Duration(days: 3, hours: 10)),
      deadline: DateTime.now().add(const Duration(days: 2)),
      capacity: 30,
      activeCount: 18,
      coverKey: 'ux-design',
      description: 'Workshop UX cơ bản cho sinh viên.',
    ),
    Event(
      id: 'e_code',
      title: 'Coding Bootcamp: Flutter & Firebase',
      clubName: 'Câu lạc bộ Lập trình F-Code',
      location: 'Lab 301 · Campus TP.HCM',
      startsAt: DateTime.now().add(const Duration(days: 5, hours: 13)),
      endsAt: DateTime.now().add(const Duration(days: 5, hours: 17)),
      deadline: DateTime.now().add(const Duration(days: 4)),
      capacity: 25,
      activeCount: 24,
      coverKey: 'career-connect',
      description: 'Thực chiến lập trình di động.',
    ),
  ];

  final initialRegistrations = [
    Registration(
      id: 'reg_pending_1',
      eventId: 'e_ux',
      status: 'pending',
      generation: 1,
      participant: const Participant(
        name: 'Nguyễn Văn An',
        email: 'an.nv@fpt.edu.vn',
        group: 'student',
        cohort: 'K18',
        phone: '0912345678',
      ),
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Registration(
      id: 'reg_approved_1',
      eventId: 'e_ux',
      status: 'approved',
      generation: 1,
      participant: const Participant(
        name: 'Nguyễn Minh Anh',
        email: 'minhanh@example.com',
        group: 'student',
        cohort: 'K18',
      ),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final fakeAuth = FakeWebAuthService(
    initialUser: const WebUserProfile(
      uid: 'admin_sys',
      email: 'admin.eventhub@fpt.edu.vn',
      displayName: 'Nguyễn Quản Trị (System Admin)',
      role: 'admin',
    ),
  );

  final fakeAdmin = FakeAdminService(
    initialUsers: sampleUsers,
    initialClubs: sampleClubs,
    initialEvents: initialEvents,
    initialRegistrations: initialRegistrations,
  );

  final fakeClub = FakeClubService(
    initialEvents: initialEvents,
    initialRegistrations: initialRegistrations,
    clubs: {for (final c in sampleClubs) c.id: c},
    enableBridgeSync: true,
  );

  final fakeAnalytics = FakeWebAnalyticsService();

  runApp(
    WebFirebaseAppBootstrap(
      initializer: () async => true,
      readyChild: ProviderScope(
        overrides: [
          webFirebaseReadyProvider.overrideWithValue(true),
          webAuthServiceProvider.overrideWithValue(fakeAuth),
          adminServiceProvider.overrideWithValue(fakeAdmin),
          clubServiceProvider.overrideWithValue(fakeClub),
          webAnalyticsServiceProvider.overrideWithValue(fakeAnalytics),
        ],
        child: const EventHubWebApp(),
      ),
    ),
  );
}
