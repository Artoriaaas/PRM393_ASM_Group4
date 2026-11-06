import '../../theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/event_data_providers.dart';
import '../../models/event.dart';
import '../../viewmodels/event_viewmodels.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../widgets/widgets.dart';
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
                onRetry: () {
                  for (final r
                      in ref.read(registrationsProvider).asData?.value ??
                          <Registration>[]) {
                    ref.invalidate(eventProvider(r.eventId));
                  }
                  ref.invalidate(registrationsProvider);
                },
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
                      _ScheduleItem(
                        entry.registration,
                        event: entry.event,
                        ended: entry.ended,
                      ),
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
  const _ScheduleItem(this.r, {required this.event, required this.ended});
  final Registration r;
  final Event? event;
  final bool ended;
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: EventPanel(
        children: [
          Text(
            !r.active
                ? 'Đã hủy đăng ký'
                : e.status == 'cancelled'
                ? 'Sự kiện đã hủy'
                : ended
                ? 'Đã kết thúc'
                : 'Đã đăng ký',
          ),
          Text(e.title, style: Theme.of(context).textTheme.titleMedium),
          Text(eventWhen(e)),
          Text(e.clubName),
          Text(e.location),
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
