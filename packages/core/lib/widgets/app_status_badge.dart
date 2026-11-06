import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppBadgeVariant { success, warning, error, info, neutral }

/// Status badge adhering to Figma 24:886
/// - Text + optional icon + semantic colors
/// - High contrast and semantic container tints
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
    this.semanticsLabel,
  });

  final String label;
  final AppBadgeVariant variant;
  final Widget? icon;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final semantic =
        Theme.of(context).extension<EventHubSemanticColors>() ??
        EventHubSemanticColors.light;

    final (Color bg, Color fg) = switch (variant) {
      AppBadgeVariant.success => (
        semantic.successContainer,
        semantic.onSuccessContainer,
      ),
      AppBadgeVariant.warning => (
        semantic.warningContainer,
        semantic.onWarningContainer,
      ),
      AppBadgeVariant.error => (
        AppColors.errorContainer,
        AppColors.onErrorContainer,
      ),
      AppBadgeVariant.info => (
        semantic.infoContainer,
        semantic.onInfoContainer,
      ),
      AppBadgeVariant.neutral => (AppColors.border, AppColors.textSecondary),
    };

    return Semantics(
      label: semanticsLabel ?? 'Trạng thái: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s8,
          vertical: AppSpacing.s4,
        ),
        decoration: BoxDecoration(color: bg, borderRadius: AppRadius.borderR6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme(
                data: IconThemeData(color: fg, size: 14),
                child: icon!,
              ),
              const SizedBox(width: AppSpacing.s4),
            ],
            Flexible(
              child: Text(
                label,
                style: AppTypography.textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
