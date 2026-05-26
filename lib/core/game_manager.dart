import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sound_manager.dart';

// ==========================================
// 🌍 VARIABEL GLOBAL (STATE MANAGEMENT)
// ==========================================
final ValueNotifier<int> globalHearts = ValueNotifier<int>(5);
final ValueNotifier<int> globalXP = ValueNotifier<int>(0);
final ValueNotifier<int> globalStreak = ValueNotifier<int>(0);
final ValueNotifier<String> globalTimerText = ValueNotifier<String>("Penuh");

final ValueNotifier<bool> globalDarkMode = ValueNotifier<bool>(false);
final ValueNotifier<String> globalLanguage = ValueNotifier<String>('en');
final ValueNotifier<List<String>> globalLearnedHiragana = ValueNotifier<List<String>>([]);
final ValueNotifier<List<String>> globalLearnedKatakana = ValueNotifier<List<String>>([]);

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
    if (meta.isEmpty) return;

    if (meta['gm_hearts'] != null) globalHearts.value = meta['gm_hearts'];
    if (meta['gm_xp'] != null) globalXP.value = meta['gm_xp'];
    if (meta['gm_streak'] != null) globalStreak.value = meta['gm_streak'];
    if (meta['setting_dark'] != null) globalDarkMode.value = meta['setting_dark'];
    if (meta['setting_lang'] != null) globalLanguage.value = meta['setting_lang'];
    
    if (meta['learned_hiragana'] != null) {
      globalLearnedHiragana.value = List<String>.from(meta['learned_hiragana']);
    }
    if (meta['learned_katakana'] != null) {
      globalLearnedKatakana.value = List<String>.from(meta['learned_katakana']);
    }

    // Sinkronkan balik ke lokal agar tetap update
    prefs.setInt('gm_hearts', globalHearts.value);
    prefs.setInt('gm_xp', globalXP.value);
    prefs.setInt('gm_streak', globalStreak.value);
    prefs.setBool('setting_dark', globalDarkMode.value);
    prefs.setString('setting_lang', globalLanguage.value);
    prefs.setInt('learned_hiragana', globalLearnedHiragana.value.length);
    prefs.setInt('learned_katakana', globalLearnedKatakana.value.length);
  }

  static void _startAuthListener() {
    _authSubscription?.cancel();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.userUpdated) {
        if (session?.user != null) {
          final prefs = await SharedPreferences.getInstance();
          _updateLocalStateFromMeta(session!.user.userMetadata ?? {}, prefs);
        }
      }
    });
  }

  // --- FUNGSI SINKRONISASI KE CLOUD ---
  static Future<void> syncToCloud() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        await supabase.auth.updateUser(UserAttributes(data: {
          'gm_xp': globalXP.value,
          'gm_hearts': globalHearts.value,
          'gm_streak': globalStreak.value,
          'setting_dark': globalDarkMode.value,
          'setting_lang': globalLanguage.value,
          'learned_hiragana': globalLearnedHiragana.value,
          'learned_katakana': globalLearnedKatakana.value,
        }));
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