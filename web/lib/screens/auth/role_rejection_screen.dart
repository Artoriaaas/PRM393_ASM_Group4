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
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderR16,
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    offset: Offset(0, 8),
                    blurRadius: 24,
                  ),
                ],
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppStatusBadge(
                        label: 'Vai trò: ${user.role.toUpperCase()}',
                        variant: AppBadgeVariant.warning,
                      ),
                      if (user.role == 'staff' &&
                          (user.clubId == null || user.clubId!.isEmpty)) ...[
                        const SizedBox(width: AppSpacing.s8),
                        const AppStatusBadge(
                          label: 'Chưa gán CLB',
                          variant: AppBadgeVariant.neutral,
                        ),
                      ],
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
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  AppButton(
                    label: 'Đăng xuất / Đổi tài khoản khác',
                    icon: const Icon(Icons.logout, size: 18),
                    onPressed: onSignOut,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
