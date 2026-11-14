import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';

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
    final analytics = ref.watch(webAnalyticsServiceProvider);

    final sub = authService.authStateChanges().listen(
      (user) {
        if (!ref.mounted) return;
        evaluateSession(user);
      },
      onError: (Object err) {
        if (!ref.mounted) return;
        final msg = err is AppFailure
            ? err.message
            : 'Không thể xác minh phiên đăng nhập: $err';
        state = WebAuthError(msg);
      },
    );
    ref.onDispose(sub.cancel);

    final initial = _mapUserToState(authService.currentUser);
    if (initial is WebAuthSuccess) {
      unawaited(analytics.setUserId(initial.user.uid));
    }
    return initial;
  }

  WebAuthUIState _mapUserToState(WebUserProfile? user) {
    if (user == null) return const WebAuthInitial();
    if (user.role == 'user') {
      return WebAuthRejected(
        reason: 'Tài khoản chưa được phân công quản lý CLB. Đại diện CLB vui lòng cung cấp email Google cho quản trị viên nhà trường, sau đó đăng nhập lại đúng email được phân công. Người tham gia sử dụng ứng dụng mobile.',
        user: user,
      );
    }
    if (user.role == 'staff' &&
        (user.clubId == null || user.clubId!.trim().isEmpty)) {
      return WebAuthRejected(
        reason: 'Tài khoản Trưởng CLB chưa được Quản trị viên phân công Câu lạc bộ. Vui lòng liên hệ Quản trị viên để được cấp quyền.',
        user: user,
      );
    }
    if (user.role != 'staff' && user.role != 'admin') {
      return WebAuthRejected(
        reason: 'Vai trò tài khoản không hợp lệ để truy cập cổng quản trị Web. Vui lòng liên hệ Quản trị viên.',
        user: user,
      );
    }
    return WebAuthSuccess(user);
  }

  void evaluateSession(WebUserProfile? user) {
    final analytics = ref.read(webAnalyticsServiceProvider);
    final nextState = _mapUserToState(user);
    if (nextState is WebAuthSuccess) {
      unawaited(analytics.setUserId(nextState.user.uid));
    } else if (nextState is WebAuthInitial) {
      unawaited(analytics.setUserId(null));
    }
    state = nextState;
  }

  Future<void> signInWithGoogle() async {
    state = const WebAuthLoading();
    final authService = ref.read(webAuthServiceProvider);
    final analyticsService = ref.read(webAnalyticsServiceProvider);

    final result = await authService.signInWithGoogle();
    if (!ref.mounted) return;

    result.when(
      success: (user) {
        final mapped = _mapUserToState(user);
        if (mapped is WebAuthSuccess) {
          unawaited(analyticsService.setUserId(user.uid));
          unawaited(
            analyticsService.logEvent('web_login', {
              'method': 'google',
              'role': user.role,
            }),
          );
        }
        state = mapped;
      },
      failure: (failure) {
        state = WebAuthError(failure.message);
      },
    );
  }

  Future<void> signOut() async {
    final authService = ref.read(webAuthServiceProvider);
    final analyticsService = ref.read(webAnalyticsServiceProvider);
    unawaited(analyticsService.logEvent('logout', {'method': 'google'}));
    unawaited(analyticsService.setUserId(null));
    await authService.signOut();
    if (!ref.mounted) return;
    state = const WebAuthInitial();
  }
}

final webAuthViewModelProvider =
    NotifierProvider<WebAuthViewModel, WebAuthUIState>(WebAuthViewModel.new);

final currentStaffProfileProvider = Provider<WebUserProfile?>((ref) {
  final authState = ref.watch(webAuthViewModelProvider);
  return authState is WebAuthSuccess ? authState.user : null;
});

final currentClubIdProvider = Provider<String>((ref) {
  return ref.watch(currentStaffProfileProvider)?.clubId?.trim() ?? '';
});
