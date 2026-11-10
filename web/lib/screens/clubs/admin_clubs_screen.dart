import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/admin_clubs_viewmodel.dart';

class AdminClubsScreen extends ConsumerStatefulWidget {
  const AdminClubsScreen({super.key});

  @override
  ConsumerState<AdminClubsScreen> createState() => _AdminClubsScreenState();
}

class _AdminClubsScreenState extends ConsumerState<AdminClubsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openClubDialog(BuildContext context, [Club? club]) {
    final nameCtrl = TextEditingController(text: club?.name ?? '');
    final shortNameCtrl = TextEditingController(text: club?.shortName ?? '');
    final descCtrl = TextEditingController(text: club?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderR16),
        title: Text(
          club == null ? 'Tạo Câu lạc bộ mới' : 'Chỉnh sửa Câu lạc bộ',
          style: AppTypography.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  labelText: 'Tên Câu lạc bộ *',
                  hintText: 'Ví dụ: Câu lạc bộ Lập trình F-Code',
                  controller: nameCtrl,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Tên Câu lạc bộ không được để trống';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s12),
                AppTextField(
                  labelText: 'Tên viết tắt',
                  hintText: 'Ví dụ: F-Code',
                  controller: shortNameCtrl,
                ),
                const SizedBox(height: AppSpacing.s12),
                AppTextField(
                  labelText: 'Mô tả hoạt động',
                  hintText: 'Giới thiệu về mục tiêu, lĩnh vực hoạt động của CLB…',
                  controller: descCtrl,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          AppButton(
            label: club == null ? 'Tạo mới' : 'Cập nhật',
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              final vm = ref.read(adminClubsViewModelProvider.notifier);
              if (club == null) {
                await vm.createClub(
                  name: nameCtrl.text.trim(),
                  shortName: shortNameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
              } else {
                final updated = Club(
                  id: club.id,
                  name: nameCtrl.text.trim(),
                  shortName: shortNameCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  status: club.status,
                );
                await vm.updateClub(updated);
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmArchive(BuildContext context, Club club) {
    showDialog(
      context: context,
      builder: (ctx) => AppConfirmationDialog(
        title: 'Lưu trữ Câu lạc bộ',
        message:
            'Bạn có chắc muốn lưu trữ Câu lạc bộ "${club.name}"? CLB sẽ được ẩn khỏi danh mục hoạt động nhưng dữ liệu sự kiện lịch sử vẫn được bảo lưu an toàn.',
        confirmLabel: 'Lưu trữ',
        onConfirm: () {
          Navigator.pop(ctx);
          ref.read(adminClubsViewModelProvider.notifier).archiveClub(club.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminClubsViewModelProvider);
    final vm = ref.read(adminClubsViewModelProvider.notifier);

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
                      'Danh mục Câu lạc bộ',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      'Quản trị danh sách các CLB sinh viên, tạo mới, chỉnh sửa thông tin và lưu trữ',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                AppButton(
                  label: 'Tạo CLB mới',
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => _openClubDialog(context),
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
                    hintText: 'Tìm kiếm theo tên CLB, tên viết tắt, mô tả…',
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
                _buildFilterChip('Tất cả', 'all', state.statusFilter, vm),
                _buildFilterChip('Đang hoạt động', 'active', state.statusFilter, vm),
                _buildFilterChip('Đã lưu trữ', 'archived', state.statusFilter, vm),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),

            // Content
            state.loadState.when(
              initial: () => const Center(child: AppLoadingState(message: 'Đang tải…')),
              loading: (_) => const Center(child: AppLoadingState(message: 'Đang tải danh sách CLB…')),
              empty: (msg) => Center(
                child: AppEmptyState(
                  title: 'Chưa có Câu lạc bộ',
                  message: msg ?? 'Chưa có Câu lạc bộ nào phù hợp với bộ lọc.',
                  actionLabel: 'Tạo CLB đầu tiên',
                  onAction: () => _openClubDialog(context),
                ),
              ),
              error: (f, _) => Center(
                child: AppErrorState(
                  title: 'Lỗi tải danh sách Câu lạc bộ',
                  message: f.message,
                  onRetry: () => vm.retry(),
                ),
              ),
              data: (clubs, _, __) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 3 : 1,
                        crossAxisSpacing: AppSpacing.s16,
                        mainAxisSpacing: AppSpacing.s16,
                        mainAxisExtent: 200,
                      ),
                      itemCount: clubs.length,
                      itemBuilder: (context, index) {
                        final club = clubs[index];
                        final isActive = club.status == 'active';

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.borderR12,
                            side: const BorderSide(color: AppColors.border),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.s16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.s8),
                                      decoration: BoxDecoration(
                                        color: AppColors.brandSubtle,
                                        borderRadius: AppRadius.borderR8,
                                      ),
                                      child: const Icon(
                                        Icons.groups,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.s12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            club.name,
                                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (club.shortName.isNotEmpty)
                                            Text(
                                              club.shortName,
                                              style: AppTypography.textTheme.labelSmall?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    AppStatusBadge(
                                      label: isActive ? 'Hoạt động' : 'Lưu trữ',
                                      variant: isActive
                                          ? AppBadgeVariant.success
                                          : AppBadgeVariant.neutral,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.s12),
                                Expanded(
                                  child: Text(
                                    club.description.isNotEmpty
                                        ? club.description
                                        : 'Chưa có mô tả cho câu lạc bộ này.',
                                    style: AppTypography.textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Divider(height: 1, color: AppColors.border),
                                const SizedBox(height: AppSpacing.s8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit_outlined, size: 16),
                                      label: const Text('Sửa'),
                                      onPressed: () => _openClubDialog(context, club),
                                    ),
                                    if (isActive)
                                      TextButton.icon(
                                        icon: const Icon(Icons.archive_outlined, size: 16),
                                        label: const Text('Lưu trữ'),
                                        onPressed: () => _confirmArchive(context, club),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
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
    AdminClubsViewModel vm,
  ) {
    final isSelected = value == currentValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => vm.setStatusFilter(value),
      selectedColor: AppColors.brandSubtle,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
