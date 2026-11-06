import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../app/providers.dart';
import 'web_auth_viewmodel.dart';

class QrCheckinState {
  const QrCheckinState({
    required this.eventId,
    this.session,
    this.qrToken,
    this.approvedRegistrations = const [],
    this.isLoading = false,
    this.isToggling = false,
    this.isGeneratingQr = false,
    this.errorMessage,
  });

  final String eventId;
  final CheckinSession? session;
  final String? qrToken;
  final List<Registration> approvedRegistrations;
  final bool isLoading;
  final bool isToggling;
  final bool isGeneratingQr;
  final String? errorMessage;

  bool get isSessionOpen => session?.open ?? false;
  int get totalApproved => approvedRegistrations.length;
  int get checkedInCount =>
      approvedRegistrations.where((r) => r.isCheckedIn).length;

  QrCheckinState copyWith({
    String? eventId,
    CheckinSession? session,
    String? qrToken,
    List<Registration>? approvedRegistrations,
    bool? isLoading,
    bool? isToggling,
    bool? isGeneratingQr,
    String? errorMessage,
  }) {
    return QrCheckinState(
      eventId: eventId ?? this.eventId,
      session: session ?? this.session,
      qrToken: qrToken ?? this.qrToken,
      approvedRegistrations:
          approvedRegistrations ?? this.approvedRegistrations,
      isLoading: isLoading ?? this.isLoading,
      isToggling: isToggling ?? this.isToggling,
      isGeneratingQr: isGeneratingQr ?? this.isGeneratingQr,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class QrCheckinViewModel extends Notifier<QrCheckinState> {
  QrCheckinViewModel(this.eventId);
  final String eventId;

  @override
  QrCheckinState build() {
    state = QrCheckinState(eventId: eventId, isLoading: true);
    _initStreams(eventId);
    return state;
  }

  void _initStreams(String id) {
    final clubService = ref.read(clubServiceProvider);

    // Stream Session
    final sessionSub =
        clubService.streamCheckinSession(id).listen((session) {
      state = state.copyWith(session: session, isLoading: false);
    });
    ref.onDispose(sessionSub.cancel);

    // Stream Registrations
    final regsSub =
        clubService.streamEventRegistrations(id).listen((regs) {
      final approved = regs.where((r) => r.isApproved).toList();
      state = state.copyWith(approvedRegistrations: approved);
    });
    ref.onDispose(regsSub.cancel);

    // Generate initial QR code token
    generateQr();
  }

  Future<void> toggleSession(bool open) async {
    state = state.copyWith(isToggling: true, errorMessage: null);
    final authState = ref.read(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
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

    res.when(
      success: (_) {
        analytics.logEvent(
          'qr_session_toggled',
          {'eventId': state.eventId, 'open': open},
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
    state = state.copyWith(isGeneratingQr: true, errorMessage: null);
    final authState = ref.read(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
    final staffUid = user?.uid ?? '';
    final clubId = user?.clubId ?? '';

    final clubService = ref.read(clubServiceProvider);
    final res = await clubService.generateAndRotateQrToken(
      eventId: state.eventId,
      clubId: clubId,
      staffUid: staffUid,
    );

    res.when(
      success: (token) {
        state = state.copyWith(
          isGeneratingQr: false,
          qrToken: token,
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

final qrCheckinViewModelProvider =
    NotifierProvider.autoDispose.family<QrCheckinViewModel, QrCheckinState, String>(
  (arg) => QrCheckinViewModel(arg),
);
