import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import 'package:eventhub_core/services/firebase/club_assignments.dart';

import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

final clubAssignmentsProvider =
    StreamProvider.autoDispose<List<ClubAssignment>>((ref) {
      if (ref.watch(currentStaffProfileProvider)?.isAdmin != true)
        return Stream.value(const []);
      return ref.watch(clubAssignmentServiceProvider).watchAssignments();
    });
final assignmentActionProvider =
    NotifierProvider.autoDispose<AssignmentAction, AsyncValue<void>>(
      AssignmentAction.new,
    );

class AssignmentAction extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);
  Future<Result<void>> assign(String email, Club club) => _run(
    () => ref
        .read(clubAssignmentServiceProvider)
        .assign(email: email, club: club),
  );
  Future<Result<void>> activate(ClubAssignment assignment) =>
      _run(() => ref.read(clubAssignmentServiceProvider).activate(assignment));
  Future<Result<void>> revoke(ClubAssignment assignment) =>
      _run(() => ref.read(clubAssignmentServiceProvider).revoke(assignment));
  Future<Result<void>> _run(Future<Result<void>> Function() action) async {
    if (state.isLoading)
      return const Failure(AppFailure(code: 'busy', message: 'Đang xử lý.'));
    state = const AsyncLoading();
    Result<void> result;
    try {
      result = await action();
    } catch (_) {
      result = const Failure(
        AppFailure(
          code: 'assignment_failed',
          message: 'Chưa hoàn tất thao tác. Kiểm tra kết nối rồi thử lại.',
          isRetryable: true,
        ),
      );
    }
    if (ref.mounted)
      state = result.isSuccess
          ? const AsyncData(null)
          : AsyncError(result.failureOrNull!.message, StackTrace.current);
    return result;
  }
}
