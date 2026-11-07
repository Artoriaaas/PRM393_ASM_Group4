import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tokens for EventHub using local 'Be Vietnam Pro'
/// Standard sizes & line heights from architecture.md / Figma handoff:
/// 32/40, 28/36, 24/32, 20/28, 18/26, 16/24, 14/21, 14/20, 12/16.
class AppTypography {
  AppTypography._();
  static const double captionFontSize = 12;
  static const double badgeFontSize = 10;
  static const double coverTitleFontSize = 22;

  static const String fontFamily = 'Be Vietnam Pro';

  static const TextTheme textTheme = TextTheme(
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      height: 26 / 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 21 / 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    // Secondary label / caption only. Note: Body text must remain >= 14 sp.
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    ),
  );
}
