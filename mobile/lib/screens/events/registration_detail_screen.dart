import '../../theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/event_data_providers.dart';
import '../../viewmodels/event_viewmodels.dart';
import '../../models/event.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';
import 'booking_widgets.dart';

class RegistrationDetailScreen extends ConsumerStatefulWidget {
  const RegistrationDetailScreen({
    super.key,
    required this.id,
    this.success = false,
    this.checkInResult = false,
  });
  final String id;
  final bool success, checkInResult;
  @override
  ConsumerState<RegistrationDetailScreen> createState() =>
      _RegistrationDetailState();
}

class _RegistrationDetailState extends ConsumerState<RegistrationDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(bookingProvider.notifier).restore());
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(registrationProvider(widget.id));
    return Scaffold(
      appBar: AppTopBar(
        showBackButton: true,
        onBack: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(widget.success ? '/discover' : '/schedule');
          }
        },
        title: (widget.checkInResult
            ? 'Kết quả điểm danh'
            : widget.success
            ? 'Kết quả đăng ký'
            : 'Chi tiết đăng ký'),
      ),
      body: registration.when(
        loading: () => const AppLoadingState(),
        error: (_, _) => EventFailure(
          onRetry: () => ref.invalidate(registrationProvider(widget.id)),
        ),
        data: (r) {
          if (r == null) {
            return const AppEmptyState(
              title: 'Không có thông tin đăng ký',
              message: 'Về lịch tham gia để kiểm tra.',
            );
          }
          final event = ref.watch(eventProvider(r.eventId));
          return event.when(
            loading: () => const AppLoadingState(),
            error: (_, _) => EventFailure(
              onRetry: () => ref.invalidate(eventProvider(r.eventId)),
            ),
            data: (e) {
              if (e == null) {
                return const AppEmptyState(
                  title: 'Sự kiện không còn khả dụng',
                  message: 'Liên hệ CLB để được hỗ trợ.',
                );
              }
              final session =
                  r.canCheckIn && r.checkInAt == null && e.status == 'published'
                  ? ref.watch(checkinSessionProvider(e.id))
                  : null;
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.s16),
                children: [
                  if (widget.success || widget.checkInResult) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: r.rejected || r.cancelled
                            ? AppColors.errorContainer
                            : r.pending
                            ? AppColors.infoContainer
                            : AppColors.successContainer,
                        child: Icon(
                          r.rejected || r.cancelled
                              ? Icons.close
                              : r.pending
                              ? Icons.schedule
                              : Icons.check,
                          size: 30,
                          color: r.rejected || r.cancelled
                              ? AppColors.error
                              : r.pending
                              ? AppColors.info
                              : AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.checkInResult
                          ? (r.checkInAt == null
                                ? 'Chưa có xác nhận điểm danh'
                                : ref.read(bookingProvider).result?.code ==
                                      'already-checked-in'
                                ? 'Bạn đã điểm danh'
                                : 'Điểm danh thành công')
                          : r.rejected
                          ? 'Đăng ký bị từ chối'
                          : r.cancelled
                          ? 'Đã hủy đăng ký'
                          : r.pending
                          ? 'Đã gửi đăng ký'
                          : 'Đăng ký được xác nhận',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    if (widget.checkInResult)
                      const Text(
                        'Đưa màn hình này cho CLB kiểm tra.',
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 24),
                    if (!widget.checkInResult) ...[
                      EventNotice(r.statusLabel),
                      const SizedBox(height: 16),
                    ],
                  ] else ...[
                    EventNotice(
                      e.status == 'cancelled'
                          ? 'Sự kiện đã hủy'
                          : r.statusLabel,
                      variant: r.checkInAt != null
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.info,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (r.pending) ...[
                    const EventNotice(
                      'Yêu cầu đang chờ CLB duyệt. Bạn chỉ có thể quét QR sau khi được duyệt.',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (r.rejected) ...[
                    EventNotice(
                      r.reason?.isNotEmpty == true
                          ? r.reason!
                          : 'CLB đã từ chối đăng ký.',
                      variant: AppBadgeVariant.error,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.checkInResult && r.checkInAt != null) ...[
                    EventNotice(
                      'Đã điểm danh lúc ${eventTime(r.checkInAt!)} · ${eventDate(r.checkInAt!)}',
                      variant: AppBadgeVariant.success,
                    ),
                    const SizedBox(height: 16),
                  ],
                  EventIdentityCard(e),
                  const SizedBox(height: 16),
                  EventParticipantCard(
                    r.participant,
                    showEmail: !widget.checkInResult && !widget.success,
                  ),
                  const SizedBox(height: 16),
                  if (!widget.checkInResult &&
                      r.canCheckIn &&
                      r.checkInAt == null &&
                      e.status == 'published') ...[
                    if (session!.isLoading) const AppLoadingState(),
                    if (session.hasError)
                      EventFailure(
                        onRetry: () =>
                            ref.invalidate(checkinSessionProvider(e.id)),
                      ),
                    if (session.asData != null)
                      EventNotice(
                        session.asData!.value
                            ? 'Phiên điểm danh đang mở. Quét mã QR do CLB hiển thị tại sự kiện.'
                            : 'Điểm danh sẽ khả dụng khi CLB mở phiên tại sự kiện.',
                      ),
                    if (!ref.watch(canCancelRegistrationProvider(r.id)))
                      const EventNotice(
                        'Sự kiện đã bắt đầu. Không thể hủy đăng ký.',
                      ),
                  ],
                  const SizedBox(height: AppSpacing.s16),
                  if (!widget.checkInResult && r.checkInAt != null) ...[
                    EventNotice(
                      'Đã điểm danh lúc ${eventTime(r.checkInAt!)} · ${eventDate(r.checkInAt!)}',
                      variant: AppBadgeVariant.success,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (r.canCheckIn &&
                      e.status == 'published' &&
                      !widget.checkInResult) ...[
                    const SizedBox(height: AppSpacing.s12),
                    AppButton(
                      label: r.checkInAt != null
                          ? 'Xem xác nhận'
                          : 'Quét QR điểm danh',
                      isDisabled:
                          r.checkInAt == null && session?.asData?.value != true,
                      onPressed: () => context.push(
                        '/registrations/${r.id}/${r.checkInAt != null ? 'check-in' : 'scan'}?eventId=${e.id}',
                      ),
                    ),
                  ],
                  if (ref.watch(canCancelRegistrationProvider(r.id)) &&
                      !widget.checkInResult &&
                      !widget.success) ...[
                    const SizedBox(height: AppSpacing.s12),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.errorContainer,
                        foregroundColor: AppColors.error,
                        minimumSize: const Size.fromHeight(48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.borderR12,
                        ),
                      ),
                      onPressed:
                          ref.watch(bookingProvider).busy ||
                              ref.watch(bookingProvider).unresolved
                          ? null
                          : () => _cancel(context, r),
                      child: const Text('Hủy đăng ký'),
                    ),
                  ],
                  if (!widget.checkInResult && !widget.success)
                    AppButton(
                      label: 'Xem đầy đủ sự kiện',
                      variant: AppButtonVariant.text,
                      onPressed: () => context.push('/events/${e.id}'),
                    ),
                  if (r.cancelled)
                    const EventPanel(
                      children: [
                        Text(
                          'Bạn đã hủy đăng ký. Đăng ký không còn trong Sắp tới và không dùng để điểm danh.',
                        ),
                      ],
                    ),
                  if (e.status == 'cancelled')
                    const EventPanel(
                      children: [
                        Text(
                          'CLB đã hủy sự kiện. Dữ liệu được giữ để xem lịch sử; không nhận điểm danh mới.',
                        ),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.s16),
                  const BookingFeedback(),
                  const SizedBox(height: AppSpacing.s16),
                  AppButton(
                    label: widget.success
                        ? 'Xem lịch tham gia'
                        : 'Về lịch tham gia',
                    onPressed: () => context.go('/schedule'),
                  ),
                  if (widget.success) ...[
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Xem chi tiết đăng ký',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.go('/registrations/${r.id}'),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _cancel(BuildContext context, Registration r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 28),
                const SizedBox(height: 24),
                Text(
                  'Hủy đăng ký?',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Đăng ký sẽ được bỏ khỏi mục Sắp tới sau khi máy chủ xác nhận. Không thể dùng đăng ký đã hủy để điểm danh.',
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Giữ đăng ký',
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.pop(dialogContext, false),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.errorContainer,
                    foregroundColor: AppColors.error,
                    minimumSize: const Size.fromHeight(48),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.borderR12,
                    ),
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Xác nhận hủy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (ok == true && mounted) {
      await ref.read(bookingProvider.notifier).cancel(r);
    }
  }
}
