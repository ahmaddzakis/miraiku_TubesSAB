import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized shadow tokens for MIRAIku (Light & Dark modes).
///
/// Provides consistent depth and elevation across all buttons, dialogs,
/// bottom sheets, snackbars, and surface cards without inline hardcoded
/// [BoxShadow] allocations.
class AppShadows {
  AppShadows._();

  // ==========================================
  // 🔘 PRIMARY BUTTON SHADOWS (Tinted Warm Terracotta)
  // ==========================================

  /// Normal state shadow for primary buttons (Light mode).
  static const List<BoxShadow> buttonLight = [
    BoxShadow(
      color: Color(0x33C85A32), // ~20% primary terracotta
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x141F1A17), // ~8% sumi ink ambient
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Normal state shadow for primary buttons (Dark mode).
  static const List<BoxShadow> buttonDark = [
    BoxShadow(
      color: Color(0x38000000), // ~22% soft dark elevation
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x24B8522A), // ~14% warm terracotta glow
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Pressed state shadow for primary buttons (Light mode) — smaller & closer.
  static const List<BoxShadow> buttonPressedLight = [
    BoxShadow(
      color: Color(0x24C85A32), // ~14% primary terracotta
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Pressed state shadow for primary buttons (Dark mode) — smaller & closer.
  static const List<BoxShadow> buttonPressedDark = [
    BoxShadow(
      color: Color(0x26000000), // ~15% dark
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  // ==========================================
  // 🚨 DANGER BUTTON SHADOWS
  // ==========================================

  static const List<BoxShadow> buttonDangerLight = [
    BoxShadow(
      color: Color(0x2EC62828), // ~18% akane crimson
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> buttonDangerDark = [
    BoxShadow(
      color: Color(0x38000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> buttonDangerPressed = [
    BoxShadow(
      color: Color(0x1FC62828),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  // ==========================================
  // 🔲 SECONDARY (OUTLINED) BUTTON SHADOWS
  // ==========================================

  static const List<BoxShadow> buttonSecondaryLight = [
    BoxShadow(
      color: Color(0x141F1A17), // ~8% ambient shadow
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> buttonSecondaryDark = [
    BoxShadow(
      color: Color(0x2E000000), // ~18% ambient shadow
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> buttonSecondaryPressed = [
    BoxShadow(
      color: Color(0x0D1F1A17), // ~5% ambient shadow
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  // ==========================================
  // 💬 DIALOG & POP-UP SHADOWS
  // ==========================================

  /// Soft, wide elevation shadow for pop-up dialogs & bottom sheets (Light mode).
  static const List<BoxShadow> dialogLight = [
    BoxShadow(
      color: Color(0x291F1A17), // ~16% sumi ink
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x12C85A32), // ~7% subtle warm ambient tint
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Soft, wide elevation shadow for pop-up dialogs & bottom sheets (Dark mode).
  static const List<BoxShadow> dialogDark = [
    BoxShadow(
      color: Color(0x52000000), // ~32% deep soft shadow for dark surfaces
      blurRadius: 36,
      offset: Offset(0, 14),
    ),
    BoxShadow(
      color: Color(0x14F28B66), // ~8% subtle warm edge depth
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  // ==========================================
  // 🗂️ CARD & SURFACE SHADOWS
  // ==========================================

  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: Color(0x141F1A17), // ~8% sumi ink
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color(0x33000000), // ~20% dark elevation
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  // ==========================================
  // 🧭 NAVIGATION BAR & FLOATING PILL SHADOWS
  // ==========================================

  static const List<BoxShadow> navBarLight = [
    BoxShadow(
      color: Color(0x141F1A17), // ~8%
      blurRadius: 20,
      offset: Offset(0, -5),
    ),
  ];

  static const List<BoxShadow> navBarDark = [
    BoxShadow(
      color: Color(0x38000000), // ~22%
      blurRadius: 20,
      offset: Offset(0, -5),
    ),
  ];

  // ==========================================
  // 🛠️ THEME-AWARE HELPERS
  // ==========================================

  static List<BoxShadow> button(bool isDark) =>
      isDark ? buttonDark : buttonLight;

  static List<BoxShadow> buttonPressed(bool isDark) =>
      isDark ? buttonPressedDark : buttonPressedLight;

  static List<BoxShadow> buttonDanger(bool isDark) =>
      isDark ? buttonDangerDark : buttonDangerLight;

  static List<BoxShadow> buttonSecondary(bool isDark) =>
      isDark ? buttonSecondaryDark : buttonSecondaryLight;

  static List<BoxShadow> dialog(bool isDark) =>
      isDark ? dialogDark : dialogLight;

  static List<BoxShadow> card(bool isDark) => isDark ? cardDark : cardLight;

  static List<BoxShadow> navBar(bool isDark) =>
      isDark ? navBarDark : navBarLight;

  /// Dynamic accent glow for active nodes, badges, or hero icons.
  static List<BoxShadow> accentGlow(Color color, {bool isDark = false}) => [
        BoxShadow(
          color: color.withValues(alpha: isDark ? 0.25 : 0.20),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ];

  /// Material shadow color token for [DialogThemeData] / [ElevatedButtonThemeData].
  static Color dialogShadowColor(bool isDark) => isDark
      ? const Color(0x73000000)
      : AppColors.textPrimaryLight.withValues(alpha: 0.24);

  static Color buttonShadowColor(bool isDark) => isDark
      ? const Color(0x59000000)
      : AppColors.primaryLight.withValues(alpha: 0.35);
}
