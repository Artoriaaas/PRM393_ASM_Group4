import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';
import '../../viewmodels/notifications_viewmodel.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';

class NotificationsTabScreen extends ConsumerWidget {
  const NotificationsTabScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(notificationsProvider);
    final message = ref.watch(notificationsActionProvider);
    return Scaffold(
      appBar: AppTopBar(title: 'Thông báo', showBackButton: false),
      body: value.when(
        loading: () => const AppLoadingState(),
        error: (_, _) =>
            EventFailure(onRetry: () => ref.invalidate(notificationsProvider)),
        data: (rows) {
          if (rows.isEmpty) {
            return AppEmptyState(
              title: 'Chưa có thông báo',
              message: 'Thông báo về sự kiện và đăng ký sẽ xuất hiện tại đây.',
              actionLabel: 'Xem lịch tham gia',
              onAction: () => context.go('/schedule'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            children: [
              if (message != null) EventPanel(children: [Text(message)]),
              for (final n in rows)
                Card(
                  child: ListTile(
                    isThreeLine: true,
                    title: Text(n.title),
                    subtitle: Text(
                      '${n.readAt == null ? 'Chưa đọc' : 'Đã đọc'}\n${n.body}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final target = await ref
                          .read(notificationsActionProvider.notifier)
                          .open(n);
                      if (context.mounted && target != '/notifications') {
                        context.push(target);
                      }
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.s16),
              const Text(
                'Thông báo vẫn có trong app khi bạn tắt thông báo đẩy.',
              ),
            ],
          );
        },
      ),
    );
  }
}
