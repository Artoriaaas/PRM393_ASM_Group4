import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

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
    String? errorMessage,
  }) {
    return DashboardState(
      loadState: loadState ?? this.loadState,
      publishedEventsCount:
          publishedEventsCount ?? this.publishedEventsCount,
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
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DashboardViewModel extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    state = const DashboardState(loadState: LoadState.loading());
    loadDashboard();
    return state;
  }

  Future<void> loadDashboard() async {
    final authState = ref.read(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
    final clubId = user?.clubId ?? '';

    if (clubId.isEmpty) {
      state = const DashboardState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'club_not_found',
            message: 'Không tìm thấy thông tin Câu lạc bộ.',
          ),
        ),
        errorMessage: 'Không tìm thấy thông tin Câu lạc bộ.',
      );
      return;
    }

    state = state.copyWith(loadState: const LoadState.loading());
    final clubService = ref.read(clubServiceProvider);

    try {
      final results = await Future.wait([
        clubService.countPublishedEvents(clubId),
        clubService.countPendingRegistrations(clubId),
        clubService.countApprovedRegistrations(clubId),
        clubService.countCheckedInRegistrations(clubId),
      ]);

      // Stream events and registrations
      final eventsStream = clubService.streamClubEvents(clubId);
      final events = await eventsStream.first;

      final allRegsStream = clubService.streamAllClubRegistrations(clubId);
      final allRegs = await allRegsStream.first;

      final pendingRegs = allRegs.where((r) => r.isPending).toList();

      // Compute chart metrics for recent events
      final chartList = <EventAttendanceMetrics>[];
      for (final ev in events.take(5)) {
        final evRegs = allRegs.where((r) => r.eventId == ev.id).toList();
        final approved = evRegs.where((r) => r.isApproved).length;
        final checkedIn = evRegs.where((r) => r.isCheckedIn).length;
        chartList.add(
          EventAttendanceMetrics(
            eventTitle: ev.title,
            capacity: ev.capacity,
            approvedCount: approved > 0 ? approved : ev.activeCount,
            checkedInCount: checkedIn,
          ),
        );
      }

      state = DashboardState(
        loadState: const LoadState.data(data: null),
        publishedEventsCount: results[0],
        pendingRegistrationsCount: results[1],
        approvedRegistrationsCount: results[2],
        checkedInRegistrationsCount: results[3],
        recentEvents: events.take(4).toList(),
        recentPendingRegistrations: pendingRegs.take(5).toList(),
        chartData: chartList,
      );
    } catch (e) {
      state = DashboardState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'dashboard_load_error',
            message: e.toString(),
          ),
        ),
        errorMessage: e.toString(),
      );
    }
  }
}

final dashboardViewModelProvider =
    NotifierProvider<DashboardViewModel, DashboardState>(DashboardViewModel.new);
