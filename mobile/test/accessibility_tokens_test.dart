import 'dart:math';

import 'package:eventhub/theme/app_theme.dart';
import 'package:eventhub/widgets/app_choice_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'enabled input hints meet normal text contrast and body is at least 14sp',
    () {
      final theme = EventHubTheme.lightTheme;
      final foreground = theme.inputDecorationTheme.hintStyle!.color!
          .computeLuminance();
      final background = theme.inputDecorationTheme.fillColor!
          .computeLuminance();
      final ratio =
          (max(foreground, background) + .05) /
          (min(foreground, background) + .05);
      expect(ratio, greaterThanOrEqualTo(4.5));
      for (final style in [
        theme.textTheme.bodySmall,
        theme.textTheme.bodyMedium,
        theme.textTheme.bodyLarge,
      ]) {
        expect(style!.fontSize, greaterThanOrEqualTo(14));
      }
    },
  );
  for (final width in [360.0, 412.0]) {
    testWidgets('selection chips have a 48dp target at $width', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: EventHubTheme.lightTheme,
          home: Scaffold(
            body: Wrap(
              children: [
                AppChoiceChip(
                  label: const Text('Đã kết thúc'),
                  selected: false,
                  onSelected: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      final size = tester.getSize(find.byType(AppChoiceChip));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(tester.takeException(), isNull);
    });
  }
}
