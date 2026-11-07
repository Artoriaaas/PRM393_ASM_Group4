import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_touch_targets.dart';
import 'app_typography.dart';

/// Central ThemeData assembly for EventHub
class EventHubTheme {
  EventHubTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.textSecondary,
      onSecondary: AppColors.surface,
      secondaryContainer: AppColors.surfaceSubtle,
      onSecondaryContainer: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      outline: AppColors.borderSubtle,
      outlineVariant: AppColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surfaceSubtle,
      textTheme: AppTypography.textTheme,
      extensions: const <ThemeExtension<dynamic>>[EventHubSemanticColors.light],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 18,
          height: 26 / 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderR12,
          side: BorderSide(color: AppColors.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        constraints: const BoxConstraints(minHeight: AppTouchTargets.min),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        errorStyle: AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.error,
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
          borderSide: BorderSide(color: AppColors.borderFocus, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderR8,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderR8,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(AppTouchTargets.min, AppTouchTargets.min),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderR8),
          textStyle: AppTypography.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s12,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppTouchTargets.min, AppTouchTargets.min),
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderR8),
          textStyle: AppTypography.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s20,
            vertical: AppSpacing.s12,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(AppTouchTargets.min, AppTouchTargets.min),
          foregroundColor: AppColors.primary,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderR8),
          textStyle: AppTypography.textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderR16),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
