import 'dart:io';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Panggil ini di main.dart: await NotificationService().init();
  Future<void> init() async {
    // 1. Inisialisasi Timezone
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    // 2. Android Settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // 3. iOS Settings
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Logika ketika notifikasi diklik: Payload akan diarahkan ke home/learning via main.dart
      },
    );
  }

  /// Panggil ini sebelum menjadwalkan
  Future<bool> requestPermissions() async {
    bool? granted = false;
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      granted = await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      final iosImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      granted = await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    return granted ?? false;
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel untuk testing notifikasi',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      fullScreenIntent: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _notificationsPlugin.show(
      999,
      'MIRAIku: Notifikasi Aktif! 🔔',
      'Sistem notifikasi berjalan lancar. Siap untuk menemani perjalanan belajarmu. Ganbatte kudasai! 🚀',
      platformChannelSpecifics,
      payload: 'test',
    );
  }

  /// Menjadwalkan pengingat harian dengan pesan yang dipersonalisasi & diacak
  Future<void> scheduleDailyStudyReminder(String languageCode) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final prefs = await SharedPreferences.getInstance();
    final bool isEnabled = prefs.getBool('is_daily_reminder_on') ?? false;

    // 1. Batalkan semua jadwal lama agar bersih
    await _notificationsPlugin.cancelAll();

    if (!isEnabled) return;

    // 2. Ambil Nama User (dari Supabase metadata atau fallback)
    final user = Supabase.instance.client.auth.currentUser;
    final String name = user?.userMetadata?['display_name'] ?? 'User';

    // 3. Daftar Pesan (Bilingual & Randomized)
    final List<Map<String, String>> messages = [
      {
        'id': 'Sempatkan 5 menit hari ini untuk kumpulkan XP dan jaga streak-mu. Ayo login sekarang! 🔥',
        'en': 'Take 5 minutes today to collect XP and keep your streak. Log in now! 🔥'
      },
      {
        'id': '$name, ayo gapai impianmu ke Jepang! Tingkatkan skor belajarmu hari ini! 🇯🇵',
        'en': '$name, reach your dreams to Japan! Boost your learning score today! 🇯🇵'
      },
      {
        'id': 'Waktunya asah kemampuan Bahasa Jepangmu, $name! XP tambahan menunggu! ✨',
        'en': 'Time to sharpen your Japanese skills, $name! Bonus XP awaits! ✨'
      },
      {
        'id': 'Okaeri $name! Mochi sudah menunggumu untuk menjaga streak belajarmu! 🍡',
        'en': 'Okaeri $name! Mochi is waiting for you to keep your learning streak! 🍡'
      }
    ];

    final random = Random();
    final selectedMessage = messages[random.nextInt(messages.length)];
    
    final String title = languageCode == 'id' 
        ? 'Waktunya Belajar, Pahlawan MIRAIku! 🎌' 
        : 'Study Time, MIRAIku Hero! 🎌';
    
    final String body = selectedMessage[languageCode] ?? selectedMessage['en']!;

    // 4. Ambil waktu dari SharedPreferences
    final int hour = prefs.getInt('reminder_hour') ?? 19;
    final int minute = prefs.getInt('reminder_minute') ?? 0;

    await _notificationsPlugin.zonedSchedule(
      0, // ID Tetap untuk Daily Reminder
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'daily_study_channel',
          'Study Reminders',
          channelDescription: 'Notifikasi pengingat belajar harian',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          styleInformation: BigTextStyleInformation(''),
          fullScreenIntent: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          subtitle: languageCode == 'id' ? 'Waktunya Belajar!' : 'Study Time!',
        ),
      ),
      payload: 'home', // Payload agar bisa dihandle saat diklik
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Perulangan harian
    );
    
    debugPrint("Daily reminder scheduled for $hour:$minute with message: $body");
  }

  /// Membatalkan semua notifikasi
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
