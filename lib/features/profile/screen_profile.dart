import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_manager.dart';
import '../../core/repository/local_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_snackbar.dart';
import '../leaderboard/screen_leaderboard.dart';
import '../login/screen_auth.dart';
import '../tracker/screen_jlpt_tracker.dart';
import 'screen_notifications.dart';
import 'screen_settings.dart';

class _AchievementBadge {
  final String text;
  final bool isLabel;
  _AchievementBadge._(this.text, this.isLabel);
  factory _AchievementBadge.text(String t) => _AchievementBadge._(t, false);
  factory _AchievementBadge.label(String t) => _AchievementBadge._(t, true);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // User Metadata
  String _userName = 'MIRAIku User';
  String _userDesc = 'Semangat Belajar Bahasa Jepang!';
  String _userEmail = 'miraiku@example.com';

  // Local Statistics
  bool _isDailyClaimedToday = false;
  bool _isClaimingDaily = false;
  bool _isBuyingShield = false;

  // Achievements Status
  bool _claimedHiragana = false;
  bool _claimedKatakana = false;
  bool _claimedKanji = false;
  bool _claimedAlphabetMaster = false;
  bool _claimedSim = false;
  bool _claimed3Days = false;
  bool _claimed7Days = false;
  bool _claimed14Days = false;
  bool _claimed30Days = false;
  bool _claimedMirai = false;

  late SharedPreferences prefs;
  bool _isPrefsInitialized = false;
  String _appVersion = "...";

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _initAppVersion();
  }

  Future<void> _initAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = info.version;
        });
      }
    } catch (_) {}
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    await _loadLocalStats();
    _loadSupabaseUserData();
    setState(() {
      _isPrefsInitialized = true;
    });
  }

  void _loadSupabaseUserData() async {
    final meta = await LocalRepository.getUserProgress();
    final user = _supabase?.auth.currentUser;

    if (mounted) {
      setState(() {
        _userName = meta['display_name'] ?? 'MIRAIku User';
        _userDesc = meta['bio'] ?? 'Semangat Belajar Bahasa Jepang!';
        globalAvatarUrl.value = meta['avatar_url'] ?? '';
        _userEmail = user?.email ?? 'miraiku@example.com';

        _claimedHiragana = meta['ach_hira'] ?? false;
        _claimedKatakana = meta['ach_kata'] ?? false;
        _claimedKanji = meta['ach_kanji'] ?? false;
        _claimedAlphabetMaster = meta['ach_alphabet'] ?? false;
        _claimedSim = meta['ach_sim'] ?? false;
        _claimed3Days = meta['ach_3d'] ?? false;
        _claimed7Days = meta['ach_7d'] ?? false;
        _claimed14Days = meta['ach_14d'] ?? false;
        _claimed30Days = meta['ach_30d'] ?? false;
        _claimedMirai = meta['ach_mirai'] ?? false;
      });

      final String today = DateTime.now().toIso8601String().substring(0, 10);
      final String? cloudLastClaim = meta['gm_last_daily_claim'];

      if (cloudLastClaim == today) {
        await prefs.setString('gm_last_daily_claim', today);
        if (mounted) {
          setState(() {
            _isDailyClaimedToday = true;
          });
        }
      } else {
        await _loadLocalStats();
      }
    }
  }

  Future<void> _loadLocalStats() async {
    await prefs.reload();
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    final lastClaim = prefs.getString('gm_last_daily_claim');

    if (mounted) {
      setState(() {
        _isDailyClaimedToday = (lastClaim == today);
      });
    }
  }

  /// Claims the Daily Omikuji Surprise Box (Core Drive 7: Unpredictability & Curiosity).
  /// Grants guaranteed +50 base XP plus a random Omikuji fortune bonus:
  /// - Daikichi (大吉 - Great Blessing): +50 Bonus XP (Total +100 XP)
  /// - Chuukichi (中吉 - Middle Blessing): +25 Bonus XP (Total +75 XP)
  /// - Shoukichi (小吉 - Small Blessing): +10 Bonus XP + 1 Heart (Total +60 XP + 1 HP)
  Future<void> _claimDailyReward() async {
    if (_isDailyClaimedToday || _isClaimingDaily) {
      if (mounted && _isDailyClaimedToday) {
        _showErrorDialog(
          _t("Already Claimed", "Sudah Diklaim"),
          _t(
            "Come back tomorrow for your next Daily Omikuji!",
            "Kembali lagi besok untuk kejutan Omikuji berikutnya!",
          ),
        );
      }
      return;
    }

    setState(() {
      _isClaimingDaily = true;
    });

    try {
      await prefs.reload();
      final String today = DateTime.now().toIso8601String().substring(0, 10);
      final String? lastClaim = prefs.getString('gm_last_daily_claim');

      if (lastClaim == today) {
        setState(() {
          _isDailyClaimedToday = true;
          _isClaimingDaily = false;
        });
        if (mounted) {
          _showErrorDialog(
            _t("Already Claimed", "Sudah Diklaim"),
            _t(
              "Come back tomorrow for your next Daily Omikuji!",
              "Kembali lagi besok untuk kejutan Omikuji berikutnya!",
            ),
          );
        }
        return;
      }

      // Draw random Omikuji fortune (Core Drive 7)
      final int roll = Random().nextInt(3);
      int totalXpReward = 50;
      String fortuneTitle = "";
      String fortuneDetail = "";

      if (roll == 0) {
        // Daikichi (大吉)
        totalXpReward = 100;
        fortuneTitle = "大吉 • Daikichi!";
        fortuneDetail = _t(
          "Great Blessing! You received +50 Base XP and +50 Surprise Bonus XP (+100 XP total)!",
          "Keberuntungan Besar! Kamu mendapat +50 XP Dasar dan +50 XP Bonus Kejutan (Total +100 XP)!",
        );
      } else if (roll == 1) {
        // Chuukichi (中吉)
        totalXpReward = 75;
        fortuneTitle = "中吉 • Chūkichi!";
        fortuneDetail = _t(
          "Middle Blessing! You received +50 Base XP and +25 Surprise Bonus XP (+75 XP total)!",
          "Keberuntungan Menengah! Kamu mendapat +50 XP Dasar dan +25 XP Bonus Kejutan (Total +75 XP)!",
        );
      } else {
        // Shoukichi (小吉)
        totalXpReward = 60;
        fortuneTitle = "小吉 • Shōkichi!";
        fortuneDetail = _t(
          "Good Blessing! You received +50 Base XP, +10 Bonus XP, and +1 Heart recovery!",
          "Keberuntungan Baik! Kamu mendapat +50 XP Dasar, +10 XP Bonus, dan pemulihan +1 Nyawa!",
        );
        await GameManager.addHeart(1);
      }

      await prefs.setString('gm_last_daily_claim', today);
      globalXP.value += totalXpReward;
      await prefs.setInt('gm_xp', globalXP.value);

      await LocalRepository.queueActionsBatch({
        'gm_last_daily_claim': today,
        'gm_xp': globalXP.value,
      });

      if (mounted) {
        setState(() {
          _isDailyClaimedToday = true;
          _isClaimingDaily = false;
        });
        _showSuccessDialog(
          "$fortuneTitle\n\n$fortuneDetail",
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isClaimingDaily = false;
        });
        _showErrorDialog(_t("Claim Failed", "Gagal Klaim"), e.toString());
      }
    }
  }

  Future<void> _buyStreakShield() async {
    if (_isBuyingShield) return;
    if (globalStreakShields.value >= GameManager.maxStreakShields) {
      AppSnackbar.showSuccess(
        context,
        _t(
          "Your Streak Shields are already at maximum (${GameManager.maxStreakShields}/${GameManager.maxStreakShields})!",
          "Streak Shield kamu sudah penuh (${GameManager.maxStreakShields}/${GameManager.maxStreakShields})!",
        ),
      );
      return;
    }

    if (globalXP.value < GameManager.streakShieldCostXP) {
      AppSnackbar.showError(
        context,
        _t(
          "Need ${GameManager.streakShieldCostXP} XP to equip a Streak Shield.",
          "Butuh ${GameManager.streakShieldCostXP} XP untuk membeli Streak Shield.",
        ),
      );
      return;
    }

    setState(() => _isBuyingShield = true);
    try {
      final bool success = await GameManager.buyStreakShieldWithXP();
      if (!mounted) return;
      if (success) {
        AppSnackbar.showSuccess(
          context,
          _t(
            "Streak Shield equipped! Your streak is protected if you miss a day.",
            "Streak Shield aktif! Streak kamu terlindungi jika terlewat 1 hari.",
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBuyingShield = false);
    }
  }

  Future<void> _claimAchievement(String key) async {
    final meta = await LocalRepository.getUserProgress();
    if (meta[key] == true) return;

    try {
      globalXP.value += 200;
      await prefs.setInt('gm_xp', globalXP.value);
      await LocalRepository.queueActionsBatch({
        'gm_xp': globalXP.value,
        key: true,
      });

      setState(() {
        if (key == 'ach_hira') _claimedHiragana = true;
        if (key == 'ach_kata') _claimedKatakana = true;
        if (key == 'ach_kanji') _claimedKanji = true;
        if (key == 'ach_alphabet') _claimedAlphabetMaster = true;
        if (key == 'ach_sim') _claimedSim = true;
        if (key == 'ach_3d') _claimed3Days = true;
        if (key == 'ach_7d') _claimed7Days = true;
        if (key == 'ach_14d') _claimed14Days = true;
        if (key == 'ach_30d') _claimed30Days = true;
        if (key == 'ach_mirai') _claimedMirai = true;
      });

      if (mounted) {
        _showSuccessDialog(
          _t("Achievement Claimed! +200 XP", "Pencapaian Diklaim! +200 XP"),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(_t("Claim Failed", "Gagal Klaim"), e.toString());
      }
    }
  }

  void _showAchievementDetailDialog({
    required String title,
    required String description,
    required _AchievementBadge badge,
    required Color accentColor,
    required bool isCompleted,
    required bool isClaimed,
    VoidCallback? onClaim,
  }) {
    final isDark = globalDarkMode.value;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge.text,
                  style: (badge.isLabel
                          ? AppTextStyles.titleLarge
                          : AppTextStyles.japaneseTitle)
                      .copyWith(
                    fontSize: badge.isLabel ? 18 : 32,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: subTextColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (isClaimed)
              AppBadge(
                label: _t("CLAIMED", "SUDAH DIKLAIM"),
                icon: Icons.check_circle_rounded,
                color: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              )
            else if (isCompleted)
              AppButton(
                label: _t("CLAIM 200 XP", "KLAIM 200 XP"),
                height: 50,
                onPressed: () {
                  Navigator.pop(context);
                  if (onClaim != null) onClaim();
                },
              )
            else
              AppButton(
                label: _t("CLOSE", "TUTUP"),
                variant: AppButtonVariant.secondary,
                height: 50,
                onPressed: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    final isDark = globalDarkMode.value;
    final errorColor = isDark ? AppColors.errorDark : AppColors.errorLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: errorColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: errorColor,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: subTextColor),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: "OK",
              height: 50,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    final isDark = globalDarkMode.value;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _t("Success", "Berhasil"),
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: subTextColor),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _t("AWESOME!", "MANTAP!"),
              height: 50,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getAvatarImage(String url) {
    if (url.isNotEmpty && url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return const AssetImage('assets/images/iconUtama.png');
    }
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPrefsInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryLight),
        ),
      );
    }
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
        final Color secondaryColor =
            isDark ? AppColors.secondaryDark : AppColors.secondaryLight;

        final int finishedUnits = [
          (prefs.getInt('u1_test_stars') ?? 0) >= 1,
          (prefs.getInt('u2_test_stars') ?? 0) >= 1,
          (prefs.getInt('u3_test_stars') ?? 0) >= 1,
          (prefs.getInt('u4_test_stars') ?? 0) >= 1,
        ].where((b) => b).length;
        final bool isAllUnitsFinished = finishedUnits >= 4;

        final int claimedCount = [
          _claimedHiragana,
          _claimedKatakana,
          _claimedKanji,
          _claimedAlphabetMaster,
          _claimedSim,
          _claimed3Days,
          _claimed7Days,
          _claimed14Days,
          _claimed30Days,
          _claimedMirai,
        ].where((c) => c).length;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            bottom: true,
            child: RefreshIndicator(
              onRefresh: () async {
                _loadSupabaseUserData();
                await _loadLocalStats();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xxl),

                    // PROFILE HEADER
                    Center(
                      child: ValueListenableBuilder<String>(
                        valueListenable: globalAvatarUrl,
                        builder: (context, avatarUrl, _) {
                          return Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusXxl),
                              border: Border.all(
                                color: primaryColor,
                                width: 3,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusXl),
                                child: Image(
                                  image: _getAvatarImage(avatarUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Padding(
                      padding: AppSpacing.screenHorizontal,
                      child: Column(
                        children: [
                          Text(
                            _userName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.displayMedium.copyWith(
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _userDesc,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userEmail,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: subTextColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // DAILY OMIKUJI SURPRISE REWARDS CARD (Core Drive 7)
                    Padding(
                      padding: AppSpacing.screenHorizontal,
                      child: AppCard(
                        onTap: _claimDailyReward,
                        borderColor: _isDailyClaimedToday
                            ? borderColor
                            : primaryColor,
                        borderWidth: _isDailyClaimedToday ? 1.5 : 2.5,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: (_isDailyClaimedToday
                                        ? subTextColor
                                        : primaryColor)
                                    .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusLg),
                              ),
                              child: Icon(
                                _isDailyClaimedToday
                                    ? Icons.check_circle_rounded
                                    : Icons.card_giftcard_rounded,
                                color: _isDailyClaimedToday
                                    ? subTextColor
                                    : primaryColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _t(
                                      "Daily Omikuji Surprise",
                                      "Kejutan Omikuji Harian",
                                    ),
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: subTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          _isDailyClaimedToday
                                              ? _t(
                                                  "Already Claimed Today",
                                                  "Sudah Diklaim Hari Ini",
                                                )
                                              : _t(
                                                  "Draw Fortune (+50~100 XP)",
                                                  "Ambil Omikuji (+50~100 XP)",
                                                ),
                                          style: AppTextStyles.titleMedium
                                              .copyWith(
                                            color: textColor,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      if (!_isDailyClaimedToday) ...[
                                        const SizedBox(width: AppSpacing.xs),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppColors.starGold,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome_rounded,
                                            color: Colors.black,
                                            size: 14,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // STREAK SHIELD PROTECTION CARD (Core Drive 8: Loss & Avoidance)
                    Padding(
                      padding: AppSpacing.screenHorizontal,
                      child: ValueListenableBuilder<int>(
                        valueListenable: globalStreakShields,
                        builder: (context, shields, _) {
                          final bool isFull =
                              shields >= GameManager.maxStreakShields;
                          return AppCard(
                            onTap: _buyStreakShield,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: secondaryColor.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusLg,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.shield_rounded,
                                    color: secondaryColor,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: AppSpacing.xs,
                                        runSpacing: 4,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            _t(
                                              "Streak Shield (Omamori)",
                                              "Pelindung Streak (Omamori)",
                                            ),
                                            style: AppTextStyles.labelMedium
                                                .copyWith(color: subTextColor),
                                          ),
                                          AppBadge(
                                            label:
                                                "$shields/${GameManager.maxStreakShields}",
                                            color: secondaryColor,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isFull
                                            ? _t(
                                                "Fully Protected",
                                                "Perlindungan Maksimal",
                                              )
                                            : _t(
                                                "Equip Shield (${GameManager.streakShieldCostXP} XP)",
                                                "Pasang Perisai (${GameManager.streakShieldCostXP} XP)",
                                              ),
                                        style:
                                            AppTextStyles.titleMedium.copyWith(
                                          color: textColor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  isFull
                                      ? Icons.verified_rounded
                                      : Icons.add_circle_outline_rounded,
                                  color: secondaryColor,
                                  size: 22,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // JLPT READINESS TRACKER CARD
                    Padding(
                      padding: AppSpacing.screenHorizontal,
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const JLPTTrackerScreen(),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: secondaryColor.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusLg),
                              ),
                              child: Icon(
                                Icons.analytics_outlined,
                                color: secondaryColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _t("JLPT Readiness", "Kesiapan JLPT"),
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: subTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _t(
                                      "Check your N5 progress",
                                      "Cek progres N5 kamu",
                                    ),
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: subTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // ACHIEVEMENTS SECTION
                    Padding(
                      padding: AppSpacing.screenHorizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _t("Achievements", "Pencapaian"),
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              AppBadge(
                                label: "$claimedCount / 10",
                                icon: Icons.emoji_events_rounded,
                                color: primaryColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ValueListenableBuilder<List<String>>(
                            valueListenable: globalLearnedHiragana,
                            builder: (context, learnedHira, _) {
                              return ValueListenableBuilder<List<String>>(
                                valueListenable: globalLearnedKatakana,
                                builder: (context, learnedKata, _) {
                                  return ValueListenableBuilder<List<String>>(
                                    valueListenable: globalLearnedKanji,
                                    builder: (context, learnedKanji, _) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        child: Row(
                                          children: [
                                            _buildAchievementCardH(
                                              badge:
                                                  _AchievementBadge.text("あ"),
                                              accentColor: primaryColor,
                                              title: _t(
                                                "Hiragana Master",
                                                "Ahli Hiragana",
                                              ),
                                              description: _t(
                                                "Learn all 104 basic Hiragana characters by completing Hiragana lessons.",
                                                "Pelajari semua 104 karakter Hiragana dasar dengan menyelesaikan pelajaran Hiragana.",
                                              ),
                                              progress: _claimedHiragana
                                                  ? 1.0
                                                  : (learnedHira.length / 104)
                                                      .clamp(0.0, 1.0),
                                              progressLabel: _claimedHiragana
                                                  ? _t("COMPLETED", "SELESAI")
                                                  : "${learnedHira.length}/104",
                                              isCompleted:
                                                  learnedHira.length >= 104 ||
                                                      _claimedHiragana,
                                              isClaimed: _claimedHiragana,
                                              onClaim: () =>
                                                  _claimAchievement('ach_hira'),
                                              cardColor: cardColor,
                                              textColor: textColor,
                                              borderColor: borderColor,
                                              isDark: isDark,
                                              subTextColor: subTextColor,
                                              primaryColor: primaryColor,
                                            ),
                                            _buildAchievementCardH(
                                              badge:
                                                  _AchievementBadge.text("ア"),
                                              accentColor: secondaryColor,
                                              title: _t(
                                                "Katakana Master",
                                                "Ahli Katakana",
                                              ),
                                              description: _t(
                                                "Learn all 104 basic Katakana characters by completing Katakana lessons.",
                                                "Pelajari semua 104 karakter Katakana dasar dengan menyelesaikan pelajaran Katakana.",
                                              ),
                                              progress: _claimedKatakana
                                                  ? 1.0
                                                  : (learnedKata.length / 104)
                                                      .clamp(0.0, 1.0),
                                              progressLabel: _claimedKatakana
                                                  ? _t("COMPLETED", "SELESAI")
                                                  : "${learnedKata.length}/104",
                                              isCompleted:
                                                  learnedKata.length >= 104 ||
                                                      _claimedKatakana,
                                              isClaimed: _claimedKatakana,
                                              onClaim: () =>
                                                  _claimAchievement('ach_kata'),
                                              cardColor: cardColor,
                                              textColor: textColor,
                                              borderColor: borderColor,
                                              isDark: isDark,
                                              subTextColor: subTextColor,
                                              primaryColor: primaryColor,
                                            ),
                                            _buildAchievementCardH(
                                              badge:
                                                  _AchievementBadge.text("漢"),
                                              accentColor:
                                                  AppColors.kanjiPurple,
                                              title: _t(
                                                "Kanji Learner",
                                                "Pembelajar Kanji",
                                              ),
                                              description: _t(
                                                "Learn all 68 essential N5 Kanji characters across all categories.",
                                                "Pelajari seluruh 68 karakter Kanji N5 penting di semua kategori.",
                                              ),
                                              progress: _claimedKanji
                                                  ? 1.0
                                                  : (learnedKanji.length / 68)
                                                      .clamp(0.0, 1.0),
                                              progressLabel: _claimedKanji
                                                  ? _t("COMPLETED", "SELESAI")
                                                  : "${learnedKanji.length}/68",
                                              isCompleted:
                                                  learnedKanji.length >= 68 ||
                                                      _claimedKanji,
                                              isClaimed: _claimedKanji,
                                              onClaim: () => _claimAchievement(
                                                'ach_kanji',
                                              ),
                                              cardColor: cardColor,
                                              textColor: textColor,
                                              borderColor: borderColor,
                                              isDark: isDark,
                                              subTextColor: subTextColor,
                                              primaryColor: primaryColor,
                                            ),
                                            _buildAchievementCardH(
                                              badge: _AchievementBadge.label(
                                                "ABC",
                                              ),
                                              accentColor: primaryColor,
                                              title: _t(
                                                "Alphabet Master",
                                                "Penguasa Alfabet",
                                              ),
                                              description: _t(
                                                "Master all Japanese writing systems by claiming Hiragana, Katakana, and Kanji achievements.",
                                                "Kuasai semua sistem penulisan Jepang dengan mengklaim pencapaian Hiragana, Katakana, dan Kanji.",
                                              ),
                                              progress: _claimedAlphabetMaster
                                                  ? 1.0
                                                  : ((_claimedHiragana &&
                                                          _claimedKatakana &&
                                                          _claimedKanji)
                                                      ? 1.0
                                                      : 0.0),
                                              progressLabel:
                                                  _claimedAlphabetMaster
                                                      ? _t(
                                                          "COMPLETED",
                                                          "SELESAI",
                                                        )
                                                      : "HiraKataKanji",
                                              isCompleted: (_claimedHiragana &&
                                                      _claimedKatakana &&
                                                      _claimedKanji) ||
                                                  _claimedAlphabetMaster,
                                              isClaimed: _claimedAlphabetMaster,
                                              onClaim: () => _claimAchievement(
                                                'ach_alphabet',
                                              ),
                                              cardColor: cardColor,
                                              textColor: textColor,
                                              borderColor: borderColor,
                                              isDark: isDark,
                                              subTextColor: subTextColor,
                                              primaryColor: primaryColor,
                                            ),
                                            ValueListenableBuilder<int>(
                                              valueListenable:
                                                  globalSimulationCount,
                                              builder: (context, simCount, _) {
                                                return _buildAchievementCardH(
                                                  badge:
                                                      _AchievementBadge.label(
                                                    "JLPT",
                                                  ),
                                                  accentColor:
                                                      AppColors.streakFlame,
                                                  title: _t(
                                                    "Simulator Pro",
                                                    "Pro Simulator",
                                                  ),
                                                  description: _t(
                                                    "Put your skills to the test! Complete 10 writing and recognition simulations.",
                                                    "Uji kemampuanmu! Selesaikan 10 simulasi penulisan dan pengenalan.",
                                                  ),
                                                  progress: _claimedSim
                                                      ? 1.0
                                                      : (simCount / 10)
                                                          .clamp(0.0, 1.0),
                                                  progressLabel: _claimedSim
                                                      ? _t(
                                                          "COMPLETED",
                                                          "SELESAI",
                                                        )
                                                      : "$simCount/10",
                                                  isCompleted: simCount >= 10 ||
                                                      _claimedSim,
                                                  isClaimed: _claimedSim,
                                                  onClaim: () =>
                                                      _claimAchievement(
                                                    'ach_sim',
                                                  ),
                                                  cardColor: cardColor,
                                                  textColor: textColor,
                                                  borderColor: borderColor,
                                                  isDark: isDark,
                                                  subTextColor: subTextColor,
                                                  primaryColor: primaryColor,
                                                );
                                              },
                                            ),
                                            ValueListenableBuilder<int>(
                                              valueListenable: globalStreak,
                                              builder: (context, streak, _) {
                                                return Row(
                                                  children: [
                                                    _buildAchievementCardH(
                                                      badge: _AchievementBadge
                                                          .label("3"),
                                                      accentColor:
                                                          AppColors.heartCrimson,
                                                      title: _t(
                                                        "3 Days Streak",
                                                        "3 Hari Beruntun",
                                                      ),
                                                      description: _t(
                                                        "Keep your learning momentum! Maintain a login streak for 3 consecutive days.",
                                                        "Pertahankan momentum belajarmu! Login selama 3 hari berturut-turut.",
                                                      ),
                                                      progress: _claimed3Days
                                                          ? 1.0
                                                          : (streak / 3)
                                                              .clamp(0.0, 1.0),
                                                      progressLabel:
                                                          _claimed3Days
                                                              ? _t(
                                                                  "COMPLETED",
                                                                  "SELESAI",
                                                                )
                                                              : "$streak/3",
                                                      isCompleted: streak >=
                                                              3 ||
                                                          _claimed3Days,
                                                      isClaimed: _claimed3Days,
                                                      onClaim: () =>
                                                          _claimAchievement(
                                                        'ach_3d',
                                                      ),
                                                      cardColor: cardColor,
                                                      textColor: textColor,
                                                      borderColor: borderColor,
                                                      isDark: isDark,
                                                      subTextColor:
                                                          subTextColor,
                                                      primaryColor:
                                                          primaryColor,
                                                    ),
                                                    _buildAchievementCardH(
                                                      badge: _AchievementBadge
                                                          .label("7"),
                                                      accentColor:
                                                          AppColors.heartCrimson,
                                                      title: _t(
                                                        "7 Days Streak",
                                                        "7 Hari Beruntun",
                                                      ),
                                                      description: _t(
                                                        "Keep your learning momentum! Maintain a login streak for 7 consecutive days.",
                                                        "Pertahankan momentum belajarmu! Login selama 7 hari berturut-turut.",
                                                      ),
                                                      progress: _claimed7Days
                                                          ? 1.0
                                                          : (streak / 7)
                                                              .clamp(0.0, 1.0),
                                                      progressLabel:
                                                          _claimed7Days
                                                              ? _t(
                                                                  "COMPLETED",
                                                                  "SELESAI",
                                                                )
                                                              : "$streak/7",
                                                      isCompleted: streak >=
                                                              7 ||
                                                          _claimed7Days,
                                                      isClaimed: _claimed7Days,
                                                      onClaim: () =>
                                                          _claimAchievement(
                                                        'ach_7d',
                                                      ),
                                                      cardColor: cardColor,
                                                      textColor: textColor,
                                                      borderColor: borderColor,
                                                      isDark: isDark,
                                                      subTextColor:
                                                          subTextColor,
                                                      primaryColor:
                                                          primaryColor,
                                                    ),
                                                    _buildAchievementCardH(
                                                      badge: _AchievementBadge
                                                          .label("14"),
                                                      accentColor:
                                                          AppColors.heartCrimson,
                                                      title: _t(
                                                        "14 Days Streak",
                                                        "14 Hari Beruntun",
                                                      ),
                                                      description: _t(
                                                        "Keep your learning momentum! Maintain a login streak for 14 consecutive days.",
                                                        "Pertahankan momentum belajarmu! Login selama 14 hari berturut-turut.",
                                                      ),
                                                      progress: _claimed14Days
                                                          ? 1.0
                                                          : (streak / 14)
                                                              .clamp(0.0, 1.0),
                                                      progressLabel:
                                                          _claimed14Days
                                                              ? _t(
                                                                  "COMPLETED",
                                                                  "SELESAI",
                                                                )
                                                              : "$streak/14",
                                                      isCompleted: streak >=
                                                              14 ||
                                                          _claimed14Days,
                                                      isClaimed: _claimed14Days,
                                                      onClaim: () =>
                                                          _claimAchievement(
                                                        'ach_14d',
                                                      ),
                                                      cardColor: cardColor,
                                                      textColor: textColor,
                                                      borderColor: borderColor,
                                                      isDark: isDark,
                                                      subTextColor:
                                                          subTextColor,
                                                      primaryColor:
                                                          primaryColor,
                                                    ),
                                                    _buildAchievementCardH(
                                                      badge: _AchievementBadge
                                                          .label("30"),
                                                      accentColor:
                                                          AppColors.heartCrimson,
                                                      title: _t(
                                                        "30 Days Streak",
                                                        "30 Hari Beruntun",
                                                      ),
                                                      description: _t(
                                                        "Keep your learning momentum! Maintain a login streak for 30 consecutive days.",
                                                        "Pertahankan momentum belajarmu! Login selama 30 hari berturut-turut.",
                                                      ),
                                                      progress: _claimed30Days
                                                          ? 1.0
                                                          : (streak / 30)
                                                              .clamp(0.0, 1.0),
                                                      progressLabel:
                                                          _claimed30Days
                                                              ? _t(
                                                                  "COMPLETED",
                                                                  "SELESAI",
                                                                )
                                                              : "$streak/30",
                                                      isCompleted: streak >=
                                                              30 ||
                                                          _claimed30Days,
                                                      isClaimed: _claimed30Days,
                                                      onClaim: () =>
                                                          _claimAchievement(
                                                        'ach_30d',
                                                      ),
                                                      cardColor: cardColor,
                                                      textColor: textColor,
                                                      borderColor: borderColor,
                                                      isDark: isDark,
                                                      subTextColor:
                                                          subTextColor,
                                                      primaryColor:
                                                          primaryColor,
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                            _buildAchievementCardH(
                                              badge:
                                                  _AchievementBadge.label("未来"),
                                              accentColor: primaryColor,
                                              title: _t("Mirai", "Mirai"),
                                              description: _t(
                                                "The ultimate goal! Complete all level tests from Unit 1 to Unit 4.",
                                                "Tujuan akhir! Selesaikan semua ujian level dari Unit 1 hingga Unit 4.",
                                              ),
                                              progress: (finishedUnits / 4)
                                                  .clamp(0.0, 1.0),
                                              progressLabel: isAllUnitsFinished
                                                  ? _t("COMPLETED", "SELESAI")
                                                  : _t(
                                                      "Unit $finishedUnits/4",
                                                      "Unit $finishedUnits/4",
                                                    ),
                                              isCompleted: isAllUnitsFinished,
                                              isClaimed: _claimedMirai,
                                              onClaim: () => _claimAchievement(
                                                'ach_mirai',
                                              ),
                                              cardColor: cardColor,
                                              textColor: textColor,
                                              borderColor: borderColor,
                                              isDark: isDark,
                                              subTextColor: subTextColor,
                                              primaryColor: primaryColor,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // MENU OPTIONS
                    Padding(
                      padding: AppSpacing.screenHorizontal,
                      child: AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            _buildMenuTile(
                              context: context,
                              icon: Icons.settings_rounded,
                              title: _t("Settings", "Pengaturan"),
                              subtitle: _t(
                                "Manage your account preferences",
                                "Kelola preferensi akunmu",
                              ),
                              textColor: textColor,
                              subTextColor: subTextColor,
                              primaryColor: primaryColor,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              ),
                              isDark: isDark,
                            ),
                            Divider(height: 1, color: borderColor, indent: 70),
                            _buildMenuTile(
                              context: context,
                              icon: Icons.notifications_rounded,
                              title: _t("Notifications", "Notifikasi"),
                              subtitle: _t(
                                "Daily reminders & info",
                                "Pengingat harian & info",
                              ),
                              textColor: textColor,
                              subTextColor: subTextColor,
                              primaryColor: primaryColor,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen(),
                                ),
                              ),
                              isDark: isDark,
                            ),
                            Divider(height: 1, color: borderColor, indent: 70),
                            _buildMenuTile(
                              context: context,
                              icon: Icons.info_outline_rounded,
                              title: _t("About", "Tentang"),
                              subtitle: _t(
                                "Learn more about MIRAIku",
                                "Pelajari lebih lanjut tentang MIRAIku",
                              ),
                              textColor: textColor,
                              subTextColor: subTextColor,
                              primaryColor: primaryColor,
                              onTap: () => AppDialogs.showAboutApp(context),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // GLOBAL LEADERBOARD CARD
                    Padding(
                      padding: AppSpacing.screenHorizontal,
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaderboardScreen(),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.medalGold.withValues(alpha: 0.14),
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusLg),
                              ),
                              child: const Icon(
                                Icons.emoji_events_outlined,
                                color: AppColors.medalGold,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _t("Global Rankings", "Peringkat Global"),
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: subTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _t(
                                      "See who is at the top",
                                      "Lihat siapa yang teratas",
                                    ),
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: subTextColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // LOGOUT AS DISTINCT ACTION
                    Center(
                      child: AppButton(
                        label: _t("LOGOUT", "KELUAR"),
                        variant: AppButtonVariant.text,
                        expand: false,
                        height: 48,
                        foregroundColor: isDark
                            ? AppColors.errorDark
                            : AppColors.errorLight,
                        onPressed: () =>
                            _showLogoutConfirmation(context, isDark),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // VERSION FOOTER
                    Center(
                      child: Text(
                        "MIRAIku Version v$_appVersion",
                        style: AppTextStyles.labelMedium.copyWith(
                          color: subTextColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height:
                          MediaQuery.of(context).padding.bottom + AppSpacing.md,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementCardH({
    required _AchievementBadge badge,
    required Color accentColor,
    required String title,
    required String description,
    required double progress,
    String? progressLabel,
    bool isCompleted = false,
    bool isClaimed = false,
    VoidCallback? onClaim,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    required bool isDark,
    required Color subTextColor,
    required Color primaryColor,
  }) {
    Widget bottomWidget = const SizedBox.shrink();
    if (isClaimed) {
      bottomWidget = Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 12, color: primaryColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _t("Already Claimed", "Sudah Diklaim"),
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: primaryColor,
              ),
            ),
          ),
        ],
      );
    } else if (isCompleted) {
      bottomWidget = Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(AppSpacing.xs),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _t("CLAIM 200 XP", "KLAIM 200 XP"),
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    } else {
      bottomWidget = Text(
        progressLabel ?? "",
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          color: subTextColor,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _showAchievementDetailDialog(
        title: title,
        description: description,
        badge: badge,
        accentColor: accentColor,
        isCompleted: isCompleted,
        isClaimed: isClaimed,
        onClaim: onClaim,
      ),
      child: Container(
        width: 154,
        height: 244,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isCompleted && !isClaimed
                ? primaryColor.withValues(alpha: 0.6)
                : borderColor,
            width: isCompleted && !isClaimed ? 2 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    badge.text,
                    style: (badge.isLabel
                            ? AppTextStyles.titleMedium
                            : AppTextStyles.japaneseTitle)
                        .copyWith(
                      fontSize: badge.isLabel ? 14 : 24,
                      fontWeight: FontWeight.w900,
                      color: isCompleted ? accentColor : subTextColor,
                    ),
                  ),
                  if (isCompleted)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: textColor,
                height: 1.15,
              ),
            ),
            const Spacer(),
            AppProgressBar(
              progress: progress,
              height: 8,
              color: primaryColor,
              semanticLabel: title,
            ),
            const SizedBox(height: AppSpacing.sm),
            bottomWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
    required VoidCallback onTap,
    String? trailingText,
    required bool isDark,
  }) {
    final Color iconBg = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w900,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 12,
          color: subTextColor,
        ),
      ),
      trailing: FittedBox(
        fit: BoxFit.scaleDown,
        child: trailingText != null
            ? Text(
                trailingText,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: subTextColor,
                ),
              )
            : Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: subTextColor,
              ),
      ),
      onTap: trailingText != null ? null : onTap,
    );
  }

  void _showLogoutConfirmation(BuildContext context, bool isDark) {
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        title: Text(
          _t("Logout?", "Keluar?"),
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        content: Text(
          _t(
            "Are you sure you want to sign out?",
            "Apakah anda yakin ingin keluar dari akun?",
          ),
          style: AppTextStyles.bodyMedium.copyWith(color: subTextColor),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _t("CANCEL", "BATAL"),
                  variant: AppButtonVariant.text,
                  height: 48,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: _t("LOGOUT", "KELUAR"),
                  height: 48,
                  borderRadius: AppSpacing.radiusMd,
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => PopScope(
                        canPop: false,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: CircularProgressIndicator(
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                    );

                    try {
                      if (!GameManager.isDevSession) {
                        await LocalRepository.flushQueue();
                      }
                      await _supabase?.auth.signOut();
                      try {
                        await GoogleSignIn().signOut();
                      } catch (_) {}

                      await GameManager.resetProgress();

                      if (!context.mounted) return;

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                        (route) => false,
                      );
                    } catch (e) {
                      debugPrint("Error during logout: $e");
                      await GameManager.resetProgress();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
