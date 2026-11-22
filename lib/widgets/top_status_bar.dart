import 'package:flutter/material.dart';
import '../core/game_manager.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/app_button.dart';

class TopStatusBar extends StatelessWidget {
  const TopStatusBar({super.key});

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color containerBg = isDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surfaceContainer;
    final Color barBg = theme.scaffoldBackgroundColor;
    final Color textColor = colorScheme.onSurface;
    final Color dividerColor = colorScheme.outlineVariant;

    return Container(
      color: barBg,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: AppSpacing.sm),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.streakFlame],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: Text(
                      "MIRAIku",
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: Colors.white,
                        letterSpacing: 2.0,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: containerBg,
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: globalStreak,
                  builder: (context, streak, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: globalHearts,
                      builder: (context, hearts, _) {
                        return ValueListenableBuilder<int>(
                          valueListenable: globalXP,
                          builder: (context, xp, _) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Semantics(
                                  button: true,
                                  label: 'Streak: $streak',
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        _showStatDialog(context, 'streak'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xxs,
                                        vertical: AppSpacing.xxs,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.local_fire_department_rounded,
                                            color: AppColors.streakFlame,
                                            size: 20,
                                          ),
                                          const SizedBox(width: AppSpacing.xxs),
                                          Text(
                                            "$streak",
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              color: AppColors.streakFlame,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    "|",
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: dividerColor,
                                    ),
                                  ),
                                ),
                                Semantics(
                                  button: true,
                                  label: 'Hearts: $hearts',
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        _showStatDialog(context, 'hearts'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xxs,
                                        vertical: AppSpacing.xxs,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.favorite_rounded,
                                            color: AppColors.heartCrimson,
                                            size: 20,
                                          ),
                                          const SizedBox(width: AppSpacing.xxs),
                                          Text(
                                            "$hearts",
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              color: AppColors.heartCrimson,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    "|",
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: dividerColor,
                                    ),
                                  ),
                                ),
                                Semantics(
                                  button: true,
                                  label: 'XP: $xp',
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _showStatDialog(context, 'xp'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xxs,
                                        vertical: AppSpacing.xxs,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.stars_rounded,
                                            color: AppColors.starGold,
                                            size: 20,
                                          ),
                                          const SizedBox(width: AppSpacing.xxs),
                                          Text(
                                            "$xp",
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                              color: textColor,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatDialog(BuildContext context, String type) {
    final colorScheme = Theme.of(context).colorScheme;

    String title = "";
    IconData icon = Icons.info;
    Color iconColor = colorScheme.onSurfaceVariant;

    if (type == 'streak') {
      title = _t("Learning Streak", "Runtutan Belajar");
      icon = Icons.local_fire_department_rounded;
      iconColor = AppColors.streakFlame;
    } else if (type == 'hearts') {
      title = _t("Your Hearts", "Nyawa Anda");
      icon = Icons.favorite_rounded;
      iconColor = AppColors.heartCrimson;
    } else if (type == 'xp') {
      title = _t("Experience Points (XP)", "Poin Pengalaman (XP)");
      icon = Icons.stars_rounded;
      iconColor = AppColors.starGold;
    }

    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<int>(
          valueListenable: globalHearts,
          builder: (context, currentHearts, _) {
            return ValueListenableBuilder<int>(
              valueListenable: globalXP,
              builder: (context, currentXP, _) {
                return AlertDialog(
                  backgroundColor: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  title: Column(
                    children: [
                      Icon(icon, size: 48, color: iconColor),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (type == 'streak') ...[
                        Text(
                          _t(
                            "You have opened the app for ${globalStreak.value} consecutive days! Don't miss a single day or your streak will reset to 1.",
                            "Kamu sudah membuka aplikasi selama ${globalStreak.value} hari berturut-turut! Jangan sampai terlewat 1 hari pun atau runtutanmu akan kembali ke 1.",
                          ),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Text(
                            _t(
                              "🎁 Login every day to claim 50 XP & Weekly bonuses in Profile!",
                              "🎁 Login setiap hari untuk klaim 50 XP & bonus Mingguan di Profil!",
                            ),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: colorScheme.onSurface,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                      if (type == 'hearts') ...[
                        Text(
                          _t(
                            "Remaining hearts: $currentHearts / ${GameManager.maxHearts}\nHearts decrease every time you answer a quiz incorrectly. 1 heart will recover automatically every 20 minutes.",
                            "Sisa nyawa: $currentHearts / ${GameManager.maxHearts}\nNyawa berkurang setiap kamu salah menjawab kuis. 1 nyawa akan pulih secara otomatis setiap 20 menit.",
                          ),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (currentHearts < GameManager.maxHearts)
                          ValueListenableBuilder<String>(
                            valueListenable: globalTimerText,
                            builder: (context, timerText, _) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.heartCrimson.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd,
                                  ),
                                ),
                                child: Text(
                                  _t(
                                    "⏳ Cooldown: $timerText",
                                    "⏳ Waktu Cooldown: $timerText",
                                  ),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.heartCrimson,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: currentHearts >= GameManager.maxHearts
                              ? _t("FULL HEARTS", "NYAWA PENUH")
                              : (currentXP < 150
                                    ? _t(
                                        "NOT ENOUGH XP (Needs 150)",
                                        "XP TIDAK CUKUP (Butuh 150)",
                                      )
                                    : _t(
                                        "BUY 1 HEART (150 XP)",
                                        "BELI 1 NYAWA (150 XP)",
                                      )),
                          icon: Icons.stars_rounded,
                          height: 48,
                          borderRadius: AppSpacing.radiusMd,
                          onPressed:
                              (currentHearts >= GameManager.maxHearts ||
                                  currentXP < 150)
                              ? null
                              : () {
                                  _showBuyConfirmationDialog(context);
                                },
                        ),
                      ],
                      if (type == 'xp') ...[
                        Text(
                          _t(
                            "Your total XP currently: $currentXP\nYou will get 25 XP every time you successfully answer a practice question correctly.",
                            "Total XP kamu saat ini: $currentXP\nKamu akan mendapatkan 25 XP setiap kali berhasil menjawab soal latihan dengan benar.",
                          ),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: Text(
                            _t(
                              "🎯 Collect 1500 XP to unlock JLPT N5 Simulation mode!",
                              "🎯 Kumpulkan 1500 XP untuk membuka mode Simulasi JLPT N5!",
                            ),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: colorScheme.onSurface,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    AppButton(
                      label: _t("CLOSE", "TUTUP"),
                      variant: AppButtonVariant.text,
                      expand: false,
                      height: 48,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showBuyConfirmationDialog(BuildContext parentContext) {
    final colorScheme = Theme.of(parentContext).colorScheme;

    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 48),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        titlePadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          0,
        ),
        title: Column(
          children: [
            Icon(
              Icons.shopping_cart_rounded,
              color: colorScheme.primary,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '本当ですか?',
              style: AppTextStyles.labelSmall.copyWith(
                fontFamily: AppTextStyles.fontFamilyJP,
                color: colorScheme.primary,
                letterSpacing: 2,
              ),
            ),
            Text(
              _t("Confirmation", "Konfirmasi"),
              style: AppTextStyles.headlineMedium.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          _t(
            "Are you sure you want to exchange 150 XP for 1 Heart?",
            "Yakin ingin menukarkan 150 XP dengan 1 Nyawa?",
          ),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _t("CANCEL", "BATAL"),
                  variant: AppButtonVariant.secondary,
                  height: 48,
                  borderRadius: AppSpacing.radiusMd,
                  borderColor: colorScheme.outline,
                  foregroundColor: colorScheme.onSurfaceVariant,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: _t("SURE", "YAKIN"),
                  height: 48,
                  borderRadius: AppSpacing.radiusMd,
                  onPressed: () async {
                    Navigator.pop(context);
                    final bool success = await GameManager.buyHeartWithXP();
                    if (success && parentContext.mounted) {
                      Navigator.pop(parentContext);
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
