import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../services/web_contracts.dart';
import '../../viewmodels/admin_users_viewmodel.dart';
import '../../viewmodels/web_auth_viewmodel.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openRoleDialog(BuildContext context, WebUserProfile targetUser, List<Club> clubs) {
    final currentUser = ref.read(currentStaffProfileProvider);
    if (currentUser?.uid == targetUser.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tự thay đổi vai trò của chính mình.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    String selectedRole = targetUser.role;
    String? selectedClubId = targetUser.clubId;
    String? selectedClubName = targetUser.clubName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderR16),
            title: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: AppColors.primary),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    'Phân quyền người dùng',
                    style: AppTypography.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: AppRadius.borderR8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          targetUser.displayName.isNotEmpty
                              ? targetUser.displayName
                              : 'Chưa đặt tên',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          targetUser.email,
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Vai trò:',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: AppRadius.borderR8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: AppSpacing.s8,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('Sinh viên / Người tham gia (user)'),
                      ),
                      DropdownMenuItem(
                        value: 'staff',
                        child: Text('Trưởng CLB (staff)'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('Quản trị viên hệ thống (admin)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedRole = val;
                          if (val != 'staff') {
                            selectedClubId = null;
                            selectedClubName = null;
                          } else if (clubs.isNotEmpty && selectedClubId == null) {
                            selectedClubId = clubs.first.id;
                            selectedClubName = clubs.first.name;
                          }
                        });
                      }
                    },
                  ),
                  if (selectedRole == 'staff') ...[
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      'Gán Câu lạc bộ:',
                      style: AppTypography.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    if (clubs.isEmpty)
                      const Text(
                        'Chưa có CLB nào hoạt động. Vui lòng tạo CLB trước.',
                        style: TextStyle(color: AppColors.error),
                      )
                    else
                      DropdownButtonFormField<String>(
                        value: clubs.any((c) => c.id == selectedClubId)
                            ? selectedClubId
                            : clubs.first.id,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: AppRadius.borderR8),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12,
                            vertical: AppSpacing.s8,
                          ),
                        ),
                        items: clubs
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final c = clubs.firstWhere((x) => x.id == val);
                            setDialogState(() {
                              selectedClubId = c.id;
                              selectedClubName = c.name;
                            });
                          }
                        },
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              AppButton(
                label: 'Lưu thay đổi',
                onPressed: () async {
                  if (selectedRole == 'staff' && (selectedClubId == null || selectedClubId!.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng chọn Câu lạc bộ cho Trưởng CLB.')),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  await ref.read(adminUsersViewModelProvider.notifier).updateUserRole(
                        targetUid: targetUser.uid,
                        newRole: selectedRole,
                        clubId: selectedClubId,
                        clubName: selectedClubName,
                      );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersViewModelProvider);
    final vm = ref.read(adminUsersViewModelProvider.notifier);
    final currentAdmin = ref.watch(currentStaffProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.s16,
              runSpacing: AppSpacing.s12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quản lý Người dùng & Phân quyền',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      'Xem danh sách tài khoản, tìm kiếm, gán vai trò và phân bổ quản lý Câu lạc bộ',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandSubtle,
                    borderRadius: AppRadius.borderR8,
                  ),
                  child: Text(
                    'Tổng: ${state.allUsers.length} tài khoản',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),

            if (state.actionMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.successContainer,
                  borderRadius: AppRadius.borderR8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.onSuccessContainer),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        state.actionMessage!,
                        style: const TextStyle(color: AppColors.onSuccessContainer),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => vm.dismissMessage(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],

            if (state.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: AppRadius.borderR8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.onErrorContainer),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: AppColors.onErrorContainer),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => vm.dismissMessage(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],

            // Search bar & filters
            Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hintText: 'Tìm kiếm theo tên, email, câu lạc bộ…',
                    controller: _searchController,
                    onChanged: (val) => vm.search(val),
                    onClear: () {
                      _searchController.clear();
                      vm.search('');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),

            Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                _buildFilterChip('Tất cả', 'all', state.roleFilter, vm),
                _buildFilterChip('Sinh viên (user)', 'user', state.roleFilter, vm),
                _buildFilterChip('Trưởng CLB (staff)', 'staff', state.roleFilter, vm),
                _buildFilterChip('Quản trị viên (admin)', 'admin', state.roleFilter, vm),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),

            // Content
            state.loadState.when(
              initial: () => const Center(child: AppLoadingState(message: 'Đang tải…')),
              loading: (_) => const Center(child: AppLoadingState(message: 'Đang tải người dùng…')),
              empty: (msg) => Center(
                child: AppEmptyState(
                  title: 'Không tìm thấy người dùng',
                  message: msg ?? 'Không có tài khoản nào phù hợp với bộ lọc.',
                  actionLabel: 'Xóa bộ lọc',
                  onAction: () {
                    _searchController.clear();
                    vm.clearFilters();
                  },
                ),
              ),
              error: (f, _) => Center(
                child: AppErrorState(
                  title: 'Lỗi tải danh sách người dùng',
                  message: f.message,
                  onRetry: () => vm.retry(),
                ),
              ),
              data: (users, _, __) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderR12,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, index) {
                      final u = users[index];
                      final isCurrent = u.uid == currentAdmin?.uid;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getRoleBgColor(u.role),
                          child: Icon(_getRoleIcon(u.role), color: _getRoleFgColor(u.role), size: 20),
                        ),
                        title: Row(
                          children: [
                            Text(
                              u.displayName.isNotEmpty ? u.displayName : 'Chưa đặt tên',
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: AppSpacing.s8),
                              const AppStatusBadge(
                                label: 'Bạn',
                                variant: AppBadgeVariant.neutral,
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              u.email,
                              style: AppTypography.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (u.role == 'staff' && (u.clubName != null && u.clubName!.isNotEmpty)) ...[
                              const SizedBox(height: AppSpacing.s4),
                              Row(
                                children: [
                                  const Icon(Icons.groups_outlined, size: 14, color: AppColors.primary),
                                  const SizedBox(width: AppSpacing.s4),
                                  Text(
                                    u.clubName!,
                                    style: AppTypography.textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppStatusBadge(
                              label: _getRoleLabel(u.role),
                              variant: _getRoleBadgeVariant(u.role),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Semantics(
                              button: true,
                              label: 'Phân quyền tài khoản ${u.displayName}',
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: const Text('Phân quyền'),
                                onPressed: isCurrent
                                    ? null
                                    : () => _openRoleDialog(context, u, state.clubs),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    String currentValue,
    AdminUsersViewModel vm,
  ) {
    final isSelected = value == currentValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => vm.setRoleFilter(value),
      selectedColor: AppColors.brandSubtle,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  IconData _getRoleIcon(String role) => switch (role) {
        'admin' => Icons.admin_panel_settings,
        'staff' => Icons.manage_accounts,
        _ => Icons.person,
      };

  Color _getRoleBgColor(String role) => switch (role) {
        'admin' => AppColors.warningContainer,
        'staff' => AppColors.brandSubtle,
        _ => AppColors.surfaceSubtle,
      };

  Color _getRoleFgColor(String role) => switch (role) {
        'admin' => AppColors.onWarningContainer,
        'staff' => AppColors.primary,
        _ => AppColors.textSecondary,
      };

  String _getRoleLabel(String role) => switch (role) {
        'admin' => 'Quản trị viên',
        'staff' => 'Trưởng CLB',
        _ => 'Sinh viên',
      };

  AppBadgeVariant _getRoleBadgeVariant(String role) => switch (role) {
        'admin' => AppBadgeVariant.warning,
        'staff' => AppBadgeVariant.info,
        _ => AppBadgeVariant.neutral,
      };
}

