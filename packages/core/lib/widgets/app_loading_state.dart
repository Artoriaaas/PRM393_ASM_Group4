import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Loading state widget conforming to Figma 24:1723
class AppLoadingState extends StatelessWidget {
  const AppLoadingState({super.key, this.message = 'Đang tải dữ liệu...'});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: message ?? 'Đang tải dữ liệu',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.s16),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
