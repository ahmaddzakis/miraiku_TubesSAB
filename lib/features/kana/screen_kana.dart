import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import fitur penyimpanan

class KanaScreen extends StatefulWidget {
  const KanaScreen({super.key});

  @override
  State<KanaScreen> createState() => _KanaScreenState();
}

class _KanaScreenState extends State<KanaScreen> {
  int _activeTab = 0; // 0 = Hiragana, 1 = Katakana, 2 = Kanji

  // Set untuk menyimpan progress (Sekarang tidak menggunakan final agar bisa dimuat ulang)
  Set<String> _learnedHiragana = {};
  Set<String> _learnedKatakana = {};

  // --- DATA LENGKAP HIRAGANA (46 Karakter) ---
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

  // --- DATA LENGKAP KATAKANA (46 Karakter) ---
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

  // Helper untuk mendapatkan list & set yang sedang aktif
  List<Map<String, String>> get _currentList => _activeTab == 0 ? _hiraganaList : (_activeTab == 1 ? _katakanaList : []);
  Set<String> get _currentLearned => _activeTab == 0 ? _learnedHiragana : (_activeTab == 1 ? _learnedKatakana : <String>{});

  @override
  void initState() {
    super.initState();
    _loadSavedData(); // Panggil fungsi muat data saat layar pertama kali dibuka
  }

  // --- LOGIKA DATABASE: Memuat data yang sudah tersimpan ---
  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _learnedHiragana = (prefs.getStringList('learnedHiragana') ?? []).toSet();
      _learnedKatakana = (prefs.getStringList('learnedKatakana') ?? []).toSet();
    });
  }

  // --- LOGIKA DATABASE: Menyimpan data setiap ada perubahan ---
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('learnedHiragana', _learnedHiragana.toList());
    await prefs.setStringList('learnedKatakana', _learnedKatakana.toList());
  }

  void _onKanaTapped(int index) {
    setState(() {
      _currentLearned.add(_currentList[index]["kana"]!);
    });
    _saveData(); // Simpan ke storage

    _showKanaPopup(context, index);
  }

  @override
  Widget build(BuildContext context) {
    String headerTitle = _activeTab == 0 ? "Learning Hiragana" : (_activeTab == 1 ? "Learning Katakana" : "Learning Kanji");
    String headerDesc = _activeTab == 0
        ? "Master the 46 basic native Japanese characters."
        : (_activeTab == 1 ? "Master the 46 angular characters used for foreign loanwords." : "Kanji lessons coming soon!");

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 24), // Memberikan jarak atas karena Top Bar dihapus

              // --- TABS (Hiragana | Katakana | Kanji) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTab(0, "Hiragana"),
                  _buildTab(1, "Katakana"),
                  _buildTab(2, "Kanji"),
                ],
              ),
              const SizedBox(height: 24),

              // --- HEADER CARD DINAMIS ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFD68A60),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      headerTitle,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22, fontFamily: 'Serif'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      headerDesc,
                      style: const TextStyle(color: Color(0xFFF7E6D4), fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Start Lesson dihapus, hanya menyisakan Progress di sebelah kanan
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_activeTab != 2) // Sembunyikan progress di tab Kanji
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7E6D4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${_currentLearned.length} / ${_currentList.length} LEARNED",
                              style: const TextStyle(color: Color(0xFFC6653B), fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                          )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- GRID HURUF KANA DINAMIS ---
              Expanded(
                child: _activeTab == 2
                    ? const Center(
                  child: Text("Kanji feature is currently under development.", style: TextStyle(color: Color(0xFF8C8A87), fontStyle: FontStyle.italic)),
                )
                    : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _currentList.length,
                  itemBuilder: (context, index) {
                    final item = _currentList[index];
                    final isLearned = _currentLearned.contains(item["kana"]);

                    return GestureDetector(
                      onTap: () => _onKanaTapped(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLearned ? const Color(0xFFF7E6D4) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isLearned ? const Color(0xFFC6653B) : const Color(0xFFE8E3DA),
                            width: isLearned ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item["kana"]!,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isLearned ? const Color(0xFFC6653B) : const Color(0xFF3E362E)
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item["romaji"]!,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: isLearned ? const Color(0xFFC6653B) : const Color(0xFFB5B0A8),
                                  fontWeight: FontWeight.w600
                              ),
                            ),
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

  // Widget Helper untuk Tab
  Widget _buildTab(int index, String title) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFC6653B) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isActive ? null : Border.all(color: const Color(0xFFE8E3DA), width: 1.5),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF8C8A87),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // --- WIDGET POP-UP DINAMIS ---
  void _showKanaPopup(BuildContext context, int initialIndex) {
    SignatureController controller = SignatureController(
      penStrokeWidth: 6,
      penColor: const Color(0xFF3E362E),
      exportBackgroundColor: Colors.white,
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
                setStatePopup(() {
                  currentIndex++;
                  controller.clear();
                });
                setState(() {
                  _currentLearned.add(_currentList[currentIndex]["kana"]!);
                });
                _saveData(); // Simpan ke storage saat pindah huruf
              }
            }

            void goToPrev() {
              if (currentIndex > 0) {
                setStatePopup(() {
                  currentIndex--;
                  controller.clear();
                });
                setState(() {
                  _currentLearned.add(_currentList[currentIndex]["kana"]!);
                });
                _saveData(); // Simpan ke storage saat pindah huruf
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: const Color(0xFFFAF7F2),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Pop-up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: Color(0xFF3E362E)),
                          ),
                          const Text("Learn Strokes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3E362E), fontFamily: 'Serif')),
                          const SizedBox(width: 24),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // URUTAN CORETAN (Stroke Order)
                      const Text(
                        "How to draw",
                        style: TextStyle(color: Color(0xFF8C8A87), fontSize: 13, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8E3DA), width: 1.5),
                        ),
                        child: Center(
                          child: Opacity(
                            opacity: 0.6,
                            child: Text(kana, style: const TextStyle(fontSize: 70, color: Color(0xFF3E362E))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Pronounce
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7E6D4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                            "Pronounce   $romaji",
                            style: const TextStyle(color: Color(0xFFC6653B), fontWeight: FontWeight.bold, fontSize: 16)
                        ),
                      ),
                      const SizedBox(height: 30),

                      // AREA LATIHAN MENULIS
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Practice Drawing Below",
                            style: TextStyle(color: Color(0xFF3E362E), fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.clear();
                              setStatePopup(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E3DA),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.edit_off_rounded, color: Color(0xFF7A7571), size: 12),
                                  SizedBox(width: 4),
                                  Text("ERASE", style: TextStyle(color: Color(0xFF7A7571), fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Kertas Virtual Coretan Jari
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE8E3DA), width: 2),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Center(child: VerticalDivider(color: Color(0xFFE8E3DA), thickness: 1, width: 1)),
                            const Center(child: Divider(color: Color(0xFFE8E3DA), thickness: 1, height: 1)),
                            Signature(
                              controller: controller,
                              height: 200,
                              backgroundColor: Colors.transparent,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- NAVIGASI BAWAH (PREV & NEXT) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          currentIndex > 0
                              ? GestureDetector(
                            onTap: goToPrev,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE8E3DA), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text("◀ Prev", style: TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold)),
                            ),
                          )
                              : const SizedBox(width: 80),

                          currentIndex < _currentList.length - 1
                              ? GestureDetector(
                            onTap: goToNext,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC6653B),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text("Next ▶", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )
                              : const SizedBox(width: 80),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      controller.dispose();
    });
  }
}