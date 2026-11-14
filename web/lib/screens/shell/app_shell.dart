import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../app/providers.dart';
import '../../services/web_contracts.dart';
import '../../viewmodels/web_auth_viewmodel.dart';

class AppShell extends ConsumerWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  final Widget child;
  final String currentLocation;

  int _calculateSelectedIndex(String location, bool isAdmin) {
    if (isAdmin) {
      if (location.startsWith('/admin-dashboard') || location == '/dashboard') return 0;
      if (location.startsWith('/users')) return 1;
      if (location.startsWith('/clubs')) return 2;
      if (location.startsWith('/events')) return 3;
      if (location.startsWith('/announcements')) return 4;
      if (location.startsWith('/crash-reports')) return 5;
      return 0;
    }
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/events')) return 1;
    if (location.startsWith('/reviews')) return 2;
    if (location.startsWith('/announcements')) return 3;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index, bool isAdmin) {
    if (isAdmin) {
      switch (index) {
        case 0:
          context.go('/admin-dashboard');
          break;
        case 1:
          context.go('/users');
          break;
        case 2:
          context.go('/clubs');
          break;
        case 3:
          context.go('/events');
          break;
        case 4:
          context.go('/announcements');
          break;
        case 5:
          context.go('/crash-reports');
          break;
      }
      return;
    }

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
    final user = ref.watch(currentStaffProfileProvider);
    final isAdmin = user?.isAdmin ?? false;
    final clubId = ref.watch(currentClubIdProvider);
    final pendingCount = ref.watch(pendingRegistrationsBadgeCountProvider(clubId));
    final activeClubAsync = ref.watch(activeClubProvider(clubId));

    final selectedIndex = _calculateSelectedIndex(currentLocation, isAdmin);
    final clubDisplayName = isAdmin
        ? 'Quản trị Toàn trường'
        : (activeClubAsync.asData?.value?.name ?? user?.clubName ?? 'Câu lạc bộ');

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return Scaffold(
            backgroundColor: AppColors.surfaceSubtle,
            body: Row(
              children: [
                _buildDesktopSidebar(
                  context,
                  ref,
                  user,
                  clubDisplayName,
                  selectedIndex,
                  pendingCount,
                  isAdmin,
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
          return Scaffold(
            backgroundColor: AppColors.surfaceSubtle,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (idx) =>
                      _onDestinationSelected(context, idx, isAdmin),
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: AppColors.surface,
                  selectedIconTheme:
                      const IconThemeData(color: AppColors.primary),
                  selectedLabelTextStyle:
                      AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                  unselectedLabelTextStyle:
                      AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  leading: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.s16),
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
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.s16),
                        child: Semantics(
                          button: true,
                          label: 'Đăng xuất tài khoản',
                          child: ConstrainedBox(
                            constraints: AppTouchTargets.minConstraints,
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
                    ),
                  ),
                  destinations: isAdmin
                      ? [
                          const NavigationRailDestination(
                            icon: Icon(Icons.dashboard_outlined),
                            selectedIcon: Icon(Icons.dashboard),
                            label: Text('Tổng quan'),
                          ),
                          const NavigationRailDestination(
                            icon: Icon(Icons.people_outlined),
                            selectedIcon: Icon(Icons.people),
                            label: Text('Người dùng'),
                          ),
                          const NavigationRailDestination(
                            icon: Icon(Icons.groups_outlined),
                            selectedIcon: Icon(Icons.groups),
                            label: Text('CLB'),
                          ),
                          const NavigationRailDestination(
                            icon: Icon(Icons.event_outlined),
                            selectedIcon: Icon(Icons.event),
                            label: Text('Duyệt sự kiện'),
                          ),
                          const NavigationRailDestination(
                            icon: Icon(Icons.campaign_outlined),
                            selectedIcon: Icon(Icons.campaign),
                            label: Text('Thông báo'),
                          ),
                          const NavigationRailDestination(
                            icon: Icon(Icons.bug_report_outlined),
                            selectedIcon: Icon(Icons.bug_report),
                            label: Text('Báo cáo lỗi'),
                          ),
                        ]
                      : [
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
                          const NavigationRailDestination(
                            icon: Icon(Icons.bug_report_outlined),
                            selectedIcon: Icon(Icons.bug_report),
                            label: Text('Báo cáo lỗi'),
                          ),
                        ],
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                Expanded(child: child),
              ],
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: AppColors.surfaceSubtle,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              title: Text(
                _getTitleForIndex(selectedIndex, isAdmin),
                style: AppTypography.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                Semantics(
                  button: true,
                  label: 'Đăng xuất tài khoản',
                  child: ConstrainedBox(
                    constraints: AppTouchTargets.minConstraints,
                    child: IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Đăng xuất',
                      onPressed: () => ref
                          .read(webAuthViewModelProvider.notifier)
                          .signOut(),
                    ),
                  ),
                ),
              ],
            ),
            drawer: Drawer(
              backgroundColor: AppColors.surface,
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
                          isAdmin ? 'EventHub Quản trị' : 'EventHub Trưởng CLB',
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
                        if (!isAdmin && clubDisplayName.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.s4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.s8,
                              vertical: AppSpacing.s4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.onPrimary.withValues(alpha: 0.15),
                              borderRadius: AppRadius.borderR6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.groups_outlined,
                                  size: 14,
                                  color: AppColors.onPrimary,
                                ),
                                const SizedBox(width: AppSpacing.s4),
                                Flexible(
                                  child: Text(
                                    clubDisplayName,
                                    style: AppTypography.textTheme.labelSmall?.copyWith(
                                      color: AppColors.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isAdmin) ...[
                    ListTile(
                      leading: const Icon(Icons.dashboard_outlined),
                      title: const Text('Bảng điều khiển'),
                      selected: selectedIndex == 0,
                      onTap: () {
                        Navigator.pop(context);
                        _onDestinationSelected(context, 0, isAdmin);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.people_outlined),
                      title: const Text('Quản lý người dùng'),
                      selected: selectedIndex == 1,
                      onTap: () {
                        Navigator.pop(context);
                        _onDestinationSelected(context, 1, isAdmin);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.groups_outlined),
                      title: const Text('Danh mục CLB'),
                      selected: selectedIndex == 2,
                      onTap: () {
                        Navigator.pop(context);
                        _onDestinationSelected(context, 2, isAdmin);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.event_outlined),
                      title: const Text('Giám sát & Duyệt sự kiện'),
                      selected: selectedIndex == 3,
                      onTap: () {
                        Navigator.pop(context);
                        _onDestinationSelected(context, 3, isAdmin);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.campaign_outlined),
                      title: const Text('Thông báo hệ thống'),
                      selected: selectedIndex == 4,
                      onTap: () {
                        Navigator.pop(context);
                        _onDestinationSelected(context, 4, isAdmin);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bug_report_outlined),
                      title: const Text('Báo cáo lỗi (Crashlytics)'),
                      selected: selectedIndex == 5,
                      onTap: () {
                        Navigator.pop(context);
                        _onDestinationSelected(context, 5, isAdmin);
                      },
                    ),
                  ] else ...[
                    ListTile(
                      leading: const Icon(Icons.dashboard_outlined),
                      title: const Text('Bảng điều khiển'),
                      selected: selectedIndex == 0,
                      onTap: () {
                        Navigator.pop(context);
                        _onDestinationSelected(context, 0, isAdmin);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.event_outlined),
                      title: const Text('Quản lý sự kiện'),
                      selected: selectedIndex == 1,
                      onTap: () {
                        Navigator.pop(context);
                        _onDestinationSelected(context, 1, isAdmin);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.how_to_reg_outlined),
                      title: const Text('Duyệt đăng ký'),
                      trailing: pendingCount > 0
                          ? _buildPendingCountBadge(pendingCount)
                          : null,
                      selected: selectedIndex == 2,
                      onTap: () {
                        Navigator.pop(context);
                        _onDestinationSelected(context, 2, isAdmin);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.campaign_outlined),
                      title: const Text('Thông báo CLB'),
                      selected: selectedIndex == 3,
                      onTap: () {
                        Navigator.pop(context);
                        _onDestinationSelected(context, 3, isAdmin);
                      },
                    ),
                  ],
                ],
              ),
            ),
            body: child,
          );
        }
      },
    );
  }

  String _getTitleForIndex(int index, bool isAdmin) {
    if (isAdmin) {
      if (currentLocation.startsWith('/crash-reports')) {
        return 'Báo cáo lỗi ứng dụng (Crashlytics)';
      }
      return switch (index) {
        0 => 'Bảng điều khiển Hệ thống',
        1 => 'Quản lý Người dùng & Phân quyền',
        2 => 'Danh mục Câu lạc bộ',
        3 => 'Giám sát Sự kiện Toàn trường',
        4 => 'Duyệt Đăng ký Toàn trường',
        5 => 'Thông báo Hệ thống',
        _ => 'EventHub Admin',
      };
    }
    return switch (index) {
      0 => 'Bảng điều khiển',
      1 => 'Quản lý sự kiện',
      2 => 'Duyệt đăng ký',
      3 => 'Thông báo CLB',
      _ => 'EventHub',
    };
  }

  Widget _buildDesktopSidebar(
    BuildContext context,
    WidgetRef ref,
    WebUserProfile? user,
    String clubName,
    int selectedIndex,
    int pendingCount,
    bool isAdmin,
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
                        isAdmin ? 'Cổng Quản trị viên' : 'Cổng Trưởng CLB',
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
                    color: isAdmin
                        ? AppColors.warningContainer
                        : AppColors.primaryContainer,
                    borderRadius: AppRadius.borderR8,
                  ),
                  child: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.groups_outlined,
                    color: isAdmin
                        ? AppColors.onWarningContainer
                        : AppColors.onPrimaryContainer,
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
                      const SizedBox(height: AppSpacing.s4),
                      AppStatusBadge(
                        label: isAdmin ? 'Quản trị viên' : 'Trưởng CLB',
                        variant: isAdmin
                            ? AppBadgeVariant.warning
                            : AppBadgeVariant.info,
                        icon: const Icon(Icons.verified_user_outlined),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              children: isAdmin
                  ? [
                      _buildNavItem(
                        icon: Icons.dashboard_outlined,
                        selectedIcon: Icons.dashboard,
                        label: 'Bảng điều khiển',
                        semanticsLabel: 'Mở Bảng điều khiển Hệ thống',
                        isSelected: selectedIndex == 0,
                        onTap: () => _onDestinationSelected(context, 0, isAdmin),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      _buildNavItem(
                        icon: Icons.people_outlined,
                        selectedIcon: Icons.people,
                        label: 'Người dùng',
                        semanticsLabel: 'Mở màn hình Quản lý người dùng',
                        isSelected: selectedIndex == 1,
                        onTap: () => _onDestinationSelected(context, 1, isAdmin),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      _buildNavItem(
                        icon: Icons.groups_outlined,
                        selectedIcon: Icons.groups,
                        label: 'Câu lạc bộ',
                        semanticsLabel: 'Mở màn hình Danh mục Câu lạc bộ',
                        isSelected: selectedIndex == 2,
                        onTap: () => _onDestinationSelected(context, 2, isAdmin),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      _buildNavItem(
                        icon: Icons.event_outlined,
                        selectedIcon: Icons.event,
                        label: 'Giám sát & Duyệt sự kiện',
                        semanticsLabel: 'Mở màn hình Giám sát và Phê duyệt sự kiện CLB',
                        isSelected: selectedIndex == 3,
                        onTap: () => _onDestinationSelected(context, 3, isAdmin),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      _buildNavItem(
                        icon: Icons.campaign_outlined,
                        selectedIcon: Icons.campaign,
                        label: 'Thông báo hệ thống',
                        semanticsLabel: 'Mở màn hình Thông báo hệ thống',
                        isSelected: selectedIndex == 4,
                        onTap: () => _onDestinationSelected(context, 4, isAdmin),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      _buildNavItem(
                        icon: Icons.bug_report_outlined,
                        selectedIcon: Icons.bug_report,
                        label: 'Báo cáo lỗi ứng dụng',
                        semanticsLabel: 'Mở màn hình Báo cáo lỗi Crashlytics',
                        isSelected: selectedIndex == 5,
                        onTap: () => _onDestinationSelected(context, 5, isAdmin),
                      ),
                    ]
                  : [
                      _buildNavItem(
                        icon: Icons.dashboard_outlined,
                        selectedIcon: Icons.dashboard,
                        label: 'Bảng điều khiển',
                        semanticsLabel: 'Mở màn hình Bảng điều khiển CLB',
                        isSelected: selectedIndex == 0,
                        onTap: () => _onDestinationSelected(context, 0, isAdmin),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      _buildNavItem(
                        icon: Icons.event_outlined,
                        selectedIcon: Icons.event,
                        label: 'Quản lý sự kiện',
                        semanticsLabel: 'Mở màn hình Quản lý sự kiện CLB',
                        isSelected: selectedIndex == 1,
                        onTap: () => _onDestinationSelected(context, 1, isAdmin),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      _buildNavItem(
                        icon: Icons.how_to_reg_outlined,
                        selectedIcon: Icons.how_to_reg,
                        label: 'Duyệt đăng ký',
                        semanticsLabel: pendingCount > 0
                            ? 'Mở màn hình Duyệt đăng ký, có $pendingCount đơn chờ duyệt'
                            : 'Mở màn hình Duyệt đăng ký',
                        badgeCount: pendingCount,
                        isSelected: selectedIndex == 2,
                        onTap: () => _onDestinationSelected(context, 2, isAdmin),
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      _buildNavItem(
                        icon: Icons.campaign_outlined,
                        selectedIcon: Icons.campaign,
                        label: 'Thông báo CLB',
                        semanticsLabel: 'Mở màn hình Thông báo CLB',
                        isSelected: selectedIndex == 3,
                        onTap: () => _onDestinationSelected(context, 3, isAdmin),
                      ),
                    ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isAdmin
                      ? AppColors.warningContainer
                      : AppColors.primaryContainer,
                  child: Text(
                    (user?.displayName.isNotEmpty == true)
                        ? user!.displayName[0].toUpperCase()
                        : 'U',
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: isAdmin ? AppColors.onWarningContainer : AppColors.primary,
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
                Semantics(
                  button: true,
                  label: 'Đăng xuất tài khoản',
                  child: ConstrainedBox(
                    constraints: AppTouchTargets.minConstraints,
                    child: IconButton(
                      icon: const Icon(
                        Icons.logout_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      tooltip: 'Đăng xuất',
                      onPressed: () =>
                          ref.read(webAuthViewModelProvider.notifier).signOut(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.borderFull,
      ),
      child: Text(
        '$count',
        style: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required String semanticsLabel,
    required bool isSelected,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final bgColor = isSelected ? AppColors.brandSubtle : Colors.transparent;
    final fgColor = isSelected ? AppColors.primary : AppColors.textPrimary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderR8,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppTouchTargets.min),
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
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  if (badgeCount > 0) _buildPendingCountBadge(badgeCount),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
