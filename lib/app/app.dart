import '../viewmodels/cloud_state.dart';
import '../viewmodels/event_data_providers.dart';

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
        if (target.path == '/notifications') {
          // Switch shell branches instead of pushing a second shell over Discover.
          router.go(target.path);
        } else {
          router.push(target.path);
        }
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
