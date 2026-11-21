import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_snackbar.dart';
import 'screen_simulation_history.dart';
import 'screen_simulation_test.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  bool _isUnlocked = false;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  void _checkUnlockStatus() {
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? {};
    setState(() {
      _isUnlocked = meta['unlocked_sim_n5'] ?? false;
      _isLoading = false;
    });
  }

  Future<void> _handleSimulationAction() async {
    if (_isProcessing) return;

    if (!_isUnlocked) {
      setState(() => _isProcessing = true);
      try {
        if (globalXP.value < 1500) {
          AppSnackbar.showError(
            context,
            _t(
              "Not enough XP to unlock the simulation.",
              "XP tidak cukup untuk membuka simulasi.",
            ),
          );
          return;
        }

        final bool success = await GameManager.spendXP(
          1500,
          extraData: {'unlocked_sim_n5': true},
        );

        if (success) {
          setState(() => _isUnlocked = true);
          if (mounted) {
            AppSnackbar.showSuccess(
              context,
              _t(
                "Simulation unlocked! Now you can start the exam for 100 XP.",
                "Simulasi terbuka! Sekarang kamu bisa memulai ujian seharga 100 XP.",
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(context, _t("Error: $e", "Kesalahan: $e"));
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    } else {
      if (globalXP.value < 100) {
        AppSnackbar.showError(
          context,
          _t(
            "Not enough XP to start the exam.",
            "XP tidak cukup untuk memulai ujian.",
          ),
        );
        return;
      }

      _showStartConfirmation();
    }
  }

  void _showStartConfirmation() {
    final isDark = globalDarkMode.value;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  64,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                  border: Border.all(color: borderColor),
                  boxShadow: AppShadows.dialog(isDark),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _t("Ready to Start?", "Siap untuk Mulai?"),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _t(
                        "Believe in yourself! You've prepared well for this. Focus and do your best!",
                        "Percayalah pada dirimu sendiri! Kamu sudah bersiap dengan baik. Fokus dan lakukan yang terbaik!",
                      ),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppBadge(
                      label: _t("Cost: 100 XP", "Biaya: 100 XP"),
                      icon: Icons.bolt_rounded,
                      color: primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: _t("CANCEL", "BATAL"),
                            variant: AppButtonVariant.ghost,
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            label: _t("START", "MULAI"),
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              setState(() => _isProcessing = true);

                              try {
                                final bool success =
                                    await GameManager.spendXP(100);

                                if (success && mounted) {
                                  await GameManager.incrementSimulationCount();
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SimulationTestScreen(),
                                      ),
                                    );
                                  }
                                } else if (!success && mounted) {
                                  AppSnackbar.showError(
                                    context,
                                    _t(
                                      "Not enough XP to start the exam.",
                                      "XP tidak cukup untuk memulai ujian.",
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  AppSnackbar.showError(
                                    context,
                                    _t("Error: $e", "Kesalahan: $e"),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _isProcessing = false);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -42,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.bannerPrimaryDark
                        : AppColors.primaryLight,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.accentGlow(
                      primaryColor,
                      isDark: isDark,
                    ),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLatestHistory() {
    final history = globalSimulationHistory.value;
    if (history.isEmpty) {
      _showCustomDialog(
        title: _t("No History", "Tidak Ada Riwayat"),
        message: _t(
          "You haven't completed any simulations yet.",
          "Kamu belum menyelesaikan simulasi apa pun.",
        ),
        icon: Icons.history_rounded,
        iconColor: globalDarkMode.value
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimulationHistoryScreen(),
      ),
    );
  }

  void _showCustomDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = globalDarkMode.value;
        return AlertDialog(
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
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: iconColor),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: "OK",
                height: 48,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  double _getScale(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width > 600) return 1.15;
    if (width < 360) return 0.9;
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryLight),
      );
    }

    final media = MediaQuery.of(context);
    final double scale = _getScale(context);
    final bool isTablet = media.size.width > 600;

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor =
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
        final Color textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final Color subTextColor =
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        final Color primaryColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                _checkUnlockStatus();
                await GameManager.syncToCloud();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? AppSpacing.huge : AppSpacing.xl,
                  ),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: AppSpacing.maxContentWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: AppSpacing.xxl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppBadge(
                                label: "OFFICIAL JLPT N5 STANDARD",
                                color: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                              ),
                              if (_isUnlocked) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Semantics(
                                  button: true,
                                  label: _t('Exam history', 'Riwayat ujian'),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusPill,
                                      ),
                                      onTap: _showLatestHistory,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: primaryColor.withValues(
                                              alpha: 0.25,
                                            ),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.history_rounded,
                                          color: primaryColor,
                                          size: 18 * scale,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: AppSpacing.md * scale),
                          Text(
                            _t("JLPT N5 Mock Exam", "Simulasi Ujian JLPT N5"),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineLarge.copyWith(
                              fontSize: 28 * scale,
                              color: textColor,
                            ),
                          ),
                          SizedBox(height: AppSpacing.sm * scale),
                          Text(
                            _t(
                              "Professional simulation covering Language Knowledge and Reading. Test your skills under official timing constraints.",
                              "Simulasi profesional mencakup Pengetahuan Bahasa dan Membaca. Uji kemampuanmu dalam batasan waktu resmi.",
                            ),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: subTextColor,
                              fontSize: 14 * scale,
                            ),
                          ),
                          SizedBox(height: AppSpacing.xxl * scale),

                          if (isTablet)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildExamStructureCard(
                                    isDark,
                                    textColor,
                                    subTextColor,
                                    primaryColor,
                                    scale,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildGradingSystemCard(
                                        isDark,
                                        textColor,
                                        subTextColor,
                                        primaryColor,
                                        scale,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      _buildOneAttemptCard(
                                        isDark,
                                        textColor,
                                        subTextColor,
                                        primaryColor,
                                        scale,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildExamStructureCard(
                              isDark,
                              textColor,
                              subTextColor,
                              primaryColor,
                              scale,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildGradingSystemCard(
                              isDark,
                              textColor,
                              subTextColor,
                              primaryColor,
                              scale,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            _buildOneAttemptCard(
                              isDark,
                              textColor,
                              subTextColor,
                              primaryColor,
                              scale,
                            ),
                          ],

                          SizedBox(height: AppSpacing.xxl * scale),
                          AppButton(
                            label: _isUnlocked
                                ? _t("START SIMULATION", "MULAI SIMULASI")
                                : _t("UNLOCK SIMULATION", "BUKA SIMULASI"),
                            height: 60 * scale,
                            isLoading: _isProcessing,
                            backgroundColor: _isUnlocked
                                ? (isDark
                                    ? AppColors.bannerPrimaryDark
                                    : AppColors.primaryLight)
                                : (isDark
                                    ? AppColors.surfaceContainerHighDark
                                    : AppColors.textSecondaryLight),
                            foregroundColor: Colors.white,
                            onPressed: _handleSimulationAction,
                            customChild: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isUnlocked
                                        ? _t(
                                            "START SIMULATION",
                                            "MULAI SIMULASI",
                                          )
                                        : _t(
                                            "UNLOCK SIMULATION",
                                            "BUKA SIMULASI",
                                          ),
                                    style: AppTextStyles.titleLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: 17 * scale,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 22 * scale,
                                  ),
                                  if (!_isUnlocked) ...[
                                    const SizedBox(width: AppSpacing.md),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.stars_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "1500 XP",
                                            style: AppTextStyles.labelLarge
                                                .copyWith(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.huge),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamStructureCard(
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color primaryColor,
    double scale,
  ) {
    final Color sectionColor = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight.withValues(alpha: 0.5);

    return AppCard(
      padding: EdgeInsets.all(AppSpacing.xl * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  color: primaryColor,
                  size: 24 * scale,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _t("Test Modules", "Modul Ujian"),
                style: AppTextStyles.titleLarge.copyWith(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl * scale),
          _buildSessionDetail(
            title: _t("Language Knowledge", "Pengetahuan Bahasa"),
            subtitle: "Moji, Goi, Bunpou",
            duration: "25",
            description: _t(
              "Kanji reading, vocabulary context, and grammar particles.",
              "Cara baca Kanji, kosakata sesuai konteks, dan partikel tata bahasa.",
            ),
            isDark: isDark,
            textColor: textColor,
            subTextColor: subTextColor,
            primaryColor: primaryColor,
            bgColor: sectionColor,
            scale: scale,
          ),
          SizedBox(height: AppSpacing.md * scale),
          _buildSessionDetail(
            title: _t("Reading", "Membaca"),
            subtitle: "Dokkai",
            duration: "25",
            description: _t(
              "Short sentences, paragraphs, and informational texts.",
              "Kalimat pendek, paragraf, dan teks informasi (email/pengumuman).",
            ),
            isDark: isDark,
            textColor: textColor,
            subTextColor: subTextColor,
            primaryColor: primaryColor,
            bgColor: sectionColor,
            scale: scale,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetail({
    required String title,
    required String subtitle,
    required String duration,
    required String description,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
    required Color bgColor,
    required double scale,
  }) {
    final badgeBg =
        isDark ? AppColors.bannerPrimaryDark : AppColors.primaryLight;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md * scale),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * scale,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: primaryColor,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      color: Colors.white,
                      size: 14 * scale,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$duration mnt",
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm * scale),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: subTextColor,
              fontSize: 13 * scale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingSystemCard(
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color primaryColor,
    double scale,
  ) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.xl * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: primaryColor,
                size: 24 * scale,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _t("Grading System", "Sistem Penilaian"),
                style: AppTextStyles.titleLarge.copyWith(
                  color: textColor,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl * scale),
          Row(
            children: [
              _buildGradeStat(
                _t("MAX SCORE", "SKOR MAKS"),
                "180",
                textColor,
                subTextColor,
                scale,
              ),
              Container(
                width: 1,
                height: 40 * scale,
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.xl * scale),
              ),
              _buildGradeStat(
                _t("PASSING GRADE", "BATAS LULUS"),
                "80",
                primaryColor,
                subTextColor,
                scale,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg * scale),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              _t(
                "Pass criteria: Total score ≥ 80 AND meet minimum sectional standard. Zero score in any section results in failure.",
                "Kriteria lulus: Skor total ≥ 80 DAN memenuhi standar minimum tiap sesi. Skor nol pada sesi mana pun dianggap tidak lulus.",
              ),
              style: AppTextStyles.labelSmall.copyWith(
                color: subTextColor,
                fontSize: 11 * scale,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeStat(
    String label,
    String value,
    Color valueColor,
    Color subTextColor,
    double scale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: subTextColor,
            fontSize: 10 * scale,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headlineLarge.copyWith(
            color: valueColor,
            fontSize: 28 * scale,
          ),
        ),
      ],
    );
  }

  Widget _buildOneAttemptCard(
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color primaryColor,
    double scale,
  ) {
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.lg * scale),
      borderColor: primaryColor.withValues(alpha: 0.25),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gavel_rounded,
              color: primaryColor,
              size: 24 * scale,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t("Strict Exam Rules", "Aturan Ujian Ketat"),
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16 * scale,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t(
                    "Continuous timer. No pauses. Result is final.",
                    "Waktu berjalan terus. Tanpa jeda. Hasil bersifat final.",
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12 * scale,
                    color: subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
