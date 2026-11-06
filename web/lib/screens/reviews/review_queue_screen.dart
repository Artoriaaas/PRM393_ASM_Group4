import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/review_queue_viewmodel.dart';
import 'reject_reason_dialog.dart';

class ReviewQueueScreen extends ConsumerWidget {
  const ReviewQueueScreen({super.key});

  void _handleApprove(
    BuildContext context,
    WidgetRef ref,
    Registration reg,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AppConfirmationDialog(
        title: 'Phê duyệt đơn đăng ký',
        message:
            'Xác nhận phê duyệt cho "${reg.participant.name}" (${reg.participant.email}) tham gia sự kiện? Số lượng chỗ sẽ tăng thêm 1 và thông báo xác nhận sẽ gửi về thiết bị của sinh viên.',
        confirmLabel: 'Phê duyệt',
        onConfirm: () {
          Navigator.of(ctx).pop();
          ref.read(reviewQueueViewModelProvider.notifier).approve(reg);
        },
      ),
    );
  }

  void _handleReject(
    BuildContext context,
    WidgetRef ref,
    Registration reg,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => RejectReasonDialog(
        participantName: reg.participant.name,
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      ref.read(reviewQueueViewModelProvider.notifier).reject(reg, reason: reason);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewQueueViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hàng đợi Xét duyệt Đăng ký',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      'Phê duyệt hoặc từ chối đơn tham gia sự kiện (Đồng bộ thời gian thực)',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (state.isProcessing)
                  const Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: AppSpacing.s8),
                      Text('Đang xử lý giao dịch...'),
                    ],
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
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        state.actionMessage!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSuccessContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],

            // Filter & Search Controls
            Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderR12,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AppSearchField(
                          hintText: 'Tìm theo họ tên, email hoặc khóa K...',
                          onChanged: (q) => ref
                              .read(reviewQueueViewModelProvider.notifier)
                              .setSearchQuery(q),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s16),
                      // Event Filter Dropdown
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: state.eventFilter,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.surfaceSubtle,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s12,
                              vertical: AppSpacing.s8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.borderR8,
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: 'all',
                              child: Text('Tất cả sự kiện CLB'),
                            ),
                            ...state.events.map(
                              (e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(
                                  e.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(reviewQueueViewModelProvider.notifier)
                                  .setEventFilter(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.s16,
                    runSpacing: AppSpacing.s12,
                    children: [
                      // Status tabs
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: [
                          _buildStatusTab(ref, 'Chờ duyệt', 'pending', state.statusFilter),
                          _buildStatusTab(ref, 'Đã duyệt', 'approved', state.statusFilter),
                          _buildStatusTab(ref, 'Bị từ chối', 'rejected', state.statusFilter),
                          _buildStatusTab(ref, 'Đã hủy', 'cancelled', state.statusFilter),
                          _buildStatusTab(ref, 'Tất cả', 'all', state.statusFilter),
                        ],
                      ),

                      // Group filter
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'all', label: Text('Tất cả')),
                          ButtonSegment(value: 'student', label: Text('Sinh viên')),
                          ButtonSegment(value: 'guest', label: Text('Khách')),
                        ],
                        selected: {state.groupFilter},
                        onSelectionChanged: (set) {
                          ref
                              .read(reviewQueueViewModelProvider.notifier)
                              .setGroupFilter(set.first);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),

            // Registrations Table (Handling 4 LoadStates)
            state.loadState.when(
              initial: () => const Center(child: AppLoadingState()),
              loading: (_) => const Center(child: AppLoadingState()),
              empty: (msg) => Center(
                child: AppEmptyState(
                  title: 'Hàng đợi trống',
                  message: msg ?? 'Không có đơn nào khớp với bộ lọc hiện tại.',
                ),
              ),
              error: (failure, _) => Center(
                child: AppErrorState(
                  title: 'Lỗi tải đơn đăng ký',
                  message: failure.message,
                ),
              ),
              data: (regs, updatedAt, isStale) {
                if (regs.isEmpty) {
                  return const Center(
                    child: AppEmptyState(
                      title: 'Không có đơn phù hợp',
                      message: 'Thử đổi tiêu chí tìm kiếm hoặc trạng thái xét duyệt.',
                    ),
                  );
                }
                return _buildRegistrationsTable(context, ref, regs, state.events);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(
    WidgetRef ref,
    String label,
    String key,
    String current,
  ) {
    final isSelected = current == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => ref
          .read(reviewQueueViewModelProvider.notifier)
          .setStatusFilter(key),
      selectedColor: AppColors.brandSubtle,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildRegistrationsTable(
    BuildContext context,
    WidgetRef ref,
    List<Registration> regs,
    List<Event> events,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderR12,
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: regs.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final reg = regs[index];
          final event = events.where((e) => e.id == reg.eventId).firstOrNull;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    reg.participant.name.isNotEmpty
                        ? reg.participant.name[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),

                // Participant Info
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              reg.participant.name,
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          AppStatusBadge(
                            label: reg.participant.group == 'student'
                                ? 'Sinh viên FPTU'
                                : 'Khách ngoài trường',
                            variant: reg.participant.group == 'student'
                                ? AppBadgeVariant.info
                                : AppBadgeVariant.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${reg.participant.email} • ${reg.participant.group == 'student' ? reg.participant.cohort : reg.participant.organization} • SĐT: ${reg.participant.phone.isEmpty ? 'Không có' : reg.participant.phone}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (reg.isRejected && reg.reason != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Lý do từ chối: ${reg.reason}',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.error,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),

                // Event & Capacity
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event?.title ?? 'Sự kiện #${reg.eventId}',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event != null
                            ? 'Còn ${event.capacity - event.activeCount}/${event.capacity} chỗ'
                            : 'Không rõ sức chứa',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),

                // Status Badge
                AppStatusBadge(
                  label: _mapStatusLabel(reg.status),
                  variant: _mapStatusVariant(reg.status),
                ),
                const SizedBox(width: AppSpacing.s16),

                // Action Buttons (Only for Pending)
                if (reg.isPending) ...[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.onSuccess,
                      elevation: 0,
                    ),
                    onPressed: () => _handleApprove(context, ref, reg),
                    child: const Text('Duyệt (Approve)'),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: () => _handleReject(context, ref, reg),
                    child: const Text('Từ chối (Reject)'),
                  ),
                ] else ...[
                  const SizedBox(
                    width: 180,
                    child: Text(
                      'Đã xử lý',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textDisabled),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _mapStatusLabel(String status) => switch (status) {
        'pending' => 'Chờ duyệt',
        'approved' => 'Đã duyệt',
        'rejected' => 'Bị từ chối',
        'cancelled' => 'Đã hủy',
        _ => status,
      };

  AppBadgeVariant _mapStatusVariant(String status) => switch (status) {
        'pending' => AppBadgeVariant.warning,
        'approved' => AppBadgeVariant.success,
        'rejected' => AppBadgeVariant.error,
        'cancelled' => AppBadgeVariant.neutral,
        _ => AppBadgeVariant.neutral,
      };
}
