import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_core/services/firebase/club_assignments.dart';
import 'package:eventhub_web/app/providers.dart';
import 'package:eventhub_web/screens/users/club_assignments_panel.dart';
import 'package:eventhub_web/viewmodels/club_assignments_viewmodel.dart';

class Assignments implements IClubAssignmentService {
  String? email;
  Club? club;
  int calls = 0;
  bool fail = false;
  bool throwError = false;
  @override
  Stream<List<ClubAssignment>> watchAssignments() => Stream.value([]);
  @override
  Future<Result<void>> assign({
    required String email,
    required Club club,
  }) async {
    if (throwError) throw StateError("offline");
    calls++;
    this.email = email;
    this.club = club;
    if (fail)
      return const Failure(AppFailure(code: 'offline', message: 'Mất kết nối'));
    return const Success(null);
  }

  @override
  Future<Result<void>> activate(ClubAssignment assignment) async =>
      const Success(null);
  @override
  Future<Result<void>> revoke(ClubAssignment assignment) async =>
      const Success(null);
}

void main() {
  const club = Club(id: 'club-it', name: 'CLB Công nghệ');
  test('normalizes email and rejects invalid input', () {
    expect(
      FirestoreClubAssignmentService.normalizeEmail('  Leader@Gmail.com '),
      'leader@gmail.com',
    );
    expect(
      FirestoreClubAssignmentService.validEmail('leader@gmail.com'),
      isTrue,
    );
    for (final bad in ['', 'leader', 'a/b@gmail.com', 'a @gmail.com']) {
      expect(FirestoreClubAssignmentService.validEmail(bad), isFalse);
    }
  });
  testWidgets(
    'assignment needs explicit club selection; errors preserve entered email',
    (tester) async {
      final service = Assignments()..fail = true;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [clubAssignmentServiceProvider.overrideWithValue(service)],
          child: const MaterialApp(
            home: Scaffold(body: AssignmentDialog(clubs: [club])),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'leader@gmail.com');
      await tester.tap(find.text('Lưu phân công'));
      await tester.pumpAndSettle();
      expect(service.calls, 0);
      expect(find.text('Vui lòng chọn CLB.'), findsOneWidget);
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CLB Công nghệ').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lưu phân công'));
      await tester.pumpAndSettle();
      expect(service.calls, 1);
      expect(service.email, 'leader@gmail.com');
      expect(service.club?.id, club.id);
      expect(find.text('Mất kết nối'), findsOneWidget);
      expect(find.text('leader@gmail.com'), findsOneWidget);
    },
  );
  testWidgets('no active clubs explains next step and blocks saving', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: AssignmentDialog(clubs: [])),
        ),
      ),
    );
    expect(find.textContaining('Chưa có CLB trống'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Lưu phân công'),
          )
          .onPressed,
      isNull,
    );
  });
  test(
    'viewmodel converts service exceptions to recoverable failure',
    () async {
      final service = Assignments()..throwError = true;
      final container = ProviderContainer(
        overrides: [clubAssignmentServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      final sub = container.listen(assignmentActionProvider, (_, __) {});
      addTearDown(sub.close);
      expect(
        (await container
                .read(assignmentActionProvider.notifier)
                .assign('leader@gmail.com', club))
            .isSuccess,
        isFalse,
      );
      expect(container.read(assignmentActionProvider).isLoading, isFalse);
    },
  );
}
