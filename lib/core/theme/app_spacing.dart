import 'package:flutter/material.dart';

/// Centralized spacing, border radius, and layout constants for MIRAIku.
class AppSpacing {
  AppSpacing._();

  // Base 4dp Spacing Scale
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;

  // Border Radius Scale
  static const double radiusSm = 10.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 18.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  static const double radiusPill = 999.0;

  // Accessibility & Responsive Constraints
  static const double minTapTarget = 48.0;
  static const double maxContentWidth = 800.0;
  static const double maxDialogWidth = 500.0;

  // Common Paddings
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets cardPadding = EdgeInsets.all(xl);
  static const EdgeInsets dialogPadding = EdgeInsets.all(xl);

  // Standard Micro-interaction Durations (150ms - 400ms per Design System guidelines)
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 280);
  static const Duration animSlow = Duration(milliseconds: 400);
}
