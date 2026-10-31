import '../../app/development.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_search_field.dart';
import '../../widgets/app_status_badge.dart';
import '../../widgets/app_top_bar.dart';

/// A02 Discover Tab Screen (Placeholder in Step 3)
class DiscoverTabScreen extends StatelessWidget {
  const DiscoverTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      appBar: AppTopBar(
        title: 'EventHub — Khám phá',
        subtitle: 'Sự kiện sinh viên FPTU',
        actions: [
          if (developmentUiEnabled)
            IconButton(
              icon: const Icon(
                Icons.palette_outlined,
                color: AppColors.primary,
              ),
              tooltip: 'Xem thử Component UI',
              onPressed: () => context.push('/dev/components'),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          children: [
            AppSearchField(
              hintText: 'Tìm kiếm sự kiện, câu lạc bộ...',
              onSubmitted: (query) => context.push('/discover/search'),
            ),
            const SizedBox(height: AppSpacing.s16),
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
                            label: 'A02 — KHÁM PHÁ (BƯỚC 3 NỀN TẢNG)',
                            variant: AppBadgeVariant.info,
                            icon: Icon(Icons.info_outline),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      'Khung điều hướng F1 — Khám phá & Đăng ký',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'Đây là màn hình placeholder trong giai đoạn dựng nền tảng (Bước 3). Nghiệp vụ khám phá, danh sách sự kiện và đăng ký thật sẽ được triển khai tại Bước 5 sau khi cấu hình Firebase.',
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    AppButton(
                      label: 'Xem luồng tìm kiếm (A03)',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.push('/discover/search'),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    AppButton(
                      label: 'Xem chi tiết sự kiện mẫu (A04)',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.push('/events/event-sample-1'),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    if (developmentUiEnabled)
                      AppButton(
                        label: 'Mở trang xem thử Component UI (360/412dp)',
                        icon: const Icon(Icons.view_quilt_outlined, size: 20),
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
