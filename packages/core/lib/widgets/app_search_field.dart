import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_touch_targets.dart';
import '../theme/app_typography.dart';

/// AppSearchField adhering to Figma 24:764
/// - Left-aligned search icon
/// - Clear button with accessible touch target
/// - Focus, submit, and live query support
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Tìm kiếm sự kiện, câu lạc bộ...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.leadingIcon,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final Widget? leadingIcon;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final hasNow = _controller.text.isNotEmpty;
    if (hasNow != _hasText) {
      setState(() => _hasText = hasNow);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: widget.hintText,
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: AppColors.surface,
          prefixIcon: ConstrainedBox(
            constraints: AppTouchTargets.minConstraints,
            child:
                widget.leadingIcon ??
                const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
          ),
          suffixIcon: _hasText
              ? Semantics(
                  button: true,
                  label: 'Xóa nội dung tìm kiếm',
                  child: InkWell(
                    onTap: _handleClear,
                    borderRadius: BorderRadius.circular(24),
                    child: ConstrainedBox(
                      constraints: AppTouchTargets.minConstraints,
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              : null,
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
            borderSide: BorderSide(color: AppColors.borderFocus, width: 1.5),
          ),
        ),
      ),
    );
  }
}
