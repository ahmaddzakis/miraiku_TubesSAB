import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_manager.dart';
import 'repository/local_repository.dart';

class SettingsController {
  static const String _themeKey = 'app_theme_mode';
  static const String _languageKey = 'app_language_code';

  // ValueNotifier for reactive state management (MaterialApp theme)
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  // Singleton pattern for global access
  static final SettingsController _instance = SettingsController._internal();
  static SettingsController get instance => _instance;
  factory SettingsController() => _instance;
  SettingsController._internal();

  /// Updates in-memory [themeMode], [locale], [globalDarkMode], and [globalLanguage]
  /// synchronously without writing to disk or triggering a cloud sync.
  void syncMemoryState({required bool isDark, required String langCode}) {
    final ThemeMode targetTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    final Locale targetLocale = Locale(langCode);
    if (globalDarkMode.value != isDark) {
      globalDarkMode.value = isDark;
    }
    if (themeMode.value != targetTheme) {
      themeMode.value = targetTheme;
    }
    if (globalLanguage.value != langCode) {
      globalLanguage.value = langCode;
    }
    if (locale.value != targetLocale) {
      locale.value = targetLocale;
    }
  }

  /// Synchronizes theme and language with local storage, global notifiers,
  /// and optionally queues a cloud sync when triggered by user interaction.
  Future<void> _syncPrefs(
    bool isDark,
    String langCode, {
    bool syncCloud = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Await Local Persistence first
    await Future.wait([
      prefs.setString(_themeKey, isDark ? 'dark' : 'light'),
      prefs.setBool('is_dark_mode', isDark),
      prefs.setBool('setting_dark', isDark),
      prefs.setString(_languageKey, langCode),
      prefs.setString('app_language', langCode),
      prefs.setString('setting_lang', langCode),
    ]);

    // 2. Update global notifiers to trigger UI rebuilds
    globalDarkMode.value = isDark;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    globalLanguage.value = langCode;
    locale.value = Locale(langCode);

    // 3. Queue settings to cloud only when explicitly changed by the user
    if (syncCloud) {
      await LocalRepository.queueActionsBatch({
        'setting_dark': isDark,
        'setting_lang': langCode,
      });
    }
  }

  /// Strictly initialize settings from SharedPreferences on app startup.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Theme Initialization
    final String? savedTheme = prefs.getString(_themeKey);
    final bool isDark = savedTheme != null
        ? savedTheme == 'dark'
        : (prefs.getBool('is_dark_mode') ??
              prefs.getBool('setting_dark') ??
              false);

    // 2. Language Initialization
    final String? savedLanguage = prefs.getString(_languageKey);
    final String langCode =
        savedLanguage ??
        prefs.getString('app_language') ??
        prefs.getString('setting_lang') ??
        'en';

    // Synchronize local keys & notifiers without firing a premature cloud sync on boot
    await _syncPrefs(isDark, langCode, syncCloud: false);
  }

  /// Toggles between Light and Dark mode
  Future<void> toggleTheme() async {
    final bool nextIsDark = themeMode.value == ThemeMode.light;
    await _syncPrefs(nextIsDark, globalLanguage.value);
  }

  /// Toggles between English and Indonesian
  Future<void> toggleLanguage() async {
    final String nextLang = globalLanguage.value == 'en' ? 'id' : 'en';
    await _syncPrefs(globalDarkMode.value, nextLang);
  }

  /// Explicitly sets the theme
  Future<void> setTheme(bool isDark) async {
    await _syncPrefs(isDark, globalLanguage.value);
  }

  /// Explicitly sets the language
  Future<void> setLanguage(String languageCode) async {
    await _syncPrefs(globalDarkMode.value, languageCode);
  }
}
