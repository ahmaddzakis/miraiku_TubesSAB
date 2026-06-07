import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../core/game_manager.dart';
import '../../data/alphabet_data.dart';

class KanaScreen extends StatefulWidget {
  const KanaScreen({super.key});

  @override
  State<KanaScreen> createState() => _KanaScreenState();
}

class _KanaScreenState extends State<KanaScreen> {
  int _activeTab = 0; // 0 = Hiragana, 1 = Katakana, 2 = Kanji

  int get _totalCurrentCharacters {
    if (_activeTab == 0) {
      return AlphabetData.hiraBasic.length + AlphabetData.hiraDakuon.length +
          AlphabetData.hiraHandakuon.length + AlphabetData.hiraYoon.length;
    } else if (_activeTab == 1) {
      return AlphabetData.kataBasic.length + AlphabetData.kataDakuon.length +
          AlphabetData.kataHandakuon.length + AlphabetData.kataYoon.length;
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

  @override
  void initState() {
    super.initState();
  }

  // --- 🔥 LOGIKA SINKRONISASI DIPERBARUI DI SINI ---
  Future<void> _saveData() async {
    await GameManager.syncToCloud();
  }

  void _onKanaTapped(Map<String, String> item, List<Map<String, String>> sourceList) {
    final char = item["jp"]!;
    if (_activeTab == 0) {
      if (!globalLearnedHiragana.value.contains(char)) {
        globalLearnedHiragana.value = [...globalLearnedHiragana.value, char];
        _saveData();
      }
    } else if (_activeTab == 1) {
      if (!globalLearnedKatakana.value.contains(char)) {
        globalLearnedKatakana.value = [...globalLearnedKatakana.value, char];
        _saveData();
      }
    } else if (_activeTab == 2) {
      if (!globalLearnedKanji.value.contains(char)) {
        globalLearnedKanji.value = [...globalLearnedKanji.value, char];
        _saveData();
      }
    }
    _showKanaPopup(context, item, sourceList);
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  double _getScale(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    if (width > 600) return 1.2; // Tablet
    if (width < 360) return 0.9; // Small phone
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final double scale = _getScale(context);
    final bool isTablet = media.size.width > 600;

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2);

        String headerTitle = _activeTab == 0 ? _t("Learning ひらがな", "Belajar ひらがな") : (_activeTab == 1 ? _t("Learning カタカナ", "Belajar カタカナ") : _t("Learning 漢字", "Belajar 漢字"));
        String headerDesc = _activeTab == 0
            ? _t("Master the basic native Japanese characters.", "Kuasai huruf dasar Jepang.")
            : (_activeTab == 1 ? _t("Master the characters used for foreign loanwords.", "Kuasai karakter untuk kata serapan asing.") : _t("Kanji are Chinese characters adapted into Japanese.", "Kanji adalah aksara Tionghoa yang diadaptasi ke dalam bahasa Jepang."));

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: ValueListenableBuilder(
              valueListenable: _activeTab == 0 
                  ? globalLearnedHiragana 
                  : (_activeTab == 1 ? globalLearnedKatakana : globalLearnedKanji),
              builder: (context, _, child) {
                return Column(
                  children: [
                    SizedBox(height: 24 * scale),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: _buildTab(0, "Hiragana", isDark, scale)),
                          SizedBox(width: 8 * scale),
                          Expanded(child: _buildTab(1, "Katakana", isDark, scale)),
                          SizedBox(width: 8 * scale),
                          Expanded(child: _buildTab(2, "Kanji", isDark, scale)),
                        ],
                      ),
                    ),
                    SizedBox(height: 24 * scale),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.0),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          width: double.infinity,
                          padding: EdgeInsets.all(24 * scale),
                          decoration: BoxDecoration(color: const Color(0xFFCC6633), borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(headerTitle, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22 * scale, fontFamily: 'Serif')),
                              SizedBox(height: 8 * scale),
                              Text(headerDesc, style: TextStyle(color: const Color(0xFFF7E6D4), fontSize: 13 * scale, height: 1.4)),
                              SizedBox(height: 20 * scale),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                                    decoration: BoxDecoration(color: const Color(0xFFF7E6D4), borderRadius: BorderRadius.circular(12)),
                                    child: Text(
                                      "${_currentLearned.length} / $_totalCurrentCharacters ${_t('LEARNED', 'SELESAI')}",
                                      style: TextStyle(color: const Color(0xFFCC6633), fontWeight: FontWeight.w900, fontSize: 12 * scale),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24 * scale),

                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.05),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: SingleChildScrollView(
                          key: ValueKey<int>(_activeTab),
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.0),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_activeTab == 0) ...[
                                    _buildSectionTitle("GOJŪON (Basic 46)", scale),
                                    _buildGrid(AlphabetData.hiraBasic, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle("DAKUON", scale),
                                    _buildGrid(AlphabetData.hiraDakuon, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle("HANDAKUON", scale),
                                    _buildGrid(AlphabetData.hiraHandakuon, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle("YŌON", scale),
                                    _buildGrid(AlphabetData.hiraYoon, isDark, isYoon: true, scale: scale),
                                    const SizedBox(height: 100),
                                  ] else if (_activeTab == 1) ...[
                                    _buildSectionTitle("GOJŪON (Basic 46)", scale),
                                    _buildGrid(AlphabetData.kataBasic, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle("DAKUON", scale),
                                    _buildGrid(AlphabetData.kataDakuon, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle("HANDAKUON", scale),
                                    _buildGrid(AlphabetData.kataHandakuon, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle("YŌON", scale),
                                    _buildGrid(AlphabetData.kataYoon, isDark, isYoon: true, scale: scale),
                                    const SizedBox(height: 100),
                                  ] else if (_activeTab == 2) ...[
                                    _buildSectionTitle(_t("NUMBERS (1-10)", "ANGKA (1-10)"), scale),
                                    _buildGrid(AlphabetData.kanjiNumbers, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle(_t("NATURE & ELEMENTS", "ALAM & ELEMEN"), scale),
                                    _buildGrid(AlphabetData.kanjiNature, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle(_t("PEOPLE & DIRECTIONS", "ORANG & ARAH"), scale),
                                    _buildGrid(AlphabetData.kanjiPeople, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle(_t("TIME & DATES", "WAKTU & TANGGAL"), scale),
                                    _buildGrid(AlphabetData.kanjiTime, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle(_t("BODY PARTS & SIZE", "BAGIAN TUBUH & UKURAN"), scale),
                                    _buildGrid(AlphabetData.kanjiBody, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle(_t("VERBS & ACTIONS", "KATA KERJA & AKSI"), scale),
                                    _buildGrid(AlphabetData.kanjiVerbs, isDark, scale: scale),
                                    SizedBox(height: 32 * scale),
                                    _buildSectionTitle(_t("PLACES & EDUCATION", "TEMPAT & PENDIDIKAN"), scale),
                                    _buildGrid(AlphabetData.kanjiPlaces, isDark, scale: scale),
                                    const SizedBox(height: 100),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0 * scale),
      child: Text(title, style: TextStyle(fontSize: 12 * scale, fontWeight: FontWeight.w900, color: const Color(0xFFB5B0A8), letterSpacing: 1.5)),
    );
  }

  Widget _buildGrid(List<Map<String, String>> dataList, bool isDark, {bool isYoon = false, required double scale}) {
    final Color textColor = isDark ? Colors.white : const Color(0xFF3E362E);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);
    final Color gridBgColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? (isYoon ? 4 : 8) : (isYoon ? 3 : 5);
        double aspectRatio = isYoon ? 1.2 : 0.85;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12 * scale,
              mainAxisSpacing: 12 * scale,
              childAspectRatio: aspectRatio
          ),
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            final item = dataList[index];
            final isLearned = _currentLearned.contains(item["jp"]);
            return GestureDetector(
              onTap: () => _onKanaTapped(item, dataList),
              child: Container(
                decoration: BoxDecoration(
                  color: isLearned ? (isDark ? const Color(0xFFCC6633).withValues(alpha: 0.2) : const Color(0xFFF7E6D4)) : gridBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isLearned ? const Color(0xFFCC6633) : borderColor, width: isLearned ? 2 : 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item["jp"]!, style: TextStyle(fontSize: (isYoon ? 20 : 24) * scale, fontWeight: FontWeight.bold, color: isLearned ? const Color(0xFFCC6633) : textColor)),
                    SizedBox(height: 4 * scale),
                    Text(item["ro"]!, style: TextStyle(fontSize: 10 * scale, color: isLearned ? const Color(0xFFCC6633) : const Color(0xFF8C8A87), fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildTab(int index, String title, bool isDark, double scale) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 10 * scale),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFCC6633) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA), width: 1.5),
        ),
        child: Text(
          title,
          style: TextStyle(color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF8C8A87)), fontWeight: FontWeight.bold, fontSize: 13 * scale),
        ),
      ),
    );
  }

  void _showKanaPopup(BuildContext context, Map<String, String> initialItem, List<Map<String, String>> sourceList) {
    final bool isDark = globalDarkMode.value;
    final Color modalBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAF7F2);
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
    final Color cardColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);
    final double scale = _getScale(context);

    SignatureController controller = SignatureController(penStrokeWidth: 5, penColor: textColor, exportBackgroundColor: cardColor);
    int currentIndex = sourceList.indexOf(initialItem);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              backgroundColor: modalBg,
              child: Padding(
                padding: EdgeInsets.all(24.0 * scale),
                child: StatefulBuilder(
                  builder: (context, setStatePopup) {
                    final currentItem = sourceList[currentIndex];
                    final kana = currentItem["jp"]!;
                    final romaji = currentItem["ro"]!;
                    final meaning = _activeTab == 2 ? (globalLanguage.value == 'id' ? currentItem["id"] : currentItem["en"]) : null;

                    void goToNext() {
                      if (currentIndex < sourceList.length - 1) {
                        setStatePopup(() { currentIndex++; controller.clear(); });
                        final nextChar = sourceList[currentIndex]["jp"]!;
                        if (_activeTab == 0) {
                          if (!globalLearnedHiragana.value.contains(nextChar)) {
                            globalLearnedHiragana.value = [...globalLearnedHiragana.value, nextChar];
                            _saveData();
                          }
                        } else if (_activeTab == 1) {
                          if (!globalLearnedKatakana.value.contains(nextChar)) {
                            globalLearnedKatakana.value = [...globalLearnedKatakana.value, nextChar];
                            _saveData();
                          }
                        } else if (_activeTab == 2) {
                          if (!globalLearnedKanji.value.contains(nextChar)) {
                            globalLearnedKanji.value = [...globalLearnedKanji.value, nextChar];
                            _saveData();
                          }
                        }
                      }
                    }

                    void goToPrev() {
                      if (currentIndex > 0) {
                        setStatePopup(() { currentIndex--; controller.clear(); });
                        final prevChar = sourceList[currentIndex]["jp"]!;
                        if (_activeTab == 0) {
                          if (!globalLearnedHiragana.value.contains(prevChar)) {
                            globalLearnedHiragana.value = [...globalLearnedHiragana.value, prevChar];
                            _saveData();
                          }
                        } else if (_activeTab == 1) {
                          if (!globalLearnedKatakana.value.contains(prevChar)) {
                            globalLearnedKatakana.value = [...globalLearnedKatakana.value, prevChar];
                            _saveData();
                          }
                        } else if (_activeTab == 2) {
                          if (!globalLearnedKanji.value.contains(prevChar)) {
                            globalLearnedKanji.value = [...globalLearnedKanji.value, prevChar];
                            _saveData();
                          }
                        }
                      }
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close_rounded, color: Color(0xFF8C8A87))),
                            const Spacer(),
                            Text(_t("Learn Strokes", "Pelajari Coretan"), style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900, color: textColor, fontFamily: 'Serif')),
                            const Spacer(),
                            const SizedBox(width: 24),
                          ],
                        ),
                        SizedBox(height: 24 * scale),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 20 * scale),
                          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
                          child: Column(
                            children: [
                              Text(_t("How to draw", "Cara Menulis"), style: TextStyle(color: const Color(0xFF8C8A87), fontSize: 11 * scale, fontWeight: FontWeight.bold, letterSpacing: 1)),
                              SizedBox(height: 12 * scale),
                              if (_activeTab != 2)
                                Opacity(
                                  opacity: isDark ? 0.85 : 1.0,
                                  child: Image.asset(
                                    _activeTab == 0 ? 'assets/gifs/hiragana_${romaji.toLowerCase()}.gif' : 'assets/gifs/katakana_${romaji.toLowerCase()}.gif',
                                    height: 90 * scale,
                                    errorBuilder: (c, e, s) => Text(kana, style: TextStyle(fontSize: 60 * scale, color: textColor)),
                                  ),
                                )
                              else
                                Text(kana, style: TextStyle(fontSize: 60 * scale, color: textColor, fontWeight: FontWeight.bold)),
                              SizedBox(height: 8 * scale),
                              Text(romaji, style: TextStyle(fontSize: 16 * scale, fontWeight: FontWeight.w900, color: const Color(0xFFCC6633))),
                              if (meaning != null) ...[
                                SizedBox(height: 4 * scale),
                                Text(meaning, style: TextStyle(fontSize: 14 * scale, color: textColor.withValues(alpha: 0.6), fontWeight: FontWeight.w600)),
                              ]
                            ],
                          ),
                        ),
                        SizedBox(height: 24 * scale),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_t("Practice", "Latihan"), style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 14 * scale)),
                            GestureDetector(
                              onTap: () { controller.clear(); setStatePopup(() {}); },
                              child: Row(
                                children: [
                                  const Icon(Icons.cleaning_services_rounded, size: 14, color: Color(0xFFCC6633)),
                                  const SizedBox(width: 4),
                                  Text(_t("ERASE", "HAPUS"), style: TextStyle(color: const Color(0xFFCC6633), fontWeight: FontWeight.w900, fontSize: 11 * scale)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * scale),
                        Container(
                          height: 160 * scale,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor, width: 2)),
                          child: Stack(
                            children: [
                              Center(child: VerticalDivider(color: isDark ? borderColor : const Color(0xFFF0EBE1), thickness: 1)),
                              Center(child: Divider(color: isDark ? borderColor : const Color(0xFFF0EBE1), thickness: 1)),
                              Signature(controller: controller, backgroundColor: Colors.transparent),
                            ],
                          ),
                        ),
                        SizedBox(height: 24 * scale),

                        Row(
                          children: [
                            if (currentIndex > 0)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: goToPrev,
                                  icon: Icon(Icons.arrow_back_rounded, size: 18 * scale),
                                  label: Text(_t("Prev", "Mundur"), style: TextStyle(fontSize: 12 * scale)),
                                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF8C8A87), side: BorderSide(color: borderColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                ),
                              ),
                            if (currentIndex > 0 && currentIndex < sourceList.length - 1)
                              SizedBox(width: 12 * scale),
                            if (currentIndex < sourceList.length - 1)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: goToNext,
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                                  label: Text(_t("Next", "Maju"), style: TextStyle(color: Colors.white, fontSize: 12 * scale)),
                                  icon: Icon(Icons.arrow_forward_rounded, size: 18 * scale, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ],
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
