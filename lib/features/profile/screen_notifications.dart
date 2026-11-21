import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/game_manager.dart';
import '../../core/notification_service.dart';
import '../../core/repository/local_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
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
    await LocalRepository.queueAction('is_daily_reminder_on', value);

    if (value) {
      final granted = await NotificationService().requestPermissions();
      await NotificationService().scheduleDailyStudyReminder(
        globalLanguage.value,
      );
      if (mounted) {
        if (granted) {
          final timeStr = globalReminderTime.value.format(context);
          AppSnackbar.showSuccess(
            context,
            _t(
              "Daily reminder activated for $timeStr!",
              "Pengingat harian berhasil diaktifkan untuk jam $timeStr!",
            ),
          );
        } else {
          AppSnackbar.showError(
            context,
            _t(
              "Notification permission denied.",
              "Izin notifikasi ditolak.",
            ),
          );
        }
      }
    } else {
      await NotificationService().cancelAll();
      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          _t(
            "Daily reminder deactivated.",
            "Pengingat harian telah dinonaktifkan.",
          ),
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
        final primaryColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;
        final surfaceColor =
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        final textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final subColor =
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        final variantColor = isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariantLight;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    onPrimary: AppColors.onPrimaryDark,
                    surface: surfaceColor,
                    onSurface: textColor,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: AppColors.onPrimaryLight,
                    surface: surfaceColor,
                    onSurface: textColor,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                textStyle: AppTextStyles.labelLarge,
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: surfaceColor,
              hourMinuteTextColor: textColor,
              hourMinuteColor: variantColor,
              dayPeriodTextColor: subColor,
              dayPeriodColor: variantColor,
              dialBackgroundColor: variantColor,
              dialHandColor: primaryColor,
              dialTextColor: textColor,
              entryModeIconColor: primaryColor,
              helpTextStyle: AppTextStyles.labelLarge.copyWith(color: subColor),
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

      await LocalRepository.queueActionsBatch({
        'reminder_hour': picked.hour,
        'reminder_minute': picked.minute,
      });

      if (_isReminderOn) {
        await NotificationService().scheduleDailyStudyReminder(
          globalLanguage.value,
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    final granted = await NotificationService().requestPermissions();
    if (granted) {
      await NotificationService().showTestNotification();
    } else {
      if (mounted) {
        AppSnackbar.showError(
          context,
          _t("Notification permission denied.", "Izin notifikasi ditolak."),
        );
      }
    }
  }

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
            final Color bgColor =
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
            final Color textColor =
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final Color subTextColor = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;
            final Color borderColor =
                isDark ? AppColors.borderDark : AppColors.borderLight;
            final Color primaryColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;
            final Color secondaryColor =
                isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

            return Scaffold(
              backgroundColor: bgColor,
              appBar: AppBar(
                backgroundColor: bgColor,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  _t("Notifications", "Notifikasi"),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              body: SafeArea(
                bottom: true,
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          AppSpacing.xl,
                          AppSpacing.xl,
                          MediaQuery.of(context).padding.bottom + AppSpacing.xl,
                        ),
                        children: [
                          Text(
                            _t("STUDY REMINDERS", "PENGINGAT BELAJAR"),
                            style: AppTextStyles.labelLarge.copyWith(
                              color: subTextColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [
                                SwitchListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg,
                                    vertical: AppSpacing.xs,
                                  ),
                                  activeThumbColor: Colors.white,
                                  activeTrackColor: primaryColor,
                                  inactiveThumbColor: subTextColor,
                                  inactiveTrackColor: isDark
                                      ? AppColors.surfaceVariantDark
                                      : AppColors.surfaceVariantLight,
                                  value: _isReminderOn,
                                  onChanged: _toggleReminder,
                                  title: Text(
                                    _t("Daily Reminder", "Pengingat Harian"),
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _t(
                                      "Get notified to maintain your streak",
                                      "Dapatkan notifikasi agar streak tetap terjaga",
                                    ),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 12,
                                      color: subTextColor,
                                    ),
                                  ),
                                  secondary: Container(
                                    padding:
                                        const EdgeInsets.all(AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      color: (_isReminderOn
                                              ? primaryColor
                                              : subTextColor)
                                          .withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.notifications_active_rounded,
                                      color: _isReminderOn
                                          ? primaryColor
                                          : subTextColor,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                if (_isReminderOn) ...[
                                  Divider(
                                    height: 1,
                                    color: borderColor,
                                    indent: 70,
                                  ),
                                  ValueListenableBuilder<TimeOfDay>(
                                    valueListenable: globalReminderTime,
                                    builder: (context, time, _) {
                                      return ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.lg,
                                          vertical: 4,
                                        ),
                                        leading: Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.sm,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withValues(
                                              alpha: 0.12,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.access_time_rounded,
                                            color: primaryColor,
                                            size: 22,
                                          ),
                                        ),
                                        title: Text(
                                          _t(
                                            "Reminder Time",
                                            "Waktu Pengingat",
                                          ),
                                          style: AppTextStyles.titleMedium
                                              .copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: textColor,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              time.format(context),
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: subTextColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.xs,
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 14,
                                              color: subTextColor,
                                            ),
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
                          const SizedBox(height: AppSpacing.md),
                          AppCard(
                            padding: EdgeInsets.zero,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.xs,
                              ),
                              onTap: _sendTestNotification,
                              title: Text(
                                _t(
                                  "Test Incoming Notification",
                                  "Test Notifikasi Masuk",
                                ),
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                              subtitle: Text(
                                _t(
                                  "Instantly trigger a test notification",
                                  "Kirim notifikasi uji coba secara instan",
                                ),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontSize: 12,
                                  color: subTextColor,
                                ),
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: secondaryColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.send_rounded,
                                  color: secondaryColor,
                                  size: 22,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: subTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            child: Text(
                              _t(
                                "Customizing your reminder time helps you build a consistent learning habit.",
                                "Menyesuaikan waktu pengingat membantu Anda membangun kebiasaan belajar yang konsisten.",
                              ),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                color: subTextColor,
                              ),
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
