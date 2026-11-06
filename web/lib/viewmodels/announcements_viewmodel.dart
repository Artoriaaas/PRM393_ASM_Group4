import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

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
    String? successMessage,
    String? errorMessage,
  }) {
    return AnnouncementsState(
      loadState: loadState ?? this.loadState,
      announcements: announcements ?? this.announcements,
      events: events ?? this.events,
      isPublishing: isPublishing ?? this.isPublishing,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AnnouncementsViewModel extends Notifier<AnnouncementsState> {
  @override
  AnnouncementsState build() {
    state = const AnnouncementsState(loadState: LoadState.loading());
    _initStreams();
    return state;
  }

  void _initStreams() {
    final authState = ref.read(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
    final clubId = user?.clubId ?? '';

    if (clubId.isEmpty) {
      state = state.copyWith(
        loadState: const LoadState.error(
          failure: AppFailure(
            code: 'club_not_found',
            message: 'Không tìm thấy thông tin câu lạc bộ.',
          ),
        ),
      );
      return;
    }

    final clubService = ref.read(clubServiceProvider);

    // Stream Events for dropdown
    final eventsSub = clubService.streamClubEvents(clubId).listen((events) {
      state = state.copyWith(events: events);
    });
    ref.onDispose(eventsSub.cancel);

    // Stream Announcements
    final annSub =
        clubService.streamClubAnnouncements(clubId).listen((announcements) {
      state = state.copyWith(
        loadState: announcements.isEmpty
            ? const LoadState.empty(
                message: 'Chưa có thông báo nào được phát hành.')
            : LoadState.data(data: announcements),
        announcements: announcements,
      );
    }, onError: (err) {
      state = state.copyWith(
        loadState: LoadState.error(
          failure: AppFailure(code: 'stream_error', message: err.toString()),
        ),
      );
    });
    ref.onDispose(annSub.cancel);
  }

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

    final authState = ref.read(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
    final staffUid = user?.uid ?? '';
    final clubId = user?.clubId ?? '';
    final clubName = user?.clubName ?? 'Câu lạc bộ';

    final announcement = Announcement(
      id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      body: body.trim(),
      scope: scope,
      clubId: clubId,
      clubName: clubName,
      eventId: eventId,
      authorUid: staffUid,
      authorRole: 'staff',
      createdAt: DateTime.now(),
    );

    final clubService = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);

    final res = await clubService.publishAnnouncement(announcement);

    res.when(
      success: (id) {
        analytics.logEvent('announcement_published', {
          'id': id,
          'scope': scope,
        });
        state = state.copyWith(
          isPublishing: false,
          successMessage: 'Đã phát hành thông báo thành công!',
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isPublishing: false,
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
