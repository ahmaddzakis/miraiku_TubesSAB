import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; // Wajib ditambahkan untuk memanggil global state

class KanaScreen extends StatefulWidget {
  const KanaScreen({super.key});

  @override
  State<KanaScreen> createState() => _KanaScreenState();
}

class _KanaScreenState extends State<KanaScreen> {
  int _activeTab = 0; // 0 = Hiragana, 1 = Katakana, 2 = Kanji

  Set<String> _learnedHiragana = {};
  Set<String> _learnedKatakana = {};

  final List<Map<String, String>> _hiraganaList = [
    {"kana": "あ", "romaji": "A"}, {"kana": "い", "romaji": "I"}, {"kana": "う", "romaji": "U"}, {"kana": "え", "romaji": "E"}, {"kana": "お", "romaji": "O"},
    {"kana": "か", "romaji": "KA"}, {"kana": "き", "romaji": "KI"}, {"kana": "く", "romaji": "KU"}, {"kana": "け", "romaji": "KE"}, {"kana": "こ", "romaji": "KO"},
    {"kana": "さ", "romaji": "SA"}, {"kana": "し", "romaji": "SHI"}, {"kana": "す", "romaji": "SU"}, {"kana": "せ", "romaji": "SE"}, {"kana": "そ", "romaji": "SO"},
    {"kana": "た", "romaji": "TA"}, {"kana": "ち", "romaji": "CHI"}, {"kana": "つ", "romaji": "TSU"}, {"kana": "て", "romaji": "TE"}, {"kana": "と", "romaji": "TO"},
    {"kana": "な", "romaji": "NA"}, {"kana": "に", "romaji": "NI"}, {"kana": "ぬ", "romaji": "NU"}, {"kana": "ね", "romaji": "NE"}, {"kana": "の", "romaji": "NO"},
    {"kana": "は", "romaji": "HA"}, {"kana": "ひ", "romaji": "HI"}, {"kana": "ふ", "romaji": "FU"}, {"kana": "へ", "romaji": "HE"}, {"kana": "ほ", "romaji": "HO"},
    {"kana": "ま", "romaji": "MA"}, {"kana": "み", "romaji": "MI"}, {"kana": "む", "romaji": "MU"}, {"kana": "め", "romaji": "ME"}, {"kana": "も", "romaji": "MO"},
    {"kana": "や", "romaji": "YA"}, {"kana": "ゆ", "romaji": "YU"}, {"kana": "よ", "romaji": "YO"},
    {"kana": "ら", "romaji": "RA"}, {"kana": "り", "romaji": "RI"}, {"kana": "る", "romaji": "RU"}, {"kana": "れ", "romaji": "RE"}, {"kana": "ろ", "romaji": "RO"},
    {"kana": "わ", "romaji": "WA"}, {"kana": "を", "romaji": "WO"},
    {"kana": "ん", "romaji": "N"},
  ];

  final List<Map<String, String>> _katakanaList = [
    {"kana": "ア", "romaji": "A"}, {"kana": "イ", "romaji": "I"}, {"kana": "ウ", "romaji": "U"}, {"kana": "エ", "romaji": "E"}, {"kana": "オ", "romaji": "O"},
    {"kana": "カ", "romaji": "KA"}, {"kana": "キ", "romaji": "KI"}, {"kana": "ク", "romaji": "KU"}, {"kana": "ケ", "romaji": "KE"}, {"kana": "コ", "romaji": "KO"},
    {"kana": "サ", "romaji": "SA"}, {"kana": "シ", "romaji": "SHI"}, {"kana": "ス", "romaji": "SU"}, {"kana": "セ", "romaji": "SE"}, {"kana": "ソ", "romaji": "SO"},
    {"kana": "タ", "romaji": "TA"}, {"kana": "チ", "romaji": "CHI"}, {"kana": "ツ", "romaji": "TSU"}, {"kana": "テ", "romaji": "TE"}, {"kana": "ト", "romaji": "TO"},
    {"kana": "ナ", "romaji": "NA"}, {"kana": "ニ", "romaji": "NI"}, {"kana": "ヌ", "romaji": "NU"}, {"kana": "ネ", "romaji": "NE"}, {"kana": "ノ", "romaji": "NO"},
    {"kana": "ハ", "romaji": "HA"}, {"kana": "ヒ", "romaji": "HI"}, {"kana": "フ", "romaji": "FU"}, {"kana": "ヘ", "romaji": "HE"}, {"kana": "ホ", "romaji": "HO"},
    {"kana": "マ", "romaji": "MA"}, {"kana": "ミ", "romaji": "MI"}, {"kana": "ム", "romaji": "MU"}, {"kana": "メ", "romaji": "ME"}, {"kana": "モ", "romaji": "MO"},
    {"kana": "ヤ", "romaji": "YA"}, {"kana": "ユ", "romaji": "YU"}, {"kana": "ヨ", "romaji": "YO"},
    {"kana": "ラ", "romaji": "RA"}, {"kana": "リ", "romaji": "RI"}, {"kana": "ル", "romaji": "RU"}, {"kana": "レ", "romaji": "RE"}, {"kana": "ロ", "romaji": "RO"},
    {"kana": "ワ", "romaji": "WA"}, {"kana": "ヲ", "romaji": "WO"},
    {"kana": "ン", "romaji": "N"},
  ];

  List<Map<String, String>> get _currentList => _activeTab == 0 ? _hiraganaList : (_activeTab == 1 ? _katakanaList : []);
  Set<String> get _currentLearned => _activeTab == 0 ? _learnedHiragana : (_activeTab == 1 ? _learnedKatakana : <String>{});

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _learnedHiragana = (prefs.getStringList('learnedHiragana') ?? []).toSet();
      _learnedKatakana = (prefs.getStringList('learnedKatakana') ?? []).toSet();
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('learnedHiragana', _learnedHiragana.toList());
    await prefs.setStringList('learnedKatakana', _learnedKatakana.toList());
  }

  void _onKanaTapped(int index) {
    setState(() {
      _currentLearned.add(_currentList[index]["kana"]!);
    });
    _saveData();
    _showKanaPopup(context, index);
  }

  // --- FUNGSI TRANSLATE OTOMATIS ---
  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    // --- VARIABEL WARNA DINAMIS ---
    final bool isDark = globalDarkMode.value;
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2);
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF3E362E);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);
    final Color gridBgColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;

    String headerTitle = _activeTab == 0 ? _t("Learning ひらがな", "Belajar ひらがな") : (_activeTab == 1 ? _t("Learning カタカナ", "Belajar カタカナ") : _t("Learning 漢字", "Belajar 漢字"));
    String headerDesc = _activeTab == 0
        ? _t("Master the 46 basic native Japanese characters.", "Kuasai 46 karakter dasar bahasa Jepang.")
        : (_activeTab == 1 ? _t("Master the 46 characters used for foreign loanwords.", "Kuasai 46 karakter untuk kata serapan asing.") : _t("Kanji lessons coming soon!", "Pelajaran Kanji akan segera hadir!"));

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab(0, "Hiragana", isDark, textColor),
                  _buildTab(1, "Katakana", isDark, textColor),
                  _buildTab(2, "Kanji", isDark, textColor),
                ],
              ),
              const SizedBox(height: 24),
              Container(
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
                              "${_currentLearned.length} / ${_currentList.length} ${_t('LEARNED', 'SELESAI')}",
                              style: const TextStyle(color: Color(0xFFC6653B), fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                          )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _activeTab == 2
                    ? Center(child: Text(_t("Kanji feature is currently under development.", "Fitur Kanji sedang dalam tahap pengembangan."), style: const TextStyle(color: Color(0xFF8C8A87), fontStyle: FontStyle.italic)))
                    : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
                  itemCount: _currentList.length,
                  itemBuilder: (context, index) {
                    final item = _currentList[index];
                    final isLearned = _currentLearned.contains(item["kana"]);
                    return GestureDetector(
                      onTap: () => _onKanaTapped(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLearned ? (isDark ? const Color(0xFFCC6633).withOpacity(0.2) : const Color(0xFFF7E6D4)) : gridBgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isLearned ? const Color(0xFFC6653B) : borderColor, width: isLearned ? 2 : 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(item["kana"]!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isLearned ? const Color(0xFFC6653B) : textColor)),
                            const SizedBox(height: 4),
                            Text(item["romaji"]!, style: TextStyle(fontSize: 10, color: isLearned ? const Color(0xFFC6653B) : const Color(0xFF8C8A87), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title, bool isDark, Color textColor) {
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
          style: TextStyle(
            color: isActive ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF8C8A87)),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showKanaPopup(BuildContext context, int initialIndex) {
    final bool isDark = globalDarkMode.value;
    final Color modalBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAF7F2);
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
    final Color cardColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);

    SignatureController controller = SignatureController(
      penStrokeWidth: 5,
      penColor: textColor, // Warna pulpen berubah putih saat Dark Mode
      exportBackgroundColor: cardColor,
    );

    int currentIndex = initialIndex;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStatePopup) {
            final currentItem = _currentList[currentIndex];
            final kana = currentItem["kana"]!;
            final romaji = currentItem["romaji"]!;

            void goToNext() {
              if (currentIndex < _currentList.length - 1) {
                setStatePopup(() { currentIndex++; controller.clear(); });
                setState(() { _currentLearned.add(_currentList[currentIndex]["kana"]!); });
                _saveData();
              }
            }

            void goToPrev() {
              if (currentIndex > 0) {
                setStatePopup(() { currentIndex--; controller.clear(); });
                setState(() { _currentLearned.add(_currentList[currentIndex]["kana"]!); });
                _saveData();
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

                          // GIF sedikit dibuat redup jika Dark Mode agar tidak menyilaukan
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
                        if (currentIndex > 0) const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: goToNext,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC6653B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                            label: Text(currentIndex < _currentList.length - 1 ? _t("Next", "Maju") : _t("Finish", "Selesai"), style: const TextStyle(color: Colors.white)),
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