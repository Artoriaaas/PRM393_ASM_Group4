import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

const Object _unset = Object();

class AdminDashboardState {
  const AdminDashboardState({
    required this.loadState,
    this.publishedEventsCount = 0,
    this.pendingEventsCount = 0,
    this.pendingRegistrationsCount = 0,
    this.approvedRegistrationsCount = 0,
    this.userCount = 0,
    this.staffCount = 0,
    this.adminCount = 0,
    this.activeClubsCount = 0,
    this.recentEvents = const [],
    this.recentPendingRegistrations = const [],
    this.clubEventStats = const [],
    this.errorMessage,
  });

  final LoadState<void> loadState;
  final int publishedEventsCount;
  final int pendingEventsCount;
  final int pendingRegistrationsCount;
  final int approvedRegistrationsCount;
  final int userCount;
  final int staffCount;
  final int adminCount;
  final int activeClubsCount;
  final List<Event> recentEvents;
  final List<Registration> recentPendingRegistrations;
  final List<Map<String, Object>> clubEventStats;
  final String? errorMessage;

  AdminDashboardState copyWith({
    LoadState<void>? loadState,
    int? publishedEventsCount,
    int? pendingEventsCount,
    int? pendingRegistrationsCount,
    int? approvedRegistrationsCount,
    int? userCount,
    int? staffCount,
    int? adminCount,
    int? activeClubsCount,
    List<Event>? recentEvents,
    List<Registration>? recentPendingRegistrations,
    List<Map<String, Object>>? clubEventStats,
    Object? errorMessage = _unset,
  }) {
    return AdminDashboardState(
      loadState: loadState ?? this.loadState,
      publishedEventsCount: publishedEventsCount ?? this.publishedEventsCount,
      pendingEventsCount: pendingEventsCount ?? this.pendingEventsCount,
      pendingRegistrationsCount:
          pendingRegistrationsCount ?? this.pendingRegistrationsCount,
      approvedRegistrationsCount:
          approvedRegistrationsCount ?? this.approvedRegistrationsCount,
      userCount: userCount ?? this.userCount,
      staffCount: staffCount ?? this.staffCount,
      adminCount: adminCount ?? this.adminCount,
      activeClubsCount: activeClubsCount ?? this.activeClubsCount,
      recentEvents: recentEvents ?? this.recentEvents,
      recentPendingRegistrations:
          recentPendingRegistrations ?? this.recentPendingRegistrations,
      clubEventStats: clubEventStats ?? this.clubEventStats,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class AdminDashboardViewModel extends Notifier<AdminDashboardState> {
  StreamSubscription<List<Event>>? _eventsSub;
  StreamSubscription<List<Registration>>? _regsSub;

  @override
  AdminDashboardState build() {
    final user = ref.watch(currentStaffProfileProvider);
    if (user == null || !user.isAdmin) {
      return const AdminDashboardState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'unauthorized',
            message: 'Chỉ Quản trị viên hệ thống mới có quyền truy cập Dashboard tổng.',
          ),
        ),
      );
    }

    final adminService = ref.watch(adminServiceProvider);

    _eventsSub = adminService.streamAllEvents().listen((events) {
      if (!ref.mounted) return;
      final sorted = List<Event>.from(events)
        ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
      state = state.copyWith(recentEvents: sorted.take(5).toList());
    });

    _regsSub = adminService.streamAllPendingRegistrations().listen((regs) {
      if (!ref.mounted) return;
      final sorted = List<Registration>.from(regs)
        ..sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
      state = state.copyWith(
        recentPendingRegistrations: sorted.take(5).toList(),
      );
    });

    ref.onDispose(() {
      _eventsSub?.cancel();
      _regsSub?.cancel();
    });

    Future.microtask(() {
      if (ref.mounted) loadDashboard();
    });

    return const AdminDashboardState(loadState: LoadState.loading());
  }

  Future<void> loadDashboard() async {
    state = state.copyWith(loadState: const LoadState.loading(), errorMessage: null);

    final adminService = ref.read(adminServiceProvider);

    try {
      final results = await Future.wait([
        adminService.countSystemPublishedEvents(),
        adminService.countSystemPendingEvents(),
        adminService.countSystemPendingRegistrations(),
        adminService.countSystemApprovedRegistrations(),
        adminService.countUsersByRole('user'),
        adminService.countUsersByRole('staff'),
        adminService.countUsersByRole('admin'),
        adminService.countActiveClubs(),
        adminService.getClubEventStats(),
      ]);

      if (!ref.mounted) return;

      state = state.copyWith(
        loadState: const LoadState.data(data: null),
        publishedEventsCount: results[0] as int,
        pendingEventsCount: results[1] as int,
        pendingRegistrationsCount: results[2] as int,
        approvedRegistrationsCount: results[3] as int,
        userCount: results[4] as int,
        staffCount: results[5] as int,
        adminCount: results[6] as int,
        activeClubsCount: results[7] as int,
        clubEventStats: results[8] as List<Map<String, Object>>,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'dashboard_error',
            message: 'Không thể tải số liệu thống kê: $e',
            isRetryable: true,
          ),
        ),
        errorMessage: 'Không thể tải số liệu thống kê: $e',
      );
    }
  }
}

final adminDashboardViewModelProvider =
    NotifierProvider<AdminDashboardViewModel, AdminDashboardState>(
  AdminDashboardViewModel.new,
);

