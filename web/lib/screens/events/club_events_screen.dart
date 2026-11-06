import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/club_events_viewmodel.dart';
import 'event_editor_dialog.dart';

class ClubEventsScreen extends ConsumerStatefulWidget {
  const ClubEventsScreen({super.key});

  @override
  ConsumerState<ClubEventsScreen> createState() => _ClubEventsScreenState();
}

class _ClubEventsScreenState extends ConsumerState<ClubEventsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openEventEditor(BuildContext context, [Event? event]) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EventEditorDialog(initialEvent: event),
    );
  }

  void _confirmArchive(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AppConfirmationDialog(
        title: 'Lưu trữ sự kiện',
        message:
            'Bạn có chắc muốn lưu trữ sự kiện "${event.title}"? Sự kiện sẽ được ẩn khỏi danh sách khám phá công khai nhưng lịch sử đăng ký của sinh viên vẫn được bảo lưu an toàn.',
        confirmLabel: 'Lưu trữ',
        onConfirm: () {
          Navigator.of(ctx).pop();
          ref.read(clubEventsViewModelProvider.notifier).archiveEvent(event.id);
        },
      ),
    );
  }

  void _confirmCancel(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AppConfirmationDialog(
        title: 'Hủy sự kiện',
        message:
            'CẢNH BÁO: Hủy sự kiện "${event.title}" sẽ đóng toàn bộ lượt đăng ký và điểm danh. Người tham gia đã đăng ký sẽ thấy thông báo sự kiện bị hủy.',
        confirmLabel: 'Xác nhận hủy',
        isDestructive: true,
        onConfirm: () {
          Navigator.of(ctx).pop();
          ref.read(clubEventsViewModelProvider.notifier).cancelEvent(event.id);
        },
      ),
    );
  }

  void _clearAllFilters() {
    _searchController.clear();
    ref.read(clubEventsViewModelProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clubEventsViewModelProvider);

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
                      'Quản lý Sự kiện CLB',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      'Tạo, chỉnh sửa, lưu trữ và điều phối điểm danh QR các sự kiện',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                AppButton(
                  label: 'Tạo sự kiện mới',
                  semanticsLabel: 'Mở biểu mẫu tạo sự kiện mới cho câu lạc bộ',
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => _openEventEditor(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),
            if (state.actionMessage != null) ...[
              Container(
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
              const SizedBox(height: AppSpacing.s16),
            ],
            if (state.errorMessage != null) ...[
              Container(
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
                  Semantics(
                    textField: true,
                    label: 'Ô tìm kiếm sự kiện theo tên, địa điểm hoặc chủ đề',
                    child: AppSearchField(
                      controller: _searchController,
                      hintText:
                          'Tìm theo tên sự kiện, địa điểm hoặc chủ đề...',
                      onChanged: (q) => ref
                          .read(clubEventsViewModelProvider.notifier)
                          .setSearchQuery(q),
                      onClear: () => ref
                          .read(clubEventsViewModelProvider.notifier)
                          .setSearchQuery(''),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      _buildFilterChip('Tất cả', 'all', state.statusFilter),
                      _buildFilterChip(
                        'Đang mở (published)',
                        'published',
                        state.statusFilter,
                      ),
                      _buildFilterChip(
                        'Bản nháp (draft)',
                        'draft',
                        state.statusFilter,
                      ),
                      _buildFilterChip(
                        'Đã hủy (cancelled)',
                        'cancelled',
                        state.statusFilter,
                      ),
                      _buildFilterChip(
                        'Lưu trữ (archived)',
                        'archived',
                        state.statusFilter,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            state.loadState.when(
              initial: () =>
                  const Center(child: AppLoadingState(message: 'Đang tải sự kiện…')),
              loading: (_) =>
                  const Center(child: AppLoadingState(message: 'Đang tải sự kiện…')),
              empty: (msg) => Center(
                child: AppEmptyState(
                  title: 'Chưa có sự kiện',
                  message: msg ?? 'Câu lạc bộ chưa khởi tạo sự kiện nào.',
                  actionLabel: 'Tạo sự kiện đầu tiên',
                  onAction: () => _openEventEditor(context),
                ),
              ),
              error: (failure, _) => Center(
                child: AppErrorState(
                  title: 'Không thể tải sự kiện',
                  message: failure.message,
                  onRetry: () =>
                      ref.read(clubEventsViewModelProvider.notifier).retry(),
                ),
              ),
              data: (events, updatedAt, isStale) {
                if (events.isEmpty) {
                  return Center(
                    child: AppEmptyState(
                      title: 'Không có kết quả',
                      message:
                          'Không tìm thấy sự kiện nào khớp với bộ lọc hiện tại.',
                      actionLabel: 'Xóa bộ lọc',
                      onAction: _clearAllFilters,
                    ),
                  );
                }
                return _buildEventsTable(context, events);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String statusKey,
    String currentFilter,
  ) {
    final isSelected = currentFilter == statusKey;
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Lọc sự kiện theo trạng thái: $label',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppTouchTargets.min),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => ref
              .read(clubEventsViewModelProvider.notifier)
              .setStatusFilter(statusKey),
          selectedColor: AppColors.brandSubtle,
          labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildEventsTable(BuildContext context, List<Event> events) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderR12,
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: events.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final event = events[index];
          final canCheckIn =
              event.status == 'published' && event.mode == 'required';

          return Semantics(
            container: true,
            label:
                'Sự kiện ${event.title}, trạng thái ${_mapStatusLabel(event.status)}, ${event.mode == "free" ? "Tham gia tự do" : "Đã duyệt ${event.activeCount} trên ${event.capacity}"}',
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 820;
                  final titleSection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: AppTypography.textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          AppStatusBadge(
                            label: _mapStatusLabel(event.status),
                            variant: _mapStatusVariant(event.status),
                            icon: Icon(_mapStatusIcon(event.status)),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        '${event.startsAt.day.toString().padLeft(2, "0")}/${event.startsAt.month.toString().padLeft(2, "0")}/${event.startsAt.year} • ${event.location} • Chủ đề: ${event.topic.isEmpty ? "Chung" : event.topic}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );

                  final capacitySection = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.mode == 'free'
                            ? 'Tham gia tự do'
                            : 'Đã duyệt: ${event.activeCount} / ${event.capacity}',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (event.mode == 'required') ...[
                        const SizedBox(height: AppSpacing.s4),
                        ClipRRect(
                          borderRadius: AppRadius.borderR6,
                          child: LinearProgressIndicator(
                            value: event.capacity > 0
                                ? (event.activeCount / event.capacity).clamp(
                                    0.0,
                                    1.0,
                                  )
                                : 0.0,
                            backgroundColor: AppColors.surfaceSubtle,
                            valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ],
                  );

                  final actionsSection = Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: AppTouchTargets.min,
                        ),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.qr_code, size: 16),
                          label: const Text('Điểm danh QR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canCheckIn
                                ? AppColors.primary
                                : AppColors.surfaceSubtle,
                            foregroundColor: canCheckIn
                                ? AppColors.onPrimary
                                : AppColors.textDisabled,
                            elevation: 0,
                          ),
                          onPressed: canCheckIn
                              ? () => context.go('/events/${event.id}/checkin')
                              : null,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: AppTouchTargets.minConstraints,
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Chỉnh sửa sự kiện',
                          onPressed: () => _openEventEditor(context, event),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: AppTouchTargets.minConstraints,
                        child: PopupMenuButton<String>(
                          tooltip: 'Tác vụ khác',
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (val) {
                            if (val == 'cancel') {
                              _confirmCancel(context, event);
                            } else if (val == 'archive') {
                              _confirmArchive(context, event);
                            }
                          },
                          itemBuilder: (context) => [
                            if (event.status != 'cancelled')
                              const PopupMenuItem(
                                value: 'cancel',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.cancel_outlined,
                                      color: AppColors.error,
                                      size: 18,
                                    ),
                                    SizedBox(width: AppSpacing.s8),
                                    Text(
                                      'Hủy sự kiện',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              ),
                            if (event.status != 'archived')
                              const PopupMenuItem(
                                value: 'archive',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.archive_outlined,
                                      color: AppColors.textSecondary,
                                      size: 18,
                                    ),
                                    SizedBox(width: AppSpacing.s8),
                                    Text('Lưu trữ (Archive)'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.brandSubtle,
                            borderRadius: AppRadius.borderR12,
                          ),
                          child: const Icon(
                            Icons.event_note,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(flex: 3, child: titleSection),
                        const SizedBox(width: AppSpacing.s16),
                        Expanded(flex: 2, child: capacitySection),
                        const SizedBox(width: AppSpacing.s16),
                        actionsSection,
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleSection,
                      const SizedBox(height: AppSpacing.s12),
                      capacitySection,
                      const SizedBox(height: AppSpacing.s12),
                      actionsSection,
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
        'published' => 'Đang mở',
        'draft' => 'Bản nháp',
        'cancelled' => 'Đã hủy',
        'archived' => 'Lưu trữ',
        _ => status,
      };

  AppBadgeVariant _mapStatusVariant(String status) => switch (status) {
        'published' => AppBadgeVariant.success,
        'draft' => AppBadgeVariant.neutral,
        'cancelled' => AppBadgeVariant.error,
        'archived' => AppBadgeVariant.info,
        _ => AppBadgeVariant.neutral,
      };

  IconData _mapStatusIcon(String status) => switch (status) {
        'published' => Icons.public,
        'draft' => Icons.edit_note,
        'cancelled' => Icons.cancel_outlined,
        'archived' => Icons.archive_outlined,
        _ => Icons.info_outline,
      };
}
