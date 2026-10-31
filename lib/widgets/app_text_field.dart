import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_touch_targets.dart';
import '../theme/app_typography.dart';

/// Reusable AppTextField adhering to Lab 2 / architecture.md specs:
/// - States: default, focus, filled, error, disabled
/// - Built-in password visibility toggle if obscureText is requested
/// - Min 48dp touch target and accessibility semantics
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
    this.semanticsLabel,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final String? semanticsLabel;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? effectiveSuffixIcon = widget.suffixIcon;

    if (widget.obscureText) {
      effectiveSuffixIcon = Semantics(
        button: true,
        label: _isObscured ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
        child: InkWell(
          onTap: () => setState(() => _isObscured = !_isObscured),
          borderRadius: BorderRadius.circular(24),
          child: ConstrainedBox(
            constraints: AppTouchTargets.minConstraints,
            child: Icon(
              _isObscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: widget.semanticsLabel ?? widget.labelText ?? widget.hintText,
      enabled: widget.enabled,
      textField: true,
      obscured: _isObscured,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.labelText != null) ...[
            Text(
              widget.labelText!,
              style: AppTypography.textTheme.labelMedium?.copyWith(
                color: widget.enabled
                    ? AppColors.textPrimary
                    : AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
          ],
          TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: _isObscured,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.validator,
            maxLines: widget.maxLines,
            style: AppTypography.textTheme.bodyLarge?.copyWith(
              color: widget.enabled
                  ? AppColors.textPrimary
                  : AppColors.textDisabled,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText: widget.errorText,
              errorMaxLines: 5,
              helperMaxLines: 5,
              prefixIcon: widget.prefixIcon != null
                  ? ConstrainedBox(
                      constraints: AppTouchTargets.minConstraints,
                      child: widget.prefixIcon,
                    )
                  : null,
              suffixIcon: effectiveSuffixIcon,
              filled: true,
              fillColor: widget.enabled
                  ? AppColors.surface
                  : AppColors.surfaceSubtle,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
              border: const OutlineInputBorder(
                borderRadius: AppRadius.borderR8,
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.borderR8,
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: AppRadius.borderR8,
                borderSide: BorderSide(
                  color: AppColors.borderFocus,
                  width: 1.5,
                ),
              ),
              errorBorder: const OutlineInputBorder(
                borderRadius: AppRadius.borderR8,
                borderSide: BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: const OutlineInputBorder(
                borderRadius: AppRadius.borderR8,
                borderSide: BorderSide(color: AppColors.error, width: 1.5),
              ),
              disabledBorder: const OutlineInputBorder(
                borderRadius: AppRadius.borderR8,
                borderSide: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
