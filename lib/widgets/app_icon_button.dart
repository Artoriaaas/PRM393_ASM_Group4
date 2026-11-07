import '../theme/app_radius.dart';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_touch_targets.dart';

/// AppIconButton with guaranteed 48x48dp touch target and accessibility semantics
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final bool canPress = isEnabled && !isLoading && onPressed != null;

    return Semantics(
      button: true,
      enabled: canPress,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: canPress ? onPressed : null,
          borderRadius: AppRadius.borderR24,
          child: ConstrainedBox(
            constraints: AppTouchTargets.minConstraints,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : IconTheme(
                      data: IconThemeData(
                        color: canPress
                            ? (color ?? AppColors.textPrimary)
                            : AppColors.textDisabled,
                        size: 24,
                      ),
                      child: icon,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
