import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_top_bar.dart';

/// A09 Notifications Tab Screen (Placeholder in Step 3)
class NotificationsTabScreen extends StatelessWidget {
  const NotificationsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      appBar: const AppTopBar(
        title: 'EventHub — Thông báo',
        subtitle: 'Cập nhật lịch & phiên điểm danh',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          children: [
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
                        AppStatusBadge(
                          label: 'A09 — HỘP THƯ THÔNG BÁO (BƯỚC 3 NỀN TẢNG)',
                          variant: AppBadgeVariant.info,
                          icon: Icon(Icons.notifications_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      'Hộp thư Firestore inbox & FCM Push Notification',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'Placeholder trong development. Hộp thư thông báo trong app và tích hợp FCM sẽ được triển khai tại Bước 9.',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s24),
            const AppEmptyState(
              icon: Icons.notifications_none_outlined,
              title: 'Không có thông báo mới',
              message:
                  'Các cập nhật về sự kiện bạn đăng ký sẽ hiển thị tại đây.',
            ),
          ],
        ),
      ),
    );
  }
}
