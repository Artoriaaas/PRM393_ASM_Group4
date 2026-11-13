import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/booking_viewmodel.dart';
import '../../viewmodels/event_data_providers.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';

class BookingFeedback extends ConsumerWidget {
  const BookingFeedback({super.key, this.showCheckButton = true});
  final bool showCheckButton;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(bookingProvider);
    final eventId = s.pending?['eventId'] as String?;
    final pendingEvent = eventId == null
        ? null
        : ref.watch(eventProvider(eventId)).asData?.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (s.message != null) EventPanel(children: [Text(s.message!)]),
        if (s.unresolved) ...[
          EventPanel(
            children: [
              Text(
                'Thao tác đang chờ: ${pendingEvent?.title ?? 'sự kiện trước đó'}',
              ),
            ],
          ),
          if (showCheckButton)
            AppButton(
              label: 'Kiểm tra trạng thái',
              isLoading: s.busy,
              onPressed: () => ref.read(bookingProvider.notifier).recover(),
            ),
          AppButton(
            variant: AppButtonVariant.text,
            onPressed: s.busy
                ? null
                : () => ref.read(bookingProvider.notifier).retryPending(),
            label: 'Thử lại cùng thao tác',
          ),
        ],
      ],
    );
  }
}
