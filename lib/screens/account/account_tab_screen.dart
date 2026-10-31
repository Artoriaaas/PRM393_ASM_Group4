import '../../app/development.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../models/auth_state.dart';
import '../../viewmodels/auth_viewmodel.dart';

import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_top_bar.dart';

/// A10 Account Tab Screen (Placeholder in Step 3)
class AccountTabScreen extends ConsumerWidget {
  const AccountTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionViewModelProvider);
    final authForm = ref.watch(authViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      appBar: const AppTopBar(
        title: 'EventHub — Tài khoản',
        subtitle: 'Thông tin cá nhân & cài đặt',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          children: [
            if (session is AuthStateSignedIn) ...[
              Text(
                session.displayName ?? 'Tài khoản EventHub',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(session.email),
              const SizedBox(height: AppSpacing.s16),
              AppButton(
                label: 'Đăng xuất',
                isLoading: authForm.busy,
                onPressed: () =>
                    ref.read(authViewModelProvider.notifier).submit('logout'),
              ),
              if (authForm.message != null) Text(authForm.message!),
            ],
            Card(
              color: AppColors.surface,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.borderR12,
                side: BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: AppStatusBadge(
                            label: 'A10 — HỒ SƠ & TÀI KHOẢN (BƯỚC 3 NỀN TẢNG)',
                            variant: AppBadgeVariant.info,
                            icon: Icon(Icons.person_outline),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      'Tài khoản người dùng & Tiện ích Lab 3',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'Hồ sơ và tiện ích Lab 3 đang được hoàn thiện. Thông tin phiên phía trên lấy từ dịch vụ xác thực khi đã kết nối.',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    AppButton(
                      label: 'Xem màn Đăng nhập (A01a)',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.push('/auth/login'),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    AppButton(
                      label: 'Xem chỉnh sửa hồ sơ (A10 edit)',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.push('/account/edit'),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    AppButton(
                      label: 'Khu Demo Firebase (L3-01)',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.push('/account/firebase-demo'),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    AppButton(
                      label: 'Xuất & Upload báo cáo (L3-02)',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.push('/account/export'),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    const Divider(),
                    const SizedBox(height: AppSpacing.s12),
                    if (developmentUiEnabled)
                      AppButton(
                        label: 'Xem thử Component UI (360/412dp)',
                        icon: const Icon(Icons.palette_outlined, size: 20),
                        variant: AppButtonVariant.primary,
                        onPressed: () => context.push('/dev/components'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
