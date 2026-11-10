import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

const Object _unset = Object();

class ReviewQueueState {
  const ReviewQueueState({
    required this.loadState,
    this.searchQuery = '',
    this.statusFilter = 'pending',
    this.eventFilter = 'all',
    this.groupFilter = 'all',
    this.allRegistrations = const [],
    this.filteredRegistrations = const [],
    this.events = const [],
    this.eventsById = const {},
    this.isProcessing = false,
    this.actionMessage,
    this.errorMessage,
  });

  final LoadState<List<Registration>> loadState;
  final String searchQuery;
  final String statusFilter;
  final String eventFilter;
  final String groupFilter;
  final List<Registration> allRegistrations;
  final List<Registration> filteredRegistrations;
  final List<Event> events;
  final Map<String, Event> eventsById;
  final bool isProcessing;
  final String? actionMessage;
  final String? errorMessage;

  ReviewQueueState copyWith({
    LoadState<List<Registration>>? loadState,
    String? searchQuery,
    String? statusFilter,
    String? eventFilter,
    String? groupFilter,
    List<Registration>? allRegistrations,
    List<Registration>? filteredRegistrations,
    List<Event>? events,
    Map<String, Event>? eventsById,
    bool? isProcessing,
    Object? actionMessage = _unset,
    Object? errorMessage = _unset,
  }) {
    return ReviewQueueState(
      loadState: loadState ?? this.loadState,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      eventFilter: eventFilter ?? this.eventFilter,
      groupFilter: groupFilter ?? this.groupFilter,
      allRegistrations: allRegistrations ?? this.allRegistrations,
      filteredRegistrations:
          filteredRegistrations ?? this.filteredRegistrations,
      events: events ?? this.events,
      eventsById: eventsById ?? this.eventsById,
      isProcessing: isProcessing ?? this.isProcessing,
      actionMessage: identical(actionMessage, _unset)
          ? this.actionMessage
          : actionMessage as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class ReviewQueueViewModel extends Notifier<ReviewQueueState> {
  @override
  ReviewQueueState build() {
    final user = ref.watch(currentStaffProfileProvider);
    final isAdmin = user?.isAdmin ?? false;
    final clubId = ref.watch(currentClubIdProvider);

    if (!isAdmin && clubId.isEmpty) {
      return const ReviewQueueState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'club_not_found',
            message: 'Không tìm thấy câu lạc bộ được phân công.',
          ),
        ),
      );
    }

    final Stream<List<Event>> eventsStream;
    final Stream<List<Registration>> regsStream;

    if (isAdmin) {
      final adminService = ref.watch(adminServiceProvider);
      eventsStream = adminService.streamAllEvents();
      regsStream = adminService.streamAllPendingRegistrations();
    } else {
      final clubService = ref.watch(clubServiceProvider);
      eventsStream = clubService.streamClubEvents(clubId);
      regsStream = clubService.streamAllClubRegistrations(clubId);
    }

    final eventsSub = eventsStream.listen(
      (events) {
        if (!ref.mounted) return;
        state = state.copyWith(
          events: events,
          eventsById: {for (final e in events) e.id: e},
        );
      },
      onError: (_) {},
    );
    ref.onDispose(eventsSub.cancel);

    final regsSub = regsStream.listen(
      (regs) {
        if (!ref.mounted) return;
        _applyRegistrations(regs);
      },
      onError: (Object err) {
        if (!ref.mounted) return;
        state = state.copyWith(
          loadState: LoadState.error(
            failure: AppFailure(
              code: 'stream_error',
              message: 'Không thể tải hàng đợi xét duyệt: $err',
              isRetryable: true,
            ),
          ),
        );
      },
    );
    ref.onDispose(regsSub.cancel);

    return const ReviewQueueState(loadState: LoadState.loading());
  }

  void retry() => ref.invalidateSelf();

  void _applyRegistrations(List<Registration> regs) {
    final sorted = List<Registration>.from(regs)
      ..sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
    final filtered = _filterRegistrations(
      sorted,
      state.searchQuery,
      state.statusFilter,
      state.eventFilter,
      state.groupFilter,
    );
    state = state.copyWith(
      loadState: sorted.isEmpty
          ? const LoadState.empty(message: 'Chưa có đơn đăng ký nào thuộc CLB.')
          : LoadState.data(data: filtered),
      allRegistrations: sorted,
      filteredRegistrations: filtered,
    );
  }

  List<Registration> _filterRegistrations(
    List<Registration> regs,
    String query,
    String statusFilter,
    String eventFilter,
    String groupFilter,
  ) {
    final normalized = query.trim().toLowerCase();
    return regs.where((r) {
      final matchesQuery = normalized.isEmpty ||
          r.participant.name.toLowerCase().contains(normalized) ||
          r.participant.email.toLowerCase().contains(normalized) ||
          r.participant.cohort.toLowerCase().contains(normalized);

      final matchesStatus = statusFilter == 'all' || r.status == statusFilter;
      final matchesEvent = eventFilter == 'all' || r.eventId == eventFilter;
      final matchesGroup =
          groupFilter == 'all' || r.participant.group == groupFilter;

      return matchesQuery && matchesStatus && matchesEvent && matchesGroup;
    }).toList();
  }

  void setSearchQuery(String q) {
    final filtered = _filterRegistrations(
      state.allRegistrations,
      q,
      state.statusFilter,
      state.eventFilter,
      state.groupFilter,
    );
    state = state.copyWith(
      searchQuery: q,
      filteredRegistrations: filtered,
      loadState: state.allRegistrations.isEmpty
          ? const LoadState.empty(message: 'Chưa có đơn đăng ký nào thuộc CLB.')
          : LoadState.data(data: filtered),
    );
  }

  void setStatusFilter(String s) {
    final filtered = _filterRegistrations(
      state.allRegistrations,
      state.searchQuery,
      s,
      state.eventFilter,
      state.groupFilter,
    );
    state = state.copyWith(
      statusFilter: s,
      filteredRegistrations: filtered,
      loadState: state.allRegistrations.isEmpty
          ? const LoadState.empty(message: 'Chưa có đơn đăng ký nào thuộc CLB.')
          : LoadState.data(data: filtered),
    );
  }

  void setEventFilter(String eventId) {
    final filtered = _filterRegistrations(
      state.allRegistrations,
      state.searchQuery,
      state.statusFilter,
      eventId,
      state.groupFilter,
    );
    state = state.copyWith(
      eventFilter: eventId,
      filteredRegistrations: filtered,
      loadState: state.allRegistrations.isEmpty
          ? const LoadState.empty(message: 'Chưa có đơn đăng ký nào thuộc CLB.')
          : LoadState.data(data: filtered),
    );
  }

  void setGroupFilter(String group) {
    final filtered = _filterRegistrations(
      state.allRegistrations,
      state.searchQuery,
      state.statusFilter,
      state.eventFilter,
      group,
    );
    state = state.copyWith(
      groupFilter: group,
      filteredRegistrations: filtered,
      loadState: state.allRegistrations.isEmpty
          ? const LoadState.empty(message: 'Chưa có đơn đăng ký nào thuộc CLB.')
          : LoadState.data(data: filtered),
    );
  }

  void resetFilters() {
    final filtered = _filterRegistrations(
      state.allRegistrations,
      '',
      'all',
      'all',
      'all',
    );
    state = state.copyWith(
      searchQuery: '',
      statusFilter: 'all',
      eventFilter: 'all',
      groupFilter: 'all',
      filteredRegistrations: filtered,
      loadState: state.allRegistrations.isEmpty
          ? const LoadState.empty(message: 'Chưa có đơn đăng ký nào thuộc CLB.')
          : LoadState.data(data: filtered),
    );
  }

  Future<Result<void>> approve(Registration reg, {String? note}) async {
    state = state.copyWith(
      isProcessing: true,
      actionMessage: null,
      errorMessage: null,
    );
    final staffUid = ref.read(currentStaffProfileProvider)?.uid ?? '';
    final clubService = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);

    final res = await clubService.approveRegistration(
      registrationId: reg.id,
      eventId: reg.eventId,
      studentUid: reg.uid,
      staffUid: staffUid,
      note: note,
    );
    if (!ref.mounted) return res;

    res.when(
      success: (_) {
        unawaited(
          analytics.logEvent('registration_reviewed', {
            'action': 'approved',
            'event_id': reg.eventId,
          }),
        );
        state = state.copyWith(
          isProcessing: false,
          actionMessage: 'Đã phê duyệt đơn của ${reg.participant.name}.',
          errorMessage: null,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isProcessing: false,
          actionMessage: null,
          errorMessage: failure.message,
        );
      },
    );
    return res;
  }

  Future<Result<void>> reject(Registration reg, {required String reason}) async {
    state = state.copyWith(
      isProcessing: true,
      actionMessage: null,
      errorMessage: null,
    );
    final staffUid = ref.read(currentStaffProfileProvider)?.uid ?? '';
    final clubService = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);

    final res = await clubService.rejectRegistration(
      registrationId: reg.id,
      eventId: reg.eventId,
      studentUid: reg.uid,
      staffUid: staffUid,
      reason: reason,
    );
    if (!ref.mounted) return res;

    res.when(
      success: (_) {
        unawaited(
          analytics.logEvent('registration_reviewed', {
            'action': 'rejected',
            'event_id': reg.eventId,
          }),
        );
        state = state.copyWith(
          isProcessing: false,
          actionMessage: 'Đã từ chối đơn của ${reg.participant.name}.',
          errorMessage: null,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isProcessing: false,
          actionMessage: null,
          errorMessage: failure.message,
        );
      },
    );
    return res;
  }
}

final reviewQueueViewModelProvider =
    NotifierProvider<ReviewQueueViewModel, ReviewQueueState>(
  ReviewQueueViewModel.new,
);
