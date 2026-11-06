import 'package:eventhub/app/app.dart';
import 'package:eventhub/app/router.dart';
import 'package:eventhub/app/providers.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub/viewmodels/session_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class UnverifiedSession extends SessionViewModel {
  @override
  AuthState build() =>
      const AuthState.unverified(uid: 'test', email: 'test@example.com');
}

void main() {
  for (final width in [360.0, 412.0]) {
    for (final route in [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/verify-email',
      '/auth/change-email',
    ]) {
      testWidgets('$route renders at $width with 200% text', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final container = ProviderContainer(
          overrides: [
            if (route.contains('verify') || route.contains('change'))
              sessionViewModelProvider.overrideWith(UnverifiedSession.new),
          ],
        );
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(2)),
              child: const EventHubApp(),
            ),
          ),
        );
        container.read(appRouterProvider).go(route);
        await tester.pumpAndSettle();
        if (!route.contains('verify')) {
          await tester.scrollUntilVisible(
            find.text(
              route.contains('change') ? 'Email mới *' : 'Email cá nhân *',
            ),
            100,
            scrollable: find.byType(Scrollable).first,
          );
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
        expect(
          find.byType(TextField),
          route.contains('verify') ? findsNothing : findsWidgets,
        );
      });
    }
  }
}
