import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/providers.dart';
import '../services/web_contracts.dart';

sealed class WebAuthUIState {
  const WebAuthUIState();
}

class WebAuthInitial extends WebAuthUIState {
  const WebAuthInitial();
}

class WebAuthLoading extends WebAuthUIState {
  const WebAuthLoading();
}

class WebAuthSuccess extends WebAuthUIState {
  const WebAuthSuccess(this.user);
  final WebUserProfile user;
}

class WebAuthRejected extends WebAuthUIState {
  const WebAuthRejected({required this.reason, required this.user});
  final String reason;
  final WebUserProfile user;
}

class WebAuthError extends WebAuthUIState {
  const WebAuthError(this.message);
  final String message;
}

class WebAuthViewModel extends Notifier<WebAuthUIState> {
  @override
  WebAuthUIState build() {
    final authService = ref.watch(webAuthServiceProvider);

    final sub = authService.authStateChanges().listen((user) {
      evaluateSession(user);
    });
    ref.onDispose(sub.cancel);

    final user = authService.currentUser;
    if (user == null) return const WebAuthInitial();

    if (user.role == 'user') {
      return WebAuthRejected(
        reason:
            'Tài khoản này thuộc vai trò Người tham gia. Vui lòng dùng ứng dụng EventHub trên di động hoặc liên hệ Quản trị viên.',
        user: user,
      );
    }
    if (user.role == 'staff' &&
        (user.clubId == null || user.clubId!.trim().isEmpty)) {
      return WebAuthRejected(
        reason:
            'Tài khoản Trưởng CLB chưa được Quản trị viên phân công Câu lạc bộ. Vui lòng liên hệ Quản trị viên để được cấp quyền.',
        user: user,
      );
    }
    return WebAuthSuccess(user);
  }

  void evaluateSession(WebUserProfile? user) {
    if (user == null) {
      state = const WebAuthInitial();
      return;
    }
    if (user.role == 'user') {
      state = WebAuthRejected(
        reason:
            'Tài khoản này thuộc vai trò Người tham gia. Vui lòng dùng ứng dụng EventHub trên di động hoặc liên hệ Quản trị viên.',
        user: user,
      );
    } else if (user.role == 'staff' &&
        (user.clubId == null || user.clubId!.trim().isEmpty)) {
      state = WebAuthRejected(
        reason:
            'Tài khoản Trưởng CLB chưa được Quản trị viên phân công Câu lạc bộ. Vui lòng liên hệ Quản trị viên để được cấp quyền.',
        user: user,
      );
    } else {
      state = WebAuthSuccess(user);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const WebAuthLoading();
    final authService = ref.read(webAuthServiceProvider);
    final analyticsService = ref.read(webAnalyticsServiceProvider);

    final result = await authService.signInWithGoogle();

    result.when(
      success: (user) {
        if (user.role == 'user') {
          state = WebAuthRejected(
            reason:
                'Tài khoản này thuộc vai trò Người tham gia. Vui lòng dùng ứng dụng EventHub trên di động hoặc liên hệ Quản trị viên.',
            user: user,
          );
        } else if (user.role == 'staff' &&
            (user.clubId == null || user.clubId!.trim().isEmpty)) {
          state = WebAuthRejected(
            reason:
                'Tài khoản Trưởng CLB chưa được Quản trị viên phân công Câu lạc bộ. Vui lòng liên hệ Quản trị viên để được cấp quyền.',
            user: user,
          );
        } else {
          analyticsService.logEvent('web_login', {'role': user.role});
          state = WebAuthSuccess(user);
        }
      },
      failure: (failure) {
        state = WebAuthError(failure.message);
      },
    );
  }

  Future<void> signOut() async {
    final authService = ref.read(webAuthServiceProvider);
    await authService.signOut();
    state = const WebAuthInitial();
  }
}

final webAuthViewModelProvider =
    NotifierProvider<WebAuthViewModel, WebAuthUIState>(WebAuthViewModel.new);
