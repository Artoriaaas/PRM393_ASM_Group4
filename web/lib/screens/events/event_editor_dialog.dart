import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eventhub_core/eventhub_core.dart';
import '../../viewmodels/club_events_viewmodel.dart';
import '../../viewmodels/web_auth_viewmodel.dart';
import 'mobile_preview_card.dart';

class EventEditorDialog extends ConsumerStatefulWidget {
  const EventEditorDialog({
    super.key,
    this.initialEvent,
  });

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
    _capacityController =
        TextEditingController(text: ev != null ? '${ev.capacity}' : '50');
    _descriptionController =
        TextEditingController(text: ev?.description ?? '');
    _audienceController = TextEditingController(text: ev?.audience ?? '');
    _preparationController =
        TextEditingController(text: ev?.preparation ?? '');
    _activitiesController =
        TextEditingController(text: ev?.activities.join('\n') ?? '');

    _startsAt = ev?.startsAt ?? DateTime.now().add(const Duration(days: 3));
    _endsAt = ev?.endsAt ?? _startsAt.add(const Duration(hours: 3));
    _deadline = ev?.deadline ?? _startsAt.subtract(const Duration(days: 1));
    _registrationMode = ev?.mode ?? 'required';

    _titleController.addListener(_updatePreview);
    _topicController.addListener(_updatePreview);
    _locationController.addListener(_updatePreview);
    _capacityController.addListener(_updatePreview);
    _descriptionController.addListener(_updatePreview);
    _audienceController.addListener(_updatePreview);
    _preparationController.addListener(_updatePreview);
    _activitiesController.addListener(_updatePreview);
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

  Future<void> _submit(String targetStatus) async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
    final clubId = user?.clubId ?? '';
    final clubName = user?.clubName ?? 'Câu lạc bộ';

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
      id: widget.initialEvent?.id ??
          'ev_${DateTime.now().millisecondsSinceEpoch}',
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
      success: (_) {
        Navigator.of(context).pop(true);
      },
      failure: (failure) {
        setState(() => _errorMessage = failure.message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(webAuthViewModelProvider);
    final user = authState is WebAuthSuccess ? authState.user : null;
    final clubName = user?.clubName ?? 'Câu lạc bộ';

    final capacity = int.tryParse(_capacityController.text.trim()) ?? 0;
    final activities = _activitiesController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderR16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 850),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialEvent != null
                        ? 'Chỉnh sửa sự kiện'
                        : 'Tạo sự kiện mới',
                    style: AppTypography.textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.s12),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: AppRadius.borderR8,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
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
                const SizedBox(height: AppSpacing.s12),
              ],

              // Content Body (Side-by-side or Form)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final showPreview = constraints.maxWidth >= 850;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Form Fields
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: ListView(
                              padding: const EdgeInsets.only(right: AppSpacing.s16),
                              children: [
                                _buildTextField(
                                  controller: _titleController,
                                  label: 'Tiêu đề sự kiện (*)',
                                  hintText: 'Nhập tên sự kiện...',
                                  maxLength: 120,
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
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.s16),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _locationController,
                                        label: 'Địa điểm tổ chức (*)',
                                        hintText: 'VD: Hội trường Beta, Alpha...',
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

                                // Mode selection
                                Text(
                                  'Chế độ tham gia',
                                  style: AppTypography.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s8),
                                Row(
                                  children: [
                                    ChoiceChip(
                                      label: const Text('Yêu cầu đăng ký (required)'),
                                      selected: _registrationMode == 'required',
                                      onSelected: (sel) {
                                        if (sel) {
                                          setState(() => _registrationMode = 'required');
                                        }
                                      },
                                    ),
                                    const SizedBox(width: AppSpacing.s12),
                                    ChoiceChip(
                                      label: const Text('Tham gia tự do (free)'),
                                      selected: _registrationMode == 'free',
                                      onSelected: (sel) {
                                        if (sel) {
                                          setState(() => _registrationMode = 'free');
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.s16),

                                if (_registrationMode == 'required') ...[
                                  _buildTextField(
                                    controller: _capacityController,
                                    label: 'Sức chứa tối đa (*)',
                                    hintText: 'VD: 100',
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      final n = int.tryParse(v?.trim() ?? '');
                                      if (n == null || n <= 0) {
                                        return 'Sức chứa phải là số dương.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.s16),
                                ],

                                _buildTextField(
                                  controller: _descriptionController,
                                  label: 'Mô tả chi tiết',
                                  hintText: 'Nội dung sự kiện...',
                                  maxLines: 3,
                                ),
                                const SizedBox(height: AppSpacing.s16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _audienceController,
                                        label: 'Đối tượng phù hợp',
                                        hintText: 'VD: Sinh viên ngành KTPM...',
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.s16),
                                    Expanded(
                                      child: _buildTextField(
                                        controller: _preparationController,
                                        label: 'Yêu cầu chuẩn bị',
                                        hintText: 'VD: Mang laptop cá nhân...',
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
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Right Column: A04 Live Preview
                        if (showPreview) ...[
                          const VerticalDivider(width: 1, color: AppColors.border),
                          const SizedBox(width: AppSpacing.s16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Xem trước giao diện Mobile (A04)',
                                style: AppTypography.textTheme.labelMedium?.copyWith(
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
                                    description: _descriptionController.text.trim(),
                                    topic: _topicController.text.trim(),
                                    audience: _audienceController.text.trim(),
                                    preparation: _preparationController.text.trim(),
                                    activities: activities,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.s16),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.s12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  AppButton(
                    label: 'Lưu bản nháp',
                    variant: AppButtonVariant.secondary,
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : () => _submit('draft'),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  AppButton(
                    label: 'Công bố sự kiện',
                    variant: AppButtonVariant.primary,
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : () => _submit('published'),
                  ),
                ],
              ),
            ],
          ),
        ),
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
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.surfaceSubtle,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s12,
              vertical: AppSpacing.s12,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderR8,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderR8,
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderR8,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
