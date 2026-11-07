import '../../theme/theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodels/event_data_providers.dart';
import '../../viewmodels/session_viewmodel.dart';
import '../../models/auth_state.dart';
import '../../models/event.dart';
import '../../viewmodels/booking_viewmodel.dart';
import '../../widgets/widgets.dart';
import '../../widgets/event_widgets.dart';
import 'booking_widgets.dart';

class RegistrationFormScreen extends ConsumerStatefulWidget {
  const RegistrationFormScreen({super.key, required this.eventId});
  final String eventId;
  @override
  ConsumerState<RegistrationFormScreen> createState() =>
      _RegistrationFormState();
}

class _RegistrationFormState extends ConsumerState<RegistrationFormScreen> {
  final name = TextEditingController(),
      email = TextEditingController(),
      cohort = TextEditingController(),
      organization = TextEditingController(),
      phone = TextEditingController();
  String group = 'student';
  @override
  void initState() {
    super.initState();
    final auth = ref.read(sessionViewModelProvider);
    if (auth is AuthStateSignedIn) {
      name.text = auth.displayName ?? '';
      email.text = auth.email;
    }
    Future.microtask(() async {
      await ref.read(bookingProvider.notifier).restore();
      if (!mounted) return;
      final c = ref.read(bookingProvider).pending;
      if (c?['eventId'] == widget.eventId && c?['participant'] is Map) {
        final p = Participant.fromJson(
          Map<String, dynamic>.from(c!['participant'] as Map),
        );
        setState(() {
          name.text = p.name;
          email.text = p.email;
          cohort.text = p.cohort;
          organization.text = p.organization;
          phone.text = p.phone;
          group = p.group;
        });
      }
    });
  }

  @override
  void dispose() {
    for (final c in [name, email, cohort, organization, phone]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = ref.watch(eventProvider(widget.eventId));
    final s = ref.watch(bookingProvider);
    ref.listen(bookingProvider, (_, next) {
      final result = next.result;
      if (result?.successful == true && result?.registrationId != null) {
        context.go(
          '/registrations/${result!.registrationId}/${result.status == 'existing' ? '' : 'success'}'
              .replaceAll(RegExp(r'/$'), ''),
        );
      }
    });
    return PopScope(
      canPop: !s.busy,
      child: Scaffold(
        appBar: AppTopBar(title: 'Thông tin đăng ký', showBackButton: true),
        body: value.when(
          loading: () => const AppLoadingState(),
          error: (_, _) => EventFailure(
            onRetry: () => ref.invalidate(eventProvider(widget.eventId)),
          ),
          data: (e) => e == null
              ? const AppEmptyState(
                  title: 'Không tìm thấy sự kiện',
                  message: 'Quay lại danh sách sự kiện.',
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  children: [
                    const BookingFeedback(showCheckButton: false),
                    EventPanel(children: [Text(e.title), Text(eventWhen(e))]),
                    const SizedBox(height: AppSpacing.s16),
                    AppTextField(
                      labelText: 'Họ tên *',
                      controller: name,

                      errorText: s.errors['name'],
                      enabled: !s.busy && !s.unresolved,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    AppTextField(
                      labelText: 'Email liên hệ *',
                      controller: email,

                      keyboardType: TextInputType.emailAddress,
                      errorText: s.errors['email'],
                      enabled: !s.busy && !s.unresolved,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Wrap(
                      spacing: AppSpacing.s8,
                      children: [
                        AppChoiceChip(
                          label: const Text('Sinh viên FPTU'),
                          selected: group == 'student',
                          onSelected: s.busy || s.unresolved
                              ? null
                              : (_) => setState(() => group = 'student'),
                        ),
                        AppChoiceChip(
                          label: const Text('Khách ngoài trường'),
                          selected: group == 'guest',
                          onSelected: s.busy || s.unresolved
                              ? null
                              : (_) => setState(() => group = 'guest'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    if (group == 'student')
                      AppTextField(
                        labelText: 'Khóa K *',
                        controller: cohort,

                        errorText: s.errors['cohort'],
                        enabled: !s.busy && !s.unresolved,
                      )
                    else
                      AppTextField(
                        labelText: 'Trường / tổ chức (tùy chọn)',
                        controller: organization,
                        errorText: s.errors['organization'],
                        enabled: !s.busy && !s.unresolved,
                      ),
                    const SizedBox(height: AppSpacing.s16),
                    AppTextField(
                      labelText: 'Số điện thoại (tùy chọn)',
                      controller: phone,
                      errorText: s.errors['phone'],
                      keyboardType: TextInputType.phone,
                      enabled: !s.busy && !s.unresolved,
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    const Text(
                      'Nhóm và khóa do bạn tự khai, không xác minh và không giới hạn quyền đăng ký.',
                    ),
                    const SizedBox(height: AppSpacing.s16),
                  ],
                ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: AppButton(
              label: s.unresolved ? 'Kiểm tra trạng thái' : 'Xác nhận đăng ký',
              isFullWidth: true,
              isLoading: s.busy,
              isDisabled: !s.unresolved && value.asData?.value == null,
              onPressed: s.unresolved
                  ? () => ref.read(bookingProvider.notifier).recover()
                  : () => ref
                        .read(bookingProvider.notifier)
                        .submit(
                          widget.eventId,
                          Participant(
                            name: name.text,
                            email: email.text,
                            group: group,
                            cohort: cohort.text,
                            organization: organization.text,
                            phone: phone.text,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
