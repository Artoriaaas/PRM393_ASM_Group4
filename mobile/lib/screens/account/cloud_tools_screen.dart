import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/theme.dart';
import '../../viewmodels/cloud_tools_viewmodel.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';

class CloudToolsScreen extends ConsumerWidget {
  const CloudToolsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(cloudToolsProvider);
    final vm = ref.read(cloudToolsProvider.notifier);
    return Scaffold(
      appBar: AppTopBar(title: 'Tiện ích Firebase', showBackButton: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          EventPanel(
            children: [
              Text('Giới hạn gợi ý: ${s.settings.recommendationLimit}'),
              Text(
                'Hiện gợi ý: ${s.settings.showRecommendations ? 'Bật' : 'Tắt'}',
              ),
              const Text(
                'Các giá trị đang dùng sẽ tác động màn Khám phá sau khi lấy cấu hình mới.',
              ),
            ],
          ),
          AppButton(
            label: 'Lấy cấu hình mới',
            isLoading: s.busy,
            onPressed: vm.refresh,
          ),
          const SizedBox(height: AppSpacing.s16),
          AppButton(
            label: 'Bật thông báo trên thiết bị',
            isDisabled: s.busy,
            onPressed: vm.enablePush,
          ),
          const SizedBox(height: AppSpacing.s16),
          AppButton(
            label: 'Trung tâm thông báo',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/notifications'),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppButton(
            label: 'Xuất và chia sẻ PDF',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/account/export'),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppButton(
            label: 'Ghi lỗi non-fatal thử nghiệm',
            variant: AppButtonVariant.secondary,
            onPressed: vm.nonFatal,
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.s16),
            AppButton(
              label: 'Test crash (debug)',
              variant: AppButtonVariant.secondary,
              onPressed: () async {
                final yes = await AppConfirmationDialog.show(
                  context: context,
                  title: 'Tạo test crash?',
                  message: 'App sẽ đóng để kiểm tra Crashlytics. Mở lại app sau đó và kiểm tra dashboard.',
                  confirmLabel: 'Tạo test crash',
                  cancelLabel: 'Quay lại',
                );
                if (yes == true) vm.crash();
              },
            ),
          ],
          if (s.message != null) ...[
            const SizedBox(height: AppSpacing.s16),
            EventPanel(children: [Text(s.message!)]),
          ],
        ],
      ),
    );
  }
}
