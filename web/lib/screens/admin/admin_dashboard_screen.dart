import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/admin_dashboard_viewmodel.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      body: state.loadState.when(
        initial: () =>
            const Center(child: AppLoadingState(message: 'Đang tải thống kê hệ thống…')),
        loading: (_) =>
            const Center(child: AppLoadingState(message: 'Đang tải thống kê hệ thống…')),
        empty: (msg) => Center(
          child: AppEmptyState(
            title: 'Chưa có dữ liệu hệ thống',
            message: msg ?? 'Hệ thống chưa ghi nhận dữ liệu thống kê nào.',
          ),
        ),
        error: (failure, _) => Center(
          child: AppErrorState(
            title: 'Lỗi tải thống kê',
            message: failure.message,
            onRetry: () =>
                ref.read(adminDashboardViewModelProvider.notifier).loadDashboard(),
          ),
        ),
        data: (_, __, ___) => _buildDashboardContent(context, ref, state),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    AdminDashboardState state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bảng điều khiển Toàn hệ thống',
                    style: AppTypography.textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s4),
                  Text(
                    'Giám sát hoạt động sự kiện, xét duyệt và cơ cấu người dùng trên toàn trường FPTU',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Làm mới số liệu',
                onPressed: () =>
                    ref.read(adminDashboardViewModelProvider.notifier).loadDashboard(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s24),

          // 4 Main metrics cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final crossAxisCount = isWide ? 4 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: AppSpacing.s16,
                mainAxisSpacing: AppSpacing.s16,
                childAspectRatio: 1.6,
                children: [
                  _buildMetricCard(
                    title: 'Sự kiện đang mở',
                    value: '${state.publishedEventsCount}',
                    icon: Icons.event,
                    color: AppColors.primary,
                    bgColor: AppColors.brandSubtle,
                  ),
                  _buildMetricCard(
                    title: 'Đề xuất sự kiện chờ duyệt',
                    value: '${state.pendingEventsCount}',
                    icon: Icons.pending_actions,
                    color: state.pendingEventsCount > 0
                        ? AppColors.warning
                        : AppColors.textSecondary,
                    bgColor: AppColors.warningContainer,
                  ),
                  _buildMetricCard(
                    title: 'Đăng ký đã duyệt',
                    value: '${state.approvedRegistrationsCount}',
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                    bgColor: AppColors.successContainer,
                  ),
                  _buildMetricCard(
                    title: 'CLB đang hoạt động',
                    value: '${state.activeClubsCount}',
                    icon: Icons.groups,
                    color: AppColors.info,
                    bgColor: AppColors.surfaceSubtle,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.s24),

          // User demographics summary
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderR12,
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_outline, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.s8),
                      Text(
                        'Cơ cấu Người dùng Hệ thống',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDemographicItem(
                          label: 'Sinh viên / Người tham gia',
                          count: state.userCount,
                          role: 'user',
                          icon: Icons.person,
                        ),
                      ),
                      Container(width: 1, height: 48, color: AppColors.border),
                      Expanded(
                        child: _buildDemographicItem(
                          label: 'Trưởng Câu lạc bộ',
                          count: state.staffCount,
                          role: 'staff',
                          icon: Icons.manage_accounts,
                        ),
                      ),
                      Container(width: 1, height: 48, color: AppColors.border),
                      Expanded(
                        child: _buildDemographicItem(
                          label: 'Quản trị viên Hệ thống',
                          count: state.adminCount,
                          role: 'admin',
                          icon: Icons.admin_panel_settings,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s24),

          // Club breakdown table/chart
          if (state.clubEventStats.isNotEmpty) ...[
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.borderR12,
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thống kê theo từng Câu lạc bộ',
                          style: AppTypography.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${state.clubEventStats.length} CLB ghi nhận',
                          style: AppTypography.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.clubEventStats.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final stat = state.clubEventStats[index];
                        final name = stat['clubName'] as String? ?? '';
                        final pub = stat['published'] as int? ?? 0;
                        final app = stat['approved'] as int? ?? 0;
                        final chk = stat['checkedIn'] as int? ?? 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.brandSubtle,
                                  borderRadius: AppRadius.borderR8,
                                ),
                                child: const Icon(
                                  Icons.groups_outlined,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s12),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  name.isNotEmpty ? name : 'CLB chưa đặt tên',
                                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '$pub sự kiện',
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '$app đã duyệt',
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '$chk đã điểm danh',
                                  style: AppTypography.textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
          ],

          // Recent pending registrations
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.borderR12,
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_note, color: AppColors.primary),
                          const SizedBox(width: AppSpacing.s8),
                          Text(
                            'Sự kiện & Đề xuất gần đây',
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.go('/events'),
                        child: const Text('Xem & Phê duyệt sự kiện →'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  if (state.recentEvents.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
                      child: Center(
                        child: Text(
                          'Chưa có sự kiện hoặc đề xuất nào.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.recentEvents.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.border),
                      itemBuilder: (context, index) {
                        final e = state.recentEvents[index];
                        final isPending = e.status == 'pending_approval';
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: isPending
                                ? AppColors.warningContainer
                                : AppColors.brandSubtle,
                            child: Icon(
                              isPending ? Icons.pending_actions : Icons.event,
                              color: isPending
                                  ? AppColors.onWarningContainer
                                  : AppColors.primary,
                            ),
                          ),
                          title: Text(
                            e.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${e.clubName} • ${e.location}',
                          ),
                          trailing: AppStatusBadge(
                            label: isPending
                                ? 'Chờ Admin duyệt'
                                : (e.status == 'published'
                                    ? 'Đang mở'
                                    : (e.status == 'draft'
                                        ? 'Bản nháp'
                                        : (e.status == 'rejected'
                                            ? 'Bị từ chối'
                                            : e.status))),
                            variant: isPending
                                ? AppBadgeVariant.warning
                                : (e.status == 'published'
                                    ? AppBadgeVariant.success
                                    : (e.status == 'rejected'
                                        ? AppBadgeVariant.error
                                        : AppBadgeVariant.neutral)),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: AppRadius.borderR8,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
              ],
            ),
            Text(
              value,
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemographicItem({
    required String label,
    required int count,
    required String role,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.s4),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            '$count',
            style: AppTypography.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
