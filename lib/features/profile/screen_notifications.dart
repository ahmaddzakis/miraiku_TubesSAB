import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/game_manager.dart';
import '../../core/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isReminderOn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isReminderOn = prefs.getBool('is_daily_reminder_on') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() {
      _isReminderOn = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_daily_reminder_on', value);

    if (value) {
      await NotificationService().requestPermissions();
      await NotificationService().scheduleDailyStudyReminder(globalLanguage.value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t("Daily reminder activated for 19:00 WIB!", "Pengingat harian berhasil diaktifkan untuk jam 19:00 WIB!"))),
        );
      }
    } else {
      await FlutterLocalNotificationsPlugin().cancelAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t("Daily reminder deactivated.", "Pengingat harian telah dinonaktifkan."))),
        );
      }
    }
  }

  // --- FUNGSI TRANSLATE ---
  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            // --- VARIABEL WARNA DINAMIS ---
            final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
            final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
            final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF8C8A87);

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: bgColor, elevation: 0, centerTitle: true,
                leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: textColor), onPressed: () => Navigator.pop(context)),
                title: Text(_t("Notifications", "Notifikasi"), style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontFamily: 'Serif')),
              ),
              body: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFCC6633)))
                : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA)),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF4CAF50),
                      inactiveThumbColor: isDark ? Colors.white54 : Colors.grey.shade400,
                      inactiveTrackColor: isDark ? const Color(0xFF333333) : Colors.grey.shade300,
                      value: _isReminderOn,
                      onChanged: _toggleReminder,
                      title: Text(
                        _t("Daily Study Reminder", "Pengingat Belajar Harian"),
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor)
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _t("Remind me to maintain streak every 19:00", "Ingatkan saya untuk mempertahankan streak tiap jam 19:00"),
                          style: TextStyle(fontSize: 13, color: subTextColor, height: 1.4)
                        ),
                      ),
                      secondary: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFCC6633)),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
