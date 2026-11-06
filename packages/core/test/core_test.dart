import 'package:eventhub_core/eventhub_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventHub Core Package', () {
    test('Design Tokens match Lab 2 spec', () {
      expect(AppColors.primary, const Color(0xFFC74316));
      expect(AppColors.surfaceSubtle, const Color(0xFFF8F9FB));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.border, const Color(0xFFE3E7ED));
      expect(AppColors.textPrimary, const Color(0xFF2B3445));
      expect(AppColors.textSecondary, const Color(0xFF5F6B7A));

      expect(AppSpacing.s4, 4.0);
      expect(AppSpacing.s8, 8.0);
      expect(AppSpacing.s12, 12.0);
      expect(AppSpacing.s16, 16.0);
      expect(AppSpacing.s24, 24.0);
      expect(AppRadius.r8, 8.0);
      expect(AppRadius.r12, 12.0);
      expect(AppRadius.r16, 16.0);
      expect(AppRadius.borderR8, const BorderRadius.all(Radius.circular(8.0)));
    });

    test('Club & Registration & Announcement models instantiate properly', () {
      const club = Club(
        id: 'club_it',
        name: 'IT Club',
        shortName: 'ITC',
        description: 'Technology Club',
      );
      expect(club.isActive, isTrue);

      const reg = Registration(
        id: 'user1_ev1',
        eventId: 'ev1',
        status: 'pending',
        generation: 1,
        participant: Participant(
          name: 'Nguyen Van A',
          email: 'a@fpt.edu.vn',
          group: 'student',
          cohort: 'K17',
        ),
      );
      expect(reg.isPending, isTrue);
      expect(reg.isApproved, isFalse);

      final notif = Announcement.fromJson('ann1', {
        'title': 'Thong bao su kien',
        'body': 'Noi dung chi tiet',
        'scope': 'club',
        'clubId': 'club_it',
        'clubName': 'IT Club',
      });
      expect(notif.title, 'Thong bao su kien');
      expect(notif.clubId, 'club_it');
    });

    testWidgets('AppButton renders with tokens', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: EventHubTheme.lightTheme,
          home: Scaffold(
            body: AppButton(
              label: 'Xác nhận',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Xác nhận'), findsOneWidget);
      await tester.tap(find.text('Xác nhận'));
      expect(pressed, isTrue);
    });
  });
}
