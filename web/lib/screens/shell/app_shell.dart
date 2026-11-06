import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../app/providers.dart';
import '../../viewmodels/web_auth_viewmodel.dart';
import '../../services/web_contracts.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  final Widget child;
  final String currentLocation;

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/events')) return 1;
    if (location.startsWith('/reviews')) return 2;
    if (location.startsWith('/announcements')) return 3;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/events');
        break;
      case 2:
        context.go('/reviews');
        break;
      case 3:
        context.go('/announcements');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
    final clubId = user?.clubId ?? '';

    final pendingCount = ref.watch(pendingRegistrationsBadgeCountProvider(clubId));
    final activeClubAsync = ref.watch(activeClubProvider(clubId));

    final selectedIndex = _calculateSelectedIndex(currentLocation);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          // Desktop Layout (>= 1024 dp)
          return Scaffold(
            backgroundColor: AppColors.surfaceSubtle,
            body: Row(
              children: [
                _buildDesktopSidebar(
                  context,
                  ref,
                  user,
                  activeClubAsync.value?.name ?? user?.clubName ?? 'Câu lạc bộ',
                  selectedIndex,
                  pendingCount,
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (constraints.maxWidth >= 600) {
          // Tablet Layout (600..1023 dp)
          return Scaffold(
            backgroundColor: AppColors.surfaceSubtle,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (idx) =>
                      _onDestinationSelected(context, idx),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: AppColors.surface,
                  selectedIconTheme:
                      const IconThemeData(color: AppColors.primary),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      decoration: const BoxDecoration(
                        color: AppColors.brandSubtle,
                        borderRadius: AppRadius.borderR8,
                      ),
                      child: const Icon(
                        Icons.hub_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
                        child: IconButton(
                          icon: const Icon(Icons.logout, size: 20),
                          tooltip: 'Đăng xuất',
                          onPressed: () => ref
                              .read(webAuthViewModelProvider.notifier)
                              .signOut(),
                        ),
                      ),
                    ),
                  ),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Tổng quan'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.event_outlined),
                      selectedIcon: Icon(Icons.event),
                      label: Text('Sự kiện'),
                    ),
                    NavigationRailDestination(
                      icon: pendingCount > 0
                          ? Badge.count(
                              count: pendingCount,
                              child: const Icon(Icons.how_to_reg_outlined),
                            )
                          : const Icon(Icons.how_to_reg_outlined),
                      selectedIcon: const Icon(Icons.how_to_reg),
                      label: const Text('Duyệt đơn'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.campaign_outlined),
                      selectedIcon: Icon(Icons.campaign),
                      label: Text('Thông báo'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(child: child),
              ],
            ),
          );
        } else {
          // Mobile Layout (< 600 dp)
          return Scaffold(
            backgroundColor: AppColors.surfaceSubtle,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              title: Text(
                _getTitleForIndex(selectedIndex),
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Đăng xuất',
                  onPressed: () =>
                      ref.read(webAuthViewModelProvider.notifier).signOut(),
                ),
              ],
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: AppColors.primary),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'EventHub Admin',
                          style: AppTypography.textTheme.titleLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          user?.displayName ?? '',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPrimary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard_outlined),
                    title: const Text('Bảng điều khiển'),
                    selected: selectedIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      _onDestinationSelected(context, 0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.event_outlined),
                    title: const Text('Quản lý sự kiện'),
                    selected: selectedIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      _onDestinationSelected(context, 1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.how_to_reg_outlined),
                    title: const Text('Duyệt đăng ký'),
                    trailing: pendingCount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$pendingCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                    selected: selectedIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      _onDestinationSelected(context, 2);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.campaign_outlined),
                    title: const Text('Thông báo CLB'),
                    selected: selectedIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      _onDestinationSelected(context, 3);
                    },
                  ),
                ],
              ),
            ),
            body: child,
          );
        }
      },
    );
  }

  String _getTitleForIndex(int index) => switch (index) {
        0 => 'Bảng điều khiển',
        1 => 'Quản lý sự kiện',
        2 => 'Duyệt đăng ký',
        3 => 'Thông báo CLB',
        _ => 'EventHub',
      };

  Widget _buildDesktopSidebar(
    BuildContext context,
    WidgetRef ref,
    WebUserProfile? user,
    String clubName,
    int selectedIndex,
    int pendingCount,
  ) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo & Title
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: const BoxDecoration(
                    color: AppColors.brandSubtle,
                    borderRadius: AppRadius.borderR8,
                  ),
                  child: const Icon(
                    Icons.hub_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EventHub',
                        style: AppTypography.textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Cổng Trưởng CLB',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Club Identification Card
          Container(
            margin: const EdgeInsets.all(AppSpacing.s16),
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: AppRadius.borderR8,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: AppRadius.borderR8,
                  ),
                  child: const Icon(
                    Icons.groups_outlined,
                    color: AppColors.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clubName,
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      AppStatusBadge(
                        label: user?.role == 'admin' ? 'Quản trị viên' : 'Trưởng CLB',
                        variant: AppBadgeVariant.info,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Bảng điều khiển',
                  isSelected: selectedIndex == 0,
                  onTap: () => _onDestinationSelected(context, 0),
                ),
                const SizedBox(height: AppSpacing.s4),
                _buildNavItem(
                  icon: Icons.event_outlined,
                  selectedIcon: Icons.event,
                  label: 'Quản lý sự kiện',
                  isSelected: selectedIndex == 1,
                  onTap: () => _onDestinationSelected(context, 1),
                ),
                const SizedBox(height: AppSpacing.s4),
                _buildNavItem(
                  icon: Icons.how_to_reg_outlined,
                  selectedIcon: Icons.how_to_reg,
                  label: 'Duyệt đăng ký',
                  badgeCount: pendingCount,
                  isSelected: selectedIndex == 2,
                  onTap: () => _onDestinationSelected(context, 2),
                ),
                const SizedBox(height: AppSpacing.s4),
                _buildNavItem(
                  icon: Icons.campaign_outlined,
                  selectedIcon: Icons.campaign,
                  label: 'Thông báo CLB',
                  isSelected: selectedIndex == 3,
                  onTap: () => _onDestinationSelected(context, 3),
                ),
              ],
            ),
          ),

          // User info and Logout Footer
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    (user?.displayName.isNotEmpty == true)
                        ? user!.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Chưa xác định',
                        style: AppTypography.textTheme.labelMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.email ?? '',
                        style: AppTypography.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.logout_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Đăng xuất',
                  onPressed: () =>
                      ref.read(webAuthViewModelProvider.notifier).signOut(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final bgColor =
        isSelected ? AppColors.brandSubtle : Colors.transparent;
    final fgColor = isSelected ? AppColors.primary : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.borderR8,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s12,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.borderR8,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: fgColor,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                label,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: fgColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
