import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub_core/eventhub_core.dart';

import '../../viewmodels/crash_reports_viewmodel.dart';
import '../../viewmodels/web_auth_viewmodel.dart';

class CrashReportsScreen extends ConsumerWidget {
  const CrashReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(currentStaffProfileProvider)?.isAdmin != true) {
      return Scaffold(
        backgroundColor: AppColors.surfaceSubtle,
        body: Center(
          child: AppErrorState(
            title: 'Từ chối truy cập',
            message: 'Chỉ tài khoản có vai trò Quản trị viên (Admin) mới có quyền xem báo cáo lỗi hệ thống.',
          ),
        ),
      );
    }

    final state = ref.watch(crashReportsProvider);
    final vm = ref.read(crashReportsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        children: [
          // Header with Back button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Quay lại Bảng điều khiển',
                onPressed: () => context.go('/admin-dashboard'),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Báo cáo lỗi ứng dụng (Crashlytics)',
                      style: AppTypography.textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      'Truy vấn trực tiếp từ Firebase Crashlytics REST API v1alpha. Sau khi thử crash trên thiết bị, mở lại app để SDK tải báo cáo lên Google Cloud rồi nhấn Làm mới.',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),

          // Action Toolbar & Guidance
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
                Wrap(
                  spacing: AppSpacing.s12,
                  runSpacing: AppSpacing.s8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: state.isLoading ? null : () => vm.load(authorize: true),
                      icon: const Icon(Icons.security, size: 18),
                      label: const Text('Kết nối Google & Cấp quyền'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                          vertical: AppSpacing.s12,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.isLoading ? null : () => vm.load(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Làm mới danh sách'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.s16,
                          vertical: AppSpacing.s12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        'Lưu ý: Tài khoản Google cần được cấp vai trò Firebase Crashlytics Viewer (roles/firebasecrashlytics.viewer) trên Google Cloud IAM của dự án eventhub-group4.',
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),

          // Main Content State
          state.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.s32),
                child: AppLoadingState(message: 'Đang kết nối và tải báo cáo từ Crashlytics API…'),
              ),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
              child: AppErrorState(
                title: 'Không thể tải báo cáo lỗi',
                message: e.toString().replaceFirst('Bad state: ', ''),
                onRetry: () => vm.load(authorize: true),
              ),
            ),
            data: (page) {
              if (page == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s32),
                    child: AppEmptyState(
                      title: 'Chưa kết nối quyền Crashlytics',
                      message: 'Nhấn nút "Kết nối Google & Cấp quyền" ở trên để xác thực quyền đọc dữ liệu Crashlytics từ Google Cloud.',
                    ),
                  ),
                );
              }

              if (page.events.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s32),
                    child: AppEmptyState(
                      title: 'Chưa có sự cố crash nào',
                      message: 'Hệ thống Crashlytics chưa ghi nhận sự cố mới nào được xử lý cho ứng dụng Android.',
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                    child: Text(
                      'Hiển thị ${page.events.length} sự cố trên trang này',
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  for (final e in page.events) _buildCrashCard(context, e),
                  if (page.nextPageToken != null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s16),
                      child: Center(
                        child: OutlinedButton.icon(
                          onPressed: () => vm.load(pageToken: page.nextPageToken),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Tải trang tiếp theo'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s24,
                              vertical: AppSpacing.s12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCrashCard(BuildContext context, Map<String, dynamic> e) {
    final issue = e['issue'] as Map<String, dynamic>? ?? {};
    final title = e['issueTitle'] as String? ?? issue['title'] as String? ?? 'Sự cố ứng dụng';
    final subtitle = e['issueSubtitle'] as String? ?? '';
    final errorType = (issue['errorType'] as String? ?? 'FATAL').toUpperCase();
    final isFatal = errorType == 'FATAL';
    final version = (e['version'] as Map<String, dynamic>?)?['displayName'] as String? ?? 'Không xác định';
    final device = (e['device'] as Map<String, dynamic>?)?['displayName'] as String? ?? 'Thiết bị không xác định';
    final eventTime = e['eventTime'] as String? ?? '—';
    final eventId = e['eventId'] as String? ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderR12,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s8),
                decoration: BoxDecoration(
                  color: isFatal ? AppColors.errorContainer : AppColors.warningContainer,
                  borderRadius: AppRadius.borderR8,
                ),
                child: Icon(
                  isFatal ? Icons.error_outline : Icons.warning_amber_outlined,
                  color: isFatal ? AppColors.onErrorContainer : AppColors.onWarningContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.s4),
                      SelectableText(
                        subtitle,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              AppStatusBadge(
                label: isFatal ? 'Fatal Crash' : 'Non-Fatal Error',
                variant: isFatal ? AppBadgeVariant.error : AppBadgeVariant.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppSpacing.s12),
          Wrap(
            spacing: AppSpacing.s24,
            runSpacing: AppSpacing.s8,
            children: [
              _buildMetaItem(Icons.devices, 'Thiết bị:', device),
              _buildMetaItem(Icons.layers_outlined, 'Phiên bản:', version),
              _buildMetaItem(Icons.access_time, 'Thời điểm:', eventTime),
              _buildMetaItem(Icons.tag, 'Mã báo cáo:', eventId, isSelectable: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String label, String value, {bool isSelectable = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.s4),
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppSpacing.s4),
        if (isSelectable)
          SelectableText(
            value,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          Text(
            value,
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
