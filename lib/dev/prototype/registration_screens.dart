import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/theme.dart';
import '../../widgets/widgets.dart';
import 'prototype_state.dart';
import 'prototype_widgets.dart';

class DemoRegistrationForm extends ConsumerStatefulWidget {
  const DemoRegistrationForm({super.key});
  @override
  ConsumerState<DemoRegistrationForm> createState() =>
      _DemoRegistrationFormState();
}

class _DemoRegistrationFormState extends ConsumerState<DemoRegistrationForm> {
  final name = TextEditingController(text: 'Minh Anh'),
      email = TextEditingController(text: 'minhanh@example.com'),
      phone = TextEditingController(),
      school = TextEditingController();
  bool student = true;
  Map<String, String> errors = {};
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    school.dispose();
    super.dispose();
  }

  Future<void> submit({bool recover = false}) async {
    final vm = ref.read(prototypeProvider.notifier);
    final p = DemoParticipant(
      name: name.text,
      email: email.text,
      phone: phone.text,
      student: student,
      school: school.text,
    );
    setState(() => errors = vm.validate(p));
    if (errors.isNotEmpty) return;
    FocusScope.of(context).unfocus();
    if (await vm.act('register', participant: p, recover: recover) && mounted) {
      demoOpen(context, ref, '/registrations/demo/success', replace: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(prototypeProvider);
    final unknown = s.scenario == DemoScenario.unknown && s.message != null;
    return DemoPage(
      title: 'Thông tin đăng ký',
      allowScenario: false,
      action: AppButton(
        label: unknown ? 'Kiểm tra trạng thái' : 'Xác nhận đăng ký',
        isLoading: s.busy,
        isFullWidth: true,
        onPressed: () => submit(recover: unknown),
      ),
      children: [
        const DemoSummary(),
        if (s.message != null) DemoMessage(s.message!, error: true),
        AppTextField(
          controller: name,
          labelText: 'Họ và tên *',
          errorText: errors['name'],
          enabled: !s.busy,
        ),
        AppTextField(
          controller: email,
          labelText: 'Email liên hệ *',
          errorText: errors['email'],
          enabled: !s.busy,
          keyboardType: TextInputType.emailAddress,
        ),
        AppTextField(
          controller: phone,
          labelText: 'Số điện thoại (tùy chọn)',
          enabled: !s.busy,
          keyboardType: TextInputType.phone,
        ),
        const Text('Bạn là'),
        AppButton(
          label: '${student ? '●' : '○'} Sinh viên FPTU',
          variant: AppButtonVariant.secondary,
          onPressed: s.busy
              ? null
              : () => setState(() {
                  student = true;
                  school.clear();
                }),
        ),
        AppButton(
          label: '${student ? '○' : '●'} Khách ngoài trường',
          variant: AppButtonVariant.secondary,
          onPressed: s.busy
              ? null
              : () => setState(() {
                  student = false;
                  school.clear();
                }),
        ),
        const Text(
          'Thông tin tự khai, không xác minh tư cách sinh viên và không giới hạn quyền đăng ký.',
        ),
        AppTextField(
          controller: school,
          labelText: student ? 'Khóa K *' : 'Trường / tổ chức (tùy chọn)',
          hintText: student ? 'Ví dụ: K18' : 'Nhập trường hoặc tổ chức',
          errorText: errors['school'],
          enabled: !s.busy,
        ),
      ],
    );
  }
}

class DemoRegistrationSuccess extends ConsumerWidget {
  const DemoRegistrationSuccess({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(prototypeProvider);
    if (!s.registered || s.cancelled) {
      return DemoPage(
        title: 'Kết quả đăng ký',
        children: [
          const DemoMessage('Chưa có đăng ký đang hoạt động.'),
          AppButton(
            label: 'Khám phá sự kiện',
            onPressed: () => demoOpen(context, ref, '/discover', replace: true),
          ),
        ],
      );
    }
    return DemoPage(
      title: 'Kết quả đăng ký',
      children: [
        const DemoStatus('Đăng ký thành công'),
        const DemoSummary(),
        DemoPerson(s.participant),
        const DemoMessage(
          'Khi CLB mở điểm danh, hãy dùng app quét mã QR do CLB hiển thị tại sự kiện.',
        ),
        AppButton(
          label: 'Xem lịch tham gia',
          onPressed: () => demoOpen(context, ref, '/schedule', replace: true),
        ),
        AppButton(
          label: 'Xem chi tiết đăng ký',
          variant: AppButtonVariant.secondary,
          onPressed: () => demoOpen(context, ref, '/registrations/demo'),
        ),
      ],
    );
  }
}

class DemoScheduleScreen extends ConsumerStatefulWidget {
  const DemoScheduleScreen({super.key});
  @override
  ConsumerState<DemoScheduleScreen> createState() => _DemoScheduleScreenState();
}

class _DemoScheduleScreenState extends ConsumerState<DemoScheduleScreen> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final s = ref.watch(prototypeProvider);
    final visible =
        s.registered &&
        s.scenario != DemoScenario.empty &&
        (tab == 0
            ? !s.cancelled &&
                  s.scenario != DemoScenario.cancelled &&
                  s.scenario != DemoScenario.ended
            : tab == 2
            ? s.cancelled || s.scenario == DemoScenario.cancelled
            : s.scenario == DemoScenario.ended);
    return DemoPage(
      title: 'Lịch tham gia',
      tab: 1,
      children: [
        Wrap(
          spacing: AppSpacing.s8,
          children: [
            for (var i = 0; i < 3; i++)
              ChoiceChip(
                label: Text(['Sắp tới', 'Đã kết thúc', 'Đã hủy'][i]),
                selected: tab == i,
                onSelected: (_) => setState(() => tab = i),
              ),
          ],
        ),
        if (s.cancelled)
          const DemoMessage(
            'Đã hủy đăng ký. Sự kiện đã được bỏ khỏi Sắp tới.',
            success: true,
          ),
        if (visible) ...[
          DemoMessage(
            s.cancelled
                ? 'Đã hủy đăng ký bởi bạn'
                : s.scenario == DemoScenario.cancelled
                ? 'Sự kiện đã hủy'
                : s.scenario == DemoScenario.ended
                ? 'Đã kết thúc'
                : s.checkedIn
                ? 'Đã điểm danh'
                : 'Đã đăng ký',
            success: !s.cancelled,
          ),
          const DemoSummary(),
          AppButton(
            label: 'Xem chi tiết đăng ký',
            variant: AppButtonVariant.secondary,
            onPressed: () => demoOpen(context, ref, '/registrations/demo'),
          ),
        ] else ...[
          DemoStatus(
            tab == 1
                ? 'Chưa có sự kiện đã kết thúc'
                : tab == 2
                ? 'Chưa có lịch sử hủy'
                : 'Không có sự kiện sắp tới',
            subtitle: 'Khám phá và chọn một sự kiện phù hợp.',
          ),
          AppButton(
            label: 'Khám phá sự kiện',
            onPressed: () => demoOpen(context, ref, '/discover', replace: true),
          ),
        ],
      ],
    );
  }
}

class DemoRegistrationDetail extends ConsumerWidget {
  const DemoRegistrationDetail({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(prototypeProvider);
    final vm = ref.read(prototypeProvider.notifier);
    if (!s.registered) {
      return DemoPage(
        title: 'Chi tiết đăng ký',
        children: [
          const DemoMessage('Bạn chưa có đăng ký cho sự kiện này.'),
          AppButton(
            label: 'Xem sự kiện',
            onPressed: () => demoOpen(context, ref, '/events/workshop'),
          ),
        ],
      );
    }
    final eventCancelled = s.scenario == DemoScenario.cancelled;
    return DemoPage(
      title: 'Chi tiết đăng ký',
      allowScenario: false,
      children: [
        DemoMessage(
          s.cancelled
              ? 'Đã hủy đăng ký bởi bạn'
              : eventCancelled
              ? 'Sự kiện đã hủy'
              : s.checkedIn
              ? 'Đã điểm danh'
              : 'Đã đăng ký',
        ),
        const DemoSummary(),
        DemoPerson(s.participant, showContact: true),
        if (s.message != null) DemoMessage(s.message!, error: true),
        if (s.scenario == DemoScenario.unknown && s.message != null)
          AppButton(
            label: 'Kiểm tra trạng thái hủy',
            isLoading: s.busy,
            onPressed: () async {
              if (await vm.act('cancel', recover: true) && context.mounted) {
                demoOpen(context, ref, '/schedule', replace: true);
              }
            },
          ),
        if (!s.cancelled && !eventCancelled) ...[
          if (s.checkedIn)
            AppButton(
              label: 'Xem xác nhận',
              onPressed: () => demoOpen(
                context,
                ref,
                '/registrations/demo/check-in?revisit=true',
              ),
            )
          else if (s.scenario == DemoScenario.closed)
            const DemoMessage('Phiên điểm danh chưa mở hoặc đã đóng.')
          else
            AppButton(
              label: 'Quét QR',
              onPressed: () =>
                  demoOpen(context, ref, '/registrations/demo/scan'),
            ),
          if (!s.checkedIn && s.scenario != DemoScenario.ended)
            AppButton(
              label: 'Hủy đăng ký',
              variant: AppButtonVariant.secondary,
              isLoading: s.busy,
              onPressed: () async {
                final confirmed = await AppConfirmationDialog.show(
                  context: context,
                  title: 'Hủy đăng ký?',
                  message: 'Chỗ của bạn sẽ được nhường lại cho người khác.',
                  confirmLabel: 'Xác nhận hủy',
                  cancelLabel: 'Giữ đăng ký',
                  isDestructive: true,
                );
                if (confirmed == true &&
                    context.mounted &&
                    await vm.act('cancel') &&
                    context.mounted) {
                  demoOpen(context, ref, '/schedule', replace: true);
                }
              },
            )
          else
            const DemoMessage(
              'Đã điểm danh hoặc sự kiện đã bắt đầu/kết thúc nên không thể hủy đăng ký.',
            ),
        ],
        AppButton(
          label: 'Xem đầy đủ sự kiện',
          variant: AppButtonVariant.text,
          onPressed: () => demoOpen(context, ref, '/events/workshop'),
        ),
        if (s.cancelled || eventCancelled)
          AppButton(
            label: 'Về lịch tham gia',
            onPressed: () => demoOpen(context, ref, '/schedule', replace: true),
          ),
      ],
    );
  }
}
