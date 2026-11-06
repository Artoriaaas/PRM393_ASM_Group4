import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase/firebase_bootstrap.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'providers.dart';
import 'app.dart';

class FirebaseAppBootstrap extends StatefulWidget {
  const FirebaseAppBootstrap({super.key, this.initializer, this.readyChild});
  final Future<bool> Function()? initializer;
  final Widget? readyChild;
  @override
  State<FirebaseAppBootstrap> createState() => _FirebaseBootstrapState();
}

class _FirebaseBootstrapState extends State<FirebaseAppBootstrap> {
  Future<bool> initialize() =>
      widget.initializer?.call() ?? initializeFirebase();
  late Future<bool> initialization = initialize();
  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: initialization,
    builder: (context, snapshot) {
      if (snapshot.data == true) {
        return widget.readyChild ?? const _ConfiguredApp();
      }
      return MaterialApp(
        theme: EventHubTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: snapshot.connectionState != ConnectionState.done
                ? const AppLoadingState(message: 'Đang kết nối EventHub…')
                : AppErrorState(
                    title: 'Chưa kết nối được EventHub',
                    message: 'Kiểm tra kết nối mạng và cấu hình Firebase của nhóm, rồi thử lại.',
                    onRetry: () => setState(() {
                      initialization = initialize();
                    }),
                  ),
          ),
        ),
      );
    },
  );
}

class _ConfiguredApp extends StatelessWidget {
  const _ConfiguredApp();
  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [firebaseReadyProvider.overrideWithValue(true)],
    child: const EventHubApp(),
  );
}
