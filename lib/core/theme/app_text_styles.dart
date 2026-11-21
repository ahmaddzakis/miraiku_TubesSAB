import 'package:flutter/material.dart';

/// Centralized typography scale for MIRAIku.
///
/// Combines `Nunito` for friendly Latin/Indonesian/English UI text with bundled
/// offline `NotoSansJP` for crisp Japanese Hiragana, Katakana, and Kanji rendering.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamilyUI = 'Nunito';
  static const String fontFamilyJP = 'NotoSansJP';
  static const List<String> fontFallbacks = [fontFamilyJP];

  // ==========================================
  // 🔤 UI TYPOGRAPHY SCALE
  // ==========================================

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 48,
    fontWeight: FontWeight.w900,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 26,
    fontWeight: FontWeight.w900,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    height: 1.35,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 13,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 1.0,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0.9,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyUI,
    fontFamilyFallback: fontFallbacks,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: 0.8,
  );

  // ==========================================
  // 🇯🇵 DEDICATED JAPANESE SCRIPT STYLES
  // ==========================================

  /// Extra-large Japanese characters for flashcard / quiz prompts (64px)
  static const TextStyle japaneseHero = TextStyle(
    fontFamily: fontFamilyJP,
    fontFamilyFallback: [fontFamilyUI],
    fontSize: 64,
    fontWeight: FontWeight.w900,
    height: 1.2,
    letterSpacing: 2.0,
  );

  /// Medium Japanese characters for Kana/Kanji grid tiles and sentences (24px)
  static const TextStyle japaneseTitle = TextStyle(
    fontFamily: fontFamilyJP,
    fontFamilyFallback: [fontFamilyUI],
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.35,
  );

  /// Standard Japanese sentence text in simulation/reading passages (18px)
  static const TextStyle japaneseBody = TextStyle(
    fontFamily: fontFamilyJP,
    fontFamilyFallback: [fontFamilyUI],
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.6,
  );

  /// Builds a complete Material 3 [TextTheme] colored for the target brightness.
  static TextTheme buildTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: primaryTextColor),
      displayMedium: displayMedium.copyWith(color: primaryTextColor),
      headlineLarge: headlineLarge.copyWith(color: primaryTextColor),
      headlineMedium: headlineMedium.copyWith(color: primaryTextColor),
      titleLarge: titleLarge.copyWith(color: primaryTextColor),
      titleMedium: titleMedium.copyWith(color: primaryTextColor),
      bodyLarge: bodyLarge.copyWith(color: primaryTextColor),
      bodyMedium: bodyMedium.copyWith(color: secondaryTextColor),
      labelLarge: labelLarge.copyWith(color: primaryTextColor),
      labelSmall: labelSmall.copyWith(color: secondaryTextColor),
    );
  }
}
