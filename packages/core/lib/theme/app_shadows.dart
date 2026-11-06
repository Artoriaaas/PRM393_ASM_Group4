import 'package:flutter/material.dart';

/// Shadow tokens from architecture.md / Figma handoff
/// Elevation 0; 0/2/8/0 6%; 0/8/24/0 10%
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> elevation0 = <BoxShadow>[];

  /// Standard card elevation: 0px 2px 8px 0px rgba(0, 0, 0, 0.06)
  static const List<BoxShadow> elevation1 = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// Floating / dialog elevation: 0px 8px 24px 0px rgba(0, 0, 0, 0.10)
  static const List<BoxShadow> elevation2 = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000), // 10% black
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
}
