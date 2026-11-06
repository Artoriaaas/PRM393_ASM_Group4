import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../services/web_firebase_bootstrap.dart';
import 'providers.dart';
import 'router.dart';

class WebFirebaseAppBootstrap extends StatefulWidget {
  const WebFirebaseAppBootstrap({
    super.key,
    this.initializer,
    this.readyChild,
  });

  final Future<bool> Function()? initializer;
  final Widget? readyChild;

  @override
  State<WebFirebaseAppBootstrap> createState() =>
      _WebFirebaseAppBootstrapState();
}

class _WebFirebaseAppBootstrapState extends State<WebFirebaseAppBootstrap> {
  Future<bool> _runInit() =>
      widget.initializer?.call() ?? initializeWebFirebase();

  late Future<bool> _initialization = _runInit();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return widget.readyChild ??
              ProviderScope(
                overrides: [webFirebaseReadyProvider.overrideWithValue(true)],
                child: const EventHubWebApp(),
              );
        }

        return MaterialApp(
          title: 'EventHub Club Leader & Admin',
          debugShowCheckedModeBanner: false,
          theme: EventHubTheme.lightTheme,
          home: Scaffold(
            backgroundColor: AppColors.surfaceSubtle,
            body: SafeArea(
              child: snapshot.connectionState != ConnectionState.done
                  ? const AppLoadingState(
                      message: 'Đang kết nối hệ thống EventHub Web…',
                    )
                  : AppErrorState(
                      title: 'Chưa kết nối được EventHub Web',
                      message:
                          'Kiểm tra kết nối mạng và các biến --dart-define cấu hình Firebase Web của dự án (FIREBASE_WEB_API_KEY, FIREBASE_WEB_APP_ID, FIREBASE_WEB_MESSAGING_SENDER_ID, FIREBASE_WEB_PROJECT_ID), rồi thử lại.',
                      onRetry: () => setState(() {
                        _initialization = _runInit();
                      }),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class EventHubWebApp extends ConsumerWidget {
  const EventHubWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(webRemoteConfigInitProvider);
    final router = ref.watch(webRouterProvider);

    return MaterialApp.router(
      title: 'EventHub Club Leader & Admin',
      debugShowCheckedModeBanner: false,
      theme: EventHubTheme.lightTheme,
      routerConfig: router,
    );
  }
}
