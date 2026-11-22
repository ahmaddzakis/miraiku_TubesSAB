import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_manager.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/repository/local_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_snackbar.dart';
import 'screen_simulation_history.dart';
import 'screen_simulation_test.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  static const int _unlockCostXp = 1500;
  static const int _sessionCostXp = 100;
  static const int _maxScore = 180;
  static const int _passingScore = 80;

  bool _isUnlocked = false;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  Future<void> _checkUnlockStatus() async {
    Map<String, dynamic> meta = {};
    if (!GameManager.isDevSession) {
      User? user;
      try {
        user = Supabase.instance.client.auth.currentUser;
      } catch (_) {}
      meta = user?.userMetadata ?? {};
    }
    if (meta.isEmpty) {
      meta = await LocalRepository.getUserProgress();
    }
    if (!mounted) return;
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
        if (globalXP.value < _unlockCostXp) {
          AppSnackbar.showError(
            context,
            AppLocalizations.simNotEnoughXpToUnlock(),
          );
          return;
        }

        final bool success = await GameManager.spendXP(
          _unlockCostXp,
          extraData: {'unlocked_sim_n5': true},
        );

        if (success) {
          setState(() => _isUnlocked = true);
          if (mounted) {
            AppSnackbar.showSuccess(
              context,
              AppLocalizations.simUnlockedSuccessMessage(),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(
            context,
            AppLocalizations.simErrorMessage(e),
          );
        }
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    } else {
      if (globalXP.value < _sessionCostXp) {
        AppSnackbar.showError(
          context,
          AppLocalizations.simNotEnoughXpToStart(),
        );
        return;
      }

      _showStartConfirmation();
    }
  }

  void _showStartConfirmation() {
    final bool isDark = globalDarkMode.value;
    final Color primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final Color secondaryColor =
        isDark ? AppColors.secondaryDark : AppColors.secondaryLight;
    final Color warningColor =
        isDark ? AppColors.warningDark : AppColors.warningLight;
    final Color surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final Color variantColor =
        isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;
    final Color borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxDialogWidth,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.huge + AppSpacing.xs,
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
                      AppBadge(
                        label: AppLocalizations.simBriefingBadge(),
                        color: primaryColor,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppLocalizations.simReadyToStartTitle(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppLocalizations.simReadyToStartSubtitle(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: subTextColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: variantColor,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            _BriefingRow(
                              icon: Icons.timer_outlined,
                              iconColor: primaryColor,
                              title: AppLocalizations.simRuleDurationTitle(),
                              subtitle:
                                  AppLocalizations.simRuleDurationSubtitle(),
                              textColor: textColor,
                              subTextColor: subTextColor,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: Divider(height: 1),
                            ),
                            _BriefingRow(
                              icon: Icons.verified_outlined,
                              iconColor: secondaryColor,
                              title: AppLocalizations.simRulePassScoreTitle(),
                              subtitle:
                                  AppLocalizations.simRulePassScoreSubtitle(),
                              textColor: textColor,
                              subTextColor: subTextColor,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: Divider(height: 1),
                            ),
                            _BriefingRow(
                              icon: Icons.bolt_rounded,
                              iconColor: warningColor,
                              title: AppLocalizations.simRuleTicketTitle(),
                              subtitle:
                                  AppLocalizations.simRuleTicketSubtitle(),
                              textColor: textColor,
                              subTextColor: subTextColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: AppLocalizations.cancelLabel(),
                              variant: AppButtonVariant.ghost,
                              onPressed: () => Navigator.pop(dialogContext),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppButton(
                              label: AppLocalizations.simStartExamAction(),
                              icon: Icons.play_arrow_rounded,
                              onPressed: () async {
                                Navigator.pop(dialogContext);
                                setState(() => _isProcessing = true);

                                try {
                                  final bool success =
                                      await GameManager.spendXP(_sessionCostXp);

                                  if (success && mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SimulationTestScreen(),
                                      ),
                                    );
                                  } else if (!success && mounted) {
                                    AppSnackbar.showError(
                                      context,
                                      AppLocalizations.simNotEnoughXpToStart(),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    AppSnackbar.showError(
                                      context,
                                      AppLocalizations.simErrorMessage(e),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _isProcessing = false);
                                  }
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
                  top: -AppSpacing.xxl,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.bannerPrimaryDark
                          : AppColors.primaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: surfaceColor,
                        width: AppSpacing.xxs,
                      ),
                      boxShadow: AppShadows.accentGlow(
                        primaryColor,
                        isDark: isDark,
                      ),
                    ),
                    child: const Icon(
                      Icons.assignment_turned_in_rounded,
                      color: AppColors.onBannerPrimary,
                      size: AppSpacing.xxl,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openHistoryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimulationHistoryScreen(),
      ),
    );
  }

  int _computeBestScore(List<dynamic> historyList) {
    int bestScore = 0;
    for (final item in historyList) {
      if (item is Map) {
        final int points = (item['totalPoints'] as num?)?.toInt() ?? 0;
        if (points > bestScore) bestScore = points;
      }
    }
    return bestScore.clamp(0, _maxScore);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryLight),
      );
    }

    final media = MediaQuery.of(context);
    final bool isTablet = media.size.width > 600;

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            return ValueListenableBuilder<int>(
              valueListenable: globalXP,
              builder: (context, currentXp, _) {
                return ValueListenableBuilder<List<dynamic>>(
                  valueListenable: globalSimulationHistory,
                  builder: (context, historyList, _) {
                    final Color bgColor = isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight;
                    final Color textColor = isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight;
                    final Color subTextColor = isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight;
                    final Color primaryColor = isDark
                        ? AppColors.primaryDark
                        : AppColors.primaryLight;
                    final Color secondaryColor = isDark
                        ? AppColors.secondaryDark
                        : AppColors.secondaryLight;
                    final Color successColor = isDark
                        ? AppColors.successDark
                        : AppColors.successLight;
                    final int bestScore = _computeBestScore(historyList);

                    return Scaffold(
                      backgroundColor: bgColor,
                      body: SafeArea(
                        child: RefreshIndicator(
                          color: primaryColor,
                          onRefresh: () async {
                            await _checkUnlockStatus();
                            await GameManager.syncToCloud();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            padding: EdgeInsets.fromLTRB(
                              isTablet ? AppSpacing.huge : AppSpacing.xl,
                              AppSpacing.lg,
                              isTablet ? AppSpacing.huge : AppSpacing.xl,
                              AppSpacing.huge,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: AppSpacing.maxContentWidth,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Card 1: Hero Header Card
                                    _buildHeroHeaderCard(
                                      isDark: isDark,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                      primaryColor: primaryColor,
                                      successColor: successColor,
                                      historyCount: historyList.length,
                                      bestScore: bestScore,
                                    ),
                                    const SizedBox(height: AppSpacing.lg),

                                    // Card 2: Exam Room / Unlock Action Card
                                    _buildExamRoomCard(
                                      isDark: isDark,
                                      textColor: textColor,
                                      subTextColor: subTextColor,
                                      primaryColor: primaryColor,
                                      successColor: successColor,
                                      currentXp: currentXp,
                                    ),
                                    const SizedBox(height: AppSpacing.xxl),

                                    if (isTablet)
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: _buildModulesSection(
                                              isDark: isDark,
                                              textColor: textColor,
                                              subTextColor: subTextColor,
                                              primaryColor: primaryColor,
                                              secondaryColor: secondaryColor,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.lg),
                                          Expanded(
                                            flex: 5,
                                            child: Column(
                                              children: [
                                                _buildGradingSystemCard(
                                                  isDark: isDark,
                                                  textColor: textColor,
                                                  subTextColor: subTextColor,
                                                  primaryColor: primaryColor,
                                                  successColor: successColor,
                                                ),
                                                const SizedBox(
                                                  height: AppSpacing.lg,
                                                ),
                                                _buildStrictRulesCard(
                                                  isDark: isDark,
                                                  textColor: textColor,
                                                  subTextColor: subTextColor,
                                                  primaryColor: primaryColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    else ...[
                                      _buildModulesSection(
                                        isDark: isDark,
                                        textColor: textColor,
                                        subTextColor: subTextColor,
                                        primaryColor: primaryColor,
                                        secondaryColor: secondaryColor,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      _buildGradingSystemCard(
                                        isDark: isDark,
                                        textColor: textColor,
                                        subTextColor: subTextColor,
                                        primaryColor: primaryColor,
                                        successColor: successColor,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      _buildStrictRulesCard(
                                        isDark: isDark,
                                        textColor: textColor,
                                        subTextColor: subTextColor,
                                        primaryColor: primaryColor,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHeroHeaderCard({
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
    required Color successColor,
    required int historyCount,
    required int bestScore,
  }) {
    final bool hasPassedBest = bestScore >= _passingScore;
    final Color progressColor = hasPassedBest ? successColor : primaryColor;
    final double scoreProgress = (bestScore / _maxScore).clamp(0.0, 1.0);
    final Color cardTint = isDark
        ? AppColors.primaryContainerDark.withValues(alpha: 0.28)
        : AppColors.primaryContainerLight.withValues(alpha: 0.45);
    final Color surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardTint, surfaceColor],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.18),
        ),
        boxShadow: AppShadows.card(isDark),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle Japanese Kanji watermark ("試験" - Exam)
          Positioned(
            right: AppSpacing.md,
            top: AppSpacing.md,
            child: IgnorePointer(
              child: Opacity(
                opacity: isDark ? 0.05 : 0.06,
                child: Text(
                  '試験',
                  style: AppTextStyles.japaneseHero.copyWith(
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Standard Badge + History Pill Button
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      AppBadge(
                        label: AppLocalizations.simOfficialStandardBadge(),
                        icon: Icons.verified_rounded,
                        color: primaryColor,
                      ),
                      Semantics(
                        button: true,
                        label: AppLocalizations.simHistorySemantics(),
                        child: Material(
                          color: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceLight,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusPill),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusPill),
                            onTap: _openHistoryScreen,
                            child: Container(
                              constraints: const BoxConstraints(
                                minHeight: AppSpacing.minTapTarget,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.history_rounded,
                                    size: AppSpacing.lg,
                                    color: textColor,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    AppLocalizations.simHistoryLabel(),
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                  if (historyCount > 0) ...[
                                    const SizedBox(width: AppSpacing.xs),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xs,
                                        vertical: AppSpacing.xxs,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusPill,
                                        ),
                                      ),
                                      child: Text(
                                        '$historyCount',
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.onBannerPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Title
                Text(
                  AppLocalizations.simTitle(),
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Short Description
                Text(
                  AppLocalizations.simHeroDescription(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Personal Best Score Progress Box (Option B)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceVariantDark.withValues(alpha: 0.75)
                        : AppColors.surfaceLight.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: progressColor.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xxs,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.emoji_events_rounded,
                                  size: AppSpacing.lg,
                                  color: progressColor,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Flexible(
                                  child: Text(
                                    '${AppLocalizations.simBestScoreTitle()}: $bestScore / $_maxScore',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            AppBadge(
                              label: hasPassedBest
                                  ? AppLocalizations.simPassedBadge()
                                  : AppLocalizations.simPassTargetBadge(),
                              icon: hasPassedBest
                                  ? Icons.check_circle_rounded
                                  : Icons.flag_rounded,
                              color: progressColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: AppSpacing.xxs,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppProgressBar(
                        progress: scoreProgress,
                        height: AppSpacing.xs,
                        color: progressColor,
                        semanticLabel: AppLocalizations.simBestScoreSemantics(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamRoomCard({
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
    required Color successColor,
    required int currentXp,
  }) {
    final Color statusColor = _isUnlocked ? successColor : primaryColor;
    final Color statusBg = _isUnlocked
        ? (isDark
            ? AppColors.successContainerDark
            : AppColors.successContainerLight)
        : (isDark
            ? AppColors.primaryContainerDark
            : AppColors.primaryContainerLight);
    final Color buttonBg = _isUnlocked
        ? (isDark ? AppColors.bannerPrimaryDark : AppColors.primaryLight)
        : (isDark
            ? AppColors.surfaceContainerHighDark
            : AppColors.textSecondaryLight);
    final int actionCost = _isUnlocked ? _sessionCostXp : _unlockCostXp;
    final double unlockProgress = (currentXp / _unlockCostXp).clamp(0.0, 1.0);
    final Color warningColor =
        isDark ? AppColors.warningDark : AppColors.warningLight;

    return AppCard(
      borderColor: primaryColor.withValues(alpha: isDark ? 0.32 : 0.24),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: AppSpacing.huge,
                height: AppSpacing.huge,
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  _isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                  color: statusColor,
                  size: AppSpacing.xl,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUnlocked
                          ? AppLocalizations.simExamRoomUnlockedTitle()
                          : AppLocalizations.simUnlockSimulationTitle(),
                      style: AppTextStyles.titleLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (!_isUnlocked) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        AppLocalizations.simUnlockRequirementInfo(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!_isUnlocked) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: [
                  Text(
                    AppLocalizations.simXpReadinessLabel(),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: subTextColor,
                    ),
                  ),
                  Text(
                    '$currentXp / $_unlockCostXp XP',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppProgressBar(
              progress: unlockProgress,
              height: AppSpacing.xs,
              color: primaryColor,
              semanticLabel: AppLocalizations.simUnlockProgressSemantics(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: _isUnlocked
                ? AppLocalizations.simStartButton()
                : AppLocalizations.simUnlockButton(),
            height: 58.0,
            isLoading: _isProcessing,
            backgroundColor: buttonBg,
            foregroundColor: AppColors.onBannerPrimary,
            onPressed: _handleSimulationAction,
            customChild: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isUnlocked
                        ? Icons.play_arrow_rounded
                        : Icons.lock_open_rounded,
                    color: AppColors.onBannerPrimary,
                    size: AppSpacing.xl,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    _isUnlocked
                        ? AppLocalizations.simStartButton()
                        : AppLocalizations.simUnlockButton(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onBannerPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.onBannerPrimary.withValues(alpha: 0.2),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.onBannerPrimary,
                          size: AppSpacing.md,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          '$actionCost XP',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.onBannerPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isUnlocked && currentXp < _sessionCostXp) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: AppSpacing.md,
                  color: warningColor,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    AppLocalizations.simMinXpWarning(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: warningColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModulesSection({
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xxs),
          child: Text(
            AppLocalizations.simModulesSectionTitle(),
            style: AppTextStyles.titleLarge.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildModuleCard(
          sectionLabel: 'SECTION 01',
          title: AppLocalizations.simModule1Title(),
          pointsLabel: AppLocalizations.simModule1Points(),
          durationLabel: AppLocalizations.simModuleDuration25(),
          description: AppLocalizations.simModule1Description(),
          icon: Icons.translate_rounded,
          accentColor: primaryColor,
          isDark: isDark,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildModuleCard(
          sectionLabel: 'SECTION 02',
          title: AppLocalizations.simModule2Title(),
          pointsLabel: AppLocalizations.simModule2Points(),
          durationLabel: AppLocalizations.simModuleDuration25(),
          description: AppLocalizations.simModule2Description(),
          icon: Icons.menu_book_rounded,
          accentColor: secondaryColor,
          isDark: isDark,
          textColor: textColor,
          subTextColor: subTextColor,
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required String sectionLabel,
    required String title,
    required String pointsLabel,
    required String durationLabel,
    required String description,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, color: accentColor, size: AppSpacing.xl),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sectionLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: durationLabel,
                icon: Icons.timer_outlined,
                color: accentColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(color: subTextColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppBadge(
            label: pointsLabel,
            color: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildGradingSystemCard({
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
    required Color successColor,
  }) {
    final Color boxBg =
        isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: primaryColor,
                  size: AppSpacing.lg,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppLocalizations.simGradingSystemTitle(),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildScoreMetricBox(
                  label: AppLocalizations.simMaxScoreLabel(),
                  value: '$_maxScore',
                  valueColor: textColor,
                  subTextColor: subTextColor,
                  bgColor: boxBg,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildScoreMetricBox(
                  label: AppLocalizations.simPassingGradeLabel(),
                  value: '$_passingScore',
                  valueColor: successColor,
                  subTextColor: subTextColor,
                  bgColor: boxBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: boxBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: AppSpacing.lg,
                  color: primaryColor,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    AppLocalizations.simPassCriteriaNote(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: subTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreMetricBox({
    required String label,
    required String value,
    required Color valueColor,
    required Color subTextColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall.copyWith(
              color: subTextColor,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTextStyles.displayMedium.copyWith(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrictRulesCard({
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderColor: primaryColor.withValues(alpha: 0.25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gavel_rounded,
              color: primaryColor,
              size: AppSpacing.xl,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.simStrictRulesTitle(),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  AppLocalizations.simStrictRulesDescription(),
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
  }
}

class _BriefingRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color textColor;
  final Color subTextColor;

  const _BriefingRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: AppSpacing.lg, color: iconColor),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
