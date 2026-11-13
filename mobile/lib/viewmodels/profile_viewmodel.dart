import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/session_viewmodel.dart';

final profileCanChangeEmailProvider = Provider<bool>((ref) {
  ref.watch(sessionViewModelProvider);
  return ref.watch(authServiceProvider).canChangeEmail;
});

class ProfileState {
  const ProfileState({
    this.busy = false,
    this.saved = false,
    this.message,
    this.pendingEmail,
    this.errors = const {},
  });
  final bool busy, saved;
  final String? message, pendingEmail;
  final Map<String, String> errors;
}

final profileProvider = NotifierProvider<ProfileViewModel, ProfileState>(
  ProfileViewModel.new,
);

class ProfileViewModel extends Notifier<ProfileState> {
  int _epoch = 0;
  @override
  ProfileState build() {
    ref.watch(signedInUidProvider);
    _epoch++;
    return const ProfileState();
  }

  Future<void> resendEmail(String password) async {
    final email = state.pendingEmail;
    if (email == null || state.busy) return;
    if (password.isEmpty) {
      state = ProfileState(
        pendingEmail: email,
        errors: {'password': 'Nhập mật khẩu hiện tại để gửi lại xác nhận.'},
      );
      return;
    }
    final uid = ref.read(signedInUidProvider);
    final epoch = _epoch;
    state = ProfileState(busy: true, pendingEmail: email);
    try {
      await ref.read(authServiceProvider).changeEmail(email, password);
      if (ref.mounted &&
          epoch == _epoch &&
          ref.read(signedInUidProvider) == uid) {
        state = ProfileState(
          saved: true,
          pendingEmail: email,
          message: 'Đã gửi lại liên kết xác nhận đến email mới.',
        );
      }
    } catch (_) {
      if (ref.mounted &&
          epoch == _epoch &&
          ref.read(signedInUidProvider) == uid) {
        state = ProfileState(
          pendingEmail: email,
          message: 'Chưa gửi lại được xác nhận. Kiểm tra kết nối và thử lại.',
        );
      }
    }
  }

  Future<void> save({
    required String name,
    required String currentEmail,
    required String email,
    required String password,
  }) async {
    if (state.busy) return;
    final uid = ref.read(signedInUidProvider);
    if (uid == null) return;
    final service = ref.read(authServiceProvider);
    final errors = <String, String>{};
    if (name.trim().isEmpty || name.trim().length > 100) {
      errors['name'] = 'Nhập họ tên từ 1 đến 100 ký tự.';
    }
    final changing = email.trim() != currentEmail;
    if (changing) {
      if (!service.canChangeEmail) {
        errors['email'] = 'Email đăng nhập do Google quản lý.';
      }
      if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
        errors['email'] = 'Nhập email đúng định dạng.';
      }
      if (password.isEmpty) {
        errors['password'] = 'Nhập mật khẩu hiện tại để xác thực lại.';
      }
    }
    if (errors.isNotEmpty) {
      state = ProfileState(errors: errors);
      return;
    }
    final epoch = _epoch;
    state = const ProfileState(busy: true);
    bool nameSaved = false;
    try {
      await service.updateName(name.trim());
      if (!ref.mounted ||
          ref.read(signedInUidProvider) != uid ||
          epoch != _epoch) {
        return;
      }
      nameSaved = true;
      if (changing) await service.changeEmail(email.trim(), password);
      if (ref.mounted &&
          epoch == _epoch &&
          ref.read(signedInUidProvider) == uid) {
        state = ProfileState(
          saved: true,
          pendingEmail: changing ? email.trim() : null,
          message: changing
              ? 'Họ tên đã lưu. Kiểm tra hộp thư mới để xác nhận đổi email; email hiện tại vẫn dùng đến khi hệ thống xác nhận.'
              : 'Đã cập nhật họ tên. Các đăng ký cũ giữ nguyên thông tin lúc đăng ký.',
        );
      }
    } catch (_) {
      if (ref.mounted &&
          epoch == _epoch &&
          ref.read(signedInUidProvider) == uid) {
        state = ProfileState(
          message: nameSaved
              ? 'Họ tên đã cập nhật; chưa hoàn tất đổi email. Kiểm tra thông tin và thử lại.'
              : 'Chưa lưu được. Thông tin đang nhập được giữ nguyên.',
        );
      }
    }
  }
}
