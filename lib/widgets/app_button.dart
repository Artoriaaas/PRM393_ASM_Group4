import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_touch_targets.dart';

enum AppButtonVariant { primary, secondary, text }

/// Reusable AppButton conforming to Lab 2 / architecture.md specs:
/// - Minimum touch target >= 48 dp
/// - Primary, secondary (outlined), and text variants
/// - Loading, disabled, and normal states
/// - Semantics support and long text handling
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isFullWidth = false,
    this.semanticsLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final bool isFullWidth;
  final String? semanticsLabel;

  bool get _enabled => !isDisabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    Widget childContent;
    if (isLoading) {
      final spinnerColor = switch (variant) {
        AppButtonVariant.primary => AppColors.onPrimary,
        AppButtonVariant.secondary ||
        AppButtonVariant.text => AppColors.primary,
      };
      childContent = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        ),
      );
    } else {
      final labelWidget = Text(label, textAlign: TextAlign.center);

      if (icon != null) {
        childContent = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon!,
            const SizedBox(width: AppSpacing.s8),
            Flexible(child: labelWidget),
          ],
        );
      } else {
        childContent = labelWidget;
      }
    }

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: _enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            minimumSize: Size(
              isFullWidth ? double.infinity : AppTouchTargets.min,
              AppTouchTargets.min,
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.textDisabled,
            elevation: 0,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderR8,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
              vertical: AppSpacing.s12,
            ),
          ),
          child: childContent,
        );
      case AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: _enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            minimumSize: Size(
              isFullWidth ? double.infinity : AppTouchTargets.min,
              AppTouchTargets.min,
            ),
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textDisabled,
            side: BorderSide(
              color: _enabled ? AppColors.primary : AppColors.border,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderR8,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
              vertical: AppSpacing.s12,
            ),
          ),
          child: childContent,
        );
      case AppButtonVariant.text:
        button = TextButton(
          onPressed: _enabled ? onPressed : null,
          style: TextButton.styleFrom(
            minimumSize: Size(
              isFullWidth ? double.infinity : AppTouchTargets.min,
              AppTouchTargets.min,
            ),
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textDisabled,
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.borderR8,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s8,
            ),
          ),
          child: childContent,
        );
    }

    return Semantics(
      button: true,
      enabled: _enabled,
      label: semanticsLabel ?? label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppTouchTargets.min),
        child: button,
      ),
    );
  }
}
