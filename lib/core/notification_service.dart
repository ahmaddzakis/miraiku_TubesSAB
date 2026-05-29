import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'game_manager.dart'; // Import to access globalLanguage

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
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Logika ketika notifikasi diklik (opsional)
      },
    );
  }

  /// Panggil ini sebelum menjadwalkan (khusus Android 13+)
  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    }
  }

  /// Menjadwalkan pengingat harian jam 19:00 (Bilingual)
  Future<void> scheduleDailyStudyReminder() async {
    // Pastikan hanya berjalan di platform yang didukung
    if (!Platform.isAndroid && !Platform.isIOS) return;

    final String title = globalLanguage.value == 'id' 
        ? 'Miraiku: Belajar Yuk! 🇯🇵' 
        : 'Miraiku: Let\'s Study! 🇯🇵';
    
    final String body = globalLanguage.value == 'id'
        ? 'Waktunya belajar Bahasa Jepang! Jangan sampai rekor streak-mu putus!'
        : 'Time to learn Japanese! Don\'t let your streak break!';

    await _notificationsPlugin.zonedSchedule(
      0, // ID Notifikasi
      title,
      body,
      _nextInstanceOfSevenPM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_study_channel',
          'Study Reminders',
          channelDescription: 'Notifikasi pengingat belajar harian',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Perulangan harian
    );
  }

  /// Membatalkan semua notifikasi
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfSevenPM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 19, 0); // Jam 19:00

    // Jika jam 19:00 sudah lewat hari ini, jadwalkan untuk besok
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
