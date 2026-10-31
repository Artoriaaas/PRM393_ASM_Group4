import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/auth_redirect.dart';
import '../../models/auth_state.dart';
import '../../screens/auth/auth_screen.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'prototype_state.dart';
import 'prototype_widgets.dart';
import 'event_screens.dart';
import 'registration_screens.dart';
import 'participation_screens.dart';
import 'account_screens.dart';

Widget buildPrototypeApp() => ProviderScope(
  overrides: [
    isUiPrototypeProvider.overrideWithValue(true),
    authServiceProvider.overrideWith((ref) {
      final service = PrototypeAuthService(
        () => ref.read(prototypeProvider).scenario,
      );
      ref.onDispose(service.dispose);
      return service;
    }),
  ],
  child: const PrototypeApp(),
);

final prototypeRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(sessionViewModelProvider, (_, _) => refresh.value++);
  final router = GoRouter(
    initialLocation: '/auth/login',
    refreshListenable: refresh,
    redirect: (context, state) => state.uri.path == '/preview'
        ? null
        : authRedirect(ref.read(sessionViewModelProvider), state.uri, false),
    routes: [
      GoRoute(
        path: '/preview',
        builder: (_, _) => const PrototypeIndexScreen(),
      ),
      for (final auth in [
        ('login', 'login'),
        ('register', 'register'),
        ('verify-email', 'verify'),
        ('forgot-password', 'reset'),
        ('change-email', 'change-email'),
      ])
        GoRoute(
          path: '/auth/${auth.$1}',
          builder: (_, _) => AuthScreen(mode: auth.$2),
        ),
      GoRoute(
        path: '/session',
        builder: (_, _) => const Scaffold(body: AppLoadingState()),
      ),
      GoRoute(path: '/discover', builder: (_, _) => const DemoDiscoverScreen()),
      GoRoute(
        path: '/discover/search',
        builder: (_, s) => DemoDiscoverScreen(
          search: true,
          initialQuery: s.uri.queryParameters['q'] ?? '',
        ),
      ),
      GoRoute(
        path: '/events/:eventId',
        builder: (_, s) =>
            DemoEventDetailScreen(eventId: s.pathParameters['eventId']!),
      ),
      GoRoute(
        path: '/events/:eventId/register',
        builder: (_, _) => const DemoRegistrationForm(),
      ),
      GoRoute(
        path: '/registrations/:registrationId/success',
        builder: (_, _) => const DemoRegistrationSuccess(),
      ),
      GoRoute(path: '/schedule', builder: (_, _) => const DemoScheduleScreen()),
      GoRoute(
        path: '/registrations/:registrationId',
        builder: (_, _) => const DemoRegistrationDetail(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (_, _) => const DemoNotificationsScreen(),
      ),
      GoRoute(path: '/account', builder: (_, _) => const DemoAccountScreen()),
      GoRoute(
        path: '/account/edit',
        builder: (_, _) => const DemoEditProfileScreen(),
      ),
      GoRoute(
        path: '/account/export',
        builder: (_, _) => const DemoExportScreen(),
      ),
      GoRoute(
        path: '/account/firebase-demo',
        builder: (_, _) => const DemoFirebaseScreen(),
      ),
      GoRoute(
        path: '/registrations/:registrationId/scan',
        builder: (_, _) => const DemoScannerScreen(),
      ),
      GoRoute(
        path: '/registrations/:registrationId/check-in',
        builder: (_, _) => const DemoCheckInResultScreen(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class PrototypeApp extends ConsumerWidget {
  const PrototypeApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    title: 'EventHub UI Prototype',
    debugShowCheckedModeBanner: false,
    theme: EventHubTheme.lightTheme,
    routerConfig: ref.watch(prototypeRouterProvider),
  );
}

class PrototypeIndexScreen extends ConsumerWidget {
  const PrototypeIndexScreen({super.key});
  static const screens = [
    ('A01a · Đăng nhập', '/auth/login'),
    ('A01b · Tạo tài khoản', '/auth/register'),
    ('A01c · Kiểm tra email', '/auth/verify-email'),
    ('A01d · Quên mật khẩu', '/auth/forgot-password'),
    ('A02 · Khám phá', '/discover'),
    ('A03 · Kết quả tìm kiếm', '/discover/search'),
    ('A04 · Chi tiết sự kiện', '/events/workshop'),
    ('A04 · Tham gia tự do', '/events/acoustic'),
    ('A05 · Thông tin đăng ký', '/events/workshop/register'),
    ('A06 · Đăng ký thành công', '/registrations/demo/success'),
    ('A07 · Lịch tham gia', '/schedule'),
    ('A08 · Chi tiết đăng ký', '/registrations/demo'),
    ('A09 · Thông báo', '/notifications'),
    ('A10 · Tài khoản', '/account'),
    ('A10 · Chỉnh sửa hồ sơ', '/account/edit'),
    ('A11 · Quét QR', '/registrations/demo/scan'),
    ('A12 · Kết quả điểm danh', '/registrations/demo/check-in'),
    ('L3-01 · Firebase demo UI', '/account/firebase-demo'),
    ('L3-02 · Xuất và upload UI', '/account/export'),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) => DemoPage(
    title: 'Danh sách màn prototype',
    allowScenario: false,
    children: [
      const Text(
        'Chọn màn để review. Nút trạng thái ở góc phải các màn cho xem loading, empty, error và các nhánh khác. Không dùng kết quả này làm bằng chứng Firebase.',
      ),
      AppButton(
        label: 'Đặt lại toàn bộ dữ liệu demo',
        variant: AppButtonVariant.secondary,
        onPressed: () => ref.read(prototypeProvider.notifier).reset(),
      ),
      for (final screen in screens)
        AppButton(
          label: screen.$1,
          variant: AppButtonVariant.secondary,
          onPressed: () async {
            final service =
                ref.read(authServiceProvider) as PrototypeAuthService;
            final vm = ref.read(prototypeProvider.notifier);
            vm.scenario(DemoScenario.normal);
            if (screen.$2.startsWith('/auth/')) {
              service.setSession(
                screen.$2.contains('verify')
                    ? const AuthState.unverified(
                        uid: 'ui-demo',
                        email: 'minhanh@example.com',
                      )
                    : const AuthState.signedOut(),
              );
            } else {
              service.setSession(
                const AuthState.signedIn(
                  uid: 'ui-demo',
                  email: 'minhanh@example.com',
                  displayName: 'Minh Anh',
                ),
              );
              if (screen.$2.startsWith('/registrations') ||
                  screen.$2 == '/schedule' ||
                  screen.$2 == '/account/export') {
                vm.presetRegistration(
                  checkedIn: screen.$2.endsWith('/check-in'),
                );
              }
            }
            await Future<void>.delayed(Duration.zero);
            if (context.mounted) context.push(screen.$2);
          },
        ),
    ],
  );
}
