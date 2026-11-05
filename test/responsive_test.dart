import 'package:eventhub/theme/app_theme.dart';
import 'package:eventhub/widgets/app_button.dart';
import 'package:eventhub/widgets/app_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [360.0, 412.0]) {
    testWidgets('long labels and dialog at $width with large text', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: EventHubTheme.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: AppConfirmationDialog(
              title: 'Bạn có chắc muốn hủy đăng ký sự kiện này?',
              message: 'Chỗ của bạn sẽ được nhường lại cho người khác.',
              confirmLabel: 'Xác nhận hủy đăng ký',
              cancelLabel: 'Giữ lại đăng ký của tôi',
              onConfirm: () {},
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      final label = tester.widget<Text>(find.text('Xác nhận hủy đăng ký'));
      expect(label.maxLines, isNull);
      expect(find.byType(AppButton), findsNWidgets(2));

    });
  }
}
