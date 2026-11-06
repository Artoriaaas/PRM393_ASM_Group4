import 'package:eventhub_core/eventhub_core.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


/// Main Shell hosting the 4 persistent bottom tabs:
/// Discover, Schedule, Notifications, Account.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          AppNavigationItem(
            label: 'Khám phá',
            icon: EventAssetIcon('nav_search', color: AppColors.textSecondary),
            activeIcon: EventAssetIcon('nav_search', color: AppColors.primary),
          ),
          AppNavigationItem(
            label: 'Lịch',
            icon: EventAssetIcon(
              'nav_calendar',
              color: AppColors.textSecondary,
            ),
            activeIcon: EventAssetIcon(
              'nav_calendar',
              color: AppColors.primary,
            ),
          ),
          AppNavigationItem(
            label: 'Thông báo',
            icon: EventAssetIcon('nav_bell', color: AppColors.textSecondary),
            activeIcon: EventAssetIcon('nav_bell', color: AppColors.primary),
          ),
          AppNavigationItem(
            label: 'Tài khoản',
            icon: EventAssetIcon('nav_account', color: AppColors.textSecondary),
            activeIcon: EventAssetIcon('nav_account', color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
