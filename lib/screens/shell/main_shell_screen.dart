import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_navigation_bar.dart';

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
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
          ),
          AppNavigationItem(
            label: 'Lịch',
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
          ),
          AppNavigationItem(
            label: 'Thông báo',
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
          ),
          AppNavigationItem(
            label: 'Tài khoản',
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
