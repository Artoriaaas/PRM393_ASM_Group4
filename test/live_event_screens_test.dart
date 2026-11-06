import 'package:eventhub/screens/account/account_tab_screen.dart';
import 'package:eventhub/screens/account/profile_edit_screen.dart';
import 'package:eventhub/screens/account/cloud_tools_screen.dart';
import 'package:eventhub/screens/account/export_screen.dart';
import 'package:eventhub/app/providers.dart';
import 'package:eventhub/app/event_providers.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:eventhub/screens/events/event_list_screen.dart';
import 'package:eventhub/screens/events/event_detail_screen.dart';
import 'package:eventhub/screens/events/registration_form_screen.dart';
import 'package:eventhub/screens/events/registration_detail_screen.dart';
import 'package:eventhub/screens/events/live_schedule_screen.dart';
import 'package:eventhub/screens/events/scanner_screen.dart';
import 'package:eventhub/screens/auth/mobile_role_rejection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_event_service.dart';

class _Session extends SessionViewModel {
  @override
  AuthState build() => const AuthState.signedIn(
    uid: 'u',
    email: 'private@example.com',
    displayName: 'Nguyễn Minh Anh',
  );
}

void main() {
  final e = Event(
    id: 'e1',
    title: 'Workshop Thiết kế trải nghiệm người dùng',
    clubName: 'CLB Thiết kế FPTU',
    location: 'Phòng 204 · Campus TP.HCM',
    startsAt: DateTime.utc(2027, 1, 1, 7),
    endsAt: DateTime.utc(2027, 1, 1, 9, 30),
    deadline: DateTime.utc(2026, 12, 31, 11),
    capacity: 24,
    activeCount: 1,
    coverKey: 'ux-workshop',
    activities: ['Phỏng vấn và tổng hợp insight'],
  );
  final r = Registration(
    id: 'r1',
    eventId: 'e1',
    status: 'active',
    generation: 1,
    participant: const Participant(
      name: 'Nguyễn Minh Anh',
      email: 'private@example.com',
      cohort: 'K18',
      phone: '0900000000',
    ),
    checkInAt: DateTime.utc(2027, 1, 1, 7, 5),
  );
  Future<void> show(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionViewModelProvider.overrideWith(_Session.new),
          eventServiceProvider.overrideWithValue(
            FakeEventService(events: [e], registrations: [r]),
          ),
          pendingBookingStoreProvider.overrideWithValue(MemoryPendingStore()),
        ],
        child: MaterialApp(
          theme: EventHubTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: screen,
        ),
      ),
    );
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  for (final width in [360.0, 412.0]) {
    testWidgets('live F1/F2/A12 layouts at $width dp and 150% text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final screen in [
        const EventListScreen(),
        const EventListScreen(search: true),
        const EventDetailScreen(eventId: 'e1'),
        const RegistrationFormScreen(eventId: 'e1'),
        const RegistrationDetailScreen(id: 'r1', success: true),
        const RegistrationDetailScreen(id: 'r1'),
        const LiveScheduleScreen(),
        const AccountTabScreen(),
        const ProfileEditScreen(),
        const CloudToolsScreen(),
        const ExportScreen(),
        const RegistrationDetailScreen(id: 'r1', checkInResult: true),
      ]) {
        await show(tester, screen);
        expect(
          tester.takeException(),
          isNull,
          reason: screen.runtimeType.toString(),
        );
        if (screen is RegistrationDetailScreen && screen.checkInResult) {
          expect(find.text('private@example.com'), findsNothing);
          expect(find.textContaining('0900000000'), findsNothing);
        }
        final list = find.byType(Scrollable);
        expect(list, findsWidgets, reason: screen.runtimeType.toString());
        await tester.drag(list.first, const Offset(0, -650));
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          tester.takeException(),
          isNull,
          reason: 'Scrolled ${screen.runtimeType}',
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      }
    });
  }
  testWidgets('guest registration removes required cohort field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await show(tester, const RegistrationFormScreen(eventId: 'e1'));
    final chip = find.ancestor(
      of: find.text('Khách ngoài trường'),
      matching: find.byType(ChoiceChip),
    );
    await Scrollable.ensureVisible(tester.element(chip), alignment: 0.3);
    await tester.pumpAndSettle();
    await tester.tap(chip);
    await tester.pump();
    expect(find.text('Khóa K *'), findsNothing);
    expect(find.text('Trường / tổ chức (tùy chọn)'), findsOneWidget);
  });

  testWidgets(
    'pending registration hides QR scan while rejected registration shows Club Leader reason and re-register CTA',
    (tester) async {
      tester.view.physicalSize = const Size(360, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const pendingReg = Registration(
        id: 'u_e1',
        eventId: 'e1',
        status: 'pending',
        generation: 1,
        participant: Participant(
          name: 'Nguyễn Minh Anh',
          email: 'private@example.com',
          cohort: 'K18',
        ),
      );
      const rejectedReg = Registration(
        id: 'u_e1_rej',
        eventId: 'e1',
        status: 'rejected',
        generation: 1,
        reason: 'Chưa điền mã số sinh viên trong hồ sơ CLB.',
        participant: Participant(
          name: 'Nguyễn Minh Anh',
          email: 'private@example.com',
          cohort: 'K18',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionViewModelProvider.overrideWith(_Session.new),
            eventServiceProvider.overrideWithValue(
              FakeEventService(
                events: [e],
                registrations: [pendingReg, rejectedReg],
              ),
            ),
            pendingBookingStoreProvider.overrideWithValue(MemoryPendingStore()),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const RegistrationDetailScreen(id: 'u_e1', success: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chờ CLB duyệt'), findsOneWidget);
      expect(find.text('Quét QR'), findsNothing);
      expect(find.text('Hủy đăng ký'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // ScannerScreen also blocks pending registration before approval
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionViewModelProvider.overrideWith(_Session.new),
            eventServiceProvider.overrideWithValue(
              FakeEventService(events: [e], registrations: [pendingReg]),
            ),
            pendingBookingStoreProvider.overrideWithValue(MemoryPendingStore()),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const ScannerScreen(registrationId: 'u_e1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Đơn đang chờ CLB duyệt'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // Rejected registration displays Club Leader reason and re-register CTA
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sessionViewModelProvider.overrideWith(_Session.new),
            eventServiceProvider.overrideWithValue(
              FakeEventService(events: [e], registrations: [rejectedReg]),
            ),
            pendingBookingStoreProvider.overrideWithValue(MemoryPendingStore()),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const RegistrationDetailScreen(id: 'u_e1_rej'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bị từ chối'), findsOneWidget);
      expect(
        find.textContaining('Chưa điền mã số sinh viên trong hồ sơ CLB.'),
        findsOneWidget,
      );
      expect(find.text('Đăng ký lại'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      // MobileRoleRejectionScreen renders cleanly for staff/admin
      await tester.pumpWidget(
        ProviderScope(
          overrides: [sessionViewModelProvider.overrideWith(_StaffSession.new)],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: const MobileRoleRejectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tài khoản quản trị dùng trên Web'), findsOneWidget);
      expect(find.textContaining('Trưởng CLB (staff)'), findsOneWidget);
      expect(find.text('Đăng xuất / Đổi tài khoản'), findsOneWidget);
    },
  );
}

class _StaffSession extends SessionViewModel {
  @override
  AuthState build() => const AuthState.signedIn(
    uid: 'staff_1',
    email: 'leader@fpt.edu.vn',
    displayName: 'Leader IT',
    role: 'staff',
    clubId: 'club_it',
  );
}
