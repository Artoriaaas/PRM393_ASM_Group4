import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'app/bootstrap.dart';
import 'app/providers.dart';
import 'services/web_contracts.dart';
import 'services/fake_web_services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final initialEvents = [
    Event(
      id: 'e_ux',
      title: 'Workshop Thiết kế trải nghiệm người dùng',
      clubName: 'Câu lạc bộ IT FPTU',
      clubId: 'club_it',
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
      clubName: 'Câu lạc bộ IT FPTU',
      clubId: 'club_it',
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
      clubId: 'club_it',
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
      id: 'reg_pending_2',
      eventId: 'e_code',
      clubId: 'club_it',
      status: 'pending',
      generation: 1,
      participant: const Participant(
        name: 'Lê Thị Bình',
        email: 'binh.lt@fpt.edu.vn',
        group: 'student',
        cohort: 'K17',
        phone: '0987654321',
      ),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  final fakeAuth = FakeWebAuthService(
    initialUser: const WebUserProfile(
      uid: 'staff_it',
      email: 'leader.it@fpt.edu.vn',
      displayName: 'Trần Hoàng Nam (Trưởng CLB)',
      role: 'staff',
      clubId: 'club_it',
      clubName: 'Câu lạc bộ IT FPTU',
    ),
  );

  final fakeClub = FakeClubService(
    initialEvents: initialEvents,
    initialRegistrations: initialRegistrations,
    enableBridgeSync: true,
  );
  final fakeAdmin = FakeAdminService();
  final fakeAnalytics = FakeWebAnalyticsService();

  runApp(
    WebFirebaseAppBootstrap(
      initializer: () async => true,
      readyChild: ProviderScope(
        overrides: [
          webFirebaseReadyProvider.overrideWithValue(true),
          webAuthServiceProvider.overrideWithValue(fakeAuth),
          clubServiceProvider.overrideWithValue(fakeClub),
          adminServiceProvider.overrideWithValue(fakeAdmin),
          webAnalyticsServiceProvider.overrideWithValue(fakeAnalytics),
        ],
        child: const EventHubWebApp(),
      ),
    ),
  );
}
