import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';

class ActivityHistoryManager {
  static const String _key = 'user_activities';

  static Future<void> addActivity(String title, String description) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activities = prefs.getStringList(_key) ?? [];

    final newActivity = {
      'title': title,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
    };

    activities.insert(0, jsonEncode(newActivity));

    if (activities.length > 100) {
      activities = activities.sublist(0, 100);
    }

    await prefs.setStringList(_key, activities);
    await prefs.setBool('has_new_activity', true);
  }

  static Future<List<Map<String, String>>> getActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> activities = prefs.getStringList(_key) ?? [];

    return activities.map((String item) {
      final Map<String, dynamic> decoded = jsonDecode(item);
      return {
        'title': decoded['title']?.toString() ?? '',
        'description': decoded['description']?.toString() ?? '',
        'timestamp': decoded['timestamp']?.toString() ?? '',
      };
    }).toList();
  }

  static Future<void> clearActivities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  late Future<List<Map<String, String>>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = ActivityHistoryManager.getActivities();
  }

  String _formatTime(String isoString) {
    if (isoString.isEmpty) return '';
    final dt = DateTime.tryParse(isoString);
    if (dt == null) return '';
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor =
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
        final Color cardColor =
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        final Color textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final Color subTextColor =
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        final Color borderColor =
            isDark ? AppColors.borderDark : AppColors.borderLight;
        final Color primaryColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            title: const Text("Riwayat Aktivitas"),
            centerTitle: true,
            backgroundColor: bgColor,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
            titleTextStyle: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.delete_sweep_rounded, color: subTextColor),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXl,
                        ),
                      ),
                      backgroundColor: cardColor,
                      title: Text(
                        "Hapus Semua?",
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      content: Text(
                        "Apakah Anda yakin ingin menghapus semua riwayat aktivitas?",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: subTextColor,
                        ),
                      ),
                      actions: [
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                label: "Batal",
                                variant: AppButtonVariant.text,
                                height: 48,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppButton(
                                label: "Ya, Hapus",
                                variant: AppButtonVariant.danger,
                                height: 48,
                                borderRadius: AppSpacing.radiusMd,
                                onPressed: () async {
                                  await ActivityHistoryManager
                                      .clearActivities();
                                  if (context.mounted) Navigator.pop(context);
                                  setState(() {
                                    _activitiesFuture =
                                        ActivityHistoryManager.getActivities();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          body: FutureBuilder<List<Map<String, String>>>(
            future: _activitiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 80,
                        color: subTextColor.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        "Belum ada aktivitas",
                        style: AppTextStyles.titleMedium.copyWith(
                          color: subTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final activities = snapshot.data!;
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.xxl),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final act = activities[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      border: Border.all(color: borderColor),
                      boxShadow: AppShadows.card(isDark),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      act['title'] ?? '',
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatTime(act['timestamp'] ?? ''),
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: subTextColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                act['description'] ?? '',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
