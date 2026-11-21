import 'package:flutter/material.dart';
import '../core/game_manager.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_shadows.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/app_button.dart';

enum NodeStatus { locked, current, completed }

class PathNode extends StatelessWidget {
  final String title;
  final NodeStatus status;
  final Alignment alignment;
  final int stars;
  final IconData? icon;
  final Function(int)? onReplaySelected;

  const PathNode({
    super.key,
    required this.title,
    required this.status,
    required this.alignment,
    required this.stars,
    this.icon,
    this.onReplaySelected,
  });

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  // 🔥 DETEKSI IKON (Lebih Dinamis & Beragam)
  IconData _getContextIcon(String text) {
    final t = text.toLowerCase();
    if (t.contains('test') || t.contains('ujian')) {
      return Icons.emoji_events_rounded;
    }
    if (t.contains('hiragana')) {
      if (t.contains('1')) return Icons.create_rounded;
      if (t.contains('2')) return Icons.record_voice_over_rounded;
      if (t.contains('3')) return Icons.school_rounded;
      return Icons.translate_rounded;
    }
    if (t.contains('katakana')) {
      if (t.contains('1')) return Icons.menu_book_rounded;
      if (t.contains('2')) return Icons.auto_stories_rounded;
      if (t.contains('3')) return Icons.extension_rounded;
      return Icons.abc_rounded;
    }
    if (t.contains('kanji')) {
      if (t.contains('1')) return Icons.brush_rounded;
      if (t.contains('2')) return Icons.history_edu_rounded;
      return Icons.architecture_rounded;
    }
    if (t.contains('vocab') || t.contains('kosakata')) {
      return Icons.chat_bubble_rounded;
    }
    if (t.contains('grammar') || t.contains('tata bahasa')) {
      return Icons.account_tree_rounded;
    }
    if (t.contains('greet') || t.contains('salam')) {
      return Icons.waving_hand_rounded;
    }
    return Icons.star_rounded;
  }

  // ==========================================
  // 🍿 POP-UP PILIH BINTANG (HANYA UNTUK NODE BIASA)
  // ==========================================
  void _showReplayDialog(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        title: Column(
          children: [
            Icon(
              Icons.replay_circle_filled_rounded,
              color: colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'リプレイ?',
              style: AppTextStyles.labelSmall.copyWith(
                fontFamily: AppTextStyles.fontFamilyJP,
                color: colorScheme.primary,
                letterSpacing: 2,
              ),
            ),
            Text(
              _t('Select Level', 'Pilih Tahapan'),
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _t(
                'Which material would you like to brush up on?',
                'Materi bagian mana yang ingin kamu asah kembali?',
              ),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildStarButton(context, 1, 0, isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildStarButton(context, 2, 1, isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildStarButton(context, 3, 2, isDark),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          AppButton(
            label: _t('CANCEL', 'BATAL'),
            variant: AppButtonVariant.text,
            expand: false,
            height: 48,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStarButton(
    BuildContext context,
    int starDisplay,
    int starIndex,
    bool isDark,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppButton(
      label: 'Star $starDisplay',
      variant: AppButtonVariant.secondary,
      height: 50,
      borderColor: colorScheme.outlineVariant,
      onPressed: () {
        Navigator.pop(context);
        if (onReplaySelected != null) onReplaySelected!(starIndex);
      },
      customChild: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Icon(
            index < starDisplay
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: AppColors.starGold,
            size: 22,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDark = colorScheme.brightness == Brightness.dark;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final bool isTestNode =
        title.toLowerCase().contains('test') ||
        title.toLowerCase().contains('ujian');

    Color nodeColor;
    Color borderColor;
    List<BoxShadow>? shadows;
    Widget centerWidget;

    final Color activeBrand = isDark
        ? AppColors.bannerPrimaryDark
        : AppColors.primaryLight;

    switch (status) {
      case NodeStatus.locked:
        nodeColor = colorScheme.surfaceContainerHighest;
        borderColor = colorScheme.outline;
        centerWidget = Icon(
          Icons.lock_rounded,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          size: 28,
        );
        break;
      case NodeStatus.current:
        nodeColor = activeBrand;
        borderColor = colorScheme.primary.withValues(alpha: 0.35);
        shadows = AppShadows.accentGlow(activeBrand, isDark: isDark);
        centerWidget = Icon(
          icon ?? _getContextIcon(title),
          color: Colors.white,
          size: 34,
        );
        break;
      case NodeStatus.completed:
        nodeColor = colorScheme.primary.withValues(alpha: 0.14);
        borderColor = colorScheme.primary;
        centerWidget = Icon(
          icon ?? _getContextIcon(title),
          color: colorScheme.primary,
          size: 32,
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                width: status == NodeStatus.current ? 72 : 64,
                height: status == NodeStatus.current ? 72 : 64,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: status == NodeStatus.locked ? 2 : 4,
                  ),
                  boxShadow: shadows,
                ),
                child: Center(child: centerWidget),
              ),
              const SizedBox(height: 6),
              // 🔥 LOGIKA HAPUS BINTANG KHUSUS UNIT TEST
              if (!isTestNode)
                Row(
                  children: List.generate(
                    3,
                    (index) => Icon(
                      index < stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: status == NodeStatus.locked
                          ? colorScheme.onSurfaceVariant.withValues(alpha: 0.35)
                          : colorScheme.primary,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status == NodeStatus.locked
                      ? _t("LOCKED", "TERKUNCI")
                      : (status == NodeStatus.current
                            ? _t("IN PROGRESS", "SEDANG DIUJI")
                            : _t("COMPLETED", "SELESAI")),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: status == NodeStatus.locked
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.primary,
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),

                // 🔥 LOGIKA MUNCULNYA TOMBOL REPLAY (BINTANG 3 ATAU MERUPAKAN UNIT TEST)
                if (status == NodeStatus.completed &&
                    (stars >= 3 || isTestNode)) ...[
                  const SizedBox(height: 4),
                  Semantics(
                    button: true,
                    label: '${_t("Replay", "Mulai Ulang")} $title',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (isTestNode) {
                          if (onReplaySelected != null) onReplaySelected!(0);
                        } else {
                          _showReplayDialog(context, isDark);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _t("Replay?", "Mulai Ulang?"),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Icon(
                              Icons.replay_rounded,
                              color: colorScheme.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
