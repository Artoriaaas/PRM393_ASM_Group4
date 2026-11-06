import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import 'club_attendance_chart.dart';

class ClubDashboardScreen extends ConsumerWidget {
  const ClubDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      body: state.loadState.when(
        initial: () =>
            const Center(child: AppLoadingState(message: 'Đang tải thống kê CLB…')),
        loading: (_) =>
            const Center(child: AppLoadingState(message: 'Đang tải thống kê CLB…')),
        empty: (msg) => Center(
          child: AppEmptyState(
            title: 'Chưa có sự kiện nào',
            message:
                msg ?? 'Câu lạc bộ của bạn chưa tạo sự kiện nào trên hệ thống.',
            actionLabel: 'Tạo sự kiện đầu tiên',
            onAction: () => context.go('/events'),
          ),
        ),
        error: (failure, _) => Center(
          child: AppErrorState(
            title: 'Lỗi tải thống kê',
            message: failure.message,
            onRetry: () =>
                ref.read(dashboardViewModelProvider.notifier).loadDashboard(),
          ),
        ),
        data: (data, updatedAt, isStale) =>
            _buildDashboardContent(context, ref, state),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    DashboardState state,
  ) {
    return SingleChildScrollView(
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
                    'Bảng điều khiển CLB',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Tổng hợp số liệu thời gian thực và quản lý đơn đăng ký',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              AppButton(
                label: 'Tạo sự kiện mới',
                semanticsLabel: 'Chuyển tới màn hình quản lý sự kiện để tạo mới',
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => context.go('/events'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 800;
              return Wrap(
                spacing: AppSpacing.s16,
                runSpacing: AppSpacing.s16,
                children: [
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - AppSpacing.s32) / 3
                        : double.infinity,
                    child: _buildMetricCard(
                      title: 'Sự kiện đang mở',
                      value: '${state.publishedEventsCount}',
                      subtitle: 'Sự kiện công khai',
                      icon: Icons.event_available,
                      iconColor: AppColors.info,
                      bgColor: AppColors.infoContainer,
                      onTap: () => context.go('/events'),
                    ),
                  ),
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - AppSpacing.s32) / 3
                        : double.infinity,
                    child: _buildMetricCard(
                      title: 'Đơn chờ duyệt',
                      value: '${state.pendingRegistrationsCount}',
                      subtitle: 'Cần xem xét ngay',
                      icon: Icons.pending_actions,
                      iconColor: AppColors.warning,
                      bgColor: AppColors.warningContainer,
                      onTap: () => context.go('/reviews'),
                      badgeLabel: state.pendingRegistrationsCount > 0
                          ? 'Cần xử lý'
                          : null,
                    ),
                  ),
                  SizedBox(
                    width: isWide
                        ? (constraints.maxWidth - AppSpacing.s32) / 3
                        : double.infinity,
                    child: _buildMetricCard(
                      title: 'Đã duyệt / Điểm danh',
                      value:
                          '${state.approvedRegistrationsCount} / ${state.checkedInRegistrationsCount}',
                      subtitle: 'Lượt tham gia thực tế',
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.success,
                      bgColor: AppColors.successContainer,
                      onTap: () => context.go('/reviews'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.s24),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderR12,
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.elevation1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.s12,
                  runSpacing: AppSpacing.s8,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thống kê Sức chứa — Đã duyệt — Điểm danh',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          'So sánh 5 sự kiện gần nhất của câu lạc bộ',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const AppStatusBadge(
                      label: 'Tổng hợp trực tiếp',
                      variant: AppBadgeVariant.neutral,
                      icon: Icon(Icons.query_stats),
                    ),
                  ],
                ),
                const Divider(height: AppSpacing.s24, color: AppColors.border),
                ClubAttendanceChart(metrics: state.chartData),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildRecentPendingCard(
                        context,
                        state.recentPendingRegistrations,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s20),
                    Expanded(
                      child: _buildRecentEventsCard(
                        context,
                        state.recentEvents,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildRecentPendingCard(
                      context,
                      state.recentPendingRegistrations,
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    _buildRecentEventsCard(context, state.recentEvents),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
    String? badgeLabel,
  }) {
    return Semantics(
      button: true,
      label: '$title: $value. $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderR12,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderR12,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: AppRadius.borderR12,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: AppSpacing.s16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: AppTypography.textTheme.labelMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeLabel != null) ...[
                            const SizedBox(width: AppSpacing.s8),
                            AppStatusBadge(
                              label: badgeLabel,
                              variant: AppBadgeVariant.warning,
                              icon: const Icon(Icons.priority_high),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        value,
                        style: AppTypography.textTheme.headlineSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        subtitle,
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPendingCard(
    BuildContext context,
    List<Registration> regs,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderR12,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Đơn mới chờ duyệt',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ConstrainedBox(
                constraints: AppTouchTargets.minConstraints,
                child: TextButton(
                  onPressed: () => context.go('/reviews'),
                  child: const Text('Xem tất cả'),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.s16, color: AppColors.border),
          if (regs.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s20),
              child: Center(
                child: Text(
                  'Không có đơn nào đang chờ duyệt.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: regs.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final reg = regs[index];
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        reg.participant.name.isNotEmpty
                            ? reg.participant.name[0].toUpperCase()
                            : 'U',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      reg.participant.name,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${reg.participant.email} • ${reg.participant.group == 'student' ? reg.participant.cohort : reg.participant.organization}',
                      style: AppTypography.textTheme.labelSmall,
                    ),
                    trailing: const AppStatusBadge(
                      label: 'Chờ duyệt',
                      variant: AppBadgeVariant.warning,
                      icon: Icon(Icons.schedule),
                    ),
                    onTap: () => context.go('/reviews'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRecentEventsCard(
    BuildContext context,
    List<Event> events,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderR12,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Sự kiện của CLB',
                  style: AppTypography.textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ConstrainedBox(
                constraints: AppTouchTargets.minConstraints,
                child: TextButton(
                  onPressed: () => context.go('/events'),
                  child: const Text('Xem tất cả'),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.s16, color: AppColors.border),
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s20),
              child: Center(
                child: Text(
                  'Câu lạc bộ chưa có sự kiện nào.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final ev = events[index];
                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: AppRadius.borderR8,
                      ),
                      child: const Icon(
                        Icons.event,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      ev.title,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${ev.activeCount}/${ev.capacity} chỗ • ${ev.location}',
                      style: AppTypography.textTheme.labelSmall,
                    ),
                    trailing: AppStatusBadge(
                      label: _mapEventStatus(ev.status),
                      variant: _mapStatusVariant(ev.status),
                      icon: Icon(_mapStatusIcon(ev.status)),
                    ),
                    onTap: () => context.go('/events'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _mapEventStatus(String status) => switch (status) {
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
