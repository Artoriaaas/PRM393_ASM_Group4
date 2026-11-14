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
      appBar: AppTopBar(title: 'Lịch tham gia', showBackButton: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s16,
              vertical: AppSpacing.s12,
            ),
            child: Container(
              height:
                  AppTouchTargets.min *
                      MediaQuery.textScalerOf(context)
                          .scale(1)
                          .clamp(1.0, 2.0) +
                  AppSpacing.s8,
              padding: const EdgeInsets.all(AppSpacing.s4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.borderR12,
              ),
              child: Row(
                children: [
                  for (final item in [
                    (0, 'Sắp tới'),
                    (1, 'Đã kết thúc'),
                    (2, 'Đã hủy / Từ chối'),
                  ])
                    Expanded(
                      child: Semantics(
                        button: true,
                        selected: tab == item.$1,
                        label: item.$2,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => ref
                                .read(scheduleTabProvider.notifier)
                                .select(item.$1),
                            borderRadius: AppRadius.borderR8,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: tab == item.$1
                                    ? AppColors.surface
                                    : Colors.transparent,
                                borderRadius: AppRadius.borderR8,
                                border: tab == item.$1
                                    ? Border.all(color: AppColors.border)
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                item.$2,
                                style: AppTypography.textTheme.labelMedium
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: tab == item.$1
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                    ),
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
                    title: tab == 0
                        ? 'Chưa có sự kiện sắp tới'
                        : tab == 1
                        ? 'Chưa có sự kiện đã kết thúc'
                        : 'Chưa có đăng ký đã hủy hoặc từ chối',
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EventNotice(
            e.status == 'cancelled'
                ? 'Sự kiện đã hủy'
                : ended && r.canCheckIn
                ? 'Đã kết thúc${r.checkInAt != null ? " · Đã điểm danh" : ""}'
                : r.statusLabel,
            variant: r.canCheckIn && !ended
                ? AppBadgeVariant.success
                : AppBadgeVariant.info,
          ),
          const SizedBox(height: 16),
          EventIdentityCard(e),
          if (r.checkInAt != null) ...[
            const SizedBox(height: 8),
            EventNotice(
              'Đã điểm danh lúc ${eventTime(r.checkInAt!)} · ${eventDate(r.checkInAt!)}',
              variant: AppBadgeVariant.success,
            ),
          ],
          const SizedBox(height: 16),
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
