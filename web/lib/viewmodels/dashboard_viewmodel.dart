import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

const Object _unset = Object();

class EventAttendanceMetrics {
  const EventAttendanceMetrics({
    required this.eventTitle,
    required this.capacity,
    required this.approvedCount,
    required this.checkedInCount,
  });

  final String eventTitle;
  final int capacity;
  final int approvedCount;
  final int checkedInCount;
}

class DashboardState {
  const DashboardState({
    required this.loadState,
    this.publishedEventsCount = 0,
    this.pendingRegistrationsCount = 0,
    this.approvedRegistrationsCount = 0,
    this.checkedInRegistrationsCount = 0,
    this.recentEvents = const [],
    this.recentPendingRegistrations = const [],
    this.chartData = const [],
    this.errorMessage,
  });

  final LoadState<void> loadState;
  final int publishedEventsCount;
  final int pendingRegistrationsCount;
  final int approvedRegistrationsCount;
  final int checkedInRegistrationsCount;
  final List<Event> recentEvents;
  final List<Registration> recentPendingRegistrations;
  final List<EventAttendanceMetrics> chartData;
  final String? errorMessage;

  DashboardState copyWith({
    LoadState<void>? loadState,
    int? publishedEventsCount,
    int? pendingRegistrationsCount,
    int? approvedRegistrationsCount,
    int? checkedInRegistrationsCount,
    List<Event>? recentEvents,
    List<Registration>? recentPendingRegistrations,
    List<EventAttendanceMetrics>? chartData,
    Object? errorMessage = _unset,
  }) {
    return DashboardState(
      loadState: loadState ?? this.loadState,
      publishedEventsCount: publishedEventsCount ?? this.publishedEventsCount,
      pendingRegistrationsCount:
          pendingRegistrationsCount ?? this.pendingRegistrationsCount,
      approvedRegistrationsCount:
          approvedRegistrationsCount ?? this.approvedRegistrationsCount,
      checkedInRegistrationsCount:
          checkedInRegistrationsCount ?? this.checkedInRegistrationsCount,
      recentEvents: recentEvents ?? this.recentEvents,
      recentPendingRegistrations:
          recentPendingRegistrations ?? this.recentPendingRegistrations,
      chartData: chartData ?? this.chartData,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class DashboardViewModel extends Notifier<DashboardState> {
  int _epoch = 0;
  StreamSubscription<List<Event>>? _eventsSub;
  StreamSubscription<List<Registration>>? _regsSub;
  List<Event>? _latestEvents;
  List<Registration>? _latestRegs;
  List<int>? _latestCounts;

  @override
  DashboardState build() {
    final clubId = ref.watch(currentClubIdProvider);
    _epoch++;
    _latestEvents = null;
    _latestRegs = null;
    _latestCounts = null;

    ref.onDispose(() {
      _eventsSub?.cancel();
      _regsSub?.cancel();
    });

    if (clubId.isEmpty) {
      return const DashboardState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'club_not_found',
            message: 'Không tìm thấy thông tin Câu lạc bộ được phân công.',
          ),
        ),
        errorMessage: 'Không tìm thấy thông tin Câu lạc bộ được phân công.',
      );
    }

    final currentEpoch = _epoch;
    Future.microtask(() {
      if (ref.mounted && _epoch == currentEpoch) {
        unawaited(loadDashboard());
      }
    });
    return const DashboardState(loadState: LoadState.loading());
  }

  Future<void> loadDashboard() async {
    final clubId = ref.read(currentClubIdProvider);
    if (clubId.isEmpty) {
      state = const DashboardState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'club_not_found',
            message: 'Không tìm thấy thông tin Câu lạc bộ được phân công.',
          ),
        ),
        errorMessage: 'Không tìm thấy thông tin Câu lạc bộ được phân công.',
      );
      return;
    }

    final requestEpoch = ++_epoch;
    _latestEvents = null;
    _latestRegs = null;
    _latestCounts = null;
    state = state.copyWith(
      loadState: const LoadState.loading(),
      errorMessage: null,
    );
    final oldEventsSub = _eventsSub;
    final oldRegsSub = _regsSub;
    _eventsSub = null;
    _regsSub = null;
    unawaited(oldEventsSub?.cancel());
    unawaited(oldRegsSub?.cancel());
    final clubService = ref.read(clubServiceProvider);

    void onStreamFailure(Object err) {
      if (!ref.mounted || requestEpoch != _epoch) return;
      final message = err is AppFailure
          ? err.message
          : 'Không thể tải dữ liệu thống kê CLB: $err';
      state = DashboardState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'dashboard_load_error',
            message: message,
            isRetryable: true,
          ),
        ),
        errorMessage: message,
      );
    }

    _eventsSub = clubService.streamClubEvents(clubId).listen(
      (events) {
        if (!ref.mounted || requestEpoch != _epoch) return;
        _latestEvents = events;
        _recomputeIfReady();
      },
      onError: onStreamFailure,
    );

    _regsSub = clubService.streamAllClubRegistrations(clubId).listen(
      (regs) {
        if (!ref.mounted || requestEpoch != _epoch) return;
        _latestRegs = regs;
        _recomputeIfReady();
      },
      onError: onStreamFailure,
    );

    try {
      final counts = await Future.wait([
        clubService.countPublishedEvents(clubId),
        clubService.countPendingRegistrations(clubId),
        clubService.countApprovedRegistrations(clubId),
        clubService.countCheckedInRegistrations(clubId),
      ]);
      if (!ref.mounted || requestEpoch != _epoch) return;
      _latestCounts = counts;
      _recomputeIfReady();
    } catch (e) {
      onStreamFailure(e);
    }
  }

  void _recomputeIfReady() {
    final events = _latestEvents;
    final allRegs = _latestRegs;
    final counts = _latestCounts;
    if (events == null || allRegs == null || counts == null) return;

    if (events.isEmpty && allRegs.isEmpty) {
      state = const DashboardState(
        loadState: LoadState.empty(
          message:
              'Câu lạc bộ của bạn chưa tạo sự kiện nào. Hãy khởi tạo sự kiện đầu tiên để bắt đầu nhận đăng ký.',
        ),
      );
      return;
    }

    final sortedEvents = List<Event>.from(events)
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    final pendingRegs = allRegs.where((r) => r.isPending).toList();

    final chartList = <EventAttendanceMetrics>[];
    for (final ev in sortedEvents.take(5)) {
      final checkedIn = allRegs
          .where((r) => r.eventId == ev.id && r.isCheckedIn)
          .length;
      chartList.add(
        EventAttendanceMetrics(
          eventTitle: ev.title,
          capacity: ev.capacity,
          approvedCount: ev.activeCount,
          checkedInCount: checkedIn,
        ),
      );
    }

    state = DashboardState(
      loadState: const LoadState.data(data: null),
      publishedEventsCount: counts[0],
      pendingRegistrationsCount: counts[1],
      approvedRegistrationsCount: counts[2],
      checkedInRegistrationsCount: counts[3],
      recentEvents: sortedEvents.take(4).toList(),
      recentPendingRegistrations: pendingRegs.take(5).toList(),
      chartData: chartList,
    );
  }
}

final dashboardViewModelProvider =
    NotifierProvider<DashboardViewModel, DashboardState>(
  DashboardViewModel.new,
);
