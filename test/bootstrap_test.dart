import 'dart:async';

import 'package:eventhub/app/bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'startup waits for real initialization and retries after failure',
    (tester) async {
      final first = Completer<bool>();
      var attempts = 0;
      await tester.pumpWidget(
        FirebaseAppBootstrap(
          initializer: () {
            attempts++;
            return attempts == 1 ? first.future : Future.value(true);
          },
          readyChild: const MaterialApp(home: Text('ready')),
        ),
      );
      expect(find.text('Đang kết nối EventHub…'), findsOneWidget);
      expect(find.text('ready'), findsNothing);
      first.complete(false);
      await tester.pumpAndSettle();
      expect(find.text('Chưa kết nối được EventHub'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.text('ready'), findsOneWidget);
      expect(attempts, 2);
    },
  );
}
