import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/event_data_providers.dart';
import '../../services/device/qr_camera_service.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';
import 'booking_widgets.dart';

final qrCameraProvider = Provider.autoDispose<QrCameraService>((ref) {
  final service = QrCameraService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, required this.registrationId, this.eventId});
  final String registrationId;
  final String? eventId;
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
      if (!mounted) return;
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
    } else {
      final r = ref
          .read(registrationProvider(widget.registrationId))
          .asData
          ?.value;
      final booking = ref.read(bookingProvider);
      if (r?.active == true &&
          r?.checkInAt == null &&
          !booking.busy &&
          !booking.unresolved) {
        unawaited(ref.read(qrCameraProvider).start());
      }
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
          if (r == null || !r.active) {
            return AppEmptyState(
              title: r == null ? 'Cần đăng ký hợp lệ' : 'Đăng ký đã hủy',
              message:
                  'Tài khoản chưa có đăng ký đang hoạt động cho sự kiện này.',
              actionLabel: r == null && widget.eventId == null
                  ? 'Về khám phá'
                  : 'Xem sự kiện',
              onAction: () =>
                  context.go(r == null ? '/discover' : '/events/${r.eventId}'),
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
