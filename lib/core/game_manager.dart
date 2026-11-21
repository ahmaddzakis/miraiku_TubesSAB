import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sound_manager.dart';
import 'notification_service.dart';
import 'repository/local_repository.dart';
import 'settings_controller.dart';
import 'widget_service.dart';

// ==========================================
// 🌍 VARIABEL GLOBAL (STATE MANAGEMENT)
// ==========================================
final ValueNotifier<int> globalHearts = ValueNotifier<int>(5);
final ValueNotifier<int> globalXP = ValueNotifier<int>(0);
final ValueNotifier<int> globalStreak = ValueNotifier<int>(0);
final ValueNotifier<int> globalStreakShields = ValueNotifier<int>(0);
final ValueNotifier<int> globalSimulationCount = ValueNotifier<int>(0);
final ValueNotifier<String> globalTimerText = ValueNotifier<String>("Penuh");

final ValueNotifier<bool> globalDarkMode = ValueNotifier<bool>(false);
final ValueNotifier<String> globalLanguage = ValueNotifier<String>('en');
final ValueNotifier<bool> globalIsPremium = ValueNotifier<bool>(false);
final ValueNotifier<String> globalAvatarUrl = ValueNotifier<String>('');
final ValueNotifier<TimeOfDay> globalReminderTime = ValueNotifier<TimeOfDay>(
  const TimeOfDay(hour: 19, minute: 0),
);
final ValueNotifier<List<String>> globalLearnedHiragana =
    ValueNotifier<List<String>>([]);
final ValueNotifier<List<String>> globalLearnedKatakana =
    ValueNotifier<List<String>>([]);
final ValueNotifier<List<String>> globalLearnedKanji =
    ValueNotifier<List<String>>([]);
final ValueNotifier<List<dynamic>> globalSimulationHistory =
    ValueNotifier<List<dynamic>>([]);

class GameManager {
  static const int maxHearts = 5;
  static const int maxStreakShields = 3;
  static const int streakShieldCostXP = 300;
  static const int cooldownMinutes = 20; // 20 Menit per 1 Nyawa
  static Timer? _uiTimer;
  static DateTime? _lastHeartLossTime;

  static StreamSubscription<AuthState>? _authSubscription;

  // 1. FUNGSI INISIALISASI (Dipanggil saat aplikasi baru dibuka)
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      // Ambil data dari Supabase jika user sedang login
      final meta = user?.userMetadata ?? {};

      // Prioritaskan data Cloud, jika tidak ada baru ambil Lokal
      _updateLocalStateFromMeta(meta, prefs);

      await _checkDailyStreak(prefs);
      await _calculateOfflineRegen(prefs);
      _startTicker();
      _startAuthListener();
    } catch (e) {
      debugPrint("GameManager Initialization Error: $e");
    }
  }

  // Helper untuk update state global dari metadata
  static void _updateLocalStateFromMeta(
    Map<String, dynamic> meta,
    SharedPreferences prefs,
  ) {
    // 1. Core Stats (Anti-Rollback logic for XP)
    final int cloudXP = (meta['gm_xp'] as num?)?.toInt() ?? 0;
    final int localXP = prefs.getInt('gm_xp') ?? 0;
    globalXP.value = cloudXP > localXP ? cloudXP : localXP;

    globalHearts.value =
        (meta['gm_hearts'] as num?)?.toInt() ?? prefs.getInt('gm_hearts') ?? 5;
    globalStreak.value =
        (meta['gm_streak'] as num?)?.toInt() ?? prefs.getInt('gm_streak') ?? 0;
    globalStreakShields.value =
        ((meta['gm_streak_shields'] as num?)?.toInt() ??
                prefs.getInt('gm_streak_shields') ??
                0)
            .clamp(0, maxStreakShields);
    globalSimulationCount.value =
        (meta['gm_simulation_count'] as num?)?.toInt() ??
        prefs.getInt('simulation_completed_count') ??
        0;

    // 2. Settings (Synchronized with SettingsController)
    final bool resolvedDark =
        meta['setting_dark'] ??
        prefs.getBool('is_dark_mode') ??
        prefs.getBool('setting_dark') ??
        false;
    final String resolvedLang =
        meta['setting_lang'] ??
        prefs.getString('app_language') ??
        prefs.getString('setting_lang') ??
        'en';
    globalDarkMode.value = resolvedDark;
    globalLanguage.value = resolvedLang;
    SettingsController.instance.syncMemoryState(
      isDark: resolvedDark,
      langCode: resolvedLang,
    );

    // Restore notification preference
    final bool isReminderOn =
        meta['is_daily_reminder_on'] ??
        prefs.getBool('is_daily_reminder_on') ??
        false;
    prefs.setBool('is_daily_reminder_on', isReminderOn);
    if (isReminderOn) {
      NotificationService().scheduleDailyStudyReminder(globalLanguage.value);
    }
    globalIsPremium.value =
        meta['is_premium'] ?? prefs.getBool('is_premium') ?? false;
    globalAvatarUrl.value =
        meta['avatar_url'] ?? prefs.getString('gm_avatar_url') ?? '';

    // Reminder Time
    final int rHour =
        meta['reminder_hour'] ?? prefs.getInt('reminder_hour') ?? 19;
    final int rMinute =
        meta['reminder_minute'] ?? prefs.getInt('reminder_minute') ?? 0;
    globalReminderTime.value = TimeOfDay(hour: rHour, minute: rMinute);

    // 3. Learned Characters
    if (meta['learned_hiragana'] != null) {
      globalLearnedHiragana.value = List<String>.from(meta['learned_hiragana']);
    } else {
      globalLearnedHiragana.value =
          prefs.getStringList('learned_hiragana_list') ?? [];
    }

    if (meta['learned_katakana'] != null) {
      globalLearnedKatakana.value = List<String>.from(meta['learned_katakana']);
    } else {
      globalLearnedKatakana.value =
          prefs.getStringList('learned_katakana_list') ?? [];
    }

    if (meta['learned_kanji'] != null) {
      globalLearnedKanji.value = List<String>.from(meta['learned_kanji']);
    } else {
      globalLearnedKanji.value =
          prefs.getStringList('learned_kanji_list') ?? [];
    }

    // 4. Simulation History
    if (meta['simulation_history'] != null) {
      globalSimulationHistory.value = List<dynamic>.from(
        meta['simulation_history'],
      );
    } else {
      final historyJson = prefs.getString('simulation_history') ?? '[]';
      try {
        globalSimulationHistory.value = jsonDecode(historyJson);
      } catch (e) {
        debugPrint("Error decoding simulation history: $e");
        globalSimulationHistory.value = [];
      }
    }

    // 5. Timestamps for Streak/Heart Sync
    if (meta['gm_last_login'] != null) {
      prefs.setString('gm_last_login', meta['gm_last_login']);
    }
    if (meta['gm_last_heart_loss'] != null) {
      final String lossStr = meta['gm_last_heart_loss'].toString();
      prefs.setString('gm_last_heart_loss', lossStr);
      _lastHeartLossTime = DateTime.tryParse(lossStr);
    } else {
      final String? localLossStr = prefs.getString('gm_last_heart_loss');
      _lastHeartLossTime = localLossStr != null
          ? DateTime.tryParse(localLossStr)
          : null;
    }
    if (meta['gm_last_daily_claim'] != null) {
      prefs.setString('gm_last_daily_claim', meta['gm_last_daily_claim']);
    } else {
      prefs.remove('gm_last_daily_claim');
    }

    // 6. Unit Progress (u1_, u2_, u3_, u4_)
    meta.forEach((key, value) {
      if (key.startsWith('u1_') ||
          key.startsWith('u2_') ||
          key.startsWith('u3_') ||
          key.startsWith('u4_')) {
        if (value is int) {
          prefs.setInt(key, value);
        }
      }
    });

    _saveProgressToLocal(prefs);
  }

  // Fungsi pembantu untuk menyimpan state saat ini ke SharedPreferences
  static void _saveProgressToLocal(SharedPreferences prefs) {
    prefs.setInt('gm_hearts', globalHearts.value);
    prefs.setInt('gm_xp', globalXP.value);
    prefs.setInt('gm_streak', globalStreak.value);
    prefs.setInt('gm_streak_shields', globalStreakShields.value);
    prefs.setInt('simulation_completed_count', globalSimulationCount.value);
    prefs.setBool('setting_dark', globalDarkMode.value);
    prefs.setString('setting_lang', globalLanguage.value);
    prefs.setBool('is_dark_mode', globalDarkMode.value);
    prefs.setString('app_language', globalLanguage.value);
    prefs.setBool('is_premium', globalIsPremium.value);
    prefs.setString('gm_avatar_url', globalAvatarUrl.value);
    prefs.setInt('reminder_hour', globalReminderTime.value.hour);
    prefs.setInt('reminder_minute', globalReminderTime.value.minute);
    prefs.setStringList('learned_hiragana_list', globalLearnedHiragana.value);
    prefs.setStringList('learned_katakana_list', globalLearnedKatakana.value);
    prefs.setStringList('learned_kanji_list', globalLearnedKanji.value);
    prefs.setString(
      'simulation_history',
      jsonEncode(globalSimulationHistory.value),
    );
  }

  // Reset semua progress ke default (digunakan saat logout)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Reset ValueNotifiers & in-memory state to defaults
    globalHearts.value = 5;
    globalXP.value = 0;
    globalAvatarUrl.value = '';
    globalStreak.value = 0;
    globalStreakShields.value = 0;
    globalSimulationCount.value = 0;
    globalIsPremium.value = false;
    globalReminderTime.value = const TimeOfDay(hour: 19, minute: 0);
    globalLearnedHiragana.value = [];
    globalLearnedKatakana.value = [];
    globalLearnedKanji.value = [];
    globalSimulationHistory.value = [];
    globalTimerText.value = "Penuh";
    _lastHeartLossTime = null;

    // 2. Clear notification preferences
    await prefs.setBool('is_daily_reminder_on', false);

    // 3. Hapus semua data terkait game di SharedPreferences agar tidak bocor ke user lain
    final keys = prefs.getKeys().toList();
    for (final String key in keys) {
      if (key.startsWith('u1_') ||
          key.startsWith('u2_') ||
          key.startsWith('u3_') ||
          key.startsWith('u4_') ||
          key.startsWith('gm_') ||
          key.startsWith('learned_') ||
          key.startsWith('setting_') ||
          key.startsWith('cache_') || // Wipe cache keys
          key == 'is_premium' ||
          key == 'simulation_completed_count' ||
          key == 'simulation_history' ||
          key == 'last_claimed_streak' ||
          key == 'has_new_activity' ||
          key == 'pending_sync_actions') {
        // Wipe sync queue
        await prefs.remove(key);
      }
    }
  }

  // Inisialisasi akun baru dengan nilai default
  static Future<void> initializeNewAccount() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Set default values
    globalHearts.value = 5;
    globalStreak.value = 1; // Hari pertama login
    globalStreakShields.value = 1; // Free starter Streak Shield (Core Drive 4 & 8)
    globalXP.value = 0;
    globalSimulationCount.value = 0;
    globalIsPremium.value = false;
    globalReminderTime.value = const TimeOfDay(hour: 19, minute: 0);
    globalLearnedHiragana.value = [];
    globalLearnedKatakana.value = [];
    globalLearnedKanji.value = [];
    globalSimulationHistory.value = [];
    _lastHeartLossTime = null;

    // 2. Set default timestamps
    final DateTime today = DateTime.now();
    final DateTime todayMidnight = DateTime(today.year, today.month, today.day);
    prefs.setString('gm_last_login', todayMidnight.toIso8601String());

    // 3. Reset all unit progress keys in SharedPreferences
    final keys = prefs.getKeys().toList();
    for (final String key in keys) {
      if (key.startsWith('u1_') ||
          key.startsWith('u2_') ||
          key.startsWith('u3_') ||
          key.startsWith('u4_') ||
          key.startsWith('learned_')) {
        await prefs.remove(key);
      }
    }

    // 4. Save to Local
    _saveProgressToLocal(prefs);

    // 5. Sync to Cloud
    await syncToCloud();
  }

  // Fetch latest cloud data and hydrate state (used during login/startup)
  static Future<void> fetchAndHydrateState() async {
    try {
      final meta = await LocalRepository.getUserProgress();
      final prefs = await SharedPreferences.getInstance();
      _updateLocalStateFromMeta(meta, prefs);
      debugPrint("State hydrated successfully from cloud.");
    } catch (e) {
      debugPrint("State hydration error: $e");
    }
  }

  static void _startAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      final AuthChangeEvent event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn) {
        if (session != null) {
          final user = session.user;
          final prefs = await SharedPreferences.getInstance();
          _updateLocalStateFromMeta(user.userMetadata ?? {}, prefs);
          await _checkDailyStreak(prefs);
          await _calculateOfflineRegen(prefs);
        }
      } else if (event == AuthChangeEvent.userUpdated) {
        // Avoid re-hydrating and triggering a feedback sync loop while our own
        // LocalRepository batch sync is pushing metadata updates.
        if (session != null && !LocalRepository.isSyncing) {
          final user = session.user;
          final prefs = await SharedPreferences.getInstance();
          _updateLocalStateFromMeta(user.userMetadata ?? {}, prefs);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        // Reset state di memori dan lokal saat logout
        await resetProgress();
      }
    });
  }

  static Future<void> syncToCloud({
    String? displayName,
    String? bio,
    String? avatarUrl,
    Map<String, dynamic>? extraData,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final Map<String, dynamic> updateData = {
          'gm_xp': globalXP.value,
          'gm_hearts': globalHearts.value,
          'gm_streak': globalStreak.value,
          'gm_streak_shields': globalStreakShields.value,
          'gm_simulation_count': globalSimulationCount.value,
          'avatar_url': globalAvatarUrl.value,
          'setting_dark': globalDarkMode.value,
          'setting_lang': globalLanguage.value,
          'is_daily_reminder_on':
              prefs.getBool('is_daily_reminder_on') ?? false,
          'reminder_hour': globalReminderTime.value.hour,
          'reminder_minute': globalReminderTime.value.minute,
          'is_premium': globalIsPremium.value,
          'learned_hiragana': globalLearnedHiragana.value,
          'learned_katakana': globalLearnedKatakana.value,
          'learned_kanji': globalLearnedKanji.value,
          'simulation_history': globalSimulationHistory.value,
          'gm_last_login': prefs.getString('gm_last_login'),
          'gm_last_heart_loss': prefs.getString('gm_last_heart_loss'),
          'gm_last_daily_claim': prefs.getString('gm_last_daily_claim'),
        };

        // --- SYNC ALL UNIT PROGRESS ---
        final keys = prefs.getKeys();
        for (final String key in keys) {
          if (key.startsWith('u1_') ||
              key.startsWith('u2_') ||
              key.startsWith('u3_') ||
              key.startsWith('u4_')) {
            updateData[key] = prefs.getInt(key);
          }
        }

        // Tambahkan data profil jika disediakan
        if (displayName != null) updateData['display_name'] = displayName;
        if (bio != null) updateData['bio'] = bio;
        if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
        if (extraData != null) updateData.addAll(extraData);

        // Enqueue all actions in a single batch and trigger one cloud sync
        await LocalRepository.queueActionsBatch(updateData);
      } catch (e) {
        debugPrint("Gagal sinkronisasi progress ke Cloud: $e");
      }
    }
  }

  // 2. LOGIKA STREAK HARIAN + STREAK SHIELD (Core Drive 2 & Core Drive 8)
  static Future<void> _checkDailyStreak(SharedPreferences prefs) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final meta = user.userMetadata ?? {};
    final String? lastLoginStr =
        meta['gm_last_login'] ?? prefs.getString('gm_last_login');

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    if (lastLoginStr != null) {
      try {
        final DateTime lastLogin = DateTime.parse(lastLoginStr);
        final DateTime lastLoginDay = DateTime(
          lastLogin.year,
          lastLogin.month,
          lastLogin.day,
        );

        final int differenceInDays = today.difference(lastLoginDay).inDays;

        if (differenceInDays == 1) {
          // Login beruntun (+1 hari)
          globalStreak.value += 1;

          // BONUS MINGGUAN (Tiap kelipatan 7 hari dapat 500 XP)
          if (globalStreak.value > 0 && globalStreak.value % 7 == 0) {
            await addXP(500);
          }
        } else if (differenceInDays > 1) {
          final int missedDays = differenceInDays - 1;
          if (globalStreakShields.value >= missedDays &&
              globalStreak.value > 0) {
            // Core Drive 8 (Loss & Avoidance - White-Hat Balanced):
            // Consume Streak Shields to protect existing streak from resetting
            globalStreakShields.value -= missedDays;
            await prefs.setInt('gm_streak_shields', globalStreakShields.value);
          } else {
            // Bolong lebih dari jumlah shield yang dimiliki -> Streak reset ke 1
            globalStreak.value = 1;
          }
        } else if (differenceInDays <= 0) {
          // Sudah login hari ini, jangan ubah streak
          return;
        }
      } catch (e) {
        debugPrint("Error parsing last login date: $e");
        globalStreak.value = 1;
      }
    } else {
      // Login pertama kali
      globalStreak.value = 1;
    }

    await prefs.setInt('gm_streak', globalStreak.value);
    await prefs.setString('gm_last_login', today.toIso8601String());

    // Update Home Widget
    await WidgetService.updateStreakWidget(globalStreak.value);

    // Sync ke cloud agar metadata terupdate real-time
    await syncToCloud();
  }

  // 3. LOGIKA REGENERASI NYAWA OFFLINE (Saat aplikasi ditutup)
  static Future<void> _calculateOfflineRegen(SharedPreferences prefs) async {
    if (globalHearts.value >= maxHearts) {
      _lastHeartLossTime = null;
      return;
    }

    final String? lastHeartLossStr = prefs.getString('gm_last_heart_loss');
    if (lastHeartLossStr != null) {
      try {
        final DateTime lastLoss = DateTime.parse(lastHeartLossStr);
        _lastHeartLossTime = lastLoss;
        final DateTime now = DateTime.now();

        final int minutesPassed = now.difference(lastLoss).inMinutes;
        final int heartsRecovered = minutesPassed ~/ cooldownMinutes;

        if (heartsRecovered > 0) {
          final int newHearts = globalHearts.value + heartsRecovered;
          if (newHearts >= maxHearts) {
            globalHearts.value = maxHearts;
            _lastHeartLossTime = null;
            await prefs.remove('gm_last_heart_loss');
          } else {
            globalHearts.value = newHearts;
            // Sisakan waktu tanggung (contoh: lewat 25 menit -> tambah 1 nyawa, sisa 5 menit cooldown)
            final int remainderMinutes = minutesPassed % cooldownMinutes;
            final DateTime updatedLossTime = now.subtract(
              Duration(minutes: remainderMinutes),
            );
            _lastHeartLossTime = updatedLossTime;
            await prefs.setString(
              'gm_last_heart_loss',
              updatedLossTime.toIso8601String(),
            );
          }
          await prefs.setInt('gm_hearts', globalHearts.value);
        }
      } catch (e) {
        debugPrint("Error parsing last heart loss date: $e");
        _lastHeartLossTime = null;
        await prefs.remove('gm_last_heart_loss');
      }
    }
  }

  // 4. TIMER UNTUK UPDATE TEKS DI LAYAR (Jalan tiap 1 detik dari state memori)
  static void _startTicker() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (globalIsPremium.value) {
        if (globalHearts.value != maxHearts) {
          globalHearts.value = maxHearts;
        }
        if (globalTimerText.value != "∞") {
          globalTimerText.value = "∞";
        }
        return;
      }

      if (globalHearts.value >= maxHearts) {
        if (globalTimerText.value != "Penuh") {
          globalTimerText.value = "Penuh";
        }
        return;
      }

      final DateTime? lastLoss = _lastHeartLossTime;
      if (lastLoss == null) {
        // Fallback: initialize cooldown timestamp if missing while hearts < maxHearts
        final DateTime now = DateTime.now();
        _lastHeartLossTime = now;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('gm_last_heart_loss', now.toIso8601String());
        return;
      }

      final DateTime nextHeartTime = lastLoss.add(
        const Duration(minutes: cooldownMinutes),
      );
      final Duration timeRemaining = nextHeartTime.difference(DateTime.now());

      if (timeRemaining.isNegative) {
        // Waktunya nambah 1 nyawa!
        await addHeart(1);
        if (globalHearts.value < maxHearts) {
          final DateTime now = DateTime.now();
          _lastHeartLossTime = now;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('gm_last_heart_loss', now.toIso8601String());
        }
      } else {
        // Format ke MM:SS (Contoh: 19:59)
        final String minutes = timeRemaining.inMinutes.toString().padLeft(
          2,
          '0',
        );
        final String seconds = (timeRemaining.inSeconds % 60)
            .toString()
            .padLeft(2, '0');
        final String formatted = "$minutes:$seconds";
        if (globalTimerText.value != formatted) {
          globalTimerText.value = formatted;
        }
      }
    });
  }

  // ==========================================
  // ⚡ ACTION FUNCTIONS (Bisa dipanggil dari mana saja)
  // ==========================================

  // Fungsi Tambah XP
  static Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    globalXP.value += amount;
    await prefs.setInt('gm_xp', globalXP.value);
    await LocalRepository.queueAction('gm_xp', globalXP.value);
  }

  // Fungsi Pakai XP (Spend XP)
  static Future<bool> spendXP(
    int amount, {
    Map<String, dynamic>? extraData,
  }) async {
    if (globalXP.value < amount) return false;

    final prefs = await SharedPreferences.getInstance();
    globalXP.value -= amount;
    await prefs.setInt('gm_xp', globalXP.value);

    final Map<String, dynamic> batch = {'gm_xp': globalXP.value};
    if (extraData != null) {
      batch.addAll(extraData);
    }
    await LocalRepository.queueActionsBatch(batch);

    return true;
  }

  // Fungsi Kurangi Nyawa (Saat salah jawab)
  static Future<void> decreaseHeart() async {
    if (globalIsPremium.value) return; // Infinite Hearts for Premium users

    if (globalHearts.value > 0) {
      final int previousHearts = globalHearts.value;

      // 1. ATOMIC DEDUCTION (Immediate UI Refresh via ValueNotifier)
      globalHearts.value -= 1;

      try {
        final prefs = await SharedPreferences.getInstance();
        final Map<String, dynamic> batch = {'gm_hearts': globalHearts.value};

        // 2. COOLDOWN MANAGEMENT
        // Start cooldown only if we were at max hearts
        if (previousHearts == maxHearts || _lastHeartLossTime == null) {
          final DateTime now = DateTime.now();
          _lastHeartLossTime = now;
          final String timestamp = now.toIso8601String();
          await prefs.setString('gm_last_heart_loss', timestamp);
          batch['gm_last_heart_loss'] = timestamp;
        }

        // 3. PERSISTENCE
        await prefs.setInt('gm_hearts', globalHearts.value);
        await LocalRepository.queueActionsBatch(batch);
      } catch (e) {
        debugPrint("Heart deduction persistence failed: $e");
      }
    }
  }

  // Fungsi Tambah Nyawa Manual (Beli pakai XP / Video Ads)
  static Future<void> addHeart(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    globalHearts.value = (globalHearts.value + amount).clamp(0, maxHearts);
    await prefs.setInt('gm_hearts', globalHearts.value);

    final Map<String, dynamic> batch = {'gm_hearts': globalHearts.value};
    if (globalHearts.value == maxHearts) {
      _lastHeartLossTime = null;
      await prefs.remove('gm_last_heart_loss');
      batch['gm_last_heart_loss'] = null;
      globalTimerText.value = "Penuh";
    }
    await LocalRepository.queueActionsBatch(batch);
  }

  // Beli Nyawa Pakai XP
  static Future<bool> buyHeartWithXP() async {
    if (globalHearts.value >= maxHearts) return false; // Sudah penuh

    // Use unified spendXP logic for deduction and syncing
    final bool success = await spendXP(150);
    if (!success) return false; // XP Tidak cukup

    // Tambah Nyawa
    await addHeart(1);
    SoundManager.playSound('benar.mp3'); // Kasih efek suara sukses beli
    return true; // Sukses beli
  }

  // Beli Streak Shield Pakai XP (Core Drive 8: Loss & Avoidance)
  static Future<bool> buyStreakShieldWithXP() async {
    if (globalStreakShields.value >= maxStreakShields) return false;

    final int nextShields =
        (globalStreakShields.value + 1).clamp(0, maxStreakShields);
    final bool success = await spendXP(
      streakShieldCostXP,
      extraData: {'gm_streak_shields': nextShields},
    );
    if (!success) return false;

    final prefs = await SharedPreferences.getInstance();
    globalStreakShields.value = nextShields;
    await prefs.setInt('gm_streak_shields', nextShields);
    SoundManager.playSound('benar.mp3');
    return true;
  }

  // Increment Simulation Count
  static Future<void> incrementSimulationCount() async {
    final prefs = await SharedPreferences.getInstance();
    globalSimulationCount.value += 1;
    await prefs.setInt(
      'simulation_completed_count',
      globalSimulationCount.value,
    );
    await LocalRepository.queueAction(
      'gm_simulation_count',
      globalSimulationCount.value,
    );
  }

  // Update Kana/Alphabet Progress
  static Future<void> updateKanaProgress(String char, int type) async {
    final prefs = await SharedPreferences.getInstance();
    bool updated = false;
    String? cloudKey;
    List<String>? updatedList;

    if (type == 0) {
      // Hiragana
      if (!globalLearnedHiragana.value.contains(char)) {
        globalLearnedHiragana.value = [...globalLearnedHiragana.value, char];
        await prefs.setStringList(
          'learned_hiragana_list',
          globalLearnedHiragana.value,
        );
        cloudKey = 'learned_hiragana';
        updatedList = globalLearnedHiragana.value;
        updated = true;
      }
    } else if (type == 1) {
      // Katakana
      if (!globalLearnedKatakana.value.contains(char)) {
        globalLearnedKatakana.value = [...globalLearnedKatakana.value, char];
        await prefs.setStringList(
          'learned_katakana_list',
          globalLearnedKatakana.value,
        );
        cloudKey = 'learned_katakana';
        updatedList = globalLearnedKatakana.value;
        updated = true;
      }
    } else if (type == 2) {
      // Kanji
      if (!globalLearnedKanji.value.contains(char)) {
        globalLearnedKanji.value = [...globalLearnedKanji.value, char];
        await prefs.setStringList(
          'learned_kanji_list',
          globalLearnedKanji.value,
        );
        cloudKey = 'learned_kanji';
        updatedList = globalLearnedKanji.value;
        updated = true;
      }
    }

    if (updated && cloudKey != null && updatedList != null) {
      await LocalRepository.queueAction(cloudKey, updatedList);
    }
  }
}
