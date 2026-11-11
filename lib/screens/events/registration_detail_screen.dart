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
        title: (widget.checkInResult
            ? 'Kết quả điểm danh'
            : widget.success
            ? 'Đăng ký thành công'
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
                  r.active && r.checkInAt == null && e.status == 'published'
                  ? ref.watch(checkinSessionProvider(e.id))
                  : null;
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.s16),
                children: [
                  if (widget.success && r.active)
                    Text(
                      r.status == 'pending'
                          ? 'Đã gửi đơn đăng ký'
                          : 'Đăng ký được xác nhận',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  if (widget.checkInResult)
                    Text(
                      r.checkInAt != null
                          ? (ref.read(bookingProvider).result?.status ==
                                        'checked-in' &&
                                    ref.read(bookingProvider).result?.code !=
                                        'already-checked-in'
                                ? 'Điểm danh thành công'
                                : 'Bạn đã điểm danh')
                          : 'Chưa có xác nhận điểm danh',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  if (widget.checkInResult && r.checkInAt != null)
                    const Text('Đưa màn hình này cho CLB kiểm tra.'),
                  if (!widget.checkInResult &&
                      r.active &&
                      r.checkInAt == null &&
                      e.status == 'published') ...[
                    if (session!.isLoading) const AppLoadingState(),
                    if (session.hasError)
                      EventFailure(
                        onRetry: () =>
                            ref.invalidate(checkinSessionProvider(e.id)),
                      ),
                    if (session.asData != null)
                      EventPanel(
                        children: [
                          Text(
                            session.asData!.value
                                ? 'Phiên điểm danh đang mở. Quét mã QR do CLB hiển thị tại sự kiện.'
                                : 'Phiên điểm danh đang đóng. Kiểm tra lại khi CLB mở phiên.',
                          ),
                        ],
                      ),
                    if (!ref.watch(canCancelRegistrationProvider(r.id)))
                      const EventPanel(
                        children: [
                          Text('Sự kiện đã bắt đầu. Không thể hủy đăng ký.'),
                        ],
                      ),
                  ],
                  AppStatusBadge(
                    label: r.status == 'pending'
                        ? 'Chờ CLB duyệt'
                        : r.status == 'rejected'
                        ? 'Bị từ chối'
                        : !r.active
                        ? 'Đã hủy đăng ký'
                        : e.status == 'cancelled'
                        ? 'Sự kiện đã hủy'
                        : r.checkInAt != null
                        ? 'Đã điểm danh'
                        : 'Đã duyệt',
                    variant: r.status == 'pending'
                        ? AppBadgeVariant.warning
                        : r.status == 'rejected'
                        ? AppBadgeVariant.error
                        : !r.active
                        ? AppBadgeVariant.neutral
                        : AppBadgeVariant.success,
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  EventSummary(e),
                  const SizedBox(height: AppSpacing.s16),
                  EventPanel(
                    children: [
                      Text(
                        'Người tham gia',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(r.participant.name),
                      Text(
                        r.participant.group == 'student'
                            ? 'Sinh viên FPTU · ${r.participant.cohort} (tự khai)'
                            : 'Khách ngoài trường',
                      ),
                      if (!widget.checkInResult) Text(r.participant.email),
                    ],
                  ),
                  if (r.checkInAt != null)
                    EventPanel(
                      children: [
                        const Text('Thời gian điểm danh đã xác nhận'),
                        Text(
                          '${eventTime(r.checkInAt!)} · ${eventDate(r.checkInAt!)}',
                        ),
                      ],
                    ),
                  const SizedBox(height: AppSpacing.s16),
                  if (!widget.checkInResult)
                    AppButton(
                      label: 'Xem đầy đủ sự kiện',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => context.push('/events/${e.id}'),
                    ),
                  if (r.canCheckIn &&
                      e.status == 'published' &&
                      !widget.checkInResult) ...[
                    const SizedBox(height: AppSpacing.s12),
                    AppButton(
                      label: r.checkInAt != null ? 'Xem xác nhận' : 'Quét QR',
                      isDisabled:
                          r.checkInAt == null && session?.asData?.value != true,
                      onPressed: () => context.push(
                        '/registrations/${r.id}/${r.checkInAt != null ? 'check-in' : 'scan'}?eventId=${e.id}',
                      ),
                    ),
                  ],
                  if (ref.watch(canCancelRegistrationProvider(r.id)) &&
                      !widget.checkInResult) ...[
                    const SizedBox(height: AppSpacing.s12),
                    AppButton(
                      label: 'Hủy đăng ký',
                      variant: AppButtonVariant.secondary,
                      isDisabled:
                          ref.watch(bookingProvider).busy ||
                          ref.watch(bookingProvider).unresolved,
                      onPressed: () => _cancel(context, r),
                    ),
                  ],
                  if (r.status == 'pending')
                    const EventPanel(
                      children: [
                        Text(
                          'Đơn đăng ký của bạn đang chờ Ban tổ chức CLB xét duyệt. Hãy kiểm tra lại sau hoặc theo dõi thông báo.',
                        ),
                      ],
                    ),
                  if (r.status == 'rejected')
                    EventPanel(
                      children: [
                        Text(
                          'Đơn đăng ký đã bị từ chối.${r.reason != null && r.reason!.isNotEmpty ? " Lý do: ${r.reason}" : ""}',
                        ),
                      ],
                    ),
                  if (r.status == 'cancelled' ||
                      (!r.active && r.status != 'pending' && r.status != 'rejected'))
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
                    label: 'Về lịch tham gia',
                    onPressed: () => context.go('/schedule'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _cancel(BuildContext context, Registration r) async {
    final ok = await AppConfirmationDialog.show(
      context: context,
      title: 'Hủy đăng ký?',
      message: 'Sau khi máy chủ xác nhận, đăng ký không còn trong Sắp tới và không dùng để điểm danh.',
      confirmLabel: 'Xác nhận hủy',
      cancelLabel: 'Giữ đăng ký',
    );
    if (ok == true && mounted) {
      await ref.read(bookingProvider.notifier).cancel(r);
    }
  }
}
