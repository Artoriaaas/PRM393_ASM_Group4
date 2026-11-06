import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

const Object _unset = Object();

class AnnouncementsState {
  const AnnouncementsState({
    required this.loadState,
    this.announcements = const [],
    this.events = const [],
    this.isPublishing = false,
    this.successMessage,
    this.errorMessage,
  });

  final LoadState<List<Announcement>> loadState;
  final List<Announcement> announcements;
  final List<Event> events;
  final bool isPublishing;
  final String? successMessage;
  final String? errorMessage;

  AnnouncementsState copyWith({
    LoadState<List<Announcement>>? loadState,
    List<Announcement>? announcements,
    List<Event>? events,
    bool? isPublishing,
    Object? successMessage = _unset,
    Object? errorMessage = _unset,
  }) {
    return AnnouncementsState(
      loadState: loadState ?? this.loadState,
      announcements: announcements ?? this.announcements,
      events: events ?? this.events,
      isPublishing: isPublishing ?? this.isPublishing,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class AnnouncementsViewModel extends Notifier<AnnouncementsState> {
  @override
  AnnouncementsState build() {
    final clubId = ref.watch(currentClubIdProvider);
    if (clubId.isEmpty) {
      return const AnnouncementsState(
        loadState: LoadState.error(
          failure: AppFailure(
            code: 'club_not_found',
            message: 'Không tìm thấy thông tin câu lạc bộ được phân công.',
          ),
        ),
      );
    }

    final clubService = ref.watch(clubServiceProvider);

    final eventsSub = clubService.streamClubEvents(clubId).listen(
      (events) {
        if (!ref.mounted) return;
        state = state.copyWith(events: events);
      },
      onError: (_) {},
    );
    ref.onDispose(eventsSub.cancel);

    final annSub = clubService.streamClubAnnouncements(clubId).listen(
      (announcements) {
        if (!ref.mounted) return;
        state = state.copyWith(
          loadState: announcements.isEmpty
              ? const LoadState.empty(
                  message: 'Chưa có thông báo nào được phát hành.',
                )
              : LoadState.data(data: announcements),
          announcements: announcements,
        );
      },
      onError: (Object err) {
        if (!ref.mounted) return;
        state = state.copyWith(
          loadState: LoadState.error(
            failure: AppFailure(
              code: 'stream_error',
              message: 'Không thể tải lịch sử thông báo: $err',
              isRetryable: true,
            ),
          ),
        );
      },
    );
    ref.onDispose(annSub.cancel);

    return const AnnouncementsState(loadState: LoadState.loading());
  }

  void retry() => ref.invalidateSelf();

  Future<Result<String>> publish({
    required String title,
    required String body,
    required String scope,
    String? eventId,
  }) async {
    state = state.copyWith(
      isPublishing: true,
      successMessage: null,
      errorMessage: null,
    );

    final user = ref.read(currentStaffProfileProvider);
    final staffUid = user?.uid ?? '';
    final clubId = user?.clubId ?? '';
    final clubName =
        ref.read(activeClubProvider(clubId)).asData?.value?.name ??
        user?.clubName ??
        'Câu lạc bộ';

    final announcement = Announcement(
      id: '',
      title: title.trim(),
      body: body.trim(),
      scope: scope,
      clubId: clubId,
      clubName: clubName,
      eventId: scope == 'event' ? eventId : null,
      authorUid: staffUid,
      authorRole: user?.role ?? 'staff',
      createdAt: DateTime.now(),
    );

    final clubService = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);

    final res = await clubService.publishAnnouncement(announcement);
    if (!ref.mounted) return res;

    res.when(
      success: (id) {
        unawaited(
          analytics.logEvent('announcement_published', {
            'announcement_id': id,
            'scope': scope,
          }),
        );
        state = state.copyWith(
          isPublishing: false,
          successMessage: 'Đã phát hành thông báo thành công!',
          errorMessage: null,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isPublishing: false,
          successMessage: null,
          errorMessage: failure.message,
        );
      },
    );

    return res;
  }
}

final announcementsViewModelProvider =
    NotifierProvider<AnnouncementsViewModel, AnnouncementsState>(
  AnnouncementsViewModel.new,
);
