import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/session_viewmodel.dart';
import '../../app/auth_redirect.dart';
import '../../models/auth_state.dart';
import '../../theme/theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/widgets.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, required this.mode});
  final String mode;
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  @override
  void initState() {
    super.initState();
    final draft = ref.read(authViewModelProvider);
    _name.text = draft.name;
    _email.text = draft.email;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _go(String path) {
    final from = safeDestination(
      GoRouterState.of(context).uri.queryParameters['from'],
    );
    context.go(Uri(path: path, queryParameters: {'from': from}).toString());
  }

  Future<void> _submit([String? action]) async {
    FocusScope.of(context).unfocus();
    final ok = await ref
        .read(authViewModelProvider.notifier)
        .submit(
          action ?? widget.mode,
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
    if (ok &&
        mounted &&
        [
          'login',
          'google',
          'register',
          'logout',
        ].contains(action ?? widget.mode)) {
      _password.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);
    final session = ref.watch(sessionViewModelProvider);
    final mode = widget.mode;
    final verify = mode == 'verify';
    final reset = mode == 'reset';
    final change = mode == 'change-email';
    final register = mode == 'register';
    final login = mode == 'login';
    final title = switch (mode) {
      'register' => 'Tạo tài khoản',
      'verify' => 'Kiểm tra email',
      'reset' => 'Quên mật khẩu?',
      'change-email' => 'Đổi email',
      _ => 'Đăng nhập',
    };
    Widget button(
      String label,
      VoidCallback onTap, {
      AppButtonVariant variant = AppButtonVariant.primary,
    }) => AppButton(
      label: label,
      onPressed: onTap,
      variant: variant,
      isDisabled: state.busy,
      isFullWidth: true,
    );
    final children = <Widget>[
      if (verify || reset) ...[
        Center(
          child: CircleAvatar(
            radius: AppSpacing.s32,
            backgroundColor: AppColors.brandSubtle,
            child: SvgPicture.asset(
              verify
                  ? 'assets/icons/auth_bell.svg'
                  : 'assets/icons/auth_eye.svg',
              width: 24,
              height: 24,
            ),
          ),
        ),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ] else
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
      if (login) const Text('Đăng nhập để khám phá và theo dõi sự kiện.'),
      if (reset)
        const Text(
          'Nhập email đã dùng để nhận liên kết đặt lại mật khẩu.',
          textAlign: TextAlign.center,
        ),
      if (verify) ...[
        const Text(
          'Mở liên kết xác nhận trong hộp thư của bạn.',
          textAlign: TextAlign.center,
        ),
        Text(
          session is AuthStateUnverified ? session.email : state.email,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        button(
          'Đổi email',
          () => _go('/auth/change-email'),
          variant: AppButtonVariant.text,
        ),
        const Text('Không thấy thư? Kiểm tra mục Spam hoặc Thư rác.'),
      ],
      if (!ref.watch(firebaseReadyProvider))
        const Text(
          'Chưa kết nối Firebase của nhóm. Các thao tác tài khoản sẽ hoạt động sau khi cấu hình project.',
        ),
      if (register)
        AppTextField(
          controller: _name,
          labelText: 'Họ và tên *',
          hintText: 'Nhập họ và tên',
          enabled: !state.busy,
          errorText: state.errors['name'],
        ),
      if (!verify)
        AppTextField(
          controller: _email,
          labelText: change ? 'Email mới *' : 'Email cá nhân *',
          hintText: 'ten@example.com',
          keyboardType: TextInputType.emailAddress,
          enabled: !state.busy,
          errorText: state.errors['email'],
        ),
      if (login || register || change)
        AppTextField(
          controller: _password,
          labelText: change ? 'Mật khẩu hiện tại *' : 'Mật khẩu *',
          hintText: 'Nhập mật khẩu',
          obscureText: true,
          enabled: !state.busy,
          errorText: state.errors['password'],
          onSubmitted: (_) {
            if (!state.busy) _submit();
          },
        ),
      if (login)
        button(
          'Quên mật khẩu?',
          () => _go('/auth/forgot-password'),
          variant: AppButtonVariant.text,
        ),
      if (register)
        const Text(
          'Bạn sẽ nhận email để xác nhận tài khoản. Mật khẩu cần ít nhất 8 ký tự.',
        ),
      if (state.message != null)
        Semantics(liveRegion: true, child: Text(state.message!)),
      AppButton(
        label: switch (mode) {
          'register' => 'Tạo tài khoản',
          'verify' => 'Tôi đã xác nhận email',
          'reset' => 'Gửi liên kết',
          'change-email' => 'Gửi liên kết xác nhận email mới',
          _ => 'Đăng nhập',
        },
        isLoading: state.busy,
        isFullWidth: true,
        onPressed: () => _submit(verify ? 'verify' : null),
      ),
      if (login) ...[
        button(
          'Tiếp tục với Google',
          () => _submit('google'),
          variant: AppButtonVariant.secondary,
        ),
        button(
          'Tạo tài khoản',
          () => _go('/auth/register'),
          variant: AppButtonVariant.secondary,
        ),
      ],
      if (register)
        button(
          'Điều khoản và chính sách dữ liệu',
          () => showDialog<void>(
            context: context,
            builder: (context) => const AppInfoDialog(
              title: 'Thông tin dữ liệu tài khoản',
              message:
                  'EventHub sử dụng họ tên và email để quản lý tài khoản. '
                  'Nhóm sinh viên và khóa K tại form đăng ký sự kiện là thông tin tự khai, không xác minh danh tính. '
                  'Không đưa email, mật khẩu vào Analytics. Chính sách chính thức cần được nhóm bổ sung trước khi phát hành.',
            ),
          ),
          variant: AppButtonVariant.text,
        ),
      if (verify) ...[
        button(
          'Gửi lại email xác nhận',
          () => _submit('resend'),
          variant: AppButtonVariant.secondary,
        ),
        button(
          'Đăng xuất',
          () => _submit('logout'),
          variant: AppButtonVariant.text,
        ),
      ],
      if (!login && !verify)
        button(
          change ? 'Quay lại kiểm tra email' : 'Đã có tài khoản? Đăng nhập',
          () => _go(change ? '/auth/verify-email' : '/auth/login'),
          variant: AppButtonVariant.text,
        ),
    ];
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppTopBar(
        title: login ? 'EventHub' : 'Tài khoản',
        showBackButton: !login && !verify,
        onBack: () {
          if (!state.busy) _go(change ? '/auth/verify-email' : '/auth/login');
        },
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenMargin),
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.s16),
              children[i],
            ],
            const SizedBox(height: AppSpacing.s16),
          ],
        ),
      ),
    );
  }
}
