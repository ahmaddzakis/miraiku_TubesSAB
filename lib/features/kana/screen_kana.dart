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
      return AlphabetData.kanjiNumbers.length + AlphabetData.kanjiNature.length + AlphabetData.kanjiPeople.length;
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

  @override
  Widget build(BuildContext context) {
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
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTab(0, "Hiragana", isDark),
                          _buildTab(1, "Katakana", isDark),
                          _buildTab(2, "Kanji", isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: const Color(0xFFD68A60), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(headerTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Serif')),
                            const SizedBox(height: 8),
                            Text(headerDesc, style: const TextStyle(color: Color(0xFFF7E6D4), fontSize: 13, height: 1.4)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFFF7E6D4), borderRadius: BorderRadius.circular(12)),
                                  child: Text(
                                    "${_currentLearned.length} / $_totalCurrentCharacters ${_t('LEARNED', 'SELESAI')}",
                                    style: const TextStyle(color: Color(0xFFC6653B), fontWeight: FontWeight.w900, fontSize: 12),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_activeTab == 0) ...[
                              _buildSectionTitle("GOJŪON (Basic 46)"),
                              _buildGrid(AlphabetData.hiraBasic, isDark, crossAxisCount: 5),
                              const SizedBox(height: 32),
                              _buildSectionTitle("DAKUON"),
                              _buildGrid(AlphabetData.hiraDakuon, isDark, crossAxisCount: 5),
                              const SizedBox(height: 32),
                              _buildSectionTitle("HANDAKUON"),
                              _buildGrid(AlphabetData.hiraHandakuon, isDark, crossAxisCount: 5),
                              const SizedBox(height: 32),
                              _buildSectionTitle("YŌON"),
                              _buildGrid(AlphabetData.hiraYoon, isDark, crossAxisCount: 3),
                              const SizedBox(height: 100),
                            ] else if (_activeTab == 1) ...[
                              _buildSectionTitle("GOJŪON (Basic 46)"),
                              _buildGrid(AlphabetData.kataBasic, isDark, crossAxisCount: 5),
                              const SizedBox(height: 32),
                              _buildSectionTitle("DAKUON"),
                              _buildGrid(AlphabetData.kataDakuon, isDark, crossAxisCount: 5),
                              const SizedBox(height: 32),
                              _buildSectionTitle("HANDAKUON"),
                              _buildGrid(AlphabetData.kataHandakuon, isDark, crossAxisCount: 5),
                              const SizedBox(height: 32),
                              _buildSectionTitle("YŌON"),
                              _buildGrid(AlphabetData.kataYoon, isDark, crossAxisCount: 3),
                              const SizedBox(height: 100),
                            ] else if (_activeTab == 2) ...[
                              _buildSectionTitle(_t("NUMBERS (1-10)", "ANGKA (1-10)")),
                              _buildGrid(AlphabetData.kanjiNumbers, isDark, crossAxisCount: 5),
                              const SizedBox(height: 32),
                              _buildSectionTitle(_t("NATURE & ELEMENTS", "ALAM & ELEMEN")),
                              _buildGrid(AlphabetData.kanjiNature, isDark, crossAxisCount: 5),
                              const SizedBox(height: 32),
                              _buildSectionTitle(_t("PEOPLE & DIRECTIONS", "ORANG & ARAH")),
                              _buildGrid(AlphabetData.kanjiPeople, isDark, crossAxisCount: 5),
                              const SizedBox(height: 100),
                            ]
                          ],
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFB5B0A8), letterSpacing: 1.5)),
    );
  }

  Widget _buildGrid(List<Map<String, String>> dataList, bool isDark, {required int crossAxisCount}) {
    final Color textColor = isDark ? Colors.white : const Color(0xFF3E362E);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);
    final Color gridBgColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: crossAxisCount == 3 ? 1.2 : 0.85
      ),
      itemCount: dataList.length,
      itemBuilder: (context, index) {
        final item = dataList[index];
        final isLearned = _currentLearned.contains(item["jp"]);
        return GestureDetector(
          onTap: () => _onKanaTapped(item, dataList),
          child: Container(
            decoration: BoxDecoration(
              color: isLearned ? (isDark ? const Color(0xFFCC6633).withOpacity(0.2) : const Color(0xFFF7E6D4)) : gridBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isLearned ? const Color(0xFFC6653B) : borderColor, width: isLearned ? 2 : 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item["jp"]!, style: TextStyle(fontSize: crossAxisCount == 3 ? 20 : 24, fontWeight: FontWeight.bold, color: isLearned ? const Color(0xFFC6653B) : textColor)),
                const SizedBox(height: 4),
                Text(item["ro"]!, style: TextStyle(fontSize: 10, color: isLearned ? const Color(0xFFC6653B) : const Color(0xFF8C8A87), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(int index, String title, bool isDark) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFC6653B) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA), width: 1.5),
        ),
        child: Text(
          title,
          style: TextStyle(color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF8C8A87)), fontWeight: FontWeight.bold, fontSize: 13),
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

    SignatureController controller = SignatureController(penStrokeWidth: 5, penColor: textColor, exportBackgroundColor: cardColor);
    int currentIndex = sourceList.indexOf(initialItem);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
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

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              backgroundColor: modalBg,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close_rounded, color: Color(0xFF8C8A87))),
                        const Spacer(),
                        Text(_t("Learn Strokes", "Pelajari Coretan"), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor, fontFamily: 'Serif')),
                        const Spacer(),
                        const SizedBox(width: 24),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor)),
                      child: Column(
                        children: [
                          Text(_t("How to draw", "Cara Menulis"), style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          if (_activeTab != 2)
                            Opacity(
                              opacity: isDark ? 0.85 : 1.0,
                              child: Image.asset(
                                _activeTab == 0 ? 'assets/gifs/hiragana_${romaji.toLowerCase()}.gif' : 'assets/gifs/katakana_${romaji.toLowerCase()}.gif',
                                height: 90,
                                errorBuilder: (c, e, s) => Text(kana, style: TextStyle(fontSize: 60, color: textColor)),
                              ),
                            )
                          else
                            Text(kana, style: TextStyle(fontSize: 60, color: textColor, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(romaji, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFC6653B))),
                          if (meaning != null) ...[
                            const SizedBox(height: 4),
                            Text(meaning, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.6), fontWeight: FontWeight.w600)),
                          ]
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_t("Practice", "Latihan"), style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
                        GestureDetector(
                          onTap: () { controller.clear(); setStatePopup(() {}); },
                          child: Row(
                            children: [
                              const Icon(Icons.cleaning_services_rounded, size: 14, color: Color(0xFFC6653B)),
                              const SizedBox(width: 4),
                              Text(_t("ERASE", "HAPUS"), style: const TextStyle(color: Color(0xFFC6653B), fontWeight: FontWeight.w900, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 160,
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
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        if (currentIndex > 0)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: goToPrev,
                              icon: const Icon(Icons.arrow_back_rounded, size: 18),
                              label: Text(_t("Prev", "Mundur")),
                              style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF8C8A87), side: BorderSide(color: borderColor), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            ),
                          ),
                        if (currentIndex > 0 && currentIndex < sourceList.length - 1)
                          const SizedBox(width: 12),
                        if (currentIndex < sourceList.length - 1)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: goToNext,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC6653B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              label: Text(_t("Next", "Maju"), style: const TextStyle(color: Colors.white)),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => controller.dispose());
  }
}