import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

const Object _unset = Object();

class QrCheckinState {
  const QrCheckinState({
    required this.eventId,
    this.event,
    this.eventLoaded = false,
    this.session,
    this.qrToken,
    this.currentQrHash,
    this.approvedRegistrations = const [],
    this.isLoading = false,
    this.isToggling = false,
    this.isGeneratingQr = false,
    this.errorMessage,
  });

  final String eventId;
  final Event? event;
  final bool eventLoaded;
  final CheckinSession? session;
  final String? qrToken;
  final String? currentQrHash;
  final List<Registration> approvedRegistrations;
  final bool isLoading;
  final bool isToggling;
  final bool isGeneratingQr;
  final String? errorMessage;

  bool get isSessionOpen => session?.open ?? false;
  int get totalApproved => approvedRegistrations.length;
  int get checkedInCount =>
      approvedRegistrations.where((r) => r.isCheckedIn).length;

  bool get isEligibleForQrCheckin =>
      event != null &&
      event!.status == 'published' &&
      event!.mode == 'required';

  QrCheckinState copyWith({
    String? eventId,
    Object? event = _unset,
    bool? eventLoaded,
    Object? session = _unset,
    Object? qrToken = _unset,
    Object? currentQrHash = _unset,
    List<Registration>? approvedRegistrations,
    bool? isLoading,
    bool? isToggling,
    bool? isGeneratingQr,
    Object? errorMessage = _unset,
  }) {
    return QrCheckinState(
      eventId: eventId ?? this.eventId,
      event: identical(event, _unset) ? this.event : event as Event?,
      eventLoaded: eventLoaded ?? this.eventLoaded,
      session: identical(session, _unset)
          ? this.session
          : session as CheckinSession?,
      qrToken: identical(qrToken, _unset) ? this.qrToken : qrToken as String?,
      currentQrHash: identical(currentQrHash, _unset)
          ? this.currentQrHash
          : currentQrHash as String?,
      approvedRegistrations:
          approvedRegistrations ?? this.approvedRegistrations,
      isLoading: isLoading ?? this.isLoading,
      isToggling: isToggling ?? this.isToggling,
      isGeneratingQr: isGeneratingQr ?? this.isGeneratingQr,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class QrCheckinViewModel extends Notifier<QrCheckinState> {
  QrCheckinViewModel(this.eventId);
  final String eventId;
  bool _initialQrRequested = false;

  @override
  QrCheckinState build() {
    final clubId = ref.watch(currentClubIdProvider);
    _initialQrRequested = false;

    if (clubId.isEmpty || eventId.isEmpty) {
      return QrCheckinState(
        eventId: eventId,
        eventLoaded: true,
        isLoading: false,
        errorMessage: 'Không tìm thấy thông tin sự kiện hoặc câu lạc bộ.',
      );
    }

    final clubService = ref.watch(clubServiceProvider);

    final eventSub = clubService.streamEvent(eventId).listen(
      (ev) {
        if (!ref.mounted) return;
        final belongsToClub = ev == null || ev.clubId == clubId;
        final validEvent = belongsToClub ? ev : null;
        state = state.copyWith(
          event: validEvent,
          eventLoaded: true,
          isLoading: false,
        );
        if (validEvent != null &&
            validEvent.status == 'published' &&
            validEvent.mode == 'required' &&
            !_initialQrRequested) {
          _initialQrRequested = true;
          unawaited(generateQr());
        }
      },
      onError: (Object err) {
        if (!ref.mounted) return;
        state = state.copyWith(
          eventLoaded: true,
          isLoading: false,
          errorMessage: 'Không thể tải thông tin sự kiện: $err',
        );
      },
    );
    ref.onDispose(eventSub.cancel);

    final sessionSub = clubService.streamCheckinSession(eventId).listen(
      (session) {
        if (!ref.mounted) return;
        state = state.copyWith(session: session, isLoading: false);
      },
      onError: (Object err) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Lỗi đồng bộ phiên điểm danh: $err',
        );
      },
    );
    ref.onDispose(sessionSub.cancel);

    final regsSub = clubService
        .streamEventRegistrations(eventId, clubId: clubId)
        .listen(
      (regs) {
        if (!ref.mounted) return;
        final approved = regs.where((r) => r.isApproved).toList();
        state = state.copyWith(approvedRegistrations: approved);
      },
      onError: (Object err) {
        if (!ref.mounted) return;
        state = state.copyWith(
          errorMessage: 'Lỗi đồng bộ danh sách điểm danh: $err',
        );
      },
    );
    ref.onDispose(regsSub.cancel);

    return QrCheckinState(eventId: eventId, isLoading: true);
  }

  void retry() => ref.invalidateSelf();

  Future<void> toggleSession(bool open) async {
    if (!state.isEligibleForQrCheckin) {
      state = state.copyWith(
        errorMessage:
            'Chỉ mở điểm danh QR cho sự kiện Yêu cầu đăng ký đang Công bố.',
      );
      return;
    }

    state = state.copyWith(isToggling: true, errorMessage: null);
    final user = ref.read(currentStaffProfileProvider);
    final staffUid = user?.uid ?? '';
    final clubId = user?.clubId ?? '';

    final clubService = ref.read(clubServiceProvider);
    final analytics = ref.read(webAnalyticsServiceProvider);

    final res = await clubService.toggleCheckinSession(
      eventId: state.eventId,
      clubId: clubId,
      open: open,
      staffUid: staffUid,
    );
    if (!ref.mounted) return;

    res.when(
      success: (_) {
        unawaited(
          analytics.logEvent('qr_session_toggled', {
            'event_id': state.eventId,
            'open': open ? 1 : 0,
          }),
        );
        state = state.copyWith(
          isToggling: false,
          session: CheckinSession(
            eventId: state.eventId,
            clubId: clubId,
            open: open,
            updatedBy: staffUid,
            updatedAt: DateTime.now(),
          ),
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isToggling: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  Future<void> generateQr() async {
    if (state.eventLoaded && !state.isEligibleForQrCheckin) {
      return;
    }
    state = state.copyWith(isGeneratingQr: true, errorMessage: null);
    final user = ref.read(currentStaffProfileProvider);
    final staffUid = user?.uid ?? '';
    final clubId = user?.clubId ?? '';

    final clubService = ref.read(clubServiceProvider);
    final res = await clubService.generateAndRotateQrToken(
      eventId: state.eventId,
      clubId: clubId,
      staffUid: staffUid,
      previousQrHash: state.currentQrHash,
    );
    if (!ref.mounted) return;

    res.when(
      success: (bundle) {
        state = state.copyWith(
          isGeneratingQr: false,
          qrToken: bundle.rawToken,
          currentQrHash: bundle.qrHash,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isGeneratingQr: false,
          errorMessage: failure.message,
        );
      },
    );
  }
}

final qrCheckinViewModelProvider = NotifierProvider.autoDispose
    .family<QrCheckinViewModel, QrCheckinState, String>(
  (arg) => QrCheckinViewModel(arg),
);
