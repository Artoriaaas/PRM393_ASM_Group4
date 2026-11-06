import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_touch_targets.dart';
import '../theme/app_typography.dart';

/// Standard Top App Bar conforming to Figma 24:945
/// - Left-aligned title
/// - Back navigation with min 48dp touch target
/// - Actions list and Semantics
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.actions,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    Widget? leadingWidget;
    if (showBackButton) {
      leadingWidget = Semantics(
        button: true,
        label: 'Quay lại',
        child: InkWell(
          onTap: () {
            if (onBack != null) {
              onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
          borderRadius: BorderRadius.circular(24),
          child: ConstrainedBox(
            constraints: AppTouchTargets.minConstraints,
            child: const Icon(
              Icons.arrow_back,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: leadingWidget,
      titleSpacing: showBackButton ? 0 : AppSpacing.screenMargin,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
      actions: actions != null
          ? [...actions!, const SizedBox(width: AppSpacing.s8)]
          : null,
      bottom: bottom,
    );
  }
}
