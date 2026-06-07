import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sound_manager.dart';
import 'notification_service.dart';

// ==========================================
// 🌍 VARIABEL GLOBAL (STATE MANAGEMENT)
// ==========================================
final ValueNotifier<int> globalHearts = ValueNotifier<int>(5);
final ValueNotifier<int> globalXP = ValueNotifier<int>(0);
final ValueNotifier<int> globalStreak = ValueNotifier<int>(0);
final ValueNotifier<String> globalTimerText = ValueNotifier<String>("Penuh");

final ValueNotifier<bool> globalDarkMode = ValueNotifier<bool>(false);
final ValueNotifier<String> globalLanguage = ValueNotifier<String>('en');
final ValueNotifier<bool> globalIsPremium = ValueNotifier<bool>(false);
final ValueNotifier<List<String>> globalLearnedHiragana = ValueNotifier<List<String>>([]);
final ValueNotifier<List<String>> globalLearnedKatakana = ValueNotifier<List<String>>([]);
final ValueNotifier<List<String>> globalLearnedKanji = ValueNotifier<List<String>>([]);
final ValueNotifier<List<dynamic>> globalSimulationHistory = ValueNotifier<List<dynamic>>([]);

class GameManager {
  static const int maxHearts = 5;
  static const int cooldownMinutes = 20; // 20 Menit per 1 Nyawa
  static Timer? _uiTimer;

  static StreamSubscription<AuthState>? _authSubscription;

  // 1. FUNGSI INISIALISASI (Dipanggil saat aplikasi baru dibuka)
  static Future<void> init() async {
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
  }

  // Helper untuk update state global dari metadata
  static void _updateLocalStateFromMeta(Map<String, dynamic> meta, SharedPreferences prefs) {
    // 1. Core Stats (Anti-Rollback logic for XP)
    int cloudXP = (meta['gm_xp'] as num?)?.toInt() ?? 0;
    int localXP = prefs.getInt('gm_xp') ?? 0;
    globalXP.value = cloudXP > localXP ? cloudXP : localXP;

    globalHearts.value = (meta['gm_hearts'] as num?)?.toInt() ?? prefs.getInt('gm_hearts') ?? 5;
    globalStreak.value = (meta['gm_streak'] as num?)?.toInt() ?? prefs.getInt('gm_streak') ?? 0;

    // 2. Settings
    globalDarkMode.value = meta['setting_dark'] ?? prefs.getBool('is_dark_mode') ?? prefs.getBool('setting_dark') ?? false;
    globalLanguage.value = meta['setting_lang'] ?? prefs.getString('app_language') ?? prefs.getString('setting_lang') ?? 'en';
    
    // Restore notification preference
    final bool isReminderOn = meta['is_daily_reminder_on'] ?? prefs.getBool('is_daily_reminder_on') ?? false;
    prefs.setBool('is_daily_reminder_on', isReminderOn);
    if (isReminderOn) {
      NotificationService().scheduleDailyStudyReminder(globalLanguage.value);
    }
    globalIsPremium.value = meta['is_premium'] ?? prefs.getBool('is_premium') ?? false;

    // 3. Learned Characters
    if (meta['learned_hiragana'] != null) {
      globalLearnedHiragana.value = List<String>.from(meta['learned_hiragana']);
    } else {
      globalLearnedHiragana.value = prefs.getStringList('learned_hiragana_list') ?? [];
    }

    if (meta['learned_katakana'] != null) {
      globalLearnedKatakana.value = List<String>.from(meta['learned_katakana']);
    } else {
      globalLearnedKatakana.value = prefs.getStringList('learned_katakana_list') ?? [];
    }

    if (meta['learned_kanji'] != null) {
      globalLearnedKanji.value = List<String>.from(meta['learned_kanji']);
    } else {
      globalLearnedKanji.value = prefs.getStringList('learned_kanji_list') ?? [];
    }

    // 4. Simulation History
    if (meta['simulation_history'] != null) {
      globalSimulationHistory.value = List<dynamic>.from(meta['simulation_history']);
    } else {
      final historyJson = prefs.getString('simulation_history') ?? '[]';
      globalSimulationHistory.value = jsonDecode(historyJson);
    }

    // 5. Timestamps for Streak/Heart Sync
    if (meta['gm_last_login'] != null) {
      prefs.setString('gm_last_login', meta['gm_last_login']);
    }
    if (meta['gm_last_heart_loss'] != null) {
      prefs.setString('gm_last_heart_loss', meta['gm_last_heart_loss']);
    }
    if (meta['gm_last_daily_claim'] != null) {
      prefs.setString('gm_last_daily_claim', meta['gm_last_daily_claim']);
    } else {
      prefs.remove('gm_last_daily_claim');
    }

    // 6. Unit Progress (u1_, u2_, u3_, u4_)
    meta.forEach((key, value) {
      if (key.startsWith('u1_') || key.startsWith('u2_') || key.startsWith('u3_') || key.startsWith('u4_')) {
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
    prefs.setBool('setting_dark', globalDarkMode.value);
    prefs.setString('setting_lang', globalLanguage.value);
    prefs.setBool('is_dark_mode', globalDarkMode.value);
    prefs.setString('app_language', globalLanguage.value);
    prefs.setBool('is_premium', globalIsPremium.value);
    prefs.setStringList('learned_hiragana_list', globalLearnedHiragana.value);
    prefs.setStringList('learned_katakana_list', globalLearnedKatakana.value);
    prefs.setStringList('learned_kanji_list', globalLearnedKanji.value);
    prefs.setString('simulation_history', jsonEncode(globalSimulationHistory.value));
    
    // Simpan juga timestamp ke local agar sinkron
    if (prefs.getString('gm_last_login') == null) {
       // default jika belum ada
    }
  }

  // Reset semua progress ke default (digunakan saat logout)
  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Reset ValueNotifiers to defaults
    globalHearts.value = 5;
    globalXP.value = 0;
    globalStreak.value = 0;
    globalIsPremium.value = false;
    globalLearnedHiragana.value = [];
    globalLearnedKatakana.value = [];
    globalLearnedKanji.value = [];
    globalSimulationHistory.value = [];
    globalTimerText.value = "Penuh";
    
    // 2. Clear notification preferences
    await prefs.setBool('is_daily_reminder_on', false);
    
    // 3. Hapus semua data terkait game di SharedPreferences agar tidak bocor ke user lain
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('u1_') || 
          key.startsWith('u2_') || 
          key.startsWith('u3_') || 
          key.startsWith('u4_') ||
          key.startsWith('gm_') ||
          key.startsWith('learned_') ||
          key.startsWith('setting_') ||
          key == 'is_premium' ||
          key == 'simulation_completed_count' ||
          key == 'simulation_history' ||
          key == 'last_claimed_streak' ||
          key == 'has_new_activity') {
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
    globalXP.value = 0;
    globalIsPremium.value = false;
    globalLearnedHiragana.value = [];
    globalLearnedKatakana.value = [];
    globalLearnedKanji.value = [];
    globalSimulationHistory.value = [];
    
    // 2. Set default timestamps
    DateTime today = DateTime.now();
    DateTime todayMidnight = DateTime(today.year, today.month, today.day);
    prefs.setString('gm_last_login', todayMidnight.toIso8601String());
    
    // 3. Reset all unit progress keys in SharedPreferences
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith('u1_') || key.startsWith('u2_') || key.startsWith('u3_') || key.startsWith('u4_') || key.startsWith('learned_')) {
        await prefs.remove(key);
      }
    }

    // 4. Save to Local
    _saveProgressToLocal(prefs);
    
    // 5. Sync to Cloud
    await syncToCloud();
  }

  static void _startAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final session = data.session; // Local variable extraction for type promotion

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.userUpdated) {
        if (session != null) {
          final user = session.user;
          final prefs = await SharedPreferences.getInstance();
          // 1. Update progress dari metadata cloud (atau fallback ke lokal/default)
          _updateLocalStateFromMeta(user.userMetadata ?? {}, prefs);
          
          // 2. Jalankan ulang logika waktu agar sinkron dengan user baru
          await _checkDailyStreak(prefs);
          await _calculateOfflineRegen(prefs);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        // Reset state di memori dan lokal saat logout
        await resetProgress();
      }
    });
  }

  static Future<void> syncToCloud({String? displayName, String? bio, String? avatarUrl}) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final Map<String, dynamic> updateData = {
          'gm_xp': globalXP.value,
          'gm_hearts': globalHearts.value,
          'gm_streak': globalStreak.value,
          'setting_dark': globalDarkMode.value,
          'setting_lang': globalLanguage.value,
          'is_daily_reminder_on': prefs.getBool('is_daily_reminder_on') ?? false,
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
        for (String key in keys) {
          if (key.startsWith('u1_') || key.startsWith('u2_') || key.startsWith('u3_') || key.startsWith('u4_')) {
            updateData[key] = prefs.getInt(key);
          }
        }

        // Tambahkan data profil jika disediakan
        if (displayName != null) updateData['display_name'] = displayName;
        if (bio != null) updateData['bio'] = bio;
        if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

        await supabase.auth.updateUser(UserAttributes(data: updateData));
      } catch (e) {
        debugPrint("Gagal sinkronisasi progress ke Cloud: $e");
      }
    }
  }

  // 2. LOGIKA STREAK HARIAN
  static Future<void> _checkDailyStreak(SharedPreferences prefs) async {
    String? lastLoginStr = prefs.getString('gm_last_login');
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day); // Abaikan jam & menit

    if (lastLoginStr != null) {
      DateTime lastLogin = DateTime.parse(lastLoginStr);
      DateTime lastLoginDay = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);

      int differenceInDays = today.difference(lastLoginDay).inDays;

      if (differenceInDays == 1) {
        // Login beruntun (+1 hari)
        globalStreak.value += 1;

        // BONUS MINGGUAN (Tiap kelipatan 7 hari dapat 500 XP)
        if (globalStreak.value > 0 && globalStreak.value % 7 == 0) {
          addXP(500);
          // Bisa tambah pop-up notifikasi nanti di UI
        }
      } else if (differenceInDays > 1) {
        // Bolong sehari, Streak hangus!
        globalStreak.value = 1;
      }
    } else {
      // Login pertama kali seumur hidup
      globalStreak.value = 1;
    }

    prefs.setInt('gm_streak', globalStreak.value);
    prefs.setString('gm_last_login', today.toIso8601String());
  }

  // 3. LOGIKA REGENERASI NYAWA OFFLINE (Saat aplikasi ditutup)
  static Future<void> _calculateOfflineRegen(SharedPreferences prefs) async {
    if (globalHearts.value >= maxHearts) return;

    String? lastHeartLossStr = prefs.getString('gm_last_heart_loss');
    if (lastHeartLossStr != null) {
      DateTime lastLoss = DateTime.parse(lastHeartLossStr);
      DateTime now = DateTime.now();

      int minutesPassed = now.difference(lastLoss).inMinutes;
      int heartsRecovered = minutesPassed ~/ cooldownMinutes;

      if (heartsRecovered > 0) {
        int newHearts = globalHearts.value + heartsRecovered;
        if (newHearts >= maxHearts) {
          globalHearts.value = maxHearts;
          prefs.remove('gm_last_heart_loss');
        } else {
          globalHearts.value = newHearts;
          // Sisakan waktu tanggung (contoh: lewat 25 menit -> tambah 1 nyawa, sisa 5 menit cooldown)
          int remainderMinutes = minutesPassed % cooldownMinutes;
          DateTime updatedLossTime = now.subtract(Duration(minutes: remainderMinutes));
          prefs.setString('gm_last_heart_loss', updatedLossTime.toIso8601String());
        }
        prefs.setInt('gm_hearts', globalHearts.value);
      }
    }
  }

  // 4. TIMER UNTUK UPDATE TEKS DI LAYAR (Jalan tiap 1 detik)
  static void _startTicker() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (globalIsPremium.value) {
        globalHearts.value = maxHearts;
        globalTimerText.value = "∞";
        return;
      }

      if (globalHearts.value >= maxHearts) {
        globalTimerText.value = "Penuh";
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      String? lastLossStr = prefs.getString('gm_last_heart_loss');
      if (lastLossStr != null) {
        DateTime lastLoss = DateTime.parse(lastLossStr);
        DateTime nextHeartTime = lastLoss.add(const Duration(minutes: cooldownMinutes));
        Duration timeRemaining = nextHeartTime.difference(DateTime.now());

        if (timeRemaining.isNegative) {
          // Waktunya nambah 1 nyawa!
          await addHeart(1);
          if (globalHearts.value < maxHearts) {
            prefs.setString('gm_last_heart_loss', DateTime.now().toIso8601String());
          }
        } else {
          // Format ke MM:SS (Contoh: 19:59)
          String minutes = timeRemaining.inMinutes.toString().padLeft(2, '0');
          String seconds = (timeRemaining.inSeconds % 60).toString().padLeft(2, '0');
          globalTimerText.value = "$minutes:$seconds";
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
    prefs.setInt('gm_xp', globalXP.value);
    await syncToCloud();
  }

  // Fungsi Kurangi Nyawa (Saat salah jawab)
  static Future<void> decreaseHeart() async {
    if (globalIsPremium.value) return; // Infinite Hearts for Premium users

    if (globalHearts.value > 0) {
      final prefs = await SharedPreferences.getInstance();

      // Jika nyawa sebelumnya penuh, catat waktu mulai cooldown
      if (globalHearts.value == maxHearts) {
        prefs.setString('gm_last_heart_loss', DateTime.now().toIso8601String());
      }

      globalHearts.value -= 1;
      prefs.setInt('gm_hearts', globalHearts.value);
      await syncToCloud();
    }
  }

  // Fungsi Tambah Nyawa Manual (Beli pakai XP / Video Ads)
  static Future<void> addHeart(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    globalHearts.value = (globalHearts.value + amount).clamp(0, maxHearts);
    prefs.setInt('gm_hearts', globalHearts.value);

    if (globalHearts.value == maxHearts) {
      prefs.remove('gm_last_heart_loss');
      globalTimerText.value = "Penuh";
    }
    await syncToCloud();
  }

  // Beli Nyawa Pakai XP
  static Future<bool> buyHeartWithXP() async {
    if (globalHearts.value >= maxHearts) return false; // Sudah penuh
    if (globalXP.value < 150) return false; // XP Tidak cukup

    final prefs = await SharedPreferences.getInstance();

    // Kurangi XP
    globalXP.value -= 150;
    prefs.setInt('gm_xp', globalXP.value);

    // Tambah Nyawa
    await addHeart(1);
    SoundManager.playSound('benar.mp3'); // Kasih efek suara sukses beli
    return true; // Sukses beli
  }
}
