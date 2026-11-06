import 'package:eventhub_core/eventhub_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: EventHubTheme.lightTheme,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppButton tests', () {
    testWidgets('renders primary button and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppButton(label: 'Đăng ký ngay', onPressed: () => tapped = true),
        ),
      );

      expect(find.text('Đăng ký ngay'), findsOneWidget);
      await tester.tap(find.text('Đăng ký ngay'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets(
      'shows loading indicator when isLoading is true and ignores tap',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          buildTestableWidget(
            AppButton(
              label: 'Đang xử lý',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Đang xử lý'), findsNothing);

        await tester.tap(find.byType(CircularProgressIndicator));
        await tester.pump();

        expect(tapped, isFalse);
      },
    );

    testWidgets('disabled button does not trigger callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppButton(
            label: 'Nút khóa',
            isDisabled: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('Nút khóa'));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('has minimum touch target >= 48dp', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          AppButton(label: 'Nút đo kích thước', onPressed: () {}),
        ),
      );

      final size = tester.getSize(find.byType(AppButton));
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));
    });
  });
}
