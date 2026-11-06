import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/club_events_viewmodel.dart';
import 'event_editor_dialog.dart';

class ClubEventsScreen extends ConsumerWidget {
  const ClubEventsScreen({super.key});

  void _openEventEditor(BuildContext context, [Event? event]) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => EventEditorDialog(initialEvent: event),
    );
  }

  void _confirmArchive(BuildContext context, WidgetRef ref, Event event) {
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

  void _confirmCancel(BuildContext context, WidgetRef ref, Event event) {
    showDialog(
      context: context,
      builder: (ctx) => AppConfirmationDialog(
        title: 'Hủy sự kiện',
        message:
            'CẢNH BÁO: Hủy sự kiện "${event.title}" sẽ đóng toàn bộ lượt đăng ký và điểm danh. Người tham gia đã đăng ký sẽ thấy thông báo sự kiện bị hủy.',
        confirmLabel: 'Xác nhận hủy',
        onConfirm: () {
          Navigator.of(ctx).pop();
          ref.read(clubEventsViewModelProvider.notifier).cancelEvent(event.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clubEventsViewModelProvider);

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
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => _openEventEditor(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s20),

            // Search and Status Filters
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
                  AppSearchField(
                    hintText: 'Tìm theo tên sự kiện, địa điểm hoặc chủ đề...',
                    onChanged: (q) => ref
                        .read(clubEventsViewModelProvider.notifier)
                        .setSearchQuery(q),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Wrap(
                    spacing: AppSpacing.s8,
                    runSpacing: AppSpacing.s8,
                    children: [
                      _buildFilterChip(ref, 'Tất cả', 'all', state.statusFilter),
                      _buildFilterChip(
                          ref, 'Đang mở (published)', 'published', state.statusFilter),
                      _buildFilterChip(
                          ref, 'Bản nháp (draft)', 'draft', state.statusFilter),
                      _buildFilterChip(
                          ref, 'Đã hủy (cancelled)', 'cancelled', state.statusFilter),
                      _buildFilterChip(
                          ref, 'Lưu trữ (archived)', 'archived', state.statusFilter),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.s20),

            // Events List Content (Handling 4 LoadStates)
            state.loadState.when(
              initial: () => const Center(child: AppLoadingState()),
              loading: (_) => const Center(child: AppLoadingState()),
              empty: (msg) => Center(
                child: AppEmptyState(
                  title: 'Chưa có sự kiện',
                  message: msg ?? 'Không tìm thấy sự kiện nào khớp bộ lọc.',
                  actionLabel: 'Tạo sự kiện mới',
                  onAction: () => _openEventEditor(context),
                ),
              ),
              error: (failure, _) => Center(
                child: AppErrorState(
                  title: 'Không thể tải sự kiện',
                  message: failure.message,
                ),
              ),
              data: (events, updatedAt, isStale) {
                if (events.isEmpty) {
                  return Center(
                    child: AppEmptyState(
                      title: 'Không có kết quả',
                      message: 'Không tìm thấy sự kiện nào với bộ lọc hiện tại.',
                      actionLabel: 'Xóa bộ lọc',
                      onAction: () {
                        ref
                            .read(clubEventsViewModelProvider.notifier)
                            .setStatusFilter('all');
                        ref
                            .read(clubEventsViewModelProvider.notifier)
                            .setSearchQuery('');
                      },
                    ),
                  );
                }
                return _buildEventsTable(context, ref, events);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    WidgetRef ref,
    String label,
    String statusKey,
    String currentFilter,
  ) {
    final isSelected = currentFilter == statusKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => ref
          .read(clubEventsViewModelProvider.notifier)
          .setStatusFilter(statusKey),
      selectedColor: AppColors.brandSubtle,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }

  Widget _buildEventsTable(
    BuildContext context,
    WidgetRef ref,
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
        itemCount: events.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          final event = events[index];
          final canCheckIn =
              event.status == 'published' && event.mode == 'required';

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Event Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
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

                // Title & Details
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: AppTypography.textTheme.titleMedium?.copyWith(
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
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        '${event.startsAt.day}/${event.startsAt.month}/${event.startsAt.year} • ${event.location} • Chủ đề: ${event.topic.isEmpty ? 'Chung' : event.topic}',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),

                // Capacity / Mode
                Expanded(
                  flex: 2,
                  child: Column(
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
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: event.capacity > 0
                              ? (event.activeCount / event.capacity).clamp(0.0, 1.0)
                              : 0.0,
                          backgroundColor: AppColors.surfaceSubtle,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 4,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s16),

                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Live Checkin Panel
                    ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code, size: 16),
                      label: const Text('Điểm danh QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canCheckIn ? AppColors.primary : AppColors.surfaceSubtle,
                        foregroundColor:
                            canCheckIn ? AppColors.onPrimary : AppColors.textDisabled,
                        elevation: 0,
                      ),
                      onPressed: canCheckIn
                          ? () => context.go('/events/${event.id}/checkin')
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.s8),

                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Chỉnh sửa sự kiện',
                      onPressed: () => _openEventEditor(context, event),
                    ),

                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (val) {
                        if (val == 'cancel') {
                          _confirmCancel(context, ref, event);
                        } else if (val == 'archive') {
                          _confirmArchive(context, ref, event);
                        }
                      },
                      itemBuilder: (context) => [
                        if (event.status != 'cancelled')
                          const PopupMenuItem(
                            value: 'cancel',
                            child: Row(
                              children: [
                                Icon(Icons.cancel_outlined,
                                    color: AppColors.error, size: 18),
                                SizedBox(width: 8),
                                Text('Hủy sự kiện',
                                    style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        if (event.status != 'archived')
                          const PopupMenuItem(
                            value: 'archive',
                            child: Row(
                              children: [
                                Icon(Icons.archive_outlined,
                                    color: AppColors.textSecondary, size: 18),
                                SizedBox(width: 8),
                                Text('Lưu trữ (Archive)'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
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
}
