import 'package:eventhub_core/eventhub_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      theme: EventHubTheme.lightTheme,
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }

  group('AppTextField tests', () {
    testWidgets('renders label, hint and enters text', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestableWidget(
          AppTextField(
            controller: controller,
            labelText: 'Email sinh viên',
            hintText: 'user@fpt.edu.vn',
          ),
        ),
      );

      expect(find.text('Email sinh viên'), findsOneWidget);
      expect(find.text('user@fpt.edu.vn'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'test@fpt.edu.vn');
      await tester.pump();

      expect(controller.text, 'test@fpt.edu.vn');
    });

    testWidgets('toggles obscureText visibility on icon tap', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppTextField(labelText: 'Mật khẩu', obscureText: true),
        ),
      );

      // Initially obscure icon is visibility_outlined
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        isTrue,
      );

      // Tap toggle visibility
      expect(tester.getSize(find.bySemanticsLabel('Hiện mật khẩu')).width, 48);
      await tester.tap(find.bySemanticsLabel('Hiện mật khẩu'));
      await tester.pump();

      // Icon changes to visibility_off_outlined
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('displays error text when provided', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const AppTextField(
            labelText: 'Số điện thoại',
            errorText: 'Số điện thoại không hợp lệ',
          ),
        ),
      );

      expect(find.text('Số điện thoại không hợp lệ'), findsOneWidget);
    });
  });
}
