import '../app/development.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/app_button.dart';
import '../widgets/app_status_badge.dart';
import '../widgets/app_top_bar.dart';

/// Standard placeholder screen for routes specified in design-traceability.md
/// Explicitly marks that business logic/screens are not yet implemented.
/// Does NOT contain fake logins or fake registration results.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.screenCode,
    required this.title,
    required this.routePath,
    this.figmaNode,
    this.expectedViewModel,
    this.expectedService,
    this.showBackButton = true,
  });

  final String screenCode;
  final String title;
  final String routePath;
  final String? figmaNode;
  final String? expectedViewModel;
  final String? expectedService;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      appBar: AppTopBar(
        title: '$screenCode — $title',
        showBackButton: showBackButton && context.canPop(),
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: AppColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.borderR12,
                  side: BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: AppStatusBadge(
                              label: 'DEVELOPMENT PLACEHOLDER',
                              variant: AppBadgeVariant.warning,
                              icon: Icon(Icons.build_circle_outlined),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            screenCode,
                            style: AppTypography.textTheme.labelMedium
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        title,
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Text(
                        'Màn hình chưa triển khai nghiệp vụ (Placeholder trong development theo phạm vi Bước 3).',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Divider(height: AppSpacing.s32),
                      _buildInfoRow('Route path', routePath),
                      if (figmaNode != null)
                        _buildInfoRow('Figma node', figmaNode!),
                      if (expectedViewModel != null)
                        _buildInfoRow('ViewModel dự kiến', expectedViewModel!),
                      if (expectedService != null)
                        _buildInfoRow('Service phụ thuộc', expectedService!),
                      _buildInfoRow(
                        'Trạng thái',
                        'Đã ánh xạ route / Chờ triển khai ở các bước sau',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              if (developmentUiEnabled)
                AppButton(
                  label: 'Mở màn xem thử Component (360 / 412 dp)',
                  icon: const Icon(Icons.palette_outlined, size: 20),
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.push('/dev/components'),
                ),
              if (showBackButton && context.canPop()) ...[
                const SizedBox(height: AppSpacing.s12),
                AppButton(
                  label: 'Quay lại màn trước',
                  variant: AppButtonVariant.text,
                  onPressed: () => context.pop(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTypography.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
