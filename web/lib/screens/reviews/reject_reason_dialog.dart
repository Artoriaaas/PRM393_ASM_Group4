import 'package:flutter/material.dart';
import 'package:eventhub_core/eventhub_core.dart';

class RejectReasonDialog extends StatefulWidget {
  const RejectReasonDialog({
    super.key,
    required this.participantName,
  });

  final String participantName;

  @override
  State<RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<RejectReasonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderR16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cancel_outlined,
                        color: AppColors.error,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Từ chối đơn đăng ký',
                            style: AppTypography.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Người tham gia: ${widget.participantName}',
                            style: AppTypography.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s16),

                Text(
                  'Vui lòng nhập lý do từ chối. Lý do này sẽ gửi trực tiếp về ứng dụng di động và hộp thư cá nhân của sinh viên.',
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),

                TextFormField(
                  controller: _controller,
                  maxLines: 4,
                  maxLength: 300,
                  validator: (v) {
                    final trimmed = v?.trim() ?? '';
                    if (trimmed.length < 3) {
                      return 'Lý do từ chối bắt buộc có tối thiểu 3 ký tự.';
                    }
                    if (trimmed.length > 300) {
                      return 'Lý do tối đa 300 ký tự.';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Nhập lý do (VD: Khóa K không đúng đối tượng, thông tin chưa đầy đủ...)',
                    filled: true,
                    fillColor: AppColors.surfaceSubtle,
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
                const SizedBox(height: AppSpacing.s20),

                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.s12,
                    runSpacing: AppSpacing.s8,
                    children: [
                      ConstrainedBox(
                        constraints: AppTouchTargets.minConstraints,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Hủy bỏ'),
                        ),
                      ),
                      AppButton(
                        label: 'Xác nhận từ chối',
                        variant: AppButtonVariant.primary,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop(_controller.text.trim());
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
