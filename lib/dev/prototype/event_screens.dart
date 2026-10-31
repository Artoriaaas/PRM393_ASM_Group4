import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'prototype_state.dart';
import 'prototype_widgets.dart';

class DemoDiscoverScreen extends ConsumerStatefulWidget {
  const DemoDiscoverScreen({
    super.key,
    this.search = false,
    this.initialQuery = '',
  });
  final bool search;
  final String initialQuery;
  @override
  ConsumerState<DemoDiscoverScreen> createState() => _DemoDiscoverScreenState();
}

class _DemoDiscoverScreenState extends ConsumerState<DemoDiscoverScreen> {
  String query = '', topic = 'Tất cả', club = 'Tất cả CLB';
  late final TextEditingController searchController;
  @override
  void initState() {
    super.initState();
    query = widget.initialQuery;
    searchController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> filters() async {
    var draft = topic;
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: StatefulBuilder(
          builder: (context, setDraft) => Padding(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Lọc sự kiện',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.s16),
                Wrap(
                  spacing: AppSpacing.s8,
                  children: [
                    for (final t in ['Tất cả', 'Thiết kế', 'Âm nhạc'])
                      ChoiceChip(
                        label: Text(t),
                        selected: draft == t,
                        onSelected: (_) => setDraft(() => draft = t),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),
                AppButton(
                  label: 'Áp dụng',
                  onPressed: () => Navigator.pop(context, draft),
                ),
                AppButton(
                  label: 'Xóa bộ lọc',
                  variant: AppButtonVariant.text,
                  onPressed: () => Navigator.pop(context, 'Tất cả'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (result != null && mounted) setState(() => topic = result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prototypeProvider);
    final events = [demoWorkshop, demoAcoustic]
        .where(
          (e) =>
              (topic == 'Tất cả' ||
                  (topic == 'Thiết kế' && !e.free) ||
                  (topic == 'Âm nhạc' && e.free)) &&
              (club == 'Tất cả CLB' || e.club == club) &&
              ('${e.title} ${e.club}'.toLowerCase().contains(
                query.toLowerCase(),
              )),
        )
        .toList();
    final empty = state.scenario == DemoScenario.empty || events.isEmpty;
    return DemoPage(
      title: widget.search ? 'Kết quả tìm kiếm' : 'Khám phá',
      tab: 0,
      background: AppColors.surfaceSubtle,
      children: [
        if (!widget.search) ...[
          Text(
            'Sắp tới tại TP.HCM',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Text('Tìm một hoạt động hợp với bạn'),
        ],
        AppSearchField(
          leadingIcon: const SizedBox(
            width: 48,
            height: 48,
            child: Center(child: DemoIcon('event_search', size: 20)),
          ),
          controller: searchController,
          hintText: 'Tìm sự kiện, CLB...',
          onChanged: (value) => setState(() => query = value),
          onSubmitted: (_) {
            if (!widget.search) {
              demoOpen(
                context,
                ref,
                Uri(
                  path: '/discover/search',
                  queryParameters: {'q': query},
                ).toString(),
              );
            }
          },
        ),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            ActionChip(
              label: const Text('Ngày'),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Mốc thời gian prototype'),
                  content: const Text(
                    'Các màn minh họa dùng mốc 24/10/2026 của Figma, không lấy ngày hiện tại để đổi trạng thái.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
            ),
            FilterChip(
              label: Text(topic == 'Tất cả' ? 'Chủ đề' : topic),
              selected: topic != 'Tất cả',
              onSelected: (_) => filters(),
            ),
            ActionChip(
              label: Text(club),
              onPressed: () => setState(
                () => club = club == 'Tất cả CLB'
                    ? 'CLB Thiết kế FPTU'
                    : 'Tất cả CLB',
              ),
            ),
          ],
        ),
        if (widget.search)
          AppButton(
            label: 'Lọc sự kiện',
            variant: AppButtonVariant.secondary,
            onPressed: filters,
          )
        else
          Row(
            children: [
              Expanded(
                child: Text(
                  'Dành cho bạn',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed: () => demoOpen(context, ref, '/discover/search'),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
        if (empty) ...[
          const DemoStatus(
            'Không tìm thấy sự kiện',
            subtitle: 'Thử đổi từ khóa hoặc xóa bộ lọc.',
          ),
          AppButton(
            label: 'Xóa tất cả bộ lọc',
            onPressed: () {
              setState(() {
                query = '';
                searchController.clear();
                topic = 'Tất cả';
                club = 'Tất cả CLB';
              });
              ref
                  .read(prototypeProvider.notifier)
                  .scenario(DemoScenario.normal);
            },
          ),
        ] else ...[
          if (widget.search) Text('${events.length} sự kiện phù hợp'),
          for (final event in events)
            DemoEventCard(
              event,
              remaining: state.registered && !state.cancelled ? 23 : 24,
              onTap: () => demoOpen(context, ref, '/events/${event.id}'),
            ),
        ],
      ],
    );
  }
}

class DemoEventDetailScreen extends ConsumerWidget {
  const DemoEventDetailScreen({super.key, required this.eventId});
  final String eventId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = eventId == 'acoustic' ? demoAcoustic : demoWorkshop;
    final s = ref.watch(prototypeProvider);
    final active = s.registered && !s.cancelled;
    final blocked = [
      DemoScenario.full,
      DemoScenario.expired,
      DemoScenario.cancelled,
    ].contains(s.scenario);
    return DemoPage(
      title: 'Chi tiết sự kiện',
      action: event.free
          ? null
          : AppButton(
              label: active
                  ? 'Xem đăng ký'
                  : blocked
                  ? 'Chọn sự kiện khác'
                  : 'Đăng ký sự kiện',
              isFullWidth: true,
              onPressed: () => demoOpen(
                context,
                ref,
                active
                    ? '/registrations/demo'
                    : blocked
                    ? '/discover/search'
                    : '/events/workshop/register',
              ),
            ),
      children: [
        DemoCover(free: event.free),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: AppSpacing.s16,
          runSpacing: AppSpacing.s8,
          children: [
            AppStatusBadge(
              label: event.free ? 'Tham gia tự do' : 'Cần đăng ký',
              variant: AppBadgeVariant.warning,
            ),
            if (!event.free)
              AppStatusBadge(
                label: active
                    ? 'Đã đăng ký'
                    : blocked
                    ? s.scenario.label
                    : 'Còn 24 chỗ',
                variant: AppBadgeVariant.success,
              ),
          ],
        ),
        Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
        Text(
          event.club,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: AppColors.primary),
        ),
        if (blocked && !event.free)
          DemoMessage(
            '${s.scenario.label}. Không nhận đăng ký mới.',
            error: true,
          ),
        DemoPanel(
          children: [
            Text(
              'Thời gian diễn ra',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: AppColors.primary),
            ),
            DemoMetadata('event_calendar', event.time),
            Text(
              'Địa điểm',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: AppColors.primary),
            ),
            DemoMetadata('event_pin', event.place),
            if (!event.free) ...[
              Text(
                'Hạn đăng ký',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: AppColors.primary),
              ),
              const DemoMetadata('event_clock', '18:00 · 23/10/2026'),
            ],
          ],
        ),
        if (event.free)
          const DemoMessage(
            'Không cần đăng ký. Đến trực tiếp theo thời gian và địa điểm trên.',
          ),
        Text('Giới thiệu', style: Theme.of(context).textTheme.titleMedium),
        Text(
          event.free ? 'Giao lưu âm nhạc và kết nối bạn bè trong campus.' : 'Thực hành nghiên cứu nhu cầu, dựng prototype và kiểm thử nhanh cùng người dùng.',
        ),
        Text('Bạn sẽ làm gì?', style: Theme.of(context).textTheme.titleMedium),
        Text(
          event.free
              ? '• Thưởng thức biểu diễn acoustic\n• Giao lưu cùng CLB âm nhạc'
              : '• Phỏng vấn và tổng hợp insight\n• Phác thảo luồng và prototype\n• Kiểm thử nhanh theo nhóm',
        ),
        DemoPanel(
          color: AppColors.brandSubtle,
          children: [
            Text('Phù hợp với', style: Theme.of(context).textTheme.labelLarge),
            Text(
              event.free
                  ? 'Sinh viên và khách quan tâm âm nhạc. Không cần chuẩn bị.'
                  : 'Người quan tâm thiết kế · Mang laptop để thực hành.',
            ),
          ],
        ),
      ],
    );
  }
}
