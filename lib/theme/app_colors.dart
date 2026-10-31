import 'package:flutter/material.dart';

/// Semantic and palette color tokens for EventHub
/// Defined according to Lab 2 handoff and architecture.md
class AppColors {
  AppColors._();

  // Primary / Action
  static const Color primary = Color(0xFFC74316);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFDE8E1);
  static const Color onPrimaryContainer = Color(0xFF8B2C0B);

  // Surface & Text
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF8F9FB);
  static const Color textPrimary = Color(0xFF2B3445);
  static const Color textSecondary = Color(0xFF5F6B7A);
  static const Color textDisabled = Color(0xFFA0ABBA);

  // Borders
  static const Color border = Color(0xFFE3E7ED);
  static const Color borderSubtle = Color(0xFFCBD2DC);
  static const Color borderFocus = Color(0xFFC74316);

  // Semantic: Error
  static const Color error = Color(0xFFB4233F);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFDE4E8);
  static const Color onErrorContainer = Color(0xFF751426);

  // Semantic: Success
  static const Color success = Color(0xFF147A55);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFDDF4E8);
  static const Color onSuccessContainer = Color(0xFF0C4D35);

  // Semantic: Warning
  static const Color warning = Color(0xFF9A5B00);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFF0D5);
  static const Color onWarningContainer = Color(0xFF613900);

  // Semantic: Info
  static const Color info = Color(0xFF315F9A);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFE7F0FC);
  static const Color onInfoContainer = Color(0xFF1B385D);
}

/// ThemeExtension for semantic colors not standard in Material ColorScheme
@immutable
class EventHubSemanticColors extends ThemeExtension<EventHubSemanticColors> {
  const EventHubSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.surfaceSubtle,
    required this.textSecondary,
    required this.borderColor,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color surfaceSubtle;
  final Color textSecondary;
  final Color borderColor;

  static const light = EventHubSemanticColors(
    success: AppColors.success,
    onSuccess: AppColors.onSuccess,
    successContainer: AppColors.successContainer,
    onSuccessContainer: AppColors.onSuccessContainer,
    warning: AppColors.warning,
    onWarning: AppColors.onWarning,
    warningContainer: AppColors.warningContainer,
    onWarningContainer: AppColors.onWarningContainer,
    info: AppColors.info,
    onInfo: AppColors.onInfo,
    infoContainer: AppColors.infoContainer,
    onInfoContainer: AppColors.onInfoContainer,
    surfaceSubtle: AppColors.surfaceSubtle,
    textSecondary: AppColors.textSecondary,
    borderColor: AppColors.border,
  );

  @override
  EventHubSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? surfaceSubtle,
    Color? textSecondary,
    Color? borderColor,
  }) {
    return EventHubSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      textSecondary: textSecondary ?? this.textSecondary,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  ThemeExtension<EventHubSemanticColors> lerp(
    covariant ThemeExtension<EventHubSemanticColors>? other,
    double t,
  ) {
    if (other is! EventHubSemanticColors) {
      return this;
    }
    return EventHubSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
    );
  }
}
