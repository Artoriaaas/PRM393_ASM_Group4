import 'package:eventhub/app/providers.dart';
import 'package:eventhub/dev/prototype/prototype_app.dart';
import 'package:eventhub/dev/prototype/prototype_state.dart';
import 'package:eventhub/models/auth_state.dart';
import 'package:eventhub/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('demo preserves history, blocks duplicate registration and check-in without registration', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final vm = c.read(prototypeProvider.notifier);
    expect(await vm.act('checkin'), false);
    expect(
      await vm.act('register', participant: const DemoParticipant()),
      true,
    );
    expect(
      await vm.act('register', participant: const DemoParticipant()),
      true,
    );
    expect(await vm.act('checkin'), true);
    expect(await vm.act('cancel'), false);
    vm.reset();
    vm.presetRegistration();
    expect(await vm.act('cancel'), true);
    expect(c.read(prototypeProvider).cancelled, true);
    expect(c.read(prototypeProvider).registered, true);
    expect(await vm.act('checkin'), false);
  });
  test('unknown mutation requires recovery and guest needs no K', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final vm = c.read(prototypeProvider.notifier);
    expect(
      vm.validate(const DemoParticipant(student: false, school: '')),
      isEmpty,
    );
    expect(vm.validate(const DemoParticipant(school: '')), contains('school'));
    vm.scenario(DemoScenario.unknown);
    expect(
      await vm.act('register', participant: const DemoParticipant()),
      false,
    );
    expect(c.read(prototypeProvider).registered, false);
    expect(await vm.act('register', recover: true), true);
  });
  for (final width in [360.0, 412.0]) {
    testWidgets('all prototype routes fit $width with large text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(buildPrototypeApp());
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(
        tester.element(find.byType(PrototypeApp)),
      );
      final service = c.read(authServiceProvider) as PrototypeAuthService;
      for (final route in PrototypeIndexScreen.screens) {
        service.setSession(
          route.$2.contains('/auth/')
              ? route.$2.contains('verify')
                    ? const AuthState.unverified(
                        uid: 'demo',
                        email: 'demo@example.com',
                      )
                    : const AuthState.signedOut()
              : const AuthState.signedIn(
                  uid: 'demo',
                  email: 'demo@example.com',
                ),
        );
        c
            .read(prototypeProvider.notifier)
            .presetRegistration(checkedIn: route.$2.endsWith('check-in'));
        await tester.pump();
        c.read(prototypeRouterProvider).go(route.$2);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: route.$1);
        // Scroll lower portions into view to catch overflow in lazily built forms.
        final lists = find.byType(ListView);
        if (lists.evaluate().isNotEmpty) {
          await tester.drag(lists.first, const Offset(0, -550));
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${route.$1} scrolled',
          );
        }
      }
    });
  }
  testWidgets('F1 registration routes to confirmation with form validation', (
    tester,
  ) async {
    await tester.pumpWidget(buildPrototypeApp());
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(
      tester.element(find.byType(PrototypeApp)),
    );
    (c.read(authServiceProvider) as PrototypeAuthService).setSession(
      const AuthState.signedIn(uid: 'demo', email: 'demo@example.com'),
    );
    await tester.pump();
    c.read(prototypeRouterProvider).go('/events/workshop/register');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Xác nhận đăng ký'));
    await tester.pumpAndSettle();
    expect(c.read(prototypeProvider).registered, false);
    await tester.scrollUntilVisible(
      find.text('Khóa K *'),
      120,
      scrollable: find
          .descendant(
            of: find.byType(ListView).first,
            matching: find.byType(Scrollable),
          )
          .first,
    );
    final field = find.byType(TextFormField).last;
    await tester.enterText(field, 'K18');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppButton, 'Xác nhận đăng ký'));
    await tester.pumpAndSettle();
    expect(c.read(prototypeProvider).registered, true);
    expect(find.text('Đăng ký thành công'), findsOneWidget);
  });
}
