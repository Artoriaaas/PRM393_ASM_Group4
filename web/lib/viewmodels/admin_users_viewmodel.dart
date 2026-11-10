import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import '../services/web_contracts.dart';
import 'web_auth_viewmodel.dart';

const Object _unset = Object();

class AdminUsersState {
  const AdminUsersState({
    required this.loadState,
    this.searchQuery = '',
    this.roleFilter = 'all',
    this.allUsers = const [],
    this.filteredUsers = const [],
    this.clubs = const [],
    this.isProcessing = false,
    this.actionMessage,
    this.errorMessage,
  });

  final LoadState<List<WebUserProfile>> loadState;
  final String searchQuery;
  final String roleFilter;
  final List<WebUserProfile> allUsers;
  final List<WebUserProfile> filteredUsers;
  final List<Club> clubs;
  final bool isProcessing;
  final String? actionMessage;
  final String? errorMessage;

  AdminUsersState copyWith({
    LoadState<List<WebUserProfile>>? loadState,
    String? searchQuery,
    String? roleFilter,
    List<WebUserProfile>? allUsers,
    List<WebUserProfile>? filteredUsers,
    List<Club>? clubs,
    bool? isProcessing,
    Object? actionMessage = _unset,
    Object? errorMessage = _unset,
  }) {
    return AdminUsersState(
      loadState: loadState ?? this.loadState,
      searchQuery: searchQuery ?? this.searchQuery,
      roleFilter: roleFilter ?? this.roleFilter,
      allUsers: allUsers ?? this.allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      clubs: clubs ?? this.clubs,
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

class AdminUsersViewModel extends Notifier<AdminUsersState> {
  StreamSubscription<List<WebUserProfile>>? _usersSub;
  StreamSubscription<List<Club>>? _clubsSub;

  @override
  AdminUsersState build() {
    final user = ref.watch(currentStaffProfileProvider);
    if (user == null || !user.isAdmin) {
      return const AdminUsersState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'unauthorized',
            message: 'Chỉ Quản trị viên hệ thống mới có quyền truy cập chức năng này.',
          ),
        ),
      );
    }

    final adminService = ref.watch(adminServiceProvider);

    _usersSub = adminService.streamAllUsers().listen(
      (users) {
        if (!ref.mounted) return;
        _applyUsers(users);
      },
      onError: (Object err) {
        if (!ref.mounted) return;
        state = state.copyWith(
          loadState: LoadState.error(
            failure: AppFailure(
              code: 'users_load_failed',
              message: 'Không thể tải danh sách người dùng: $err',
              isRetryable: true,
            ),
          ),
        );
      },
    );

    _clubsSub = adminService.streamAllClubs().listen(
      (clubs) {
        if (!ref.mounted) return;
        state = state.copyWith(clubs: clubs);
      },
      onError: (_) {},
    );

    ref.onDispose(() {
      _usersSub?.cancel();
      _clubsSub?.cancel();
    });

    return const AdminUsersState(loadState: LoadState.loading());
  }

  void retry() => ref.invalidateSelf();

  void _applyUsers(List<WebUserProfile> users) {
    final sorted = List<WebUserProfile>.from(users)
      ..sort((a, b) => a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
    final filtered = _filterList(sorted, state.searchQuery, state.roleFilter);
    state = state.copyWith(
      loadState: sorted.isEmpty
          ? const LoadState.empty(message: 'Chưa có người dùng nào trong hệ thống.')
          : LoadState.data(data: filtered),
      allUsers: sorted,
      filteredUsers: filtered,
    );
  }

  List<WebUserProfile> _filterList(
    List<WebUserProfile> list,
    String query,
    String role,
  ) {
    var result = list;
    if (role != 'all') {
      result = result.where((u) => u.role == role).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((u) {
        final nameMatch = u.displayName.toLowerCase().contains(q);
        final emailMatch = u.email.toLowerCase().contains(q);
        final clubMatch = (u.clubName ?? '').toLowerCase().contains(q);
        return nameMatch || emailMatch || clubMatch;
      }).toList();
    }
    return result;
  }

  void search(String query) {
    final filtered = _filterList(state.allUsers, query, state.roleFilter);
    state = state.copyWith(
      searchQuery: query,
      filteredUsers: filtered,
      loadState: filtered.isEmpty && state.allUsers.isNotEmpty
          ? const LoadState.empty(message: 'Không tìm thấy người dùng phù hợp với từ khóa.')
          : LoadState.data(data: filtered),
    );
  }

  void setRoleFilter(String role) {
    final filtered = _filterList(state.allUsers, state.searchQuery, role);
    state = state.copyWith(
      roleFilter: role,
      filteredUsers: filtered,
      loadState: filtered.isEmpty && state.allUsers.isNotEmpty
          ? const LoadState.empty(message: 'Không có người dùng nào thuộc bộ lọc này.')
          : LoadState.data(data: filtered),
    );
  }

  void clearFilters() {
    final filtered = _filterList(state.allUsers, '', 'all');
    state = state.copyWith(
      searchQuery: '',
      roleFilter: 'all',
      filteredUsers: filtered,
      loadState: LoadState.data(data: filtered),
    );
  }

  Future<Result<void>> updateUserRole({
    required String targetUid,
    required String newRole,
    String? clubId,
    String? clubName,
  }) async {
    state = state.copyWith(
      isProcessing: true,
      actionMessage: null,
      errorMessage: null,
    );

    final adminService = ref.read(adminServiceProvider);
    final res = await adminService.updateUserRole(
      targetUid: targetUid,
      newRole: newRole,
      clubId: clubId,
      clubName: clubName,
    );

    if (!ref.mounted) return res;

    res.when(
      success: (_) {
        state = state.copyWith(
          isProcessing: false,
          actionMessage: 'Cập nhật phân quyền người dùng thành công!',
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

final adminUsersViewModelProvider =
    NotifierProvider<AdminUsersViewModel, AdminUsersState>(AdminUsersViewModel.new);

