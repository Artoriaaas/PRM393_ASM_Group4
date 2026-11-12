import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/qr_checkin_viewmodel.dart';
import '../../viewmodels/web_auth_viewmodel.dart';

class LiveQrPanelScreen extends ConsumerWidget {
  const LiveQrPanelScreen({
    super.key,
    required this.eventId,
  });

  final String eventId;

  String _formatEventWindow(Event event) {
    final dd = event.startsAt.day.toString().padLeft(2, '0');
    final mm = event.startsAt.month.toString().padLeft(2, '0');
    final sh = event.startsAt.hour.toString().padLeft(2, '0');
    final sm = event.startsAt.minute.toString().padLeft(2, '0');
    final eh = event.endsAt.hour.toString().padLeft(2, '0');
    final em = event.endsAt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${event.startsAt.year} • $sh:$sm – $eh:$em • ${event.location}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentStaffProfileProvider);
    final isAdmin = user?.isAdmin ?? false;

    if (isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.surfaceSubtle,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.s32),
            margin: const EdgeInsets.all(AppSpacing.s24),
            constraints: const BoxConstraints(maxWidth: 580),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.borderR16,
              border: Border.all(color: AppColors.border),
              boxShadow: AppShadows.elevation1,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: const BoxDecoration(
                    color: AppColors.brandSubtle,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Text(
                  'Phân quyền Điểm danh QR',
                  style: AppTypography.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s12),
                Text(
                  'Theo phân quyền hệ thống, việc mở phiên và điều phối điểm danh QR do chính Ban tổ chức/Trưởng Câu lạc bộ trực tiếp phụ trách tại sự kiện. Quản trị viên chỉ thực hiện giám sát và phê duyệt đề xuất sự kiện, không quản lý việc điểm danh.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s24),
                AppButton(
                  label: 'Quay lại Giám sát & Phê duyệt Sự kiện',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/events'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final qrState = ref.watch(qrCheckinViewModelProvider(eventId));

    if (!qrState.eventLoaded && qrState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surfaceSubtle,
        body: Center(
          child: AppLoadingState(
            message: 'Đang tải thông tin phiên điểm danh QR…',
          ),
        ),
      );
    }

    final event = qrState.event;
    if (event == null) {
      if (qrState.errorMessage != null) {
        return Scaffold(
          backgroundColor: AppColors.surfaceSubtle,
          body: Center(
            child: AppErrorState(
              title: 'Không thể tải phiên điểm danh',
              message: qrState.errorMessage!,
              onRetry: () =>
                  ref.read(qrCheckinViewModelProvider(eventId).notifier).retry(),
            ),
          ),
        );
      }
      return Scaffold(
        backgroundColor: AppColors.surfaceSubtle,
        body: Center(
          child: AppEmptyState(
            title: 'Không tìm thấy sự kiện',
            message:
                'Sự kiện không tồn tại hoặc không thuộc phạm vi Câu lạc bộ của bạn.',
            actionLabel: 'Quay lại danh sách sự kiện',
            onAction: () => context.go('/events'),
          ),
        ),
      );
    }

    if (!qrState.isEligibleForQrCheckin) {
      return Scaffold(
        backgroundColor: AppColors.surfaceSubtle,
        body: Center(
          child: AppEmptyState(
            icon: Icons.qr_code_2,
            title: 'Chưa mở điều phối QR cho sự kiện này',
            message:
                'Panel điểm danh QR chỉ khả dụng cho sự kiện ở chế độ "Yêu cầu đăng ký (required)" và đang "Công bố (published)".',
            actionLabel: 'Quay lại danh sách sự kiện',
            onAction: () => context.go('/events'),
          ),
        ),
      );
    }

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
            Row(
              children: [
                ConstrainedBox(
                  constraints: AppTouchTargets.minConstraints,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Quay lại danh sách sự kiện',
                    onPressed: () => context.go('/events'),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.s12,
                        runSpacing: AppSpacing.s8,
                        children: [
                          Text(
                            'Điểm danh QR Trực tiếp',
                            style: AppTypography.textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
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
                        '${event.title} • ${_formatEventWindow(event)}',
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
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: const BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: AppRadius.borderR8,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
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
              ),
              const SizedBox(height: AppSpacing.s16),
            ],
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 950;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                }
                return Column(
                  children: [
                    _buildQrPresentationStage(context, ref, event, qrState),
                    const SizedBox(height: AppSpacing.s24),
                    _buildRealtimeAttendancePanel(
                      context,
                      qrState,
                      totalApproved,
                      checkedInCount,
                    ),
                  ],
                );
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
    Event event,
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
        boxShadow: AppShadows.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            event.title,
            style: AppTypography.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            _formatEventWindow(event),
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s16),
          Semantics(
            label: isSessionOpen
                ? 'Mã QR điểm danh đang mở cho sự kiện ${event.title}'
                : 'Mã QR đang tạm khóa vì phiên điểm danh đang đóng',
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: AppColors.surface,
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
          ),
          const SizedBox(height: AppSpacing.s16),
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
                        ? 'Sinh viên mở Mobile App → Lịch tham gia → Quét mã QR để điểm danh.'
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
          Wrap(
            spacing: AppSpacing.s12,
            runSpacing: AppSpacing.s12,
            alignment: WrapAlignment.center,
            children: [
              AppButton(
                label: isSessionOpen ? 'Đóng phiên' : 'Mở phiên điểm danh',
                variant: isSessionOpen
                    ? AppButtonVariant.secondary
                    : AppButtonVariant.primary,
                icon: Icon(
                  isSessionOpen
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  size: 18,
                ),
                isLoading: state.isToggling,
                onPressed: () => ref
                    .read(qrCheckinViewModelProvider(eventId).notifier)
                    .toggleSession(!isSessionOpen),
              ),
              AppButton(
                label: 'Làm mới QR',
                semanticsLabel: 'Tạo mới mã QR và vô hiệu hóa mã QR cũ',
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
                      'Tự động đồng bộ ngay khi sinh viên quét QR trên Mobile (ẩn email/SĐT bảo vệ quyền riêng tư)',
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
                icon: const Icon(Icons.how_to_reg),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s16),
          ClipRRect(
            borderRadius: AppRadius.borderR6,
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.surfaceSubtle,
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          const Divider(height: 1, color: AppColors.border),
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
                final affiliation = reg.participant.group == 'student'
                    ? 'Sinh viên FPTU • ${reg.participant.cohort}'
                    : 'Khách • ${reg.participant.organization.isEmpty ? "Ngoài trường" : reg.participant.organization}';

                return Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.s4,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isCheckedIn
                          ? AppColors.successContainer
                          : AppColors.surfaceSubtle,
                      child: Icon(
                        isCheckedIn ? Icons.check : Icons.person_outline,
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
                      affiliation,
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
                                icon: Icon(Icons.check_circle_outline),
                              ),
                              if (reg.checkInAt != null) ...[
                                const SizedBox(height: AppSpacing.s4),
                                Text(
                                  '${reg.checkInAt!.hour.toString().padLeft(2, '0')}:${reg.checkInAt!.minute.toString().padLeft(2, '0')}:${reg.checkInAt!.second.toString().padLeft(2, '0')}',
                                  style: AppTypography.textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ],
                          )
                        : const AppStatusBadge(
                            label: 'Chưa điểm danh',
                            variant: AppBadgeVariant.neutral,
                            icon: Icon(Icons.schedule),
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
