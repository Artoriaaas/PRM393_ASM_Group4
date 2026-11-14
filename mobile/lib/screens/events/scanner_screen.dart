import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/event_data_providers.dart';
import '../../viewmodels/scanner_viewmodel.dart';
import '../../widgets/qr_camera_preview.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, required this.registrationId, this.eventId});
  final String registrationId;
  final String? eventId;
  @override
  ConsumerState<ScannerScreen> createState() => _ScannerState();
}

class _ScannerState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      if (mounted) {
        ref.read(scannerProvider(widget.registrationId).notifier).initialize();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final vm = ref.read(scannerProvider(widget.registrationId).notifier);
    unawaited(state == AppLifecycleState.resumed ? vm.resume() : vm.pause());
  }

  @override
  Widget build(BuildContext context) {
    final camera = ref.watch(scannerProvider(widget.registrationId));
    final cameraVM = ref.read(scannerProvider(widget.registrationId).notifier);
    ref.listen(scannerProvider(widget.registrationId), (_, next) {
      if (next.phase == ScannerPhase.completed) {
        context.go('/registrations/${widget.registrationId}/check-in');
      }
    });
    final registration = ref.watch(registrationProvider(widget.registrationId));
    final s = ref.watch(bookingProvider);
    ref.listen(bookingProvider, (_, next) {
      if (next.result?.status == 'checked-in') {
        context.go('/registrations/${widget.registrationId}/check-in');
      }
    });
    return Scaffold(
      appBar: AppTopBar(title: 'Quét QR điểm danh', showBackButton: true),
      body: registration.when(
        loading: () => const AppLoadingState(),
        error: (_, _) => EventFailure(
          onRetry: () =>
              ref.invalidate(registrationProvider(widget.registrationId)),
        ),
        data: (r) {
          if (r == null || !r.canCheckIn) {
            return AppEmptyState(
              title: r == null ? 'Cần đăng ký hợp lệ' : r.statusLabel,
              message: r?.pending == true
                  ? 'Chờ CLB duyệt đăng ký trước khi quét QR.'
                  : 'Tài khoản chưa có đăng ký được duyệt cho sự kiện này.',
              actionLabel: r == null && widget.eventId == null
                  ? 'Về khám phá'
                  : 'Xem sự kiện',
              onAction: () => context.go(
                r == null
                    ? (widget.eventId == null
                          ? '/discover'
                          : '/events/${widget.eventId}')
                    : '/events/${r.eventId}',
              ),
            );
          }
          final failed =
              camera.phase == ScannerPhase.error ||
              s.result?.status == 'rejected';
          if (s.busy || s.unresolved || failed) {
            final title = s.busy
                ? 'Đang kiểm tra'
                : s.unresolved
                ? 'Chưa xác nhận được kết quả'
                : camera.phase == ScannerPhase.error
                ? 'Cần quyền camera'
                : s.message ?? 'Chưa thể điểm danh';
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 32),
                Center(
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.warningContainer,
                    child: s.busy
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.warning_amber_rounded,
                            color: AppColors.textPrimary,
                            size: 28,
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  s.busy
                      ? 'Vui lòng chờ kết quả xác nhận.'
                      : s.unresolved
                      ? 'Kiểm tra trạng thái điểm danh trước khi thử lại.'
                      : camera.message ?? 'Hãy quét mã do CLB hiển thị cho sự kiện bạn đang tham gia.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (!s.busy)
                  AppButton(
                    label: s.unresolved
                        ? 'Kiểm tra trạng thái'
                        : camera.phase == ScannerPhase.error
                        ? 'Mở cài đặt'
                        : 'Quét lại',
                    onPressed: s.unresolved
                        ? () => ref.read(bookingProvider.notifier).recover()
                        : camera.phase == ScannerPhase.error
                        ? cameraVM.openSettings
                        : cameraVM.retry,
                  ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Quay về chi tiết đăng ký',
                  variant: AppButtonVariant.text,
                  onPressed: s.busy
                      ? null
                      : () => context.go(
                          '/registrations/${widget.registrationId}',
                        ),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Đưa mã QR do CLB hiển thị vào khung hình.'),
              const SizedBox(height: 20),
              AspectRatio(
                aspectRatio: 0.62,
                child: ClipRRect(
                  borderRadius: AppRadius.borderR16,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: Color(0xFF182133)),
                      QrCameraPreview(
                        handle: camera.previewHandle,
                        onDetected: cameraVM.detected,
                      ),
                      IgnorePointer(
                        child: Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.76,
                            heightFactor: 0.50,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: AppRadius.borderR16,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Quay về chi tiết đăng ký',
                variant: AppButtonVariant.text,
                onPressed: () =>
                    context.go('/registrations/${widget.registrationId}'),
              ),
            ],
          );
        },
      ),
    );
  }
}
