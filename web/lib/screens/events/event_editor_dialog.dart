import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';

import '../../app/providers.dart';
import '../../viewmodels/club_events_viewmodel.dart';
import '../../viewmodels/web_auth_viewmodel.dart';
import 'mobile_preview_card.dart';

class EventEditorDialog extends ConsumerStatefulWidget {
  const EventEditorDialog({super.key, this.initialEvent});

  final Event? initialEvent;

  @override
  ConsumerState<EventEditorDialog> createState() => _EventEditorDialogState();
}

class _EventEditorDialogState extends ConsumerState<EventEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _topicController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _audienceController;
  late final TextEditingController _preparationController;
  late final TextEditingController _activitiesController;

  late DateTime _startsAt;
  late DateTime _endsAt;
  DateTime? _deadline;
  late String _registrationMode; // 'required' | 'free'

  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final ev = widget.initialEvent;
    _titleController = TextEditingController(text: ev?.title ?? '');
    _topicController = TextEditingController(text: ev?.topic ?? '');
    _locationController = TextEditingController(text: ev?.location ?? '');
    _capacityController = TextEditingController(
      text: ev != null && ev.capacity > 0 ? '${ev.capacity}' : '50',
    );
    _descriptionController = TextEditingController(text: ev?.description ?? '');
    _audienceController = TextEditingController(text: ev?.audience ?? '');
    _preparationController = TextEditingController(text: ev?.preparation ?? '');
    _activitiesController = TextEditingController(
      text: ev?.activities.join('\n') ?? '',
    );

    final baseStart = DateTime.now().add(const Duration(days: 3));
    _startsAt =
        ev?.startsAt ??
        DateTime(baseStart.year, baseStart.month, baseStart.day, 9, 0);
    _endsAt = ev?.endsAt ?? _startsAt.add(const Duration(hours: 3));
    _deadline = ev?.deadline ?? _startsAt.subtract(const Duration(days: 1));
    _registrationMode = ev?.mode ?? 'required';

    for (final c in [
      _titleController,
      _topicController,
      _locationController,
      _capacityController,
      _descriptionController,
      _audienceController,
      _preparationController,
      _activitiesController,
    ]) {
      c.addListener(_updatePreview);
    }
  }

  void _updatePreview() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleController.dispose();
    _topicController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _audienceController.dispose();
    _preparationController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year} • $hh:$min';
  }

  Future<void> _pickDateTime({
    required DateTime current,
    required ValueChanged<DateTime> onPicked,
  }) async {
    if (ref.read(currentStaffProfileProvider)?.isAdmin == true) return;
    final now = DateTime.now();
    final firstDate = current.isBefore(now)
        ? DateTime(current.year, 1, 1)
        : DateTime(now.year, 1, 1);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5, 12, 31),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (pickedTime == null || !mounted) return;

    onPicked(
      DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      ),
    );
  }

  Future<void> _submit(String targetStatus) async {
    if (!_formKey.currentState!.validate()) return;

    if (!_endsAt.isAfter(_startsAt)) {
      setState(() {
        _errorMessage = 'Thời gian kết thúc phải sau thời gian bắt đầu.';
      });
      return;
    }

    if (_registrationMode == 'required') {
      if (_deadline == null || !_deadline!.isBefore(_startsAt)) {
        setState(() {
          _errorMessage = 'Hạn đăng ký phải trước thời gian bắt đầu sự kiện.';
        });
        return;
      }
    }

    final user = ref.read(currentStaffProfileProvider);
    final clubId = ref.read(currentClubIdProvider);
    if (user?.role != 'staff' ||
        clubId.isEmpty ||
        (widget.initialEvent != null &&
            widget.initialEvent!.clubId != clubId)) {
      setState(
        () => _errorMessage =
            'Chỉ CLB được phân công mới có thể tạo hoặc sửa sự kiện của mình.',
      );
      return;
    }
    final clubName =
        widget.initialEvent?.clubName ??
        ref.read(activeClubProvider(clubId)).asData?.value?.name ??
        user?.clubName ??
        'Câu lạc bộ';
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    final isEdit = widget.initialEvent != null;

    if (isEdit &&
        _registrationMode != 'free' &&
        capacity < widget.initialEvent!.activeCount) {
      setState(() {
        _errorMessage =
            'Sức chứa không được nhỏ hơn số lượt đã duyệt hiện tại (${widget.initialEvent!.activeCount}).';
      });
      return;
    }

    final activities = _activitiesController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final eventToSave = Event(
      id: widget.initialEvent?.id ?? '',
      title: _titleController.text.trim(),
      clubName: clubName,
      location: _locationController.text.trim(),
      startsAt: _startsAt,
      endsAt: _endsAt,
      deadline: _registrationMode == 'free' ? null : _deadline,
      description: _descriptionController.text.trim(),
      topic: _topicController.text.trim(),
      audience: _audienceController.text.trim(),
      preparation: _preparationController.text.trim(),
      activities: activities,
      coverKey: widget.initialEvent?.coverKey ?? '',
      coverUrl: widget.initialEvent?.coverUrl ?? '',
      mode: _registrationMode,
      status: targetStatus,
      capacity: _registrationMode == 'free' ? 0 : capacity,
      activeCount: widget.initialEvent?.activeCount ?? 0,
      clubId: clubId,
      visibility: 'public',
      updatedAt: DateTime.now(),
    );

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final res = await ref
        .read(clubEventsViewModelProvider.notifier)
        .saveEvent(eventToSave, isNew: !isEdit);

    if (!mounted) return;
    setState(() => _isSaving = false);

    res.when(
      success: (_) => Navigator.of(context).pop(true),
      failure: (failure) => setState(() => _errorMessage = failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentStaffProfileProvider);
    final isAdmin = user?.isAdmin ?? false;
    final clubId = ref.watch(currentClubIdProvider);
    final clubName =
        ref.watch(activeClubProvider(clubId)).asData?.value?.name ??
        user?.clubName ??
        'Câu lạc bộ';

    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    final activities = _activitiesController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final existingStatus = widget.initialEvent?.status;
    final isEditingNonDraft =
        existingStatus != null && existingStatus != 'draft';

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(AppSpacing.s24),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderR16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1120, maxHeight: 860),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isAdmin
                          ? (widget.initialEvent?.status == 'pending_approval'
                                ? 'Xét duyệt Đề xuất Sự kiện'
                                : 'Chi tiết Sự kiện')
                          : (widget.initialEvent != null
                                ? 'Chỉnh sửa sự kiện'
                                : 'Tạo sự kiện mới'),
                      style: AppTypography.textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: AppTouchTargets.minConstraints,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Đóng hộp thoại',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.s12),
              if (isAdmin && widget.initialEvent != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandSubtle,
                    borderRadius: AppRadius.borderR8,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          'CLB Đề xuất: ${widget.initialEvent!.clubName.isNotEmpty ? widget.initialEvent!.clubName : "Câu lạc bộ"} • Chế độ xem xét phê duyệt dành cho Quản trị viên',
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
              ],
              if (_errorMessage != null) ...[
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
                            _errorMessage!,
                            style: AppTypography.textTheme.bodyMedium?.copyWith(
                              color: AppColors.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),
              ],
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showPreview = constraints.maxWidth >= 850;
                    final formWidget = ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          padding: EdgeInsets.only(
                            right: showPreview ? AppSpacing.s16 : 0,
                          ),
                          children: [
                            _buildTextField(
                              controller: _titleController,
                              label: 'Tiêu đề sự kiện (*)',
                              hintText: 'Nhập tên sự kiện...',
                              maxLength: 120,
                              readOnly: isAdmin,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Vui lòng nhập tiêu đề.';
                                }
                                if (v.trim().length > 120) {
                                  return 'Tiêu đề không quá 120 ký tự.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _topicController,
                                    label: 'Chủ đề',
                                    hintText: 'VD: AI, Mobile, Thiết kế...',
                                    readOnly: isAdmin,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _locationController,
                                    label: 'Địa điểm tổ chức (*)',
                                    hintText: 'VD: Hội trường Beta, Alpha...',
                                    readOnly: isAdmin,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Vui lòng nhập địa điểm.';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDateTimeField(
                                    label: 'Thời gian bắt đầu (*)',
                                    valueText: _formatDateTime(_startsAt),
                                    onTap: () => _pickDateTime(
                                      current: _startsAt,
                                      onPicked: (dt) => setState(() {
                                        _startsAt = dt;
                                        if (!_endsAt.isAfter(_startsAt)) {
                                          _endsAt = _startsAt.add(
                                            const Duration(hours: 2),
                                          );
                                        }
                                      }),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s16),
                                Expanded(
                                  child: _buildDateTimeField(
                                    label: 'Thời gian kết thúc (*)',
                                    valueText: _formatDateTime(_endsAt),
                                    onTap: () => _pickDateTime(
                                      current: _endsAt,
                                      onPicked: (dt) =>
                                          setState(() => _endsAt = dt),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            Text(
                              'Chế độ tham gia',
                              style: AppTypography.textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: AppSpacing.s8),
                            Wrap(
                              spacing: AppSpacing.s12,
                              runSpacing: AppSpacing.s8,
                              children: [
                                ChoiceChip(
                                  label: const Text(
                                    'Yêu cầu đăng ký (required)',
                                  ),
                                  selected: _registrationMode == 'required',
                                  onSelected: isAdmin
                                      ? null
                                      : (sel) {
                                          if (sel) {
                                            setState(() {
                                              _registrationMode = 'required';
                                              _deadline ??= _startsAt.subtract(
                                                const Duration(days: 1),
                                              );
                                            });
                                          }
                                        },
                                ),
                                ChoiceChip(
                                  label: const Text('Tham gia tự do (free)'),
                                  selected: _registrationMode == 'free',
                                  onSelected: isAdmin
                                      ? null
                                      : (sel) {
                                          if (sel) {
                                            setState(
                                              () => _registrationMode = 'free',
                                            );
                                          }
                                        },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            if (_registrationMode == 'required') ...[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildDateTimeField(
                                      label: 'Hạn đăng ký (*)',
                                      valueText: _deadline != null
                                          ? _formatDateTime(_deadline!)
                                          : 'Chọn hạn đăng ký',
                                      onTap: () => _pickDateTime(
                                        current:
                                            _deadline ??
                                            _startsAt.subtract(
                                              const Duration(days: 1),
                                            ),
                                        onPicked: (dt) =>
                                            setState(() => _deadline = dt),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s16),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _capacityController,
                                      label: 'Sức chứa tối đa (*)',
                                      hintText: 'VD: 100',
                                      keyboardType: TextInputType.number,
                                      readOnly: isAdmin,
                                      validator: (v) {
                                        final n = int.tryParse(v?.trim() ?? '');
                                        if (n == null || n <= 0) {
                                          return 'Sức chứa phải là số dương.';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.s16),
                            ],
                            _buildTextField(
                              controller: _descriptionController,
                              label: 'Mô tả chi tiết',
                              hintText: 'Nội dung sự kiện...',
                              maxLines: 3,
                              readOnly: isAdmin,
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _audienceController,
                                    label: 'Đối tượng phù hợp',
                                    hintText: 'VD: Sinh viên ngành KTPM...',
                                    readOnly: isAdmin,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _preparationController,
                                    label: 'Yêu cầu chuẩn bị',
                                    hintText: 'VD: Mang laptop cá nhân...',
                                    readOnly: isAdmin,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            _buildTextField(
                              controller: _activitiesController,
                              label: 'Các hoạt động chính (mỗi dòng một mục)',
                              hintText: 'VD:\nCheck-in nhận quà\nDiễn giả chia sẻ\nQ&A',
                              maxLines: 3,
                              readOnly: isAdmin,
                            ),
                          ],
                        ),
                      ),
                    );

                    if (!showPreview) {
                      return Center(child: formWidget);
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: formWidget),
                        const VerticalDivider(
                          width: 1,
                          color: AppColors.border,
                        ),
                        const SizedBox(width: AppSpacing.s16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Xem trước giao diện Mobile (A04)',
                              style: AppTypography.textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            Expanded(
                              child: SingleChildScrollView(
                                child: MobilePreviewCard(
                                  title: _titleController.text.trim(),
                                  clubName: clubName,
                                  location: _locationController.text.trim(),
                                  startsAt: _startsAt,
                                  endsAt: _endsAt,
                                  deadline: _deadline,
                                  registrationMode: _registrationMode,
                                  capacity: capacity,
                                  description: _descriptionController.text
                                      .trim(),
                                  topic: _topicController.text.trim(),
                                  audience: _audienceController.text.trim(),
                                  preparation: _preparationController.text
                                      .trim(),
                                  activities: activities,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.s12),
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.s12,
                runSpacing: AppSpacing.s8,
                children: [
                  ConstrainedBox(
                    constraints: AppTouchTargets.minConstraints,
                    child: TextButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        isAdmin && widget.initialEvent != null ? 'Đóng' : 'Hủy',
                      ),
                    ),
                  ),
                  if (isAdmin &&
                      existingStatus == 'pending_approval' &&
                      widget.initialEvent != null) ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Từ chối đề xuất'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showRejectDialog(context, widget.initialEvent!);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text('Phê duyệt sự kiện'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.onSuccess,
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        ref
                            .read(clubEventsViewModelProvider.notifier)
                            .approveEvent(widget.initialEvent!.id);
                      },
                    ),
                  ] else if (!isAdmin) ...[
                    if (!isEditingNonDraft)
                      AppButton(
                        label: 'Lưu bản nháp',
                        variant: AppButtonVariant.secondary,
                        isLoading: _isSaving,
                        onPressed: _isSaving ? null : () => _submit('draft'),
                      ),
                    if (isEditingNonDraft && existingStatus != 'published')
                      AppButton(
                        label: 'Lưu cập nhật',
                        variant: AppButtonVariant.secondary,
                        isLoading: _isSaving,
                        onPressed: _isSaving
                            ? null
                            : () => _submit(existingStatus),
                      ),
                    AppButton(
                      label: existingStatus == 'published'
                          ? 'Cập nhật sự kiện'
                          : (existingStatus == 'pending_approval'
                                ? 'Cập nhật đề xuất'
                                : 'Gửi Admin phê duyệt'),
                      variant: AppButtonVariant.primary,
                      isLoading: _isSaving,
                      onPressed: _isSaving
                          ? null
                          : () => _submit(
                              existingStatus == 'published'
                                  ? 'published'
                                  : 'pending_approval',
                            ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        Semantics(
          button: true,
          label: '$label: $valueText',
          child: Material(
            color: AppColors.surfaceSubtle,
            borderRadius: AppRadius.borderR8,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.borderR8,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppTouchTargets.min,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.borderR8,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.s8),
                      Expanded(
                        child: Text(
                          valueText,
                          style: AppTypography.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showRejectDialog(BuildContext context, Event event) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Từ chối đề xuất sự kiện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhập lý do từ chối sự kiện "${event.title}" của ${event.clubName}:',
            ),
            const SizedBox(height: AppSpacing.s12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Lý do từ chối...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surface,
            ),
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) return;
              Navigator.of(ctx).pop();
              ref
                  .read(clubEventsViewModelProvider.notifier)
                  .rejectEvent(event.id, reason: reason);
            },
            child: const Text('Từ chối đề xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          readOnly: readOnly,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.surfaceSubtle,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s12,
            ),
            border: const OutlineInputBorder(
              borderRadius: AppRadius.borderR8,
              borderSide: BorderSide(color: AppColors.borderSubtle),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderR8,
              borderSide: BorderSide(color: AppColors.borderSubtle),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppRadius.borderR8,
              borderSide: BorderSide(color: AppColors.borderFocus, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
