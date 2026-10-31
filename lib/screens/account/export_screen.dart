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
      appBar: AppBar(title: const Text('Xuất lịch tham gia')),
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
            for (final row in data)
              EventPanel(
                children: [Text(row.title), Text(row.when), Text(row.status)],
              ),
            if (data.isEmpty)
              const AppEmptyState(
                title: 'Chưa có dữ liệu để xuất',
                message: 'Đăng ký sự kiện trước khi tạo báo cáo.',
              ),
            if (s.busy) LinearProgressIndicator(value: s.progress),
            if (s.message != null) Text(s.message!),
            if (s.url != null) ...[
              SelectableText(s.url!),
              AppButton(
                label: 'Sao chép liên kết PDF',
                onPressed: () => ref.read(exportProvider.notifier).copy(),
              ),
            ],
            const SizedBox(height: AppSpacing.s16),
            AppButton(
              label: 'Tạo PDF và tải lên',
              isLoading: s.busy,
              isDisabled: data.isEmpty,
              onPressed: () => ref.read(exportProvider.notifier).upload(data),
            ),
          ],
        ),
      ),
    );
  }
}
