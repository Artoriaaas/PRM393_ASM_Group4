import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_top_bar.dart';

/// A07 Schedule Tab Screen (Placeholder in Step 3)
class ScheduleTabScreen extends StatelessWidget {
  const ScheduleTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      appBar: const AppTopBar(
        title: 'EventHub — Lịch tham gia',
        subtitle: 'Sự kiện đã đăng ký',
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
                          label: 'A07 — LỊCH SỰ KIỆN (BƯỚC 3 NỀN TẢNG)',
                          variant: AppBadgeVariant.info,
                          icon: Icon(Icons.calendar_today_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      'Khung điều hướng F2 — Theo dõi & Hủy đăng ký',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'Đây là màn hình placeholder trong giai đoạn dựng nền tảng (Bước 3). Danh sách lịch thật và thao tác hủy đăng ký sẽ được kết nối với Firestore tại Bước 6.',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    AppButton(
                      label: 'Xem chi tiết đăng ký mẫu (A08)',
                      variant: AppButtonVariant.secondary,
                      onPressed: () =>
                          context.push('/registrations/reg-sample-1'),
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
