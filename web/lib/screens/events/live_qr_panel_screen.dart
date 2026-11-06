import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/qr_checkin_viewmodel.dart';
import '../../viewmodels/club_events_viewmodel.dart';

class LiveQrPanelScreen extends ConsumerWidget {
  const LiveQrPanelScreen({
    super.key,
    required this.eventId,
  });

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrState = ref.watch(qrCheckinViewModelProvider(eventId));
    final eventsState = ref.watch(clubEventsViewModelProvider);
    final event = eventsState.allEvents
        .where((e) => e.id == eventId)
        .firstOrNull;

    final isSessionOpen = qrState.isSessionOpen;
    final totalApproved = qrState.totalApproved;
    final checkedInCount = qrState.checkedInCount;

    return Scaffold(
      backgroundColor: AppColors.surfaceSubtle,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation & Breadcrumb
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Quay lại danh sách sự kiện',
                  onPressed: () => context.go('/events'),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Điểm danh QR Trực tiếp',
                            style: AppTypography.textTheme.headlineMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          AppStatusBadge(
                            label: isSessionOpen
                                ? 'Phiên đang mở'
                                : 'Phiên đang đóng',
                            variant: isSessionOpen
                                ? AppBadgeVariant.success
                                : AppBadgeVariant.error,
                            icon: Icon(
                              isSessionOpen ? Icons.sensors : Icons.sensors_off,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        event?.title ?? 'Sự kiện #$eventId',
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s24),

            if (qrState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: AppRadius.borderR8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 20),
                    const SizedBox(width: AppSpacing.s8),
                    Expanded(
                      child: Text(
                        qrState.errorMessage!,
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
            ],

            // 2-Column Responsive Layout
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 950;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column: Presentation Stage (QR Code)
                      SizedBox(
                        width: 440,
                        child: _buildQrPresentationStage(
                          context,
                          ref,
                          event,
                          qrState,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s24),
                      // Right Column: Realtime Attendance Table
                      Expanded(
                        child: _buildRealtimeAttendancePanel(
                          context,
                          qrState,
                          totalApproved,
                          checkedInCount,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildQrPresentationStage(
                        context,
                        ref,
                        event,
                        qrState,
                      ),
                      const SizedBox(height: AppSpacing.s24),
                      _buildRealtimeAttendancePanel(
                        context,
                        qrState,
                        totalApproved,
                        checkedInCount,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrPresentationStage(
    BuildContext context,
    WidgetRef ref,
    Event? event,
    QrCheckinState state,
  ) {
    final isSessionOpen = state.isSessionOpen;
    final qrToken = state.qrToken ?? '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderR16,
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Event Title & Badge on projector
          Text(
            event?.title ?? 'Sự kiện EventHub',
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            'Chiếu màn hình này tại hội trường sự kiện',
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Big QR Box
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.borderR12,
              border: Border.all(
                color: isSessionOpen ? AppColors.primary : AppColors.border,
                width: isSessionOpen ? 3 : 1,
              ),
            ),
            child: qrToken.isEmpty
                ? const SizedBox(
                    width: 240,
                    height: 240,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Opacity(
                    opacity: isSessionOpen ? 1.0 : 0.35,
                    child: QrImageView(
                      data: qrToken,
                      version: QrVersions.auto,
                      size: 240.0,
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.s16),

          // Instructions
          Container(
            padding: const EdgeInsets.all(AppSpacing.s12),
            decoration: BoxDecoration(
              color: isSessionOpen
                  ? AppColors.brandSubtle
                  : AppColors.surfaceSubtle,
              borderRadius: AppRadius.borderR8,
            ),
            child: Row(
              children: [
                Icon(
                  isSessionOpen
                      ? Icons.info_outline
                      : Icons.warning_amber_rounded,
                  color: isSessionOpen ? AppColors.primary : AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Text(
                    isSessionOpen
                        ? 'Sinh viên mở Mobile App -> Vé sự kiện -> Quét mã QR để điểm danh.'
                        : 'Phiên điểm danh đang đóng. Hãy mở phiên để sinh viên có thể điểm danh.',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s24),

          // Session & QR Controls
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: isSessionOpen ? 'Đóng phiên' : 'Mở phiên điểm danh',
                  variant: isSessionOpen
                      ? AppButtonVariant.secondary
                      : AppButtonVariant.primary,
                  icon: Icon(
                    isSessionOpen ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                    size: 18,
                  ),
                  isLoading: state.isToggling,
                  onPressed: () => ref
                      .read(qrCheckinViewModelProvider(eventId).notifier)
                      .toggleSession(!isSessionOpen),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              AppButton(
                label: 'Làm mới QR',
                variant: AppButtonVariant.secondary,
                icon: const Icon(Icons.refresh, size: 18),
                isLoading: state.isGeneratingQr,
                onPressed: () => ref
                    .read(qrCheckinViewModelProvider(eventId).notifier)
                    .generateQr(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRealtimeAttendancePanel(
    BuildContext context,
    QrCheckinState state,
    int totalApproved,
    int checkedInCount,
  ) {
    final percent = totalApproved > 0
        ? (checkedInCount / totalApproved).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.borderR16,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bảng theo dõi Điểm danh Realtime',
                      style: AppTypography.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    Text(
                      'Tự động đồng bộ ngay khi sinh viên quét QR trên Mobile',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              AppStatusBadge(
                label: '$checkedInCount / $totalApproved Đã đến',
                variant: checkedInCount == totalApproved && totalApproved > 0
                    ? AppBadgeVariant.success
                    : AppBadgeVariant.info,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),

          // Progress Bar
          LinearProgressIndicator(
            value: percent,
            backgroundColor: AppColors.surfaceSubtle,
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: AppSpacing.s16),
          const Divider(height: 1, color: AppColors.border),

          // Participant Realtime List
          if (state.approvedRegistrations.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s40),
              child: Center(
                child: Text(
                  'Chưa có đơn đăng ký nào được duyệt cho sự kiện này.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.approvedRegistrations.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final reg = state.approvedRegistrations[index];
                final isCheckedIn = reg.isCheckedIn;

                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: isCheckedIn
                          ? AppColors.successContainer
                          : AppColors.surfaceSubtle,
                      child: Icon(
                        isCheckedIn
                            ? Icons.check
                            : Icons.person_outline,
                        color: isCheckedIn
                            ? AppColors.onSuccessContainer
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      reg.participant.name,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${reg.participant.email} • ${reg.participant.group == 'student' ? reg.participant.cohort : reg.participant.organization}',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isCheckedIn
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const AppStatusBadge(
                                label: 'Đã điểm danh',
                                variant: AppBadgeVariant.success,
                              ),
                              if (reg.checkInAt != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '${reg.checkInAt!.hour.toString().padLeft(2, '0')}:${reg.checkInAt!.minute.toString().padLeft(2, '0')}:${reg.checkInAt!.second.toString().padLeft(2, '0')}',
                                  style: AppTypography.textTheme.labelSmall?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ],
                          )
                        : const AppStatusBadge(
                            label: 'Chưa điểm danh',
                            variant: AppBadgeVariant.neutral,
                          ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
