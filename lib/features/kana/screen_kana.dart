import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // IMPORT UNTUK SHAREDPREFERENCES
import '../../main.dart'; // IMPORT MAIN.DART UNTUK AKSES VARIABEL GLOBAL
import '../../data/alphabet_data.dart';

class KanaScreen extends StatefulWidget {
  const KanaScreen({super.key});

  @override
  State<KanaScreen> createState() => _KanaScreenState();
}

class _KanaScreenState extends State<KanaScreen> {
  final _supabase = Supabase.instance.client;
  int _activeTab = 0; // 0 = Hiragana, 1 = Katakana, 2 = Kanji

  Set<String> _learnedHiragana = {};
  Set<String> _learnedKatakana = {};

  int get _totalCurrentCharacters {
    if (_activeTab == 0) {
      return AlphabetData.hiraBasic.length + AlphabetData.hiraDakuon.length +
          AlphabetData.hiraHandakuon.length + AlphabetData.hiraYoon.length;
    } else if (_activeTab == 1) {
      return AlphabetData.kataBasic.length + AlphabetData.kataDakuon.length +
          AlphabetData.kataHandakuon.length + AlphabetData.kataYoon.length;
    }
    return 0;
  }

  Set<String> get _currentLearned => _activeTab == 0 ? _learnedHiragana : (_activeTab == 1 ? _learnedKatakana : <String>{});

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final metadata = user.userMetadata;
      if (metadata != null) {
        setState(() {
          if (metadata['learned_hiragana'] != null) {
            _learnedHiragana = List<String>.from(metadata['learned_hiragana']).toSet();
          }
          if (metadata['learned_katakana'] != null) {
            _learnedKatakana = List<String>.from(metadata['learned_katakana']).toSet();
          }
        });
      }
    }
  }

  // --- 🔥 LOGIKA SINKRONISASI DIPERBARUI DI SINI ---
  Future<void> _saveData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.auth.updateUser(
          UserAttributes(
            data: {
              'learned_hiragana': _learnedHiragana.toList(),
              'learned_katakana': _learnedKatakana.toList(),
            },
          ),
        );

        // 1. Simpan ke lokal (buat jaga-jaga kalau offline)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('learned_hiragana', _learnedHiragana.length);
        await prefs.setInt('learned_katakana', _learnedKatakana.length);

        // 2. UPDATE VARIABEL GLOBAL AGAR PROFIL LANGSUNG TERSINKRON
        globalLearnedHiragana.value = _learnedHiragana.length;
        globalLearnedKatakana.value = _learnedKatakana.length;

      } catch (e) {
        debugPrint("Gagal menyimpan progress alfabet: $e");
      }
    }
  }

  void _onKanaTapped(Map<String, String> item, List<Map<String, String>> sourceList) {
    setState(() {
      _currentLearned.add(item["jp"]!);
    });
    _saveData(); // Panggil fungsi yang sudah dimodifikasi tadi
    _showKanaPopup(context, item, sourceList);
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = globalDarkMode.value;
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2);
    final Color textColor = isDark ? Colors.white : const Color(0xFF3E362E);

    String headerTitle = _activeTab == 0 ? _t("Learning ひらがな", "Belajar ひらがな") : (_activeTab == 1 ? _t("Learning カタカナ", "Belajar カタカナ") : _t("Learning 漢字", "Belajar 漢字"));
    String headerDesc = _activeTab == 0
        ? _t("Master the basic native Japanese characters including Dakuon and Yoon.", "Kuasai huruf dasar Jepang beserta Dakuon dan Yoon.")
        : (_activeTab == 1 ? _t("Master the characters used for foreign loanwords.", "Kuasai karakter untuk kata serapan asing.") : _t("Kanji lessons coming soon!", "Pelajaran Kanji akan segera hadir!"));

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
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
                        if (_activeTab != 2)
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
              child: _activeTab == 2
                  ? Center(child: Text(_t("Kanji feature is currently under development.", "Fitur Kanji sedang dalam tahap pengembangan."), style: const TextStyle(color: Color(0xFF8C8A87), fontStyle: FontStyle.italic)))
                  : SingleChildScrollView(
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
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
              color: isLearned ? (isDark ? const Color(0xFFCC6633).withValues(alpha: 0.2) : const Color(0xFFF7E6D4)) : gridBgColor,
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

            void goToNext() {
              if (currentIndex < sourceList.length - 1) {
                setStatePopup(() { currentIndex++; controller.clear(); });
                setState(() { _currentLearned.add(sourceList[currentIndex]["jp"]!); });
                _saveData(); // Panggil simpan & sync
              }
            }

            void goToPrev() {
              if (currentIndex > 0) {
                setStatePopup(() { currentIndex--; controller.clear(); });
                setState(() { _currentLearned.add(sourceList[currentIndex]["jp"]!); });
                _saveData(); // Panggil simpan & sync
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
                          Opacity(
                            opacity: isDark ? 0.85 : 1.0,
                            child: Image.asset(
                              _activeTab == 0 ? 'assets/gifs/hiragana_${romaji.toLowerCase()}.gif' : 'assets/gifs/katakana_${romaji.toLowerCase()}.gif',
                              height: 90,
                              errorBuilder: (c, e, s) => Text(kana, style: TextStyle(fontSize: 60, color: textColor)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(romaji, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFC6653B))),
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