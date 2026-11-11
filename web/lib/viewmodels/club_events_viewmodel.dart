import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

const Object _unset = Object();

class ClubEventsState {
  const ClubEventsState({
    required this.loadState,
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.allEvents = const [],
    this.filteredEvents = const [],
    this.actionMessage,
    this.errorMessage,
  });

  final LoadState<List<Event>> loadState;
  final String searchQuery;
  final String statusFilter;
  final List<Event> allEvents;
  final List<Event> filteredEvents;
  final String? actionMessage;
  final String? errorMessage;

  ClubEventsState copyWith({
    LoadState<List<Event>>? loadState,
    String? searchQuery,
    String? statusFilter,
    List<Event>? allEvents,
    List<Event>? filteredEvents,
    Object? actionMessage = _unset,
    Object? errorMessage = _unset,
  }) {
    return ClubEventsState(
      loadState: loadState ?? this.loadState,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      actionMessage: identical(actionMessage, _unset)
          ? this.actionMessage
          : actionMessage as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class ClubEventsViewModel extends Notifier<ClubEventsState> {
  @override
  ClubEventsState build() {
    final user = ref.watch(currentStaffProfileProvider);
    final isAdmin = user?.isAdmin ?? false;
    final clubId = ref.watch(currentClubIdProvider);

    if (!isAdmin && clubId.isEmpty) {
      return const ClubEventsState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'club_not_found',
            message: 'Không tìm thấy câu lạc bộ được phân công.',
          ),
        ),
      );
    }

    final Stream<List<Event>> stream;
    if (isAdmin) {
      final adminService = ref.watch(adminServiceProvider);
      stream = adminService.streamAllEvents();
    } else {
      final service = ref.watch(clubServiceProvider);
      stream = service.streamClubEvents(clubId);
    }

    final sub = stream.listen(
      (events) {
        if (!ref.mounted) return;
        _applyEvents(events);
      },
      onError: (Object err) {
        if (!ref.mounted) return;
        state = state.copyWith(
          loadState: LoadState.error(
            failure: AppFailure(
              code: 'stream_error',
              message: 'Không thể tải danh sách sự kiện: $err',
              isRetryable: true,
            ),
          ),
        );
      },
    );

    ref.onDispose(sub.cancel);
    return const ClubEventsState(loadState: LoadState.loading());
  }

  void retry() => ref.invalidateSelf();

  void _applyEvents(List<Event> events) {
    final sorted = List<Event>.from(events)
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    final filtered = _filterList(sorted, state.searchQuery, state.statusFilter);
    state = state.copyWith(
      loadState: sorted.isEmpty
          ? const LoadState.empty(message: 'Câu lạc bộ chưa có sự kiện nào.')
          : LoadState.data(data: filtered),
      allEvents: sorted,
      filteredEvents: filtered,
    );
  }

  List<Event> _filterList(
    List<Event> events,
    String query,
    String statusFilter,
  ) {
    final normalized = query.trim().toLowerCase();
    return events.where((e) {
      final matchesQuery = normalized.isEmpty ||
          e.title.toLowerCase().contains(normalized) ||
          e.location.toLowerCase().contains(normalized) ||
          e.topic.toLowerCase().contains(normalized);

      final matchesStatus = statusFilter == 'all' || e.status == statusFilter;

      return matchesQuery && matchesStatus;
    }).toList();
  }

  void setSearchQuery(String query) {
    final filtered = _filterList(state.allEvents, query, state.statusFilter);
    state = state.copyWith(
      searchQuery: query,
      filteredEvents: filtered,
      loadState: state.allEvents.isEmpty
          ? const LoadState.empty(message: 'Câu lạc bộ chưa có sự kiện nào.')
          : LoadState.data(data: filtered),
    );
  }

  void setStatusFilter(String status) {
    final filtered = _filterList(state.allEvents, state.searchQuery, status);
    state = state.copyWith(
      statusFilter: status,
      filteredEvents: filtered,
      loadState: state.allEvents.isEmpty
          ? const LoadState.empty(message: 'Câu lạc bộ chưa có sự kiện nào.')
          : LoadState.data(data: filtered),
    );
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      statusFilter: 'all',
      filteredEvents: state.allEvents,
      loadState: state.allEvents.isEmpty
          ? const LoadState.empty(message: 'Câu lạc bộ chưa có sự kiện nào.')
          : LoadState.data(data: state.allEvents),
    );
  }

  Future<Result<String>> saveEvent(Event event, {required bool isNew}) async {
    state = state.copyWith(actionMessage: null, errorMessage: null);
    final service = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);

    if (isNew) {
      final result = await service.createEvent(event);
      if (!ref.mounted) return result;
      result.when(
        success: (createdId) {
          unawaited(
            analytics.logEvent('event_saved', {
              'action': 'created',
              'event_id': createdId,
              'status': event.status,
            }),
          );
          state = state.copyWith(
            actionMessage: 'Đã tạo sự kiện "${event.title}" thành công.',
          );
        },
        failure: (f) {
          state = state.copyWith(errorMessage: f.message);
        },
      );
      return result;
    } else {
      final updateResult = await service.updateEvent(event);
      if (!ref.mounted) {
        return updateResult.isSuccess
            ? Result.success(event.id)
            : Result.failure(updateResult.failureOrNull!);
      }
      return updateResult.when(
        success: (_) {
          unawaited(
            analytics.logEvent('event_saved', {
              'action': 'updated',
              'event_id': event.id,
              'status': event.status,
            }),
          );
          state = state.copyWith(
            actionMessage: 'Đã cập nhật sự kiện "${event.title}".',
          );
          return Result.success(event.id);
        },
        failure: (f) {
          state = state.copyWith(errorMessage: f.message);
          return Result.failure(f);
        },
      );
    }
  }

  Future<Result<void>> archiveEvent(String eventId) async {
    state = state.copyWith(actionMessage: null, errorMessage: null);
    final service = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);
    final res = await service.archiveEvent(eventId);
    if (!ref.mounted) return res;
    res.when(
      success: (_) {
        unawaited(
          analytics.logEvent('event_saved', {
            'action': 'archived',
            'event_id': eventId,
          }),
        );
        state = state.copyWith(
          actionMessage: 'Đã chuyển sự kiện sang trạng thái Lưu trữ.',
        );
      },
      failure: (f) => state = state.copyWith(errorMessage: f.message),
    );
    return res;
  }

  Future<Result<void>> cancelEvent(String eventId) async {
    state = state.copyWith(actionMessage: null, errorMessage: null);
    final service = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);
    final res = await service.cancelEvent(eventId);
    if (!ref.mounted) return res;
    res.when(
      success: (_) {
        unawaited(
          analytics.logEvent('event_saved', {
            'action': 'cancelled',
            'event_id': eventId,
          }),
        );
        state = state.copyWith(actionMessage: 'Đã hủy sự kiện.');
      },
      failure: (f) => state = state.copyWith(errorMessage: f.message),
    );
    return res;
  }

  Future<Result<void>> approveEvent(String eventId) async {
    state = state.copyWith(actionMessage: null, errorMessage: null);
    final user = ref.read(currentStaffProfileProvider);
    if (!(user?.isAdmin ?? false)) {
      const f = AppFailure(
        code: 'unauthorized',
        message: 'Chỉ Quản trị viên mới có quyền phê duyệt sự kiện.',
      );
      state = state.copyWith(errorMessage: f.message);
      return Result.failure(f);
    }
    final adminService = ref.read(adminServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);
    final res = await adminService.adminApproveEvent(eventId);
    if (!ref.mounted) return res;
    res.when(
      success: (_) {
        unawaited(
          analytics.logEvent('event_approved_by_admin', {'event_id': eventId}),
        );
        state = state.copyWith(
          actionMessage: 'Đã phê duyệt đề xuất sự kiện và lên lịch công bố.',
        );
      },
      failure: (f) => state = state.copyWith(errorMessage: f.message),
    );
    return res;
  }

  Future<Result<void>> rejectEvent(String eventId, {required String reason}) async {
    state = state.copyWith(actionMessage: null, errorMessage: null);
    final user = ref.read(currentStaffProfileProvider);
    if (!(user?.isAdmin ?? false)) {
      const f = AppFailure(
        code: 'unauthorized',
        message: 'Chỉ Quản trị viên mới có quyền từ chối sự kiện.',
      );
      state = state.copyWith(errorMessage: f.message);
      return Result.failure(f);
    }
    final adminService = ref.read(adminServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);
    final res = await adminService.adminRejectEvent(eventId, reason: reason);
    if (!ref.mounted) return res;
    res.when(
      success: (_) {
        unawaited(
          analytics.logEvent('event_rejected_by_admin', {
            'event_id': eventId,
            'reason': reason,
          }),
        );
        state = state.copyWith(
          actionMessage: 'Đã từ chối đề xuất sự kiện của CLB.',
        );
      },
      failure: (f) => state = state.copyWith(errorMessage: f.message),
    );
    return res;
  }
}

final clubEventsViewModelProvider =
    NotifierProvider<ClubEventsViewModel, ClubEventsState>(
  ClubEventsViewModel.new,
);
