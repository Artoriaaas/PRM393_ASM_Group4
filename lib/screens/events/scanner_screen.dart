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
import 'booking_widgets.dart';

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
      appBar: AppTopBar(title: 'Quét QR', showBackButton: true),
      body: registration.when(
        loading: () => const AppLoadingState(),
        error: (_, _) => EventFailure(
          onRetry: () =>
              ref.invalidate(registrationProvider(widget.registrationId)),
        ),
        data: (r) {
          if (r == null || !r.active) {
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
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.s16),
            children: [
              const Text(
                'Quét mã QR do CLB hiển thị trên web tại sự kiện. App không mở hoặc điều khiển web CLB.',
              ),
              const SizedBox(height: AppSpacing.s16),
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: AppRadius.borderR16,
                  child: QrCameraPreview(
                    handle: camera.previewHandle,
                    onDetected: cameraVM.detected,
                  ),
                ),
              ),
              if (camera.message != null)
                EventPanel(children: [Text(camera.message!)]),
              const SizedBox(height: AppSpacing.s16),
              const BookingFeedback(),
              AppButton(
                label: 'Quét lại',
                isDisabled: s.busy || s.unresolved,
                onPressed: cameraVM.retry,
              ),
              AppButton(
                variant: AppButtonVariant.text,
                onPressed: cameraVM.openSettings,
                label: 'Mở Cài đặt camera',
              ),
              AppButton(
                variant: AppButtonVariant.text,
                onPressed: () =>
                    context.go('/registrations/${widget.registrationId}'),
                label: 'Quay về chi tiết đăng ký',
              ),
            ],
          );
        },
      ),
    );
  }
}
