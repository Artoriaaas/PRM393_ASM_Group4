import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/web_auth_viewmodel.dart';
import 'role_rejection_screen.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(webAuthViewModelProvider);

    if (authState is WebAuthRejected) {
      return RoleRejectionScreen(
        reason: authState.reason,
        user: authState.user,
        onSignOut: () =>
            ref.read(webAuthViewModelProvider.notifier).signOut(),
      );
    }

    final isLoading = authState is WebAuthLoading;
    final errorMessage =
        authState is WebAuthError ? authState.message : null;

    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s12),
                        decoration: const BoxDecoration(
                          color: AppColors.brandSubtle,
                          borderRadius: AppRadius.borderR12,
                        ),
                        child: const Icon(
                          Icons.hub_outlined,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EventHub',
                              style: AppTypography.textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Cổng Quản Trị CLB & Admin',
                              style: AppTypography.textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s32),

                  Text(
                    'Đăng nhập tài khoản',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    'Hệ thống dành riêng cho Trưởng Câu lạc bộ (staff) và Quản trị viên (admin). Sinh viên vui lòng truy cập ứng dụng Mobile.',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.s24),

                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: AppRadius.borderR8,
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
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
                              errorMessage,
                              style: AppTypography.textTheme.bodyMedium?.copyWith(
                                color: AppColors.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),
                  ],

                  // Google Sign-In Button
                  AppButton(
                    label: isLoading
                        ? 'Đang xác thực...'
                        : 'Đăng nhập bằng Google',
                    icon: const Icon(Icons.login, size: 20),
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () => ref
                            .read(webAuthViewModelProvider.notifier)
                            .signInWithGoogle(),
                  ),

                  const SizedBox(height: AppSpacing.s24),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppSpacing.s16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Flexible(
                        child: Text(
                          'Bảo mật bởi Firebase & Role Rejection Gate',
                          style: AppTypography.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
