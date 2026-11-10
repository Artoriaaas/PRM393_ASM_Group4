import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

const Object _unset = Object();

class AdminClubsState {
  const AdminClubsState({
    required this.loadState,
    this.searchQuery = '',
    this.statusFilter = 'all',
    this.allClubs = const [],
    this.filteredClubs = const [],
    this.isProcessing = false,
    this.actionMessage,
    this.errorMessage,
  });

  final LoadState<List<Club>> loadState;
  final String searchQuery;
  final String statusFilter;
  final List<Club> allClubs;
  final List<Club> filteredClubs;
  final bool isProcessing;
  final String? actionMessage;
  final String? errorMessage;

  AdminClubsState copyWith({
    LoadState<List<Club>>? loadState,
    String? searchQuery,
    String? statusFilter,
    List<Club>? allClubs,
    List<Club>? filteredClubs,
    bool? isProcessing,
    Object? actionMessage = _unset,
    Object? errorMessage = _unset,
  }) {
    return AdminClubsState(
      loadState: loadState ?? this.loadState,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      allClubs: allClubs ?? this.allClubs,
      filteredClubs: filteredClubs ?? this.filteredClubs,
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

class AdminClubsViewModel extends Notifier<AdminClubsState> {
  StreamSubscription<List<Club>>? _sub;

  @override
  AdminClubsState build() {
    final user = ref.watch(currentStaffProfileProvider);
    if (user == null || !user.isAdmin) {
      return const AdminClubsState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'unauthorized',
            message: 'Chỉ Quản trị viên hệ thống mới có quyền truy cập chức năng này.',
          ),
        ),
      );
    }

    final adminService = ref.watch(adminServiceProvider);

    _sub = adminService.streamAllClubs().listen(
      (clubs) {
        if (!ref.mounted) return;
        _applyClubs(clubs);
      },
      onError: (Object err) {
        if (!ref.mounted) return;
        state = state.copyWith(
          loadState: LoadState.error(
            failure: AppFailure(
              code: 'clubs_load_failed',
              message: 'Không thể tải danh sách Câu lạc bộ: $err',
              isRetryable: true,
            ),
          ),
        );
      },
    );

    ref.onDispose(() => _sub?.cancel());

    return const AdminClubsState(loadState: LoadState.loading());
  }

  void retry() => ref.invalidateSelf();

  void _applyClubs(List<Club> clubs) {
    final sorted = List<Club>.from(clubs)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final filtered = _filterList(sorted, state.searchQuery, state.statusFilter);
    state = state.copyWith(
      loadState: sorted.isEmpty
          ? const LoadState.empty(message: 'Hệ thống chưa có Câu lạc bộ nào.')
          : LoadState.data(data: filtered),
      allClubs: sorted,
      filteredClubs: filtered,
    );
  }

  List<Club> _filterList(List<Club> list, String query, String status) {
    var result = list;
    if (status != 'all') {
      result = result.where((c) => c.status == status).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.shortName.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q);
      }).toList();
    }
    return result;
  }

  void search(String query) {
    final filtered = _filterList(state.allClubs, query, state.statusFilter);
    state = state.copyWith(
      searchQuery: query,
      filteredClubs: filtered,
      loadState: filtered.isEmpty && state.allClubs.isNotEmpty
          ? const LoadState.empty(message: 'Không tìm thấy Câu lạc bộ phù hợp.')
          : LoadState.data(data: filtered),
    );
  }

  void setStatusFilter(String status) {
    final filtered = _filterList(state.allClubs, state.searchQuery, status);
    state = state.copyWith(
      statusFilter: status,
      filteredClubs: filtered,
      loadState: filtered.isEmpty && state.allClubs.isNotEmpty
          ? const LoadState.empty(message: 'Không có Câu lạc bộ nào thuộc bộ lọc này.')
          : LoadState.data(data: filtered),
    );
  }

  Future<Result<String>> createClub({
    required String name,
    String shortName = '',
    String description = '',
  }) async {
    state = state.copyWith(
      isProcessing: true,
      actionMessage: null,
      errorMessage: null,
    );

    final adminService = ref.read(adminServiceProvider);
    final res = await adminService.createClub(
      name: name,
      shortName: shortName,
      description: description,
    );

    if (!ref.mounted) return res;

    res.when(
      success: (id) {
        state = state.copyWith(
          isProcessing: false,
          actionMessage: 'Tạo Câu lạc bộ mới thành công!',
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

  Future<Result<void>> updateClub(Club club) async {
    state = state.copyWith(
      isProcessing: true,
      actionMessage: null,
      errorMessage: null,
    );

    final adminService = ref.read(adminServiceProvider);
    final res = await adminService.updateClub(club);

    if (!ref.mounted) return res;

    res.when(
      success: (_) {
        state = state.copyWith(
          isProcessing: false,
          actionMessage: 'Cập nhật thông tin Câu lạc bộ thành công!',
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

  Future<Result<void>> archiveClub(String clubId) async {
    state = state.copyWith(
      isProcessing: true,
      actionMessage: null,
      errorMessage: null,
    );

    final adminService = ref.read(adminServiceProvider);
    final res = await adminService.archiveClub(clubId);

    if (!ref.mounted) return res;

    res.when(
      success: (_) {
        state = state.copyWith(
          isProcessing: false,
          actionMessage: 'Đã lưu trữ Câu lạc bộ thành công.',
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

  void dismissMessage() {
    state = state.copyWith(actionMessage: null, errorMessage: null);
  }
}

final adminClubsViewModelProvider =
    NotifierProvider<AdminClubsViewModel, AdminClubsState>(AdminClubsViewModel.new);

