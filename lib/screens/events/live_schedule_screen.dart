import 'package:eventhub_core/eventhub_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/event_providers.dart';
import '../../viewmodels/event_viewmodels.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../widgets/event_widgets.dart';
import 'booking_widgets.dart';

class LiveScheduleScreen extends ConsumerStatefulWidget {
  const LiveScheduleScreen({super.key});
  @override
  ConsumerState<LiveScheduleScreen> createState() => _LiveScheduleState();
}

class _LiveScheduleState extends ConsumerState<LiveScheduleScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bookingProvider.notifier).restore());
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(scheduleEntriesProvider);
    final tab = ref.watch(scheduleTabProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch tham gia')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Wrap(
              spacing: AppSpacing.s8,
              runSpacing: AppSpacing.s8,
              children: [
                for (final item in ['Sắp tới', 'Đã kết thúc', 'Đã hủy'].indexed)
                  ChoiceChip(
                    label: Text(item.$2),
                    selected: tab == item.$1,
                    onSelected: (_) =>
                        ref.read(scheduleTabProvider.notifier).select(item.$1),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: BookingFeedback(),
          ),
          Expanded(
            child: value.when(
              loading: () => const AppLoadingState(),
              error: (_, _) => EventFailure(
                onRetry: () => ref.invalidate(registrationsProvider),
              ),
              data: (rows) {
                if (rows.isEmpty) {
                  return AppEmptyState(
                    title: 'Chưa có lịch tham gia',
                    message: 'Khám phá và đăng ký sự kiện phù hợp.',
                    actionLabel: 'Khám phá sự kiện',
                    onAction: () => context.go('/discover'),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  children: [
                    for (final entry in rows)
                      _ScheduleItem(entry.registration, event: entry.event),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleItem extends ConsumerWidget {
  const _ScheduleItem(this.r, {required this.event});
  final Registration r;
  final Event? event;

  (String, AppBadgeVariant, IconData) _badgeFor(Event e, bool ended) {
    if (r.isRejected) {
      return ('Bị từ chối', AppBadgeVariant.error, Icons.cancel_outlined);
    }
    if (r.isCancelled) {
      return (
        'Đã hủy đăng ký',
        AppBadgeVariant.neutral,
        Icons.remove_circle_outline,
      );
    }
    if (e.status == 'cancelled') {
      return ('Sự kiện đã hủy', AppBadgeVariant.error, Icons.event_busy);
    }
    if (r.checkInAt != null) {
      return (
        'Đã điểm danh',
        AppBadgeVariant.success,
        Icons.check_circle_outline,
      );
    }
    if (ended) {
      return ('Đã kết thúc', AppBadgeVariant.neutral, Icons.history);
    }
    if (r.isPending) {
      return ('Chờ CLB duyệt', AppBadgeVariant.warning, Icons.schedule);
    }
    return ('Đã duyệt', AppBadgeVariant.success, Icons.verified_outlined);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = event;
    if (e == null) {
      return EventPanel(
        children: [
          const Text('Thông tin sự kiện không còn khả dụng.'),
          AppButton(
            label: 'Xem đăng ký',
            onPressed: () => context.push('/registrations/${r.id}'),
          ),
        ],
      );
    }
    final ended = scheduleBucket(r, e, DateTime.now()) == 1;
    final (label, variant, icon) = _badgeFor(e, ended);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: EventPanel(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AppStatusBadge(
              label: label,
              variant: variant,
              icon: Icon(icon),
            ),
          ),
          Text(e.title, style: Theme.of(context).textTheme.titleMedium),
          Text(eventWhen(e)),
          Text(e.clubName),
          Text(e.location),
          if (r.isRejected && r.reason != null && r.reason!.isNotEmpty)
            Text(
              'Lý do từ chối: ${r.reason}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          AppButton(
            label: 'Xem chi tiết đăng ký',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/registrations/${r.id}'),
          ),
        ],
      ),
    );
  }
}
