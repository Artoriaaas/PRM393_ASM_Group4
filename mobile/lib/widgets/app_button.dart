import 'package:eventhub_core/widgets/app_button.dart' as core;

import '../theme/app_colors.dart';

export 'package:eventhub_core/widgets/app_button.dart' show AppButtonVariant;

/// Mobile reference uses a quiet border for secondary actions.
/// Behavior and accessibility stay in the shared component.
class AppButton extends core.AppButton {
  const AppButton({
    super.key,
    required super.label,
    required super.onPressed,
    super.variant,
    super.isLoading,
    super.isDisabled,
    super.icon,
    super.isFullWidth,
    super.semanticsLabel,
  }) : super(outlineColor: AppColors.border);
}
