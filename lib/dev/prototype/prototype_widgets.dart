import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'prototype_state.dart';

void demoOpen(
  BuildContext context,
  WidgetRef ref,
  String path, {
  bool replace = false,
}) {
  if (replace) {
    context.go(path);
  } else {
    context.push(path);
  }
}

class DemoIcon extends StatelessWidget {
  const DemoIcon(this.name, {super.key, this.color, this.size = 24});
  final String name;
  final Color? color;
  final double size;
  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/icons/$name.svg',
    width: size,
    height: size,
    colorFilter: color == null
        ? null
        : ColorFilter.mode(color!, BlendMode.srcIn),
  );
}

class DemoPage extends ConsumerWidget {
  const DemoPage({
    super.key,
    required this.title,
    required this.children,
    this.tab,
    this.action,
    this.background,
    this.allowScenario = true,
  });
  final String title;
  final List<Widget> children;
  final int? tab;
  final Widget? action;
  final Color? background;
  final bool allowScenario;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(prototypeProvider);
    Widget body = ListView(
      key: PageStorageKey(title),
      padding: const EdgeInsets.all(AppSpacing.s16),
      children: [
        for (final child in children)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s16),
            child: child,
          ),
      ],
    );
    if (allowScenario && s.scenario == DemoScenario.loading) {
      body = const AppLoadingState();
    }
    if (allowScenario &&
        s.scenario == DemoScenario.error &&
        !s.busy &&
        s.message == null) {
      body = Center(
        child: AppErrorState(
          title: 'Không thể tải dữ liệu',
          message: 'Không thể tải dữ liệu. Đây là trạng thái lỗi mô phỏng.',
          onRetry: () => ref
              .read(prototypeProvider.notifier)
              .scenario(DemoScenario.normal),
        ),
      );
    }
    return Scaffold(
      backgroundColor: background ?? AppColors.surface,
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Container(
            width: double.infinity,
            color: AppColors.warningContainer,
            padding: const EdgeInsets.all(AppSpacing.s4),
            child: Text(
              'UI PROTOTYPE • DỮ LIỆU MÔ PHỎNG',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: AppColors.warning),
            ),
          ),
        ),
        title: Text(title),
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: tab == null
            ? IconButton(
                tooltip: 'Quay lại',
                icon: const DemoIcon('auth_back'),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/discover');
                  }
                },
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Danh sách màn',
            icon: const Icon(Icons.grid_view_outlined),
            onPressed: () => context.push('/preview'),
          ),
          PopupMenuButton<DemoScenario>(
            tooltip: 'Trạng thái mô phỏng',
            icon: const Icon(Icons.tune),
            onSelected: (value) =>
                ref.read(prototypeProvider.notifier).scenario(value),
            itemBuilder: (_) => [
              for (final scenario in DemoScenario.values)
                PopupMenuItem(value: scenario, child: Text(scenario.label)),
            ],
          ),
        ],
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: tab != null
          ? AppNavigationBar(
              currentIndex: tab!,
              onTap: (i) => demoOpen(
                context,
                ref,
                ['/discover', '/schedule', '/notifications', '/account'][i],
                replace: true,
              ),
              items: [
                for (final item in [
                  ('Khám phá', 'nav_search'),
                  ('Lịch', 'nav_calendar'),
                  ('Thông báo', 'nav_bell'),
                  ('Tài khoản', 'nav_account'),
                ])
                  AppNavigationItem(
                    label: item.$1,
                    icon: DemoIcon(item.$2, color: AppColors.textSecondary),
                    activeIcon: DemoIcon(item.$2, color: AppColors.primary),
                  ),
              ],
            )
          : action == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: action,
              ),
            ),
    );
  }
}

class DemoPanel extends StatelessWidget {
  const DemoPanel({super.key, required this.children, this.color});
  final List<Widget> children;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.s16),
    decoration: BoxDecoration(
      color: color ?? AppColors.surfaceSubtle,
      borderRadius: AppRadius.borderR16,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.s8),
          children[i],
        ],
      ],
    ),
  );
}

class DemoMessage extends StatelessWidget {
  const DemoMessage(
    this.text, {
    super.key,
    this.error = false,
    this.success = false,
  });
  final String text;
  final bool error, success;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.s12),
      decoration: BoxDecoration(
        color: error
            ? AppColors.errorContainer
            : success
            ? AppColors.successContainer
            : AppColors.infoContainer,
        borderRadius: AppRadius.borderR12,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: error
              ? AppColors.error
              : success
              ? AppColors.success
              : AppColors.info,
        ),
      ),
    ),
  );
}

class DemoSummary extends StatelessWidget {
  const DemoSummary({super.key, this.event = demoWorkshop});
  final DemoEvent event;
  @override
  Widget build(BuildContext context) => DemoPanel(
    children: [
      Text(event.title, style: Theme.of(context).textTheme.titleMedium),
      Text(
        event.time,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.textSecondary),
      ),
      Text(
        event.club,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: AppColors.primary),
      ),
      Text(
        event.place,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: AppColors.textSecondary),
      ),
    ],
  );
}

class DemoPerson extends StatelessWidget {
  const DemoPerson(this.person, {super.key, this.showContact = false});
  final DemoParticipant person;
  final bool showContact;
  @override
  Widget build(BuildContext context) => DemoPanel(
    children: [
      Text(
        showContact ? 'Thông tin đăng ký' : 'Người tham gia',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      Text(person.name, style: Theme.of(context).textTheme.titleMedium),
      if (showContact) Text(person.email),
      Text(person.group),
    ],
  );
}

class DemoStatus extends StatelessWidget {
  const DemoStatus(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(AppSpacing.s16),
    child: Column(
      children: [
        const CircleAvatar(
          radius: AppSpacing.s32,
          backgroundColor: AppColors.successContainer,
          child: DemoIcon('status_check'),
        ),
        const SizedBox(height: AppSpacing.s16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.s12),
          Text(subtitle!, textAlign: TextAlign.center),
        ],
      ],
    ),
  );
}

class DemoCover extends StatelessWidget {
  const DemoCover({super.key, this.free = false});
  final bool free;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadius.borderR16,
    child: AspectRatio(
      aspectRatio: 2,
      child: FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: 328,
          height: 164,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFA93612), Color(0xFFF47A3B)],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                const Positioned(
                  left: 198,
                  top: -64,
                  child: SizedBox(
                    width: 190,
                    height: 190,
                    child: DemoIcon('cover_orbit', size: 190),
                  ),
                ),
                const Positioned(
                  left: -34,
                  top: 92,
                  child: SizedBox(
                    width: 112,
                    height: 112,
                    child: DemoIcon('cover_corner', size: 112),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 18,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.borderFull,
                    ),
                    child: Text(
                      free ? 'ÂM NHẠC' : 'UX WORKSHOP',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFA93612),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 60,
                  child: Text(
                    free ? 'ACOUSTIC\nCAMPUS' : 'THIẾT KẾ\nTRẢI NGHIỆM',
                    style: const TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surface,
                    ),
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 126,
                  child: Text(
                    free
                        ? 'Live music  •  Campus'
                        : 'Research  •  Prototype  •  Test',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFFE9DE),
                    ),
                  ),
                ),
                if (!free) ...[
                  Positioned(
                    left: 238,
                    top: 24,
                    child: Container(
                      width: 76,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.borderR12,
                      ),
                    ),
                  ),
                  for (final r in [
                    (43.0, 12.0, Color(0xFFFFD3BE)),
                    (64.0, 34.0, Color(0xFFFFF1EA)),
                    (106.0, 24.0, Color(0xFFFFE3D5)),
                  ])
                    Positioned(
                      left: 250,
                      top: r.$1,
                      child: Container(
                        width: 52,
                        height: r.$2,
                        decoration: BoxDecoration(
                          color: r.$3,
                          borderRadius: AppRadius.borderR6,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class DemoEventCard extends StatelessWidget {
  const DemoEventCard(
    this.event, {
    super.key,
    required this.onTap,
    this.remaining = 24,
  });
  final DemoEvent event;
  final VoidCallback onTap;
  final int remaining;
  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
    child: InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DemoCover(free: event.free),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppStatusBadge(
                  label: event.free ? 'Tham gia tự do' : 'Cần đăng ký',
                  variant: AppBadgeVariant.warning,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s8),
                Text(
                  event.club,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.s8),
                DemoMetadata('event_calendar', event.time),
                const SizedBox(height: AppSpacing.s8),
                DemoMetadata('event_pin', event.place),
                const SizedBox(height: AppSpacing.s12),
                Wrap(
                  spacing: AppSpacing.s16,
                  runSpacing: AppSpacing.s4,
                  children: [
                    Text(
                      event.free ? 'Vào cửa tự do' : 'Còn $remaining chỗ',
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: AppColors.success),
                    ),
                    Text(
                      event.free ? 'Không cần đăng ký' : 'Hạn 18:00 · 23/10',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class DemoMetadata extends StatelessWidget {
  const DemoMetadata(this.icon, this.text, {super.key});
  final String icon, text;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DemoIcon(icon, size: 20, color: AppColors.primary),
      const SizedBox(width: AppSpacing.s8),
      Expanded(child: Text(text)),
    ],
  );
}
