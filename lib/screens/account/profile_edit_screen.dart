import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../viewmodels/profile_viewmodel.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../widgets/event_widgets.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditState();
}

class _ProfileEditState extends ConsumerState<ProfileEditScreen> {
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController();
  String initialName = '', initialEmail = '';
  bool saved = false;
  @override
  void initState() {
    super.initState();
    final auth = ref.read(sessionViewModelProvider);
    if (auth is AuthStateSignedIn) {
      name.text = initialName = auth.displayName ?? '';
      email.text = initialEmail = auth.email;
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(profileProvider);
    final canEmail = ref.watch(authServiceProvider).canChangeEmail;
    final dirty =
        !saved && (name.text != initialName || email.text != initialEmail);
    return PopScope(
      canPop: !s.busy && !dirty,
      onPopInvokedWithResult: (popped, _) async {
        if (popped || s.busy) return;
        final yes = await showDialog<bool>(
          context: context,
          builder: (dialog) => AlertDialog(
            title: const Text('Bỏ thay đổi chưa lưu?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialog, false),
                child: const Text('Tiếp tục sửa'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialog, true),
                child: const Text('Bỏ thay đổi'),
              ),
            ],
          ),
        );
        if (yes == true && mounted) {
          setState(() => saved = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Chỉnh sửa thông tin')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          children: [
            AppTextField(
              labelText: 'Họ tên *',
              controller: name,
              enabled: !s.busy,
              onChanged: (_) => setState(() => saved = false),
              errorText: s.errors['name'],
            ),
            const SizedBox(height: AppSpacing.s16),
            AppTextField(
              labelText: 'Email tài khoản app',
              controller: email,
              enabled: !s.busy && canEmail,
              onChanged: (_) => setState(() => saved = false),
              errorText: s.errors['email'],
            ),
            if (!canEmail)
              const Text(
                'Email đăng nhập do Google quản lý. App không thay email Google của bạn.',
              ),
            if (canEmail) ...[
              const SizedBox(height: AppSpacing.s16),
              AppTextField(
                labelText: 'Mật khẩu hiện tại (khi đổi email)',
                controller: password,
                obscureText: true,
                enabled: !s.busy,
                errorText: s.errors['password'],
              ),
            ],
            const SizedBox(height: AppSpacing.s16),
            if (s.pendingEmail != null)
              EventPanel(
                children: [
                  const Text('Email mới — chờ xác nhận'),
                  Text(s.pendingEmail!),
                ],
              ),
            if (s.message != null) EventPanel(children: [Text(s.message!)]),
            const Text(
              'Thay đổi hồ sơ không tự cập nhật thông tin trên các đăng ký cũ.',
            ),
            const SizedBox(height: AppSpacing.s16),
            AppButton(
              label: 'Lưu thay đổi',
              isLoading: s.busy,
              onPressed: () async {
                await ref
                    .read(profileProvider.notifier)
                    .save(
                      name: name.text,
                      currentEmail: initialEmail,
                      email: email.text,
                      password: password.text,
                    );
                password.clear();
                if (mounted && ref.read(profileProvider).saved) {
                  setState(() => saved = true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
