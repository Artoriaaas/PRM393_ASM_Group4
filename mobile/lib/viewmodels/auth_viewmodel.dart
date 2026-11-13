import '../services/report_providers.dart';
import 'export_viewmodel.dart';
import '../services/event_service_providers.dart';
import '../viewmodels/cloud_state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/session_viewmodel.dart';
import '../utils/app_failure.dart';
import '../services/initial_auth_service.dart';
import 'booking_viewmodel.dart';

class AuthFormState {
  const AuthFormState({
    this.busy = false,
    this.message,
    this.errors = const {},
    this.name = '',
    this.email = '',
  });
  final bool busy;
  final String? message;
  final Map<String, String> errors;
  final String name;
  final String email;
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthFormState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<bool> submit(
    String mode, {
    String name = '',
    String email = '',
    String password = '',
  }) async {
    if (state.busy) return false;
    email = email.trim();
    name = name.trim();
    final errors = <String, String>{};
    if (['login', 'register', 'reset', 'change-email'].contains(mode) &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      errors['email'] = 'Vui lòng nhập email đúng định dạng.';
    }
    if (['login', 'register', 'change-email'].contains(mode) &&
        password.isEmpty) {
      errors['password'] = 'Vui lòng nhập mật khẩu.';
    }
    if (mode == 'register') {
      if (name.isEmpty) errors['name'] = 'Vui lòng nhập họ và tên.';
      if (password.length < 8) {
        errors['password'] = 'Mật khẩu cần ít nhất 8 ký tự.';
      }
    }
    state = AuthFormState(
      name: name.isEmpty ? state.name : name,
      email: email.isEmpty ? state.email : email,
      errors: errors,
      busy: errors.isEmpty,
    );
    if (errors.isNotEmpty) return false;
    final draft = state;
    try {
      final service = ref.read(authServiceProvider);
      String? message;
      switch (mode) {
        case 'login':
          await service.signIn(email, password);
          await track(ref, 'login', {'method': 'password'});
        case 'google':
          await service.signInWithGoogle();
          await track(ref, 'login', {'method': 'google'});
        case 'register':
          await service.register(name, email, password);
          message = 'Đã gửi email xác nhận. Mở liên kết trong hộp thư của bạn.';
        case 'verify':
          await service.reloadUser();
          if (service.currentAuthState.isUnverified) message = 'Hệ thống chưa ghi nhận xác nhận. Hãy mở liên kết trong email rồi kiểm tra lại.';
        case 'resend':
          await service.sendVerification();
          message = 'Đã gửi lại email xác nhận.';
        case 'reset':
          await service.resetPassword(email);
          message = 'Nếu email có tài khoản EventHub, bạn sẽ nhận liên kết đặt lại mật khẩu. Kiểm tra cả mục Spam/Thư rác.';
        case 'change-email':
          await service.changeEmail(email, password);
          message = 'Kiểm tra hộp thư địa chỉ mới và mở liên kết xác nhận. Email tài khoản chỉ đổi khi hệ thống xác nhận.';
        case 'logout':
          if (ref.read(bookingProvider).busy || ref.read(exportProvider).busy) {
            state = AuthFormState(
              message: 'Đang xử lý đăng ký. Vui lòng chờ kết quả trước khi đăng xuất.',
            );
            return false;
          }
          await track(ref, 'logout', {'method': 'manual'});
          final uid = ref.read(signedInUidProvider);
          if (uid != null) {
            // Do not retain personal pending commands after an explicit logout.
            // A later login reads current server state, never replays this draft.
            await ref.read(pendingBookingStoreProvider).clear(uid);
            try {
              await ref.read(reportFileServiceProvider).clearUser(uid);
            } catch (_) {
              /* Private files remain inaccessible to other accounts. */
            }
            try {
              await ref
                  .read(cloudServicesProvider)
                  .disablePush(uid)
                  .timeout(const Duration(seconds: 3));
            } catch (_) {
              /* Auth sign-out must still proceed. */
            }
          }
          await service.signOut();
          state = const AuthFormState();
          return true;
        default:
          throw const AppFailure(
            code: 'invalid-action',
            message: 'Thao tác không hợp lệ.',
          );
      }
      state = AuthFormState(
        name: draft.name,
        email: draft.email,
        message: message,
      );
      return true;
    } catch (error) {
      final message = switch (error) {
        AppFailure(:final message) => message,
        AuthServiceUnavailable() =>
          'Chưa kết nối Firebase của nhóm. Vui lòng hoàn tất cấu hình project.',
        _ => 'Chưa thể hoàn tất thao tác. Dữ liệu đã nhập được giữ nguyên; vui lòng thử lại.',
      };
      state = AuthFormState(
        name: draft.name,
        email: draft.email,
        message: message,
      );
      return false;
    }
  }
}
