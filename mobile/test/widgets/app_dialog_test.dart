import 'package:eventhub/theme/theme.dart';
import 'package:eventhub/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: EventHubTheme.lightTheme,
      home: Scaffold(body: child),
    );
  }

  group('AppConfirmationDialog tests', () {
    testWidgets('triggers onConfirm and onCancel correctly', (tester) async {
      bool confirmed = false;
      bool cancelled = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppConfirmationDialog(
            title: 'Hủy đăng ký',
            message: 'Bạn có chắc muốn hủy không?',
            confirmLabel: 'Đồng ý',
            cancelLabel: 'Bỏ qua',
            onConfirm: () => confirmed = true,
            onCancel: () => cancelled = true,
          ),
        ),
      );

      expect(find.text('Hủy đăng ký'), findsOneWidget);
      expect(find.text('Bạn có chắc muốn hủy không?'), findsOneWidget);

      await tester.tap(find.text('Bỏ qua'));
      await tester.pump();
      expect(cancelled, isTrue);

      await tester.tap(find.text('Đồng ý'));
      await tester.pump();
      expect(confirmed, isTrue);
    });

    testWidgets('disables actions when isPending is true', (tester) async {
      bool confirmed = false;

      await tester.pumpWidget(
        buildTestableWidget(
          AppConfirmationDialog(
            title: 'Đang xử lý',
            message: 'Vui lòng đợi giây lát...',
            confirmLabel: 'Đồng ý',
            isPending: true,
            onConfirm: () => confirmed = true,
          ),
        ),
      );

      // In pending state, confirm button shows progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(CircularProgressIndicator));
      await tester.pump();

      expect(confirmed, isFalse);
    });
  });
}
