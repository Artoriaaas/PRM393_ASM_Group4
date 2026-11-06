import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';

import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

class MobileRoleRejectionScreen extends ConsumerWidget {
  const MobileRoleRejectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(sessionViewModelProvider);
    final signedIn = auth is AuthStateSignedIn ? auth : null;
    final authForm = ref.watch(authViewModelProvider);
    final role = signedIn != null ? (signedIn as dynamic).role as String? : null;
    final roleLabel = switch (role) {
      'admin' => 'Quản trị viên (admin)',
      'staff' => 'Trưởng CLB (staff)',
      final r? => r,
      null => 'Không thuộc nhóm người tham gia',
    };

    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      appBar: AppBar(
        title: const Text('Giới hạn vai trò truy cập'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.borderR16,
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.elevation1,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: AppColors.warningContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.gpp_bad_outlined,
                          size: 34,
                          color: AppColors.onWarningContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Text(
                      'Tài khoản quản trị dùng trên Web',
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Center(
                      child: AppStatusBadge(
                        label: 'Vai trò: $roleLabel',
                        variant: AppBadgeVariant.warning,
                        icon: const Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    if (signedIn != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.s12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: AppRadius.borderR12,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (signedIn as dynamic).displayName?.isNotEmpty == true
                                  ? (signedIn as dynamic).displayName!
                                  : 'Tài khoản đang đăng nhập',
                              style: AppTypography.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: AppSpacing.s4),
                            Text(
                              (signedIn as dynamic).email.toString(),
                              style: AppTypography.textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                    ],
                    Text(
                      'Ứng dụng EventHub trên Android chỉ phục vụ vai trò Người tham gia (user). Tài khoản Trưởng CLB và Quản trị viên vui lòng truy cập cổng EventHub Web Admin trên trình duyệt máy tính, hoặc đăng xuất để đổi sang tài khoản sinh viên.',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    AppButton(
                      label: 'Đăng xuất / Đổi tài khoản',
                      isFullWidth: true,
                      isLoading: authForm.busy,
                      icon: const Icon(Icons.logout, size: 18),
                      onPressed: authForm.busy
                          ? null
                          : () => ref
                                .read(sessionViewModelProvider.notifier)
                                .signOut(),
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
