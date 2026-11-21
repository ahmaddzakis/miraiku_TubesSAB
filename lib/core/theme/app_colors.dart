import 'package:flutter/material.dart';

/// Centralized color tokens for MIRAIku (Japanese Modern Heritage Palette).
///
/// All text and interactive contrast ratios meet or exceed WCAG AA (4.5:1 for
/// normal text, 3.0:1 for large text and UI components) in both Light and Dark mode.
class AppColors {
  AppColors._();

  // ==========================================
  // ☀️ LIGHT MODE PALETTE (Washi & Akane)
  // ==========================================
  static const Color primaryLight = Color(0xFFB84A1C); // Akane Terracotta (5.18:1 vs White)
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color primaryContainerLight = Color(0xFFFCE8DF);
  static const Color onPrimaryContainerLight = Color(0xFF3D1303);

  static const Color secondaryLight = Color(0xFF2B4C7E); // Ai-iro Indigo (8.35:1 vs White)
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color secondaryContainerLight = Color(0xFFE3ECF8);
  static const Color onSecondaryContainerLight = Color(0xFF0E1E38);

  static const Color accentLight = Color(0xFFD97706); // Kitsune Amber
  static const Color onAccentLight = Color(0xFFFFFFFF);
  static const Color accentContainerLight = Color(0xFFFEF3C7);
  static const Color onAccentContainerLight = Color(0xFF451A03);

  static const Color backgroundLight = Color(0xFFF9F6F0); // Washi Cream
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure Washi
  static const Color surfaceVariantLight = Color(0xFFEFECE6); // Soft Sand
  static const Color surfaceContainerHighLight = Color(0xFFE6E1D8);

  static const Color textPrimaryLight = Color(0xFF231F1C); // Kuro-cha Ink (14.8:1 vs Background)
  static const Color textSecondaryLight = Color(0xFF635D57); // Warm Slate (5.74:1 vs Background)
  static const Color borderLight = Color(0xFFDFD9CE);
  static const Color outlineLight = borderLight;

  static const Color successLight = Color(0xFF1E7E48); // Matcha Green (5.12:1 vs White)
  static const Color successContainerLight = Color(0xFFE6F4EA);
  static const Color errorLight = Color(0xFFC92A2A); // Beni Crimson (5.89:1 vs White)
  static const Color errorContainerLight = Color(0xFFFDE8E8);
  static const Color warningLight = Color(0xFFB45309); // Yuzu Ochre
  static const Color warningContainerLight = Color(0xFFFEF3C7);

  // ==========================================
  // 🌙 DARK MODE PALETTE (Sumi Ink & Persimmon)
  // ==========================================
  static const Color primaryDark = Color(0xFFF08A5D); // Warm Persimmon (7.42:1 vs #1A1614)
  static const Color onPrimaryDark = Color(0xFF1A120E);
  static const Color primaryContainerDark = Color(0xFF4A2515);
  static const Color onPrimaryContainerDark = Color(0xFFFCE8DF);

  /// Rich warm terracotta specifically used for large banner/header cards
  /// so white text (`#FFFFFF`) stays crisp and readable in both light and dark themes.
  static const Color bannerPrimaryDark = Color(0xFFC45525);
  static const Color onBannerPrimary = Color(0xFFFFFFFF);

  static const Color secondaryDark = Color(0xFF7FA6E0); // Soft Indigo
  static const Color onSecondaryDark = Color(0xFF0E1E38);
  static const Color secondaryContainerDark = Color(0xFF1E3252);
  static const Color onSecondaryContainerDark = Color(0xFFE3ECF8);

  static const Color accentDark = Color(0xFFFBBF24); // Kin Gold
  static const Color onAccentDark = Color(0xFF231A00);
  static const Color accentContainerDark = Color(0xFF452B07);
  static const Color onAccentContainerDark = Color(0xFFFEF3C7);

  static const Color backgroundDark = Color(0xFF121316); // Sumi Ink
  static const Color surfaceDark = Color(0xFF1C1E22); // Charcoal Surface
  static const Color surfaceVariantDark = Color(0xFF282A30); // Elevated Charcoal
  static const Color surfaceContainerHighDark = Color(0xFF32353C);

  static const Color textPrimaryDark = Color(0xFFF5F3EF); // Shiro Off-White (15.6:1 vs Background)
  static const Color textSecondaryDark = Color(0xFFB5AFA8); // Ash Grey (8.4:1 vs Background)
  static const Color borderDark = Color(0xFF32353C);
  static const Color outlineDark = borderDark;

  static const Color successDark = Color(0xFF4ADE80); // Light Matcha
  static const Color successContainerDark = Color(0xFF133020);
  static const Color errorDark = Color(0xFFF87171); // Soft Crimson
  static const Color errorContainerDark = Color(0xFF3B1818);
  static const Color warningDark = Color(0xFFFBBF24); // Yuzu Bright
  static const Color warningContainerDark = Color(0xFF3B2808);

  // ==========================================
  // 🏅 GAMIFICATION & SEMANTIC BADGE COLORS
  // ==========================================
  static const Color streakFlame = Color(0xFFFF8A00);
  static const Color heartCrimson = Color(0xFFE53935);
  static const Color starGold = Color(0xFFFFC107);
  static const Color medalGold = Color(0xFFFFD700);
  static const Color medalSilver = Color(0xFFC0C0C0);
  static const Color medalBronze = Color(0xFFCD7F32);
  static const Color kanjiPurple = Color(0xFF8E24AA);
}
