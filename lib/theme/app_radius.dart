import 'package:flutter/material.dart';

/// Corner radius constants from Lab 2 design tokens
/// 6, 8, 12, 16, 24, 999
class AppRadius {
  AppRadius._();

  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r24 = 24.0;
  static const double full = 999.0;

  static const BorderRadius borderR6 = BorderRadius.all(Radius.circular(r6));
  static const BorderRadius borderR8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius borderR12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius borderR16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius borderR24 = BorderRadius.all(Radius.circular(r24));
  static const BorderRadius borderFull = BorderRadius.all(
    Radius.circular(full),
  );
}
