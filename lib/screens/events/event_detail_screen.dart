import '../../theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/event_providers.dart';
import '../../viewmodels/event_viewmodels.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});
  final String eventId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(eventProvider(eventId));
    final registrations = ref.watch(registrationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sự kiện'), centerTitle: false),
      body: value.when(
        loading: () => const AppLoadingState(),
        error: (_, _) =>
            EventFailure(onRetry: () => ref.invalidate(eventProvider(eventId))),
        data: (e) {
          if (e == null) {
            return const AppEmptyState(
              title: 'Không tìm thấy sự kiện',
              message: 'Sự kiện không còn khả dụng.',
            );
          }
          final blocked = ref.watch(eventAvailabilityProvider(eventId));
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            children: [
              EventSummary(e, cover: true),
              const SizedBox(height: AppSpacing.s16),
              if (blocked != null) EventPanel(children: [Text(blocked)]),
              if (registrations.hasError)
                EventPanel(
                  children: [
                    const Text(
                      'Chưa kiểm tra được đăng ký hiện có. Thử lại trước khi đăng ký mới.',
                    ),
                    AppButton(
                      label: 'Kiểm tra đăng ký',
                      onPressed: () => ref.invalidate(registrationsProvider),
                    ),
                  ],
                ),
              if (e.isFree)
                const EventPanel(
                  children: [
                    Text(
                      'Không cần đăng ký. Đến trực tiếp theo thời gian và địa điểm công bố. Không có điểm danh QR trên app.',
                    ),
                  ],
                ),
              Text(
                'Giới thiệu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(e.description),
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Bạn sẽ làm gì?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final a in e.activities) Text('• $a'),
              if (e.audience.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s16),
                Text(
                  'Dành cho ai?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(e.audience),
              ],
              if (e.preparation.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s16),
                Text(
                  'Cần chuẩn bị',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(e.preparation),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: value.asData?.value == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Builder(
                  builder: (_) {
                    final e = value.asData!.value!;
                    final r = ref.watch(
                      activeRegistrationForEventProvider(eventId),
                    );
                    if (e.isFree) return const SizedBox.shrink();
                    return AppButton(
                      isFullWidth: true,
                      label: r != null ? 'Xem đăng ký' : 'Đăng ký sự kiện',
                      isDisabled:
                          r == null &&
                          (ref.watch(eventAvailabilityProvider(eventId)) !=
                                  null ||
                              !registrations.hasValue),
                      onPressed: () => context.push(
                        r != null
                            ? '/registrations/${r.id}'
                            : '/events/$eventId/register',
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
