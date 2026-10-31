import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'prototype_state.dart';
import 'prototype_widgets.dart';

class DemoNotificationsScreen extends ConsumerWidget {
  const DemoNotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(prototypeProvider);
    return DemoPage(
      title: 'Thông báo',
      tab: 2,
      children: [
        if (s.scenario == DemoScenario.empty) ...[
          const DemoStatus(
            'Chưa có thông báo',
            subtitle: 'Thông báo sự kiện và đăng ký sẽ xuất hiện tại đây.',
          ),
          AppButton(
            label: 'Xem lịch tham gia',
            onPressed: () => demoOpen(context, ref, '/schedule', replace: true),
          ),
        ] else ...[
          for (final item in [
            (
              'Workshop diễn ra ngày mai',
              'Bắt đầu lúc 14:00 tại Phòng 204 · Campus TP.HCM.',
            ),
            (
              'Cập nhật ngày giờ và địa điểm',
              'Lịch mới: 14:00–16:30 · 24/10/2026. Phòng 204 · Campus TP.HCM.',
            ),
            ('Đăng ký đã được xác nhận', demoWorkshop.title),
          ])
            DemoPanel(
              children: [
                Text(
                  '${s.readNotifications ? 'Đã đọc' : 'Chưa đọc'} · 23/10/2026',
                  style: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(color: AppColors.primary),
                ),
                Text(item.$1, style: Theme.of(context).textTheme.titleMedium),
                Text(item.$2),
                AppButton(
                  label: 'Xem chi tiết',
                  variant: AppButtonVariant.text,
                  onPressed: () {
                    ref.read(prototypeProvider.notifier).markRead();
                    demoOpen(
                      context,
                      ref,
                      s.registered ? '/registrations/demo' : '/events/workshop',
                    );
                  },
                ),
              ],
            ),
          if (s.scenario == DemoScenario.cancelled)
            const DemoMessage(
              'CLB đã hủy sự kiện. Mở chi tiết để xem trạng thái mới nhất.',
              error: true,
            ),
        ],
      ],
    );
  }
}

class DemoScannerScreen extends ConsumerWidget {
  const DemoScannerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(prototypeProvider);
    final blocked = [
      DemoScenario.cameraDenied,
      DemoScenario.closed,
      DemoScenario.wrongQr,
      DemoScenario.cancelled,
    ].contains(s.scenario);
    final message = blocked ? s.scenario.label : s.message;
    return DemoPage(
      title: 'Quét QR điểm danh',
      allowScenario: false,
      action: AppButton(
        label: blocked
            ? 'Quét lại'
            : s.scenario == DemoScenario.unknown && s.message != null
            ? 'Kiểm tra trạng thái'
            : 'Mô phỏng quét QR',
        isLoading: s.busy,
        isFullWidth: true,
        onPressed: () async {
          if (blocked) {
            ref.read(prototypeProvider.notifier).scenario(DemoScenario.normal);
            return;
          }
          final ok = await ref
              .read(prototypeProvider.notifier)
              .act(
                'checkin',
                recover:
                    s.scenario == DemoScenario.unknown && s.message != null,
              );
          if (ok && context.mounted) {
            demoOpen(
              context,
              ref,
              '/registrations/demo/check-in',
              replace: true,
            );
          }
        },
      ),
      children: [
        const Text('Đưa mã QR do CLB hiển thị vào khung hình.'),
        if (message != null) DemoMessage(message, error: true),
        if (!s.registered || s.cancelled) ...[
          const DemoMessage(
            'Cần đăng ký hợp lệ. Chưa ghi nhận điểm danh.',
            error: true,
          ),
          AppButton(
            label: 'Xem sự kiện',
            onPressed: () => demoOpen(context, ref, '/events/workshop'),
          ),
        ] else if (!blocked)
          Container(
            height: 440,
            decoration: const BoxDecoration(
              color: Color(0xFF172033),
              borderRadius: AppRadius.borderR16,
            ),
            child: Center(
              child: Container(
                width: 248,
                height: 248,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                  borderRadius: AppRadius.borderR16,
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s16),
                    child: Text(
                      'Camera mô phỏng\nKhông sử dụng camera thiết bị',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.surface),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (s.scenario == DemoScenario.cameraDenied)
          AppButton(
            label: 'Mô phỏng cấp quyền camera',
            variant: AppButtonVariant.secondary,
            onPressed: () => ref
                .read(prototypeProvider.notifier)
                .scenario(DemoScenario.normal),
          ),
        AppButton(
          label: 'Quay về chi tiết đăng ký',
          variant: AppButtonVariant.text,
          onPressed: () => demoOpen(context, ref, '/registrations/demo'),
        ),
      ],
    );
  }
}

class DemoCheckInResultScreen extends ConsumerWidget {
  const DemoCheckInResultScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(prototypeProvider);
    if (!s.checkedIn) {
      return DemoPage(
        title: 'Xác nhận điểm danh',
        children: [
          const DemoMessage('Chưa có xác nhận điểm danh.'),
          AppButton(
            label: 'Về lịch tham gia',
            onPressed: () => demoOpen(context, ref, '/schedule', replace: true),
          ),
        ],
      );
    }
    return DemoPage(
      title: 'Xác nhận điểm danh',
      children: [
        DemoStatus(
          GoRouterState.of(context).uri.queryParameters['revisit'] == 'true'
              ? 'Bạn đã điểm danh'
              : 'Điểm danh thành công',
          subtitle: 'Đưa màn hình này cho CLB kiểm tra.',
        ),
        if (s.scenario == DemoScenario.cancelled)
          const DemoMessage(
            'Sự kiện đã hủy. Đây là lịch sử điểm danh trước khi hủy.',
            error: true,
          ),
        const DemoMessage('Đã điểm danh lúc 14:05 · 24/10/2026', success: true),
        const DemoSummary(),
        DemoPerson(s.participant),
        AppButton(
          label: 'Về lịch tham gia',
          onPressed: () => demoOpen(context, ref, '/schedule', replace: true),
        ),
      ],
    );
  }
}
