import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/session_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/auth_state.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
class RoleRejectionScreen extends ConsumerWidget {
  const RoleRejectionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(sessionViewModelProvider);
    final unavailable =
        auth is AuthStateSignedIn &&
        ['unknown', 'unavailable'].contains(auth.role);
    final isStaff = auth is AuthStateSignedIn && auth.role == 'staff';
    final staffClubId = isStaff ? (auth as AuthStateSignedIn).clubId : null;
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
            if (isStaff) ...[
              const SizedBox(height: AppSpacing.s16),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: AppRadius.borderR8,
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin vai trò hiện tại:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    const Text('• Vai trò: Trưởng câu lạc bộ (Staff)'),
                    if (staffClubId != null && staffClubId.isNotEmpty)
                      Text('• Câu lạc bộ quản lý: $staffClubId'),
                    const SizedBox(height: AppSpacing.s4),
                    const Text(
                      'Vui lòng truy cập cổng Web Admin trên máy tính để quản lý sự kiện và xét duyệt đơn của CLB.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s16),
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
