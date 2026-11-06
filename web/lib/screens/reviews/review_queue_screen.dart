import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/review_queue_viewmodel.dart';
import 'reject_reason_dialog.dart';

class ReviewQueueScreen extends ConsumerStatefulWidget {
  const ReviewQueueScreen({super.key});

  @override
  ConsumerState<ReviewQueueScreen> createState() => _ReviewQueueScreenState();
}

class _ReviewQueueScreenState extends ConsumerState<ReviewQueueScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleApprove(BuildContext context, Registration reg) {
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

  Future<void> _handleReject(BuildContext context, Registration reg) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => RejectReasonDialog(participantName: reg.participant.name),
    );

    if (reason != null && reason.isNotEmpty && mounted) {
      await ref
          .read(reviewQueueViewModelProvider.notifier)
          .reject(reg, reason: reason);
    }
  }

  String _formatSubmittedAt(DateTime? dt) {
    if (dt == null) return 'Chưa rõ thời điểm gửi';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return 'Gửi lúc $dd/$mm/${dt.year} $hh:$min';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewQueueViewModelProvider);

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
                    mainAxisSize: MainAxisSize.min,
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
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: const BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: AppRadius.borderR8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 20,
                      ),
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
              ),
              const SizedBox(height: AppSpacing.s16),
            ],
            if (state.errorMessage != null) ...[
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: const BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: AppRadius.borderR8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
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
              ),
              const SizedBox(height: AppSpacing.s16),
            ],
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
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 720;
                      final searchWidget = Semantics(
                        textField: true,
                        label:
                            'Tìm kiếm người đăng ký theo họ tên, email hoặc khóa K',
                        child: AppSearchField(
                          controller: _searchController,
                          hintText: 'Tìm theo họ tên, email hoặc khóa K...',
                          onChanged: (q) => ref
                              .read(reviewQueueViewModelProvider.notifier)
                              .setSearchQuery(q),
                          onClear: () => ref
                              .read(reviewQueueViewModelProvider.notifier)
                              .setSearchQuery(''),
                        ),
                      );

                      final eventDropdown = DropdownButtonFormField<String>(
                        key: ValueKey('event_filter_${state.eventFilter}'),
                        initialValue: state.eventFilter,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: AppColors.surfaceSubtle,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s12,
                            vertical: AppSpacing.s12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.borderR8,
                            borderSide: BorderSide(color: AppColors.border),
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
                      );

                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(flex: 3, child: searchWidget),
                            const SizedBox(width: AppSpacing.s16),
                            Expanded(flex: 2, child: eventDropdown),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          searchWidget,
                          const SizedBox(height: AppSpacing.s12),
                          eventDropdown,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.s16,
                    runSpacing: AppSpacing.s12,
                    children: [
                      Wrap(
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s8,
                        children: [
                          _buildStatusTab(
                            'Chờ duyệt',
                            'pending',
                            state.statusFilter,
                          ),
                          _buildStatusTab(
                            'Đã duyệt',
                            'approved',
                            state.statusFilter,
                          ),
                          _buildStatusTab(
                            'Bị từ chối',
                            'rejected',
                            state.statusFilter,
                          ),
                          _buildStatusTab(
                            'Đã hủy',
                            'cancelled',
                            state.statusFilter,
                          ),
                          _buildStatusTab('Tất cả', 'all', state.statusFilter),
                        ],
                      ),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'all', label: Text('Tất cả')),
                          ButtonSegment(
                            value: 'student',
                            label: Text('Sinh viên'),
                          ),
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
            state.loadState.when(
              initial: () => const Center(
                child: AppLoadingState(message: 'Đang tải hàng đợi xét duyệt…'),
              ),
              loading: (_) => const Center(
                child: AppLoadingState(message: 'Đang tải hàng đợi xét duyệt…'),
              ),
              empty: (msg) => Center(
                child: AppEmptyState(
                  title: 'Hàng đợi trống',
                  message: msg ?? 'Chưa có đơn đăng ký nào trong câu lạc bộ.',
                ),
              ),
              error: (failure, _) => Center(
                child: AppErrorState(
                  title: 'Lỗi tải đơn đăng ký',
                  message: failure.message,
                  onRetry: () =>
                      ref.read(reviewQueueViewModelProvider.notifier).retry(),
                ),
              ),
              data: (regs, updatedAt, isStale) {
                if (regs.isEmpty) {
                  return Center(
                    child: AppEmptyState(
                      title: 'Không có đơn phù hợp',
                      message:
                          'Không có đơn nào khớp với bộ lọc hiện tại.',
                      actionLabel: 'Hiển thị tất cả đơn',
                      onAction: () {
                        _searchController.clear();
                        ref
                            .read(reviewQueueViewModelProvider.notifier)
                            .resetFilters();
                      },
                    ),
                  );
                }
                return _buildRegistrationsTable(
                  context,
                  regs,
                  state.eventsById,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(String label, String key, String current) {
    final isSelected = current == key;
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Lọc trạng thái đơn: $label',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppTouchTargets.min),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => ref
              .read(reviewQueueViewModelProvider.notifier)
              .setStatusFilter(key),
          selectedColor: AppColors.brandSubtle,
          labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationsTable(
    BuildContext context,
    List<Registration> regs,
    Map<String, Event> eventsById,
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
          final event = eventsById[reg.eventId];

          return Semantics(
            container: true,
            label:
                'Đơn đăng ký của ${reg.participant.name}, trạng thái ${_mapStatusLabel(reg.status)}',
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 920;

                  final participantSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.s8,
                        runSpacing: AppSpacing.s4,
                        children: [
                          Text(
                            reg.participant.name,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AppStatusBadge(
                            label: reg.participant.group == 'student'
                                ? 'Sinh viên FPTU'
                                : 'Khách ngoài trường',
                            variant: reg.participant.group == 'student'
                                ? AppBadgeVariant.info
                                : AppBadgeVariant.neutral,
                            icon: Icon(
                              reg.participant.group == 'student'
                                  ? Icons.school_outlined
                                  : Icons.person_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        '${reg.participant.email} • ${reg.participant.group == 'student' ? reg.participant.cohort : reg.participant.organization} • SĐT: ${reg.participant.phone.isEmpty ? 'Không có' : reg.participant.phone}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        _formatSubmittedAt(reg.createdAt),
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (reg.isRejected && reg.reason != null) ...[
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          'Lý do từ chối: ${reg.reason}',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.error,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  );

                  final eventSection = Column(
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
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        event != null
                            ? 'Còn ${event.available}/${event.capacity} chỗ (${event.activeCount}/${event.capacity})'
                            : 'Đang đồng bộ sức chứa',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );

                  final badgeWidget = AppStatusBadge(
                    label: _mapStatusLabel(reg.status),
                    variant: _mapStatusVariant(reg.status),
                    icon: Icon(_mapStatusIcon(reg.status)),
                  );

                  final actionsWidget = reg.isPending
                      ? Wrap(
                          spacing: AppSpacing.s8,
                          runSpacing: AppSpacing.s8,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: AppTouchTargets.min,
                              ),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.check, size: 16),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: AppColors.onSuccess,
                                  elevation: 0,
                                ),
                                onPressed: () => _handleApprove(context, reg),
                                label: const Text('Duyệt (Approve)'),
                              ),
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: AppTouchTargets.min,
                              ),
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.close, size: 16),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(
                                    color: AppColors.error,
                                  ),
                                ),
                                onPressed: () => _handleReject(context, reg),
                                label: const Text('Từ chối (Reject)'),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          width: isWide ? 180 : null,
                          child: Text(
                            'Đã xử lý',
                            textAlign: isWide
                                ? TextAlign.center
                                : TextAlign.start,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textDisabled,
                            ),
                          ),
                        );

                  if (isWide) {
                    return Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          child: Text(
                            reg.participant.name.isNotEmpty
                                ? reg.participant.name[0].toUpperCase()
                                : 'U',
                            style: AppTypography.textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(flex: 3, child: participantSection),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(flex: 2, child: eventSection),
                        const SizedBox(width: AppSpacing.s16),
                        badgeWidget,
                        const SizedBox(width: AppSpacing.s16),
                        actionsWidget,
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: eventSection),
                          const SizedBox(width: AppSpacing.s8),
                          badgeWidget,
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                      participantSection,
                      const SizedBox(height: AppSpacing.s12),
                      actionsWidget,
                    ],
                  );
                },
              ),
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

  IconData _mapStatusIcon(String status) => switch (status) {
        'pending' => Icons.schedule,
        'approved' => Icons.check_circle_outline,
        'rejected' => Icons.cancel_outlined,
        'cancelled' => Icons.remove_circle_outline,
        _ => Icons.info_outline,
      };
}
