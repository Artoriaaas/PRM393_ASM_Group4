import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/theme.dart';
import '../../viewmodels/export_viewmodel.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';

class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(reportRowsProvider);
    final s = ref.watch(exportProvider);
    return Scaffold(
      appBar: AppTopBar(title: 'Xuất lịch tham gia', showBackButton: true),
      body: rows.when(
        loading: () => const AppLoadingState(),
        error: (_, _) =>
            EventFailure(onRetry: () => ref.invalidate(reportRowsProvider)),
        data: (data) => ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            Text(
              'PDF sẽ chứa ${data.length} đăng ký đang hiển thị dưới đây, gồm cả lịch sử đã hủy.',
            ),
            const Text(
              'PDF lưu trong vùng riêng của ứng dụng; chỉ chia sẻ file khi bạn bấm Chia sẻ. Firestore chỉ lưu metadata, không lưu nội dung PDF.',
            ),
            for (final row in data)
              EventPanel(
                children: [Text(row.title), Text(row.when), Text(row.status)],
              ),
            if (data.isEmpty)
              const AppEmptyState(
                title: 'Chưa có dữ liệu để xuất',
                message: 'Đăng ký sự kiện trước khi tạo báo cáo.',
              ),
            if (s.busy) const LinearProgressIndicator(),
            if (s.message != null) Text(s.message!),
            if (s.path != null) ...[
              const Text('PDF đã được lưu trên thiết bị.'),
              AppButton(
                label: 'Chia sẻ PDF',
                isDisabled: s.busy,
                onPressed: () => ref.read(exportProvider.notifier).share(),
              ),
              if (!s.recorded)
                AppButton(
                  label: 'Thử lưu metadata',
                  isDisabled: s.busy,
                  variant: AppButtonVariant.secondary,
                  onPressed: () =>
                      ref.read(exportProvider.notifier).recordMetadata(),
                ),
            ],
            const SizedBox(height: AppSpacing.s16),
            AppButton(
              label: 'Tạo và lưu PDF',
              isLoading: s.busy,
              isDisabled: data.isEmpty,
              onPressed: () => ref.read(exportProvider.notifier).generate(data),
            ),
          ],
        ),
      ),
    );
  }
}
