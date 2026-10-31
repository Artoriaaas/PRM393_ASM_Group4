import 'cloud_providers.dart';
import 'event_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import 'router.dart';

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

/// Root application widget for EventHub
class EventHubApp extends ConsumerWidget {
  const EventHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    ref.watch(cloudInitializationProvider);
    ref.listen(pushTargetsProvider, (_, next) {
      final target = next.asData?.value;
      final uid = ref.read(signedInUidProvider);
      if (target == null ||
          uid == null ||
          (target.uid != null && target.uid != uid)) {
        return;
      }
      if (target.opened) {
        router.push(target.path);
      } else {
        _messengerKey.currentState?.showSnackBar(
          SnackBar(
            content: const Text('Bạn có thông báo EventHub mới.'),
            action: SnackBarAction(
              label: 'Xem',
              onPressed: () => router.go('/notifications'),
            ),
          ),
        );
      }
    });

    return MaterialApp.router(
      title: 'EventHub',
      scaffoldMessengerKey: _messengerKey,
      debugShowCheckedModeBanner: false,
      theme: EventHubTheme.lightTheme,
      routerConfig: router,
    );
  }
}
