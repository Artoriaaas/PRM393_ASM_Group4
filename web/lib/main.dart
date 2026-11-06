import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'app/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: EventHubWebApp(),
    ),
  );
}

class EventHubWebApp extends ConsumerWidget {
  const EventHubWebApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(webRouterProvider);

    return MaterialApp.router(
      title: 'EventHub Club Leader & Admin',
      debugShowCheckedModeBanner: false,
      theme: EventHubTheme.lightTheme,
      routerConfig: router,
    );
  }
}
