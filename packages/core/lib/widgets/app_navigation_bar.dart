import '../theme/app_radius.dart';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_touch_targets.dart';
import '../theme/app_typography.dart';

class AppNavigationItem {
  const AppNavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount,
  });

  final String label;
  final Widget icon;
  final Widget activeIcon;
  final int? badgeCount;
}

/// Custom Bottom Navigation Bar conforming to Figma 24:954 / 24:955
/// - 4 tabs: Discover, Schedule, Notifications, Account
/// - Min 48dp touch targets per tab
/// - Semantics support
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppNavigationItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: '${item.label}, Tab ${index + 1} / ${items.length}',
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: ConstrainedBox(
                      constraints: AppTouchTargets.minConstraints,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconTheme(
                                data: IconThemeData(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  size: 24,
                                ),
                                child: isSelected ? item.activeIcon : item.icon,
                              ),
                              if (item.badgeCount != null &&
                                  item.badgeCount! > 0)
                                Positioned(
                                  top: -4,
                                  right: -8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s4,
                                      vertical: AppSpacing.badgeVertical,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error,
                                      borderRadius: AppRadius.borderR12,
                                    ),
                                    child: Text(
                                      item.badgeCount! > 99
                                          ? '99+'
                                          : '${item.badgeCount}',
                                      style: const TextStyle(
                                        color: AppColors.onError,
                                        fontSize: AppTypography.badgeFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
