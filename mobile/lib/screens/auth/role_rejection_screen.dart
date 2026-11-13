import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/auth_state.dart';
import '../../widgets/widgets.dart';

class RoleRejectionScreen extends ConsumerWidget {
  const RoleRejectionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(sessionViewModelProvider);
    final unavailable =
        auth is AuthStateSignedIn &&
        ['unknown', 'unavailable'].contains(auth.role);
    final state = ref.watch(authViewModelProvider);
    return Scaffold(
      appBar: AppTopBar(title: 'Tài khoản', showBackButton: false),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              unavailable
                  ? 'Chưa xác minh được vai trò'
                  : 'Tài khoản này dành cho web',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              unavailable
                  ? 'Kiểm tra kết nối và thử lại. Dữ liệu cá nhân chưa được mở.'
                  : 'Ứng dụng mobile dành cho người tham gia. Tài khoản CLB và quản trị viên sử dụng ứng dụng web của nhóm.',
            ),
            if (unavailable)
              AppButton(
                label: 'Thử lại',
                isLoading: state.busy,
                onPressed: () =>
                    ref.read(authViewModelProvider.notifier).submit('verify'),
              ),
            AppButton(
              label: 'Đăng xuất',
              isLoading: state.busy,
              onPressed: () =>
                  ref.read(authViewModelProvider.notifier).submit('logout'),
            ),
            if (state.message != null) Text(state.message!),
          ],
        ),
      ),
    );
  }
}
