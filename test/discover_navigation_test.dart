import 'package:eventhub/app/event_providers.dart';
import 'package:eventhub/models/event.dart';
import 'package:eventhub/screens/events/event_list_screen.dart';
import 'package:eventhub/viewmodels/event_viewmodels.dart';
import 'package:eventhub/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_event_service.dart';

void main() {
  final events = List.generate(
    5,
    (i) => Event(
      id: 'e$i',
      title: 'Workshop $i',
      clubName: 'CLB',
      location: 'Campus',
      startsAt: DateTime.utc(2027),
      endsAt: DateTime.utc(2027, 1, 1, 2),
    ),
  );
  test('home preview is capped and independent of search filters', () async {
    final c = ProviderContainer(
      overrides: [
        signedInUidProvider.overrideWithValue('u'),
        eventServiceProvider.overrideWithValue(
          FakeEventService(events: events),
        ),
      ],
    );
    addTearDown(c.dispose);
    final sub = c.listen(recommendationFeedProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(eventsProvider.future);
    c.read(eventFilterProvider.notifier).set(query: 'no match');
    expect(c.read(eventFeedProvider).requireValue, isEmpty);
    expect(c.read(recommendationFeedProvider).requireValue.length, 3);
  });
  for (final q in ['', 'Workshop']) {
    testWidgets('list title reflects query: $q', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            signedInUidProvider.overrideWithValue('u'),
            eventServiceProvider.overrideWithValue(
              FakeEventService(events: events),
            ),
          ],
          child: MaterialApp(
            theme: EventHubTheme.lightTheme,
            home: EventListScreen(search: true, initialQuery: q),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(q.isEmpty ? 'Tất cả sự kiện' : 'Kết quả tìm kiếm'),
        findsOneWidget,
      );
      expect(find.text('Câu lạc bộ'), findsOneWidget);
      expect(find.text('Dành cho bạn'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('home keeps preview without duplicated advanced filters', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          signedInUidProvider.overrideWithValue('u'),
          eventServiceProvider.overrideWithValue(
            FakeEventService(events: events),
          ),
        ],
        child: MaterialApp(
          theme: EventHubTheme.lightTheme,
          home: const EventListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dành cho bạn'), findsOneWidget);
    expect(find.text('Xem tất cả'), findsNothing);
    expect(find.text('Tìm sự kiện, CLB...'), findsOneWidget);
    expect(find.text('Câu lạc bộ'), findsNothing);
    expect(find.text('Xóa từ khóa và bộ lọc'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
