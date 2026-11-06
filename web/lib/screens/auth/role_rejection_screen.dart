import 'package:flutter/material.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../services/web_contracts.dart';

class RoleRejectionScreen extends StatelessWidget {
  const RoleRejectionScreen({
    super.key,
    required this.reason,
    required this.user,
    required this.onSignOut,
  });

  final String reason;
  final WebUserProfile user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Semantics(
              container: true,
              label: 'Từ chối quyền truy cập. $reason',
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.borderR16,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.elevation2,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: AppColors.warningContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.gpp_bad_outlined,
                        size: 36,
                        color: AppColors.onWarningContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                    Text(
                      'Từ chối quyền truy cập',
                      style: AppTypography.textTheme.headlineSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: AppSpacing.s8,
                      runSpacing: AppSpacing.s8,
                      children: [
                        AppStatusBadge(
                          label: 'Vai trò: ${user.role.toUpperCase()}',
                          variant: AppBadgeVariant.warning,
                          icon: const Icon(Icons.badge_outlined),
                        ),
                        if (user.role == 'staff' &&
                            (user.clubId == null || user.clubId!.isEmpty))
                          const AppStatusBadge(
                            label: 'Chưa gán CLB',
                            variant: AppBadgeVariant.neutral,
                            icon: Icon(Icons.link_off_outlined),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: AppRadius.borderR12,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tài khoản đăng nhập:',
                            style: AppTypography.textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            '${user.displayName} (${user.email})',
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Divider(height: AppSpacing.s20),
                          Text(
                            reason,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    AppButton(
                      label: 'Đăng xuất / Đổi tài khoản khác',
                      semanticsLabel:
                          'Đăng xuất để đổi sang tài khoản Trưởng CLB hoặc Quản trị viên',
                      icon: const Icon(Icons.logout, size: 18),
                      isFullWidth: true,
                      onPressed: onSignOut,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
