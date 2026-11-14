import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_web/app/providers.dart';
import 'package:eventhub_web/services/web_contracts.dart';
import 'package:eventhub_web/viewmodels/club_events_viewmodel.dart';
import 'package:eventhub_web/viewmodels/dashboard_viewmodel.dart';
import 'package:eventhub_web/screens/events/club_events_screen.dart';
import 'package:eventhub_web/screens/events/event_editor_dialog.dart';

import 'support/fake_web_services.dart';

const staff = WebUserProfile(
  uid: 'staff',
  email: 'test@example.org',
  displayName: 'Staff',
  role: 'staff',
  clubId: 'club_it',
  clubName: 'Club',
);
const admin = WebUserProfile(
  uid: 'admin',
  email: 'admin@example.org',
  displayName: 'Admin',
  role: 'admin',
);
Event event(String id, {String status = 'draft', String description = ''}) =>
    Event(
      id: id,
      title: 'Workshop $id',
      description: description,
      clubName: 'Club',
      clubId: 'club_it',
      location: 'Room',
      startsAt: DateTime(2030, 1, 2),
      endsAt: DateTime(2030, 1, 2, 3),
      deadline: DateTime(2030, 1, 1),
      status: status,
      capacity: 8,
      coverKey: 'ux-workshop',
      coverUrl: 'https://example.org/cover.jpg',
    );

class Config implements IWebRemoteConfigService {
  @override
  Future<void> initialize({bool forceRefresh = false}) async {}
  @override
  int getInt(String key, {int defaultValue = 0}) =>
      key == 'web_dashboard_recent_limit' ? 1 : 2;
  @override
  bool getBool(String key, {bool defaultValue = false}) => defaultValue;
  @override
  String getString(String key, {String defaultValue = ''}) => defaultValue;
}

class SuggestionService implements IAiEventAssistService {
  @override
  Future<Result<AiEventSuggestion>> suggestEventContent({
    required String title,
    String? topic,
    String? currentDescription,
  }) async => Result.success(
    const AiEventSuggestion(
      topic: 'New topic',
      description: 'Generated draft',
      audience: 'Students',
      preparation: 'Laptop',
      activities: ['Discuss'],
    ),
  );
}

void main() {
  testWidgets('AI preview requires confirmation and cancel preserves input', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final original = event('a', description: 'Nội dung CLB đã viết');
    final clubService = FakeClubService(initialEvents: [original]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          webAuthServiceProvider.overrideWithValue(
            FakeWebAuthService(initialUser: staff),
          ),
          clubServiceProvider.overrideWithValue(clubService),
          webAnalyticsServiceProvider.overrideWithValue(
            FakeWebAnalyticsService(),
          ),
          geminiAiServiceProvider.overrideWithValue(SuggestionService()),
        ],
        child: MaterialApp(
          home: Scaffold(body: EventEditorDialog(initialEvent: original)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final request = find.widgetWithText(ElevatedButton, 'Tạo bản nháp AI');
    await tester.enterText(
      find.byKey(const ValueKey('ai-event-idea')),
      'Workshop chụp ảnh bằng điện thoại cho người mới',
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(request);
    await tester.tap(request);
    await tester.pumpAndSettle();
    expect(find.text('Bản nháp do Gemini AI đề xuất'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(const ValueKey('ai-apply-description')),
          )
          .value,
      isFalse,
    );
    final generatedField = find.byWidgetPredicate(
      (w) => w is TextFormField && w.controller?.text == 'Generated draft',
    );
    expect(generatedField, findsNothing);
    await tester.tap(find.text('Hủy').last);
    await tester.pumpAndSettle();
    expect(generatedField, findsNothing);
    final retry = find.widgetWithText(ElevatedButton, 'Tạo bản nháp khác');
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tạo lại'));
    await tester.pumpAndSettle();
    expect(find.text('Bản nháp do Gemini AI đề xuất'), findsOneWidget);
    expect(generatedField, findsNothing);
    await tester.tap(find.byKey(const ValueKey('ai-apply-description')));
    await tester.tap(find.byKey(const ValueKey('ai-apply-audience')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Áp dụng phần đã chọn'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      generatedField,
      300,
      scrollable: find
          .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
          .first,
    );
    expect(generatedField, findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is TextFormField && w.controller?.text == 'Students',
      ),
      findsNothing,
    );
    await tester.tap(find.text('Lưu bản nháp'));
    await tester.pumpAndSettle();
    final saved = await tester.runAsync(
      () => clubService.streamEvent('a').first,
    );
    expect(saved!.description, 'Generated draft');
    expect(saved.audience, original.audience);
    expect(saved.title, original.title);
    expect(saved.startsAt, original.startsAt);
    expect(saved.endsAt, original.endsAt);
    expect(saved.deadline, original.deadline);
    expect(saved.location, original.location);
    expect(saved.capacity, original.capacity);
    expect(saved.mode, original.mode);
    expect(tester.takeException(), isNull);
  });

  test('web Remote Config values feed dashboard presentation limits', () async {
    final c = ProviderContainer(
      overrides: [
        webRemoteConfigServiceProvider.overrideWithValue(Config()),
        webRemoteConfigInitProvider.overrideWith((ref) async {}),
      ],
    );
    addTearDown(c.dispose);
    final keep = c.listen(webDashboardSettingsProvider, (_, _) {});
    addTearDown(keep.close);
    await c.read(webRemoteConfigInitProvider.future);
    expect(c.read(webDashboardSettingsProvider).recentLimit, 1);
    expect(c.read(webDashboardSettingsProvider).chartLimit, 2);
  });
  test('dashboard applies config limits to real viewmodel output', () async {
    final service = FakeClubService(
      initialEvents: [event('a'), event('b'), event('c')],
    );
    final c = ProviderContainer(
      overrides: [
        webAuthServiceProvider.overrideWithValue(
          FakeWebAuthService(initialUser: staff),
        ),
        clubServiceProvider.overrideWithValue(service),
        webAnalyticsServiceProvider.overrideWithValue(
          FakeWebAnalyticsService(),
        ),
        webDashboardSettingsProvider.overrideWithValue((
          recentLimit: 1,
          chartLimit: 2,
        )),
      ],
    );
    addTearDown(c.dispose);
    final keep = c.listen(dashboardViewModelProvider, (_, _) {});
    addTearDown(keep.close);
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(c.read(dashboardViewModelProvider).recentEvents, hasLength(1));
    expect(c.read(dashboardViewModelProvider).chartData, hasLength(2));
  });
  test(
    'admin cannot create and staff cannot save another club event',
    () async {
      for (final user in [
        admin,
        const WebUserProfile(
          uid: 'other',
          email: 'other@example.org',
          displayName: 'Other',
          role: 'staff',
          clubId: 'club_other',
        ),
      ]) {
        final service = FakeClubService();
        final c = ProviderContainer(
          overrides: [
            webAuthServiceProvider.overrideWithValue(
              FakeWebAuthService(initialUser: user),
            ),
            clubServiceProvider.overrideWithValue(service),
            adminServiceProvider.overrideWithValue(FakeAdminService()),
            webAnalyticsServiceProvider.overrideWithValue(
              FakeWebAnalyticsService(),
            ),
          ],
        );
        for (var i = 0; i < 5; i++) {
          await Future<void>.delayed(Duration.zero);
        }
        final result = await c
            .read(clubEventsViewModelProvider.notifier)
            .saveEvent(event('x'), isNew: true);
        expect(result.isSuccess, isFalse);
        expect(await service.streamEvent('x').first, isNull);
        c.dispose();
      }
    },
  );
  for (final scenario in ['draft', 'published']) {
    testWidgets(
      'staff ${scenario == 'draft' ? 'submits draft to admin' : 'edits event without losing cover'}',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final service = FakeClubService(
          initialEvents: [event('a', status: scenario)],
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              webAuthServiceProvider.overrideWithValue(
                FakeWebAuthService(initialUser: staff),
              ),
              clubServiceProvider.overrideWithValue(service),
              webAnalyticsServiceProvider.overrideWithValue(
                FakeWebAnalyticsService(),
              ),
            ],
            child: MaterialApp(
              theme: EventHubTheme.lightTheme,
              home: const ClubEventsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (scenario == 'draft') {
          expect(find.text('Công bố sự kiện'), findsNothing);
          await tester.tap(find.text('Gửi Admin phê duyệt'));
        } else {
          await tester.tap(find.byTooltip('Chỉnh sửa sự kiện'));
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byType(TextFormField).first,
            'Updated title',
          );
          await tester.tap(find.text('Cập nhật sự kiện'));
        }
        await tester.pumpAndSettle();
        final saved = await tester.runAsync(
          () => service.streamEvent('a').first,
        );
        expect(saved!.coverKey, 'ux-workshop');
        expect(
          saved.status,
          scenario == 'draft' ? 'pending_approval' : 'published',
        );
        if (scenario == 'published') expect(saved.title, 'Updated title');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
