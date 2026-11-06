import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/event_providers.dart';
import '../../services/device/qr_camera_service.dart';
import '../../viewmodels/booking_viewmodel.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../widgets/event_widgets.dart';
import 'booking_widgets.dart';

final qrCameraProvider = Provider.autoDispose<QrCameraService>((ref) {
  final service = QrCameraService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, required this.registrationId});
  final String registrationId;
  @override
  ConsumerState<ScannerScreen> createState() => _ScannerState();
}

class _ScannerState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver {
  StreamSubscription<String>? _codes, _errors;
  String? message;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      final service = ref.read(qrCameraProvider);
      _codes = service.tokens.listen((token) {
        final r = ref
            .read(registrationProvider(widget.registrationId))
            .asData
            ?.value;
        if (r != null) ref.read(bookingProvider.notifier).checkIn(r, token);
      });
      _errors = service.errors.listen((value) {
        if (mounted) setState(() => message = value);
      });
      await ref.read(bookingProvider.notifier).restore();
      try {
        final registration = await ref.read(
          registrationProvider(widget.registrationId).future,
        );
        if (mounted &&
            registration?.active == true &&
            !ref.read(bookingProvider).unresolved) {
          if (registration!.checkInAt != null) {
            context.go('/registrations/${widget.registrationId}/check-in');
          } else {
            await service.start();
          }
        }
      } catch (_) {
        if (mounted) {
          setState(
            () =>
                message = 'Chưa tải được đăng ký. Thử tải lại trước khi quét.',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _codes?.cancel();
    _errors?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(ref.read(qrCameraProvider).stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = ref.watch(qrCameraProvider);
    final registration = ref.watch(registrationProvider(widget.registrationId));
    final s = ref.watch(bookingProvider);
    ref.listen(bookingProvider, (_, next) {
      if (next.result?.status == 'checked-in') {
        context.go('/registrations/${widget.registrationId}/check-in');
      }
    });
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR')),
      body: registration.when(
        loading: () => const AppLoadingState(),
        error: (_, _) => EventFailure(
          onRetry: () =>
              ref.invalidate(registrationProvider(widget.registrationId)),
        ),
        data: (r) {
          if (r == null || !r.canCheckIn) {
            return AppEmptyState(
              title: r?.isPending == true
                  ? 'Đơn đang chờ CLB duyệt'
                  : 'Cần đăng ký đã được duyệt',
              message: r?.isPending == true
                  ? 'Đơn đăng ký của bạn đang chờ Trưởng CLB phê duyệt trước khi mở quét QR điểm danh.'
                  : 'Tài khoản chưa có đăng ký đã được duyệt cho sự kiện này.',
              actionLabel: r != null ? 'Về chi tiết đăng ký' : 'Về khám phá',
              onAction: () => context.go(
                r != null ? '/registrations/${r.id}' : '/discover',
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
                  child: camera.preview(),
                ),
              ),
              if (message != null) EventPanel(children: [Text(message!)]),
              const SizedBox(height: AppSpacing.s16),
              const BookingFeedback(),
              AppButton(
                label: 'Quét lại',
                isDisabled: s.busy || s.unresolved,
                onPressed: () {
                  setState(() => message = null);
                  ref.read(bookingProvider.notifier).clearResult();
                  camera.start();
                },
              ),
              TextButton(
                onPressed: () => camera.openSettings(),
                child: const Text('Mở Cài đặt camera'),
              ),
              TextButton(
                onPressed: () =>
                    context.go('/registrations/${widget.registrationId}'),
                child: const Text('Quay về chi tiết đăng ký'),
              ),
            ],
          );
        },
      ),
    );
  }
}
