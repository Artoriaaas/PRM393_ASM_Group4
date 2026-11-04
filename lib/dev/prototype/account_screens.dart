import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'prototype_state.dart';
import 'prototype_widgets.dart';

class DemoAccountScreen extends ConsumerWidget {
  const DemoAccountScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(prototypeProvider);
    return DemoPage(
      title: 'Tài khoản',
      tab: 3,
      children: [
        const Center(
          child: CircleAvatar(
            radius: AppSpacing.s32,
            backgroundColor: AppColors.brandSubtle,
            child: DemoIcon('profile_account'),
          ),
        ),
        Text(
          s.profileName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(s.profileEmail, textAlign: TextAlign.center),
        const DemoMessage('Email đã xác nhận', success: true),
        if (s.pendingEmail != null)
          DemoMessage('Email mới chờ xác nhận: ${s.pendingEmail}'),
        AppButton(
          label: 'Chỉnh sửa thông tin',
          variant: AppButtonVariant.secondary,
          onPressed: () => demoOpen(context, ref, '/account/edit'),
        ),
        AppButton(
          label: 'Xuất lịch tham gia',
          variant: AppButtonVariant.secondary,
          onPressed: () => demoOpen(context, ref, '/account/export'),
        ),
        AppButton(
          label: 'Khu demo Firebase',
          variant: AppButtonVariant.secondary,
          onPressed: () => demoOpen(context, ref, '/account/firebase-demo'),
        ),
        AppButton(
          label: 'Đăng xuất',
          variant: AppButtonVariant.secondary,
          onPressed: () async {
            ref.read(prototypeProvider.notifier).reset();
            await ref.read(authViewModelProvider.notifier).submit('logout');
          },
        ),
      ],
    );
  }
}

class DemoEditProfileScreen extends ConsumerStatefulWidget {
  const DemoEditProfileScreen({super.key});
  @override
  ConsumerState<DemoEditProfileScreen> createState() =>
      _DemoEditProfileScreenState();
}

class _DemoEditProfileScreenState extends ConsumerState<DemoEditProfileScreen> {
  late final TextEditingController name, email;
  bool dirty = false;
  @override
  void initState() {
    super.initState();
    final s = ref.read(prototypeProvider);
    name = TextEditingController(text: s.profileName);
    email = TextEditingController(text: s.pendingEmail ?? s.profileEmail);
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(prototypeProvider);
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final discard = await AppConfirmationDialog.show(
          context: context,
          title: 'Thay đổi chưa lưu',
          message: 'Bạn muốn bỏ thay đổi đang nhập?',
          confirmLabel: 'Bỏ thay đổi',
          cancelLabel: 'Tiếp tục sửa',
        );
        if (discard == true && context.mounted) {
          setState(() => dirty = false);
          await Future<void>.delayed(Duration.zero);
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: DemoPage(
        title: 'Chỉnh sửa thông tin',
        allowScenario: false,
        children: [
          const Text(
            'Cập nhật họ tên và email liên hệ. Thay đổi hồ sơ không sửa dữ liệu đăng ký cũ.',
          ),
          AppTextField(
            controller: name,
            labelText: 'Họ tên *',
            onChanged: (_) => setState(() => dirty = true),
          ),
          AppTextField(
            controller: email,
            labelText: 'Email liên hệ *',
            onChanged: (_) => setState(() => dirty = true),
          ),
          if (s.message != null) DemoMessage(s.message!, error: true),
          if (s.pendingEmail != null) ...[
            DemoMessage(
              'Chờ xác nhận email mới: ${s.pendingEmail}. Email đang dùng vẫn là ${s.profileEmail}.',
            ),
            AppButton(
              label: 'Mô phỏng xác nhận email mới',
              onPressed: () =>
                  ref.read(prototypeProvider.notifier).verifyContact(),
            ),
          ],
          AppButton(
            label: 'Lưu thay đổi',
            onPressed: () {
              if (ref
                  .read(prototypeProvider.notifier)
                  .saveProfile(name.text, email.text)) {
                setState(() => dirty = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã lưu trong prototype local.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class DemoExportScreen extends ConsumerStatefulWidget {
  const DemoExportScreen({super.key});
  @override
  ConsumerState<DemoExportScreen> createState() => _DemoExportScreenState();
}

class _DemoExportScreenState extends ConsumerState<DemoExportScreen> {
  bool done = false, busy = false;
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(prototypeProvider);
    return DemoPage(
      title: 'Xuất lịch tham gia',
      allowScenario: false,
      children: [
        const DemoMessage(
          'Bản xem thử giao diện. Chưa tạo PDF hoặc upload lên Cloudinary.',
        ),
        const DemoSummary(),
        if (!s.registered || s.scenario == DemoScenario.empty)
          const DemoMessage('Chưa có dữ liệu đăng ký để xuất.'),
        if (s.scenario == DemoScenario.error)
          const DemoMessage(
            'Mô phỏng upload lỗi. Thử lại khi kết nối ổn định.',
            error: true,
          ),
        if (busy) const LinearProgressIndicator(),
        if (done)
          const DemoMessage(
            'Hoàn tất mô phỏng. Không có file hoặc link cloud thật.',
            success: true,
          ),
        AppButton(
          label: 'Xem trước báo cáo',
          variant: AppButtonVariant.secondary,
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Nội dung PDF dự kiến'),
              content: const SingleChildScrollView(child: DemoSummary()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ),
        ),
        AppButton(
          label: 'Mô phỏng xuất và upload',
          isLoading: busy,
          isDisabled: !s.registered,
          onPressed: () async {
            setState(() => busy = true);
            await Future<void>.delayed(const Duration(milliseconds: 600));
            if (mounted) {
              setState(() {
                busy = false;
                done = s.scenario != DemoScenario.error;
              });
            }
          },
        ),
      ],
    );
  }
}

class DemoFirebaseScreen extends ConsumerStatefulWidget {
  const DemoFirebaseScreen({super.key});
  @override
  ConsumerState<DemoFirebaseScreen> createState() => _DemoFirebaseScreenState();
}

class _DemoFirebaseScreenState extends ConsumerState<DemoFirebaseScreen> {
  bool recommendations = true;
  double limit = 6;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'Khu demo Firebase',
    children: [
      const DemoMessage(
        'Các điều khiển dưới đây chỉ thay đổi UI local. Chưa kết nối Remote Config, FCM hoặc Crashlytics.',
      ),
      DemoPanel(
        children: [
          Text('Remote Config', style: Theme.of(context).textTheme.titleMedium),
          Material(
            color: AppColors.surfaceSubtle,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Hiện gợi ý sự kiện'),
              value: recommendations,
              onChanged: (v) => setState(() => recommendations = v),
            ),
          ),
          Text('Giới hạn gợi ý: ${limit.round()}'),
          Slider(
            min: 1,
            max: 10,
            divisions: 9,
            value: limit,
            onChanged: (v) => setState(() => limit = v),
          ),
          Text(
            recommendations
                ? 'Đang hiển thị khối gợi ý (${limit.round()} mục tối đa)'
                : 'Đã ẩn khối gợi ý',
          ),
        ],
      ),
      AppButton(
        label: 'Mở trung tâm thông báo',
        onPressed: () =>
            demoOpen(context, ref, '/notifications', replace: true),
      ),
      AppButton(
        label: 'Xuất và upload file',
        onPressed: () => demoOpen(context, ref, '/account/export'),
      ),
      AppButton(
        label: 'Xem thử phản hồi ghi lỗi',
        variant: AppButtonVariant.secondary,
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Crashlytics — bản xem thử'),
            content: const Text(
              'Chưa gửi lỗi hoặc gây crash. Nút test crash thật sẽ được thêm sau khi cấu hình Firebase.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
