import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

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
    bool? isProcessing,
    String? actionMessage,
    String? errorMessage,
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
      isProcessing: isProcessing ?? this.isProcessing,
      actionMessage: actionMessage ?? this.actionMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ReviewQueueViewModel extends Notifier<ReviewQueueState> {
  @override
  ReviewQueueState build() {
    state = const ReviewQueueState(loadState: LoadState.loading());
    _initSubscriptions();
    return state;
  }

  void _initSubscriptions() {
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

    final clubService = ref.read(clubServiceProvider);

    // Stream Events for dropdown
    final eventsSub = clubService.streamClubEvents(clubId).listen((events) {
      state = state.copyWith(events: events);
    });
    ref.onDispose(eventsSub.cancel);

    // Stream Registrations
    final regsSub =
        clubService.streamAllClubRegistrations(clubId).listen((regs) {
      _applyRegistrations(regs);
    }, onError: (err) {
      state = state.copyWith(
        loadState: LoadState.error(
          failure: AppFailure(code: 'stream_error', message: err.toString()),
        ),
      );
    });
    ref.onDispose(regsSub.cancel);
  }

  void _applyRegistrations(List<Registration> regs) {
    final filtered = _filterRegistrations(
      regs,
      state.searchQuery,
      state.statusFilter,
      state.eventFilter,
      state.groupFilter,
    );
    state = state.copyWith(
      loadState: regs.isEmpty
          ? const LoadState.empty(message: 'Chưa có đơn đăng ký nào.')
          : LoadState.data(data: filtered),
      allRegistrations: regs,
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
    return regs.where((r) {
      final matchesQuery = query.isEmpty ||
          r.participant.name.toLowerCase().contains(query.toLowerCase()) ||
          r.participant.email.toLowerCase().contains(query.toLowerCase()) ||
          r.participant.cohort.toLowerCase().contains(query.toLowerCase());

      final matchesStatus =
          statusFilter == 'all' || r.status == statusFilter;

      final matchesEvent =
          eventFilter == 'all' || r.eventId == eventFilter;

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
      loadState: LoadState.data(data: filtered),
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
      loadState: LoadState.data(data: filtered),
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
      loadState: LoadState.data(data: filtered),
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
      loadState: LoadState.data(data: filtered),
    );
  }

  Future<Result<void>> approve(Registration reg, {String? note}) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);
    final authState = ref.read(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
    final staffUid = user?.uid ?? '';

    final clubService = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);

    final res = await clubService.approveRegistration(
      registrationId: reg.id,
      eventId: reg.eventId,
      studentUid: reg.uid,
      staffUid: staffUid,
      note: note,
    );

    res.when(
      success: (_) {
        analytics.logEvent('registration_reviewed', {
          'action': 'approved',
          'registrationId': reg.id,
        });
        state = state.copyWith(
          isProcessing: false,
          actionMessage: 'Đã phê duyệt đơn của ${reg.participant.name}.',
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: failure.message,
        );
      },
    );
    return res;
  }

  Future<Result<void>> reject(Registration reg, {required String reason}) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);
    final authState = ref.read(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
    final staffUid = user?.uid ?? '';

    final clubService = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);

    final res = await clubService.rejectRegistration(
      registrationId: reg.id,
      studentUid: reg.uid,
      staffUid: staffUid,
      reason: reason,
    );

    res.when(
      success: (_) {
        analytics.logEvent('registration_reviewed', {
          'action': 'rejected',
          'registrationId': reg.id,
        });
        state = state.copyWith(
          isProcessing: false,
          actionMessage: 'Đã từ chối đơn của ${reg.participant.name}.',
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isProcessing: false,
          errorMessage: failure.message,
        );
      },
    );
    return res;
  }
}

final reviewQueueViewModelProvider =
    NotifierProvider<ReviewQueueViewModel, ReviewQueueState>(ReviewQueueViewModel.new);
