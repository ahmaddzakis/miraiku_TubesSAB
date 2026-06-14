import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_manager.dart';
import '../../core/notification_service.dart';
import '../../core/widgets/app_snackbar.dart';

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
        final timeStr = globalReminderTime.value.format(context);
        AppSnackbar.showSuccess(
          context,
          _t("Daily reminder activated for $timeStr!", "Pengingat harian berhasil diaktifkan untuk jam $timeStr!")
        );
      }
    } else {
      await NotificationService().cancelAll();
      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          _t("Daily reminder deactivated.", "Pengingat harian telah dinonaktifkan.")
        );
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: globalReminderTime.value,
      builder: (context, child) {
        final isDark = globalDarkMode.value;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFCC6633),
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              onSurface: isDark ? Colors.white : Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFCC6633),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              hourMinuteTextColor: isDark ? Colors.white : Colors.black,
              hourMinuteColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
              dayPeriodTextColor: isDark ? Colors.white70 : Colors.black87,
              dayPeriodColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
              dialBackgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
              dialHandColor: const Color(0xFFCC6633),
              dialTextColor: isDark ? Colors.white : Colors.black,
              entryModeIconColor: const Color(0xFFCC6633),
              helpTextStyle: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      globalReminderTime.value = picked;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_hour', picked.hour);
      await prefs.setInt('reminder_minute', picked.minute);

      // Sinkron ke Supabase Cloud
      try {
        await Supabase.instance.client.auth.updateUser(UserAttributes(data: {
          'reminder_hour': picked.hour,
          'reminder_minute': picked.minute,
        }));
      } catch (e) {
        debugPrint("Gagal sinkronisasi waktu pengingat ke Cloud: $e");
      }

      if (_isReminderOn) {
        await NotificationService().scheduleDailyStudyReminder(globalLanguage.value);
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
                title: Text(_t("Notifications", "Notifikasi"), style: TextStyle(color: textColor, fontWeight: FontWeight.w900)),
              ),
              body: SafeArea(
                bottom: true,
                child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFCC6633)))
                  : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
                  children: [
                  Text(
                    _t("STUDY REMINDERS", "PENGINGAT BELAJAR"),
                    style: const TextStyle(
                      color: Color(0xFF8C8A87),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFFCC6633),
                          inactiveThumbColor: isDark ? Colors.white54 : Colors.grey.shade400,
                          inactiveTrackColor: isDark ? const Color(0xFF333333) : Colors.grey.shade300,
                          value: _isReminderOn,
                          onChanged: _toggleReminder,
                          title: Text(
                            _t("Daily Reminder", "Pengingat Harian"),
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: textColor)
                          ),
                          subtitle: Text(
                            _t("Get notified to maintain your streak", "Dapatkan notifikasi agar streak tetap terjaga"),
                            style: TextStyle(fontSize: 12, color: subTextColor)
                          ),
                          secondary: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (_isReminderOn ? const Color(0xFFCC6633) : subTextColor).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_active_rounded,
                              color: _isReminderOn ? const Color(0xFFCC6633) : subTextColor,
                              size: 22,
                            ),
                          ),
                        ),
                        if (_isReminderOn) ...[
                          Divider(height: 1, color: isDark ? const Color(0xFF333333) : const Color(0xFFF0EBE1), indent: 70),
                          ValueListenableBuilder<TimeOfDay>(
                            valueListenable: globalReminderTime,
                            builder: (context, time, _) {
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.access_time_rounded, color: Color(0xFFCC6633), size: 22),
                                ),
                                title: Text(
                                  _t("Reminder Time", "Waktu Pengingat"),
                                  style: TextStyle(fontWeight: FontWeight.w800, color: textColor),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      time.format(context),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8C8A87)),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF8C8A87)),
                                  ],
                                ),
                                onTap: _selectTime,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      _t(
                        "Customizing your reminder time helps you build a consistent learning habit.",
                        "Menyesuaikan waktu pengingat membantu Anda membangun kebiasaan belajar yang konsisten."
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: subTextColor, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          );
          },
        );
      },
    );
  }
}
