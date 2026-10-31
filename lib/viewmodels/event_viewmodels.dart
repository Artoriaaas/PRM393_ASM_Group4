import '../app/cloud_providers.dart';
import 'cloud_tools_viewmodel.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/event_providers.dart';
import '../models/event.dart';

// A periodic clock updates availability and date buckets while the app stays open.
final eventClockProvider = StreamProvider.autoDispose<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(minutes: 1), (_) => DateTime.now());
});

class EventFilter {
  const EventFilter({
    this.query = '',
    this.topic,
    this.club,
    this.today = false,
  });
  final String query;
  final String? topic, club;
  final bool today;
}

final eventFilterProvider =
    NotifierProvider.autoDispose<EventFilterViewModel, EventFilter>(
      EventFilterViewModel.new,
    );

class EventFilterViewModel extends Notifier<EventFilter> {
  @override
  EventFilter build() => const EventFilter();
  void set({
    String? query,
    String? topic,
    String? club,
    bool? today,
    bool clearTopic = false,
    bool clearClub = false,
  }) => state = EventFilter(
    query: query ?? state.query,
    topic: clearTopic ? null : topic ?? state.topic,
    club: clearClub ? null : club ?? state.club,
    today: today ?? state.today,
  );
  void reset() => state = const EventFilter();
  Future<void> searchSubmitted(String text) =>
      track(ref, 'search', {'query_length': text.trim().length});
}

List<Event> filterEvents(List<Event> events, EventFilter filter, DateTime now) {
  final day = now.toUtc().add(const Duration(hours: 7));
  return events.where((e) {
    final d = e.startsAt.toUtc().add(const Duration(hours: 7));
    return '${e.title} ${e.clubName}'.toLowerCase().contains(
          filter.query.trim().toLowerCase(),
        ) &&
        (filter.topic == null || e.topic == filter.topic) &&
        (filter.club == null || e.clubName == filter.club) &&
        (!filter.today ||
            (d.year == day.year && d.month == day.month && d.day == day.day));
  }).toList();
}

final eventFeedProvider = Provider.autoDispose<AsyncValue<List<Event>>>((ref) {
  final now = ref.watch(eventClockProvider).asData?.value ?? DateTime.now();
  return ref
      .watch(eventsProvider)
      .whenData(
        (rows) => filterEvents(rows, ref.watch(eventFilterProvider), now),
      );
});

class ScheduleEntry {
  const ScheduleEntry(this.registration, this.event);
  final Registration registration;
  final Event? event;
}

int scheduleBucket(Registration r, Event? e, DateTime now) {
  if (!r.active || e?.status == 'cancelled') return 2;
  if (e != null && !now.isBefore(e.endsAt)) return 1;
  return 0;
}

final scheduleTabProvider =
    NotifierProvider.autoDispose<ScheduleTabViewModel, int>(
      ScheduleTabViewModel.new,
    );

class ScheduleTabViewModel extends Notifier<int> {
  @override
  int build() => 0;
  void select(int tab) => state = tab;
}

final scheduleEntriesProvider =
    Provider.autoDispose<AsyncValue<List<ScheduleEntry>>>((ref) {
      final regs = ref.watch(registrationsProvider);
      final now = ref.watch(eventClockProvider).asData?.value ?? DateTime.now();
      final tab = ref.watch(scheduleTabProvider);
      if (regs.hasError) {
        return AsyncError(regs.error!, regs.stackTrace ?? StackTrace.current);
      }
      if (!regs.hasValue) return const AsyncLoading();
      final list = <ScheduleEntry>[];
      for (final r in regs.requireValue) {
        final e = ref.watch(eventProvider(r.eventId));
        if (e.hasError) {
          return AsyncError(e.error!, e.stackTrace ?? StackTrace.current);
        }
        if (!e.hasValue) return const AsyncLoading();
        if (scheduleBucket(r, e.value, now) == tab) {
          list.add(ScheduleEntry(r, e.value));
        }
      }
      return AsyncData(list);
    });

final eventAvailabilityProvider = Provider.autoDispose.family<String?, String>((
  ref,
  id,
) {
  final now = ref.watch(eventClockProvider).asData?.value ?? DateTime.now();
  return ref.watch(eventProvider(id)).asData?.value?.unavailable(now);
});
final activeRegistrationForEventProvider = Provider.autoDispose
    .family<Registration?, String>(
      (ref, id) => ref
          .watch(registrationsProvider)
          .asData
          ?.value
          .where((r) => r.eventId == id && r.active)
          .firstOrNull,
    );
final canCancelRegistrationProvider = Provider.autoDispose.family<bool, String>(
  (ref, id) {
    final r = ref.watch(registrationProvider(id)).asData?.value;
    if (r == null) return false;
    final e = ref.watch(eventProvider(r.eventId)).asData?.value;
    final now = ref.watch(eventClockProvider).asData?.value ?? DateTime.now();
    return r.active &&
        r.checkInAt == null &&
        e?.status == 'published' &&
        e != null &&
        now.isBefore(e.startsAt);
  },
);

final recommendationFeedProvider =
    Provider.autoDispose<AsyncValue<List<Event>>>((ref) {
      final settings = ref.watch(cloudToolsProvider).settings;
      return ref
          .watch(eventFeedProvider)
          .whenData(
            (rows) => settings.showRecommendations
                ? rows.take(settings.recommendationLimit).toList()
                : [],
          );
    });
