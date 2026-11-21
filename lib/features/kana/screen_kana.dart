import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../data/alphabet_data.dart';

class KanaScreen extends StatefulWidget {
  const KanaScreen({super.key});

  @override
  State<KanaScreen> createState() => _KanaScreenState();
}

class _KanaSectionData {
  final String title;
  final List<Map<String, String>> items;
  final bool isYoon;

  const _KanaSectionData({
    required this.title,
    required this.items,
    this.isYoon = false,
  });
}

class _KanaScreenState extends State<KanaScreen> {
  int _activeTab = 0; // 0 = Hiragana, 1 = Katakana, 2 = Kanji

  int get _totalCurrentCharacters {
    if (_activeTab == 0) {
      return AlphabetData.hiraBasic.length +
          AlphabetData.hiraDakuon.length +
          AlphabetData.hiraHandakuon.length +
          AlphabetData.hiraYoon.length;
    } else if (_activeTab == 1) {
      return AlphabetData.kataBasic.length +
          AlphabetData.kataDakuon.length +
          AlphabetData.kataHandakuon.length +
          AlphabetData.kataYoon.length;
    } else if (_activeTab == 2) {
      return AlphabetData.kanjiNumbers.length +
          AlphabetData.kanjiNature.length +
          AlphabetData.kanjiPeople.length +
          AlphabetData.kanjiTime.length +
          AlphabetData.kanjiBody.length +
          AlphabetData.kanjiVerbs.length +
          AlphabetData.kanjiPlaces.length;
    }
    return 0;
  }

  List<String> get _currentLearned => _activeTab == 0
      ? globalLearnedHiragana.value
      : (_activeTab == 1
          ? globalLearnedKatakana.value
          : globalLearnedKanji.value);

  void _onKanaTapped(
    Map<String, String> item,
    List<Map<String, String>> sourceList,
  ) {
    final char = item["jp"]!;
    GameManager.updateKanaProgress(char, _activeTab);
    _showKanaPopup(context, item, sourceList);
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

  List<_KanaSectionData> _getSectionsForActiveTab() {
    if (_activeTab == 0) {
      return [
        const _KanaSectionData(
          title: "GOJŪON (Basic 46)",
          items: AlphabetData.hiraBasic,
        ),
        const _KanaSectionData(
          title: "DAKUON",
          items: AlphabetData.hiraDakuon,
        ),
        const _KanaSectionData(
          title: "HANDAKUON",
          items: AlphabetData.hiraHandakuon,
        ),
        const _KanaSectionData(
          title: "YŌON",
          items: AlphabetData.hiraYoon,
          isYoon: true,
        ),
      ];
    } else if (_activeTab == 1) {
      return [
        const _KanaSectionData(
          title: "GOJŪON (Basic 46)",
          items: AlphabetData.kataBasic,
        ),
        const _KanaSectionData(
          title: "DAKUON",
          items: AlphabetData.kataDakuon,
        ),
        const _KanaSectionData(
          title: "HANDAKUON",
          items: AlphabetData.kataHandakuon,
        ),
        const _KanaSectionData(
          title: "YŌON",
          items: AlphabetData.kataYoon,
          isYoon: true,
        ),
      ];
    } else {
      return [
        _KanaSectionData(
          title: _t("NUMBERS (1-10)", "ANGKA (1-10)"),
          items: AlphabetData.kanjiNumbers,
        ),
        _KanaSectionData(
          title: _t("NATURE & ELEMENTS", "ALAM & ELEMEN"),
          items: AlphabetData.kanjiNature,
        ),
        _KanaSectionData(
          title: _t("PEOPLE & DIRECTIONS", "ORANG & ARAH"),
          items: AlphabetData.kanjiPeople,
        ),
        _KanaSectionData(
          title: _t("TIME & DATES", "WAKTU & TANGGAL"),
          items: AlphabetData.kanjiTime,
        ),
        _KanaSectionData(
          title: _t("BODY PARTS & SIZE", "BAGIAN TUBUH & UKURAN"),
          items: AlphabetData.kanjiBody,
        ),
        _KanaSectionData(
          title: _t("VERBS & ACTIONS", "KATA KERJA & AKSI"),
          items: AlphabetData.kanjiVerbs,
        ),
        _KanaSectionData(
          title: _t("PLACES & EDUCATION", "TEMPAT & PENDIDIKAN"),
          items: AlphabetData.kanjiPlaces,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final double scale = _getScale(context);
    final bool isTablet = media.size.width > 600;
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final double horizontalPadding =
        isTablet ? AppSpacing.huge : AppSpacing.xl;

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor =
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
        final Color bannerBg =
            isDark ? AppColors.bannerPrimaryDark : AppColors.primaryLight;
        final Color bannerFg = AppColors.onBannerPrimary;

        final String headerTitle = _activeTab == 0
            ? _t("Learning ひらがな", "Belajar ひらがな")
            : (_activeTab == 1
                ? _t("Learning カタカナ", "Belajar カタカナ")
                : _t("Learning 漢字", "Belajar 漢字"));
        final String headerDesc = _activeTab == 0
            ? _t(
                "Master the basic native Japanese characters.",
                "Kuasai huruf dasar Jepang.",
              )
            : (_activeTab == 1
                ? _t(
                    "Master the characters used for foreign loanwords.",
                    "Kuasai karakter untuk kata serapan asing.",
                  )
                : _t(
                    "Kanji are Chinese characters adapted into Japanese.",
                    "Kanji adalah aksara Tionghoa yang diadaptasi ke dalam bahasa Jepang.",
                  ));

        final sections = _getSectionsForActiveTab();

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await GameManager.syncToCloud();
                if (mounted) setState(() {});
              },
              child: ValueListenableBuilder(
                valueListenable: _activeTab == 0
                    ? globalLearnedHiragana
                    : (_activeTab == 1
                        ? globalLearnedKatakana
                        : globalLearnedKanji),
                builder: (context, _, child) {
                  return AnimatedSwitcher(
                    duration:
                        reduceMotion ? Duration.zero : AppSpacing.animNormal,
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      if (reduceMotion) return child;
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.03),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: CustomScrollView(
                      key: ValueKey<int>(_activeTab),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        // Header Tabs & Hero Banner
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            AppSpacing.xl * scale,
                            horizontalPadding,
                            AppSpacing.xl * scale,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildTab(
                                        0,
                                        "Hiragana",
                                        isDark,
                                        scale,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.xs * scale),
                                    Expanded(
                                      child: _buildTab(
                                        1,
                                        "Katakana",
                                        isDark,
                                        scale,
                                      ),
                                    ),
                                    SizedBox(width: AppSpacing.xs * scale),
                                    Expanded(
                                      child: _buildTab(
                                        2,
                                        "Kanji",
                                        isDark,
                                        scale,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSpacing.xl * scale),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(AppSpacing.xl * scale),
                                  decoration: BoxDecoration(
                                    color: bannerBg,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusXl,
                                    ),
                                    boxShadow: AppShadows.accentGlow(
                                      bannerBg,
                                      isDark: isDark,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        headerTitle,
                                        style: AppTextStyles.headlineMedium
                                            .copyWith(
                                          color: bannerFg,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 22 * scale,
                                        ),
                                      ),
                                      SizedBox(height: AppSpacing.xs * scale),
                                      Text(
                                        headerDesc,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                          color: bannerFg.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: 13 * scale,
                                        ),
                                      ),
                                      SizedBox(height: AppSpacing.lg * scale),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm * scale,
                                              vertical: 6 * scale,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors
                                                  .primaryContainerLight,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                AppSpacing.radiusSm,
                                              ),
                                            ),
                                            child: Text(
                                              "${_currentLearned.length} / $_totalCurrentCharacters ${_t('LEARNED', 'SELESAI')}",
                                              style: AppTextStyles.labelMedium
                                                  .copyWith(
                                                color: AppColors.primaryLight,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12 * scale,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Lazy Sliver Grids for Each Section
                        for (final section in sections) ...[
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              AppSpacing.sm * scale,
                            ),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                section.title,
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontSize: 12 * scale,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              horizontalPadding,
                              0,
                              horizontalPadding,
                              AppSpacing.xxl * scale,
                            ),
                            sliver: _buildSliverGrid(
                              section.items,
                              isDark,
                              isYoon: section.isYoon,
                              isTablet: isTablet,
                              scale: scale,
                            ),
                          ),
                        ],

                        const SliverToBoxAdapter(
                          child: SizedBox(height: 100),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverGrid(
    List<Map<String, String>> dataList,
    bool isDark, {
    bool isYoon = false,
    required bool isTablet,
    required double scale,
  }) {
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final Color borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final Color gridBgColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final Color primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    final int crossAxisCount =
        isTablet ? (isYoon ? 4 : 8) : (isYoon ? 3 : 5);
    final double aspectRatio = isYoon ? 1.2 : 0.85;

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.sm * scale,
        mainAxisSpacing: AppSpacing.sm * scale,
        childAspectRatio: aspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = dataList[index];
          final isLearned = _currentLearned.contains(item["jp"]);
          return Semantics(
            button: true,
            label: '${item["jp"]} (${item["ro"]})',
            selected: isLearned,
            child: GestureDetector(
              onTap: () => _onKanaTapped(item, dataList),
              child: Container(
                decoration: BoxDecoration(
                  color: isLearned
                      ? (isDark
                          ? AppColors.primaryContainerDark
                          : AppColors.primaryContainerLight)
                      : gridBgColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isLearned ? primaryColor : borderColor,
                    width: isLearned ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item["jp"]!,
                      style: AppTextStyles.japaneseTitle.copyWith(
                        fontSize: (isYoon ? 20 : 24) * scale,
                        fontWeight: FontWeight.bold,
                        color: isLearned ? primaryColor : textColor,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      item["ro"]!,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontSize: 10 * scale,
                        color: isLearned ? primaryColor : subTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: dataList.length,
      ),
    );
  }

  Widget _buildTab(int index, String title, bool isDark, double scale) {
    final bool isActive = _activeTab == index;
    final Color primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final Color borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final Color subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Semantics(
      button: true,
      selected: isActive,
      label: title,
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTapTarget,
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 10 * scale),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.bannerPrimaryDark : primaryColor)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: isActive
                ? null
                : Border.all(color: borderColor, width: 1.5),
          ),
          child: Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: isActive ? Colors.white : subTextColor,
              fontSize: 13 * scale,
            ),
          ),
        ),
      ),
    );
  }

  void _showKanaPopup(
    BuildContext context,
    Map<String, String> initialItem,
    List<Map<String, String>> sourceList,
  ) {
    final bool isDark = globalDarkMode.value;
    final Color modalBg =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final Color textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color subTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final Color cardColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final Color borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final Color primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final double scale = _getScale(context);

    final SignatureController controller = SignatureController(
      penStrokeWidth: 5,
      penColor: textColor,
      exportBackgroundColor: cardColor,
    );
    int currentIndex = sourceList.indexOf(initialItem);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxDialogWidth,
            ),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: modalBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                  boxShadow: AppShadows.dialog(isDark),
                ),
                padding: EdgeInsets.all(AppSpacing.xl * scale),
                child: StatefulBuilder(
                  builder: (context, setStatePopup) {
                    final currentItem = sourceList[currentIndex];
                    final kana = currentItem["jp"]!;
                    final romaji = currentItem["ro"]!;
                    final meaning = _activeTab == 2
                        ? (globalLanguage.value == 'id'
                            ? currentItem["id"]
                            : currentItem["en"])
                        : null;

                    void goToNext() {
                      if (currentIndex < sourceList.length - 1) {
                        setStatePopup(() {
                          currentIndex++;
                          controller.clear();
                        });
                        final nextChar = sourceList[currentIndex]["jp"]!;
                        GameManager.updateKanaProgress(nextChar, _activeTab);
                      }
                    }

                    void goToPrev() {
                      if (currentIndex > 0) {
                        setStatePopup(() {
                          currentIndex--;
                          controller.clear();
                        });
                        final prevChar = sourceList[currentIndex]["jp"]!;
                        GameManager.updateKanaProgress(prevChar, _activeTab);
                      }
                    }

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: subTextColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _t("Learn Strokes", "Pelajari Coretan"),
                                style: AppTextStyles.titleLarge.copyWith(
                                  fontSize: 18 * scale,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(width: 24),
                            ],
                          ),
                          SizedBox(height: AppSpacing.xl * scale),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.lg * scale,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusXl),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _t("How to draw", "Cara Menulis"),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: subTextColor,
                                    fontSize: 11 * scale,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.sm * scale),
                                if (_activeTab != 2)
                                  Opacity(
                                    opacity: isDark ? 0.88 : 1.0,
                                    child: Image.asset(
                                      _activeTab == 0
                                          ? 'assets/gifs/hiragana_${romaji.toLowerCase()}.gif'
                                          : 'assets/gifs/katakana_${romaji.toLowerCase()}.gif',
                                      height: 90 * scale,
                                      cacheHeight: (90 *
                                              scale *
                                              MediaQuery.of(context)
                                                  .devicePixelRatio)
                                          .toInt(),
                                      errorBuilder: (c, e, s) => Text(
                                        kana,
                                        style: AppTextStyles.japaneseHero
                                            .copyWith(
                                          fontSize: 60 * scale,
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    kana,
                                    style: AppTextStyles.japaneseHero.copyWith(
                                      fontSize: 60 * scale,
                                      color: textColor,
                                    ),
                                  ),
                                SizedBox(height: AppSpacing.xs * scale),
                                Text(
                                  romaji,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w900,
                                    color: primaryColor,
                                  ),
                                ),
                                if (meaning != null) ...[
                                  SizedBox(height: 4 * scale),
                                  Text(
                                    meaning,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 14 * scale,
                                      color: subTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl * scale),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _t("Practice", "Latihan"),
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14 * scale,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  controller.clear();
                                  setStatePopup(() {});
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.cleaning_services_rounded,
                                      size: 14,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _t("ERASE", "HAPUS"),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11 * scale,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.sm * scale),
                          Container(
                            height: 160 * scale,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusXl),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: VerticalDivider(
                                    color: borderColor,
                                    thickness: 1,
                                  ),
                                ),
                                Center(
                                  child: Divider(
                                    color: borderColor,
                                    thickness: 1,
                                  ),
                                ),
                                Signature(
                                  controller: controller,
                                  backgroundColor: Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl * scale),

                          Row(
                            children: [
                              if (currentIndex > 0)
                                Expanded(
                                  child: AppButton(
                                    label: _t("Prev", "Mundur"),
                                    icon: Icons.arrow_back_rounded,
                                    variant: AppButtonVariant.secondary,
                                    height: 48,
                                    onPressed: goToPrev,
                                  ),
                                ),
                              if (currentIndex > 0 &&
                                  currentIndex < sourceList.length - 1)
                                SizedBox(width: AppSpacing.sm * scale),
                              if (currentIndex < sourceList.length - 1)
                                Expanded(
                                  child: AppButton(
                                    label: _t("Next", "Maju"),
                                    icon: Icons.arrow_forward_rounded,
                                    height: 48,
                                    onPressed: goToNext,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) => controller.dispose());
  }
}
