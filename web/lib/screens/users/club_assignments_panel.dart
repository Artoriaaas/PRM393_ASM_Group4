import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';

import '../../viewmodels/club_assignments_viewmodel.dart';

class ClubAssignmentsPanel extends ConsumerWidget {
  const ClubAssignmentsPanel({super.key, required this.clubs});
  final List<Club> clubs;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(clubAssignmentsProvider);
    final action = ref.watch(assignmentActionProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân công đại diện CLB bằng email',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Tạo CLB trước, sau đó phân công email Google của người đại diện. Họ không cần đăng ký trên mobile. Nhà trường gửi link cổng CLB cho đại diện.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: action.isLoading || !assignments.hasValue
                      ? null
                      : () => showDialog<void>(
                          context: context,
                          builder: (_) => AssignmentDialog(
                            clubs: clubs
                                .where(
                                  (c) =>
                                      c.isActive &&
                                      !assignments.requireValue.any(
                                        (a) =>
                                            a.clubId == c.id &&
                                            a.status != 'revoked',
                                      ),
                                )
                                .toList(),
                          ),
                        ),
                  child: const Text('Phân công bằng email'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(
                        text: Uri.base.hasAuthority
                            ? '${Uri.base.origin}/'
                            : 'https://eventhub-group4.web.app/',
                      ),
                    );
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã sao chép link cổng CLB.'),
                        ),
                      );
                  },
                  child: const Text('Sao chép link cổng CLB'),
                ),
              ],
            ),
            if (action.isLoading) const LinearProgressIndicator(),
            if (action.hasError)
              Text(
                '${action.error}',
                style: const TextStyle(color: AppColors.error),
              ),
            assignments.when(
              loading: () =>
                  const AppLoadingState(message: 'Đang tải phân công…'),
              error: (_, __) => AppErrorState(
                title: 'Lỗi tải phân công',
                message: 'Chưa tải được phân công.',
                onRetry: () => ref.invalidate(clubAssignmentsProvider),
              ),
              data: (rows) => rows.isEmpty
                  ? const Text('Chưa có phân công bằng email.')
                  : Column(
                      children: rows
                          .map(
                            (a) => ListTile(
                              title: Text(a.email),
                              subtitle: Text(
                                '${a.clubName} · ${switch (a.status) {
                                  "pending" => "Chờ đăng nhập",
                                  "awaiting_activation" => "Chờ Admin kích hoạt",
                                  "accepted" => "Đã kích hoạt",
                                  _ => "Đã thu hồi",
                                }}',
                              ),
                              leading: a.status == 'awaiting_activation'
                                  ? FilledButton(
                                      onPressed: action.isLoading
                                          ? null
                                          : () => ref
                                                .read(
                                                  assignmentActionProvider
                                                      .notifier,
                                                )
                                                .activate(a),
                                      child: const Text('Kích hoạt'),
                                    )
                                  : null,
                              trailing: a.status == 'revoked'
                                  ? null
                                  : TextButton(
                                      onPressed: action.isLoading
                                          ? null
                                          : () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                    'Thu hồi phân công?',
                                                  ),
                                                  content: Text(
                                                    'Thu hồi quyền quản lý ${a.clubName} của ${a.email}. Sự kiện vẫn được giữ.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: const Text('Hủy'),
                                                    ),
                                                    FilledButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Thu hồi',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true)
                                                await ref
                                                    .read(
                                                      assignmentActionProvider
                                                          .notifier,
                                                    )
                                                    .revoke(a);
                                            },
                                      child: const Text('Thu hồi'),
                                    ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignmentDialog extends ConsumerStatefulWidget {
  const AssignmentDialog({super.key, required this.clubs});
  final List<Club> clubs;
  @override
  ConsumerState<AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends ConsumerState<AssignmentDialog> {
  final email = TextEditingController();
  Club? club;
  String? error;
  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(assignmentActionProvider).isLoading;
    return PopScope(
      canPop: !busy,
      child: AlertDialog(
        scrollable: true,
        title: const Text('Phân công đại diện CLB'),
        content: SizedBox(
          width: 460,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.clubs.isEmpty)
                const Text(
                  'Chưa có CLB trống đang hoạt động. Tạo CLB trong mục Quản lý CLB hoặc thu hồi phân công cũ trước.',
                ),
              TextField(
                controller: email,
                enabled: !busy,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Google của người đại diện',
                  hintText: 'Không nhập mật khẩu',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Chọn CLB'),
                items: widget.clubs
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: busy
                    ? null
                    : (id) => setState(
                        () => club = widget.clubs.firstWhere((c) => c.id == id),
                      ),
              ),
              if (error != null)
                Text(error!, style: const TextStyle(color: AppColors.error)),
              if (busy) const LinearProgressIndicator(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: busy || widget.clubs.isEmpty
                ? null
                : () async {
                    if (club == null) {
                      setState(() => error = 'Vui lòng chọn CLB.');
                      return;
                    }
                    final result = await ref
                        .read(assignmentActionProvider.notifier)
                        .assign(email.text, club!);
                    if (!mounted) return;
                    if (result.isSuccess) {
                      Navigator.pop(context);
                    } else {
                      setState(() => error = result.failureOrNull!.message);
                    }
                  },
            child: Text(busy ? 'Đang lưu…' : 'Lưu phân công'),
          ),
        ],
      ),
    );
  }
}
