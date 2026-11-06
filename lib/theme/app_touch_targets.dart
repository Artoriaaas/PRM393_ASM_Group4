import 'package:flutter/material.dart';

/// Touch target constraints ensuring WCAG / Lab 3 rubric compliance (min 48dp)
class AppTouchTargets {
  AppTouchTargets._();

  static const double min = 48.0;

  static const BoxConstraints minConstraints = BoxConstraints(
    minWidth: min,
    minHeight: min,
  );
}
