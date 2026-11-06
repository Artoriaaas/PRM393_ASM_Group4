import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

class ClubEventsState {
  const ClubEventsState({
    required this.loadState,
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.allEvents = const [],
    this.filteredEvents = const [],
  });

  final LoadState<List<Event>> loadState;
  final String searchQuery;
  final String statusFilter;
  final List<Event> allEvents;
  final List<Event> filteredEvents;

  ClubEventsState copyWith({
    LoadState<List<Event>>? loadState,
    String? searchQuery,
    String? statusFilter,
    List<Event>? allEvents,
    List<Event>? filteredEvents,
  }) {
    return ClubEventsState(
      loadState: loadState ?? this.loadState,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
    );
  }
}

class ClubEventsViewModel extends Notifier<ClubEventsState> {
  @override
  ClubEventsState build() {
    state = const ClubEventsState(loadState: LoadState.loading());
    _subscribeEvents();
    return state;
  }

  void _subscribeEvents() {
    final authState = ref.read(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
    final clubId = user?.clubId ?? '';

    if (clubId.isEmpty) {
      state = state.copyWith(
        loadState: const LoadState.error(
          failure: AppFailure(
            code: 'club_not_found',
            message: 'Không tìm thấy câu lạc bộ.',
          ),
        ),
      );
      return;
    }

    final service = ref.read(clubServiceProvider);
    final sub = service.streamClubEvents(clubId).listen((events) {
      _applyEvents(events);
    }, onError: (err) {
      state = state.copyWith(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'stream_error',
            message: err.toString(),
          ),
        ),
      );
    });

    ref.onDispose(sub.cancel);
  }

  void _applyEvents(List<Event> events) {
    final filtered = _filterList(events, state.searchQuery, state.statusFilter);
    state = state.copyWith(
      loadState: events.isEmpty
          ? const LoadState.empty(message: 'Câu lạc bộ chưa có sự kiện nào.')
          : LoadState.data(data: filtered),
      allEvents: events,
      filteredEvents: filtered,
    );
  }

  List<Event> _filterList(
    List<Event> events,
    String query,
    String statusFilter,
  ) {
    return events.where((e) {
      final matchesQuery = query.isEmpty ||
          e.title.toLowerCase().contains(query.toLowerCase()) ||
          e.location.toLowerCase().contains(query.toLowerCase()) ||
          e.topic.toLowerCase().contains(query.toLowerCase());

      final matchesStatus =
          statusFilter == 'all' || e.status == statusFilter;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String query) {
    final filtered = _filterList(state.allEvents, query, state.statusFilter);
    state = state.copyWith(
      searchQuery: query,
      filteredEvents: filtered,
      loadState: LoadState.data(data: filtered),
    );
  }

  void setStatusFilter(String status) {
    final filtered = _filterList(state.allEvents, state.searchQuery, status);
    state = state.copyWith(
      statusFilter: status,
      filteredEvents: filtered,
      loadState: LoadState.data(data: filtered),
    );
  }

  Future<Result<String>> saveEvent(Event event, {required bool isNew}) async {
    final service = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);

    if (isNew) {
      final result = await service.createEvent(event);
      if (result.isSuccess) {
        analytics.logEvent('event_saved', {'action': 'created', 'id': event.id});
      }
      return result;
    } else {
      final updateResult = await service.updateEvent(event);
      if (updateResult.isSuccess) {
        analytics.logEvent('event_saved', {'action': 'updated', 'id': event.id});
        return Result.success(event.id);
      }
      return Result.failure(updateResult.failureOrNull!);
    }
  }

  Future<Result<void>> archiveEvent(String eventId) async {
    final service = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);
    final res = await service.archiveEvent(eventId);
    if (res.isSuccess) {
      analytics.logEvent('event_saved', {'action': 'archived', 'id': eventId});
    }
    return res;
  }

  Future<Result<void>> cancelEvent(String eventId) async {
    final service = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);
    final res = await service.cancelEvent(eventId);
    if (res.isSuccess) {
      analytics.logEvent('event_saved', {'action': 'cancelled', 'id': eventId});
    }
    return res;
  }
}

final clubEventsViewModelProvider =
    NotifierProvider<ClubEventsViewModel, ClubEventsState>(ClubEventsViewModel.new);
