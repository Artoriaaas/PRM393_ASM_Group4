import '../../widgets/event_asset_icon.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../models/auth_state.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';

class AccountTabScreen extends ConsumerWidget {
  const AccountTabScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(sessionViewModelProvider);
    final s = ref.watch(authViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          if (auth is AuthStateSignedIn)
            EventPanel(
              children: [
                const CircleAvatar(
                  radius: AppSpacing.s32,
                  backgroundColor: AppColors.brandSubtle,
                  child: EventAssetIcon('profile_account'),
                ),
                Text(
                  auth.displayName ?? 'Tài khoản EventHub',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(auth.email, textAlign: TextAlign.center),
              ],
            ),
          AppButton(
            label: 'Chỉnh sửa thông tin',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/account/edit'),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppButton(
            label: 'Xuất lịch tham gia',
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/account/export'),
          ),
          const SizedBox(height: AppSpacing.s16),
          AppButton(
            label: 'Đăng xuất',
            isLoading: s.busy,
            onPressed: () =>
                ref.read(authViewModelProvider.notifier).submit('logout'),
          ),
          if (kDebugMode && const bool.fromEnvironment('LAB3_DIAGNOSTICS')) ...[
            const SizedBox(height: AppSpacing.s16),
            AppButton(
              label: 'Chẩn đoán Lab 3',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/account/firebase-demo'),
            ),
          ],
          if (s.message != null) Text(s.message!),
        ],
      ),
    );
  }
}
