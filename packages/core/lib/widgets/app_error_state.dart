import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Error state widget conforming to Figma error states (e.g. 179:852, 179:1896)
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Thử lại',
    this.icon = Icons.error_outline,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Lỗi: $title. $message',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.s24),
                AppButton(
                  label: retryLabel,
                  onPressed: onRetry,
                  variant: AppButtonVariant.primary,
                  icon: const Icon(Icons.refresh, size: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
