import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub_web/services/crash_reports_service.dart';
import 'package:eventhub_web/viewmodels/crash_reports_viewmodel.dart';
import 'package:eventhub_web/viewmodels/web_auth_viewmodel.dart';
import 'package:eventhub_web/services/web_contracts.dart';

class FakeCrashReportsService extends CrashReportsService {
  FakeCrashReportsService({
    this.events = const [],
    this.failAuth = false,
    this.failLoad = false,
  });

  final List<Map<String, dynamic>> events;
  final bool failAuth;
  final bool failLoad;
  bool authorized = false;

  @override
  Future<void> authorize() async {
    if (failAuth) throw StateError('Chưa cấp quyền đọc Crashlytics.');
    authorized = true;
  }

  @override
  Future<CrashReportPage> load({String? pageToken}) async {
    if (failLoad) throw StateError('Lỗi tải API');
    return CrashReportPage(events, null);
  }
}

void main() {
  group('CrashReportsService parser', () {
    test('parses actual event fields and preserves pagination', () {
      final page = CrashReportsService.parse(
        '{"events":[{"eventId":"abc","issueTitle":"native crash","issue":{"errorType":"FATAL"}}],"nextPageToken":"next"}',
      );
      expect(page.events.single['eventId'], 'abc');
      expect(page.events.single['issueTitle'], 'native crash');
      expect(page.nextPageToken, 'next');
    });

    test('empty response does not create mock crashes', () {
      expect(CrashReportsService.parse('{}').events, isEmpty);
    });

    test('malformed response is not silently treated as successful', () {
      expect(() => CrashReportsService.parse('not json'), throwsFormatException);
    });
  });

  group('CrashReportsViewModel', () {
    const adminUser = WebUserProfile(
      uid: 'admin_1',
      email: 'admin@fpt.edu.vn',
      displayName: 'Quản trị viên',
      role: 'admin',
    );

    const staffUser = WebUserProfile(
      uid: 'staff_1',
      email: 'staff@fpt.edu.vn',
      displayName: 'Trưởng CLB',
      role: 'staff',
      clubId: 'c_fcode',
    );

    test('blocks non-admin users from viewing crash reports', () async {
      final fakeService = FakeCrashReportsService();
      final container = ProviderContainer(
        overrides: [
          currentStaffProfileProvider.overrideWith((ref) => staffUser),
          crashReportsServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final vm = container.read(crashReportsProvider.notifier);
      await vm.load(authorize: true);

      final state = container.read(crashReportsProvider);
      expect(state.hasError, isTrue);
      expect(
        state.error.toString(),
        contains('Chỉ Admin được xem báo cáo lỗi.'),
      );
      expect(fakeService.authorized, isFalse);
    });

    test('allows admin to authorize and load crash reports', () async {
      final sampleEvents = [
        {
          'eventId': 'ev_123',
          'issueTitle': 'NullPointerException in Release',
          'issue': {'errorType': 'FATAL'},
        },
      ];
      final fakeService = FakeCrashReportsService(events: sampleEvents);
      final container = ProviderContainer(
        overrides: [
          currentStaffProfileProvider.overrideWith((ref) => adminUser),
          crashReportsServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      final vm = container.read(crashReportsProvider.notifier);
      await vm.load(authorize: true);

      final state = container.read(crashReportsProvider);
      expect(state.hasValue, isTrue);
      expect(state.value?.events.length, 1);
      expect(state.value?.events.first['eventId'], 'ev_123');
      expect(fakeService.authorized, isTrue);
    });
  });
}
