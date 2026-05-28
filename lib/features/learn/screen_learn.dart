import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/game_manager.dart';
import '../../widgets/path_node.dart';
import 'widget_learn.dart';
import 'screen_exercise.dart';

class LearnScreen extends StatefulWidget {
  final bool isUnit1Completed;
  final VoidCallback onUnit1Completed;

  const LearnScreen({
    super.key,
    required this.isUnit1Completed,
    required this.onUnit1Completed,
  });

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  // --- STATE UNIT 1 ---
  int _u1Hira1Stars = 0, _u1Hira2Stars = 0, _u1Hira3Stars = 0, _u1Hira4Stars = 0;
  int _u1GreetStars = 0, _u1NumStars = 0, _u1TestCompleted = 0;

  // --- STATE UNIT 2 (DIPERLUAS 4 Katakana, 2 Kata) ---
  int _u2Kata1Stars = 0, _u2Kata2Stars = 0, _u2Kata3Stars = 0, _u2Kata4Stars = 0;
  int _u2Words1Stars = 0, _u2Words2Stars = 0, _u2TestCompleted = 0;

  // --- STATE UNIT 3 (BASIC KANJI) ---
  int _u3NumStars = 0, _u3NatureStars = 0, _u3PeopleStars = 0, _u3TestCompleted = 0;

  // --- STATE UNIT 4 (BASIC GRAMMAR) ---
  int _u4ParticlesStars = 0, _u4Verbs1Stars = 0, _u4Verbs2Stars = 0, _u4AdjectivesStars = 0, _u4TestCompleted = 0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _u1Hira1Stars = prefs.getInt('u1_hira1_stars') ?? 0;
      _u1Hira2Stars = prefs.getInt('u1_hira2_stars') ?? 0;
      _u1Hira3Stars = prefs.getInt('u1_hira3_stars') ?? 0;
      _u1Hira4Stars = prefs.getInt('u1_hira4_stars') ?? 0;
      _u1GreetStars = prefs.getInt('u1_greet_stars') ?? 0;
      _u1NumStars = prefs.getInt('u1_num_stars') ?? 0;
      _u1TestCompleted = prefs.getInt('u1_test_stars') ?? 0;

      // Katakana States
      _u2Kata1Stars = prefs.getInt('u2_kata1_stars') ?? 0;
      _u2Kata2Stars = prefs.getInt('u2_kata2_stars') ?? 0;
      _u2Kata3Stars = prefs.getInt('u2_kata3_stars') ?? 0;
      _u2Kata4Stars = prefs.getInt('u2_kata4_stars') ?? 0;
      _u2Words1Stars = prefs.getInt('u2_words1_stars') ?? 0;
      _u2Words2Stars = prefs.getInt('u2_words2_stars') ?? 0;
      _u2TestCompleted = prefs.getInt('u2_test_stars') ?? 0;

      // Unit 3 States
      _u3NumStars = prefs.getInt('u3_num_stars') ?? 0;
      _u3NatureStars = prefs.getInt('u3_nature_stars') ?? 0;
      _u3PeopleStars = prefs.getInt('u3_people_stars') ?? 0;
      _u3TestCompleted = prefs.getInt('u3_test_stars') ?? 0;

      // Unit 4 States
      _u4ParticlesStars = prefs.getInt('u4_particles_stars') ?? 0;
      _u4Verbs1Stars = prefs.getInt('u4_verbs1_stars') ?? 0;
      _u4Verbs2Stars = prefs.getInt('u4_verbs2_stars') ?? 0;
      _u4AdjectivesStars = prefs.getInt('u4_adjectives_stars') ?? 0;
      _u4TestCompleted = prefs.getInt('u4_test_stars') ?? 0;
    });
  }

  Future<void> _saveStarProgress(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
            final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);

            // Kunci Pembuka Unit 2 & 3 & 4
            bool isUnit2Unlocked = widget.isUnit1Completed || _u1TestCompleted >= 1;
            bool isUnit3Unlocked = _u2TestCompleted >= 1;
            bool isUnit4Unlocked = _u3TestCompleted >= 1;

            return Scaffold(
              backgroundColor: bgColor,
              body: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const UnitHeaderCard(),
              const SizedBox(height: 40),

              // ==================== UNIT 1 ====================
              _buildClickableNode(context, _t("Hiragana Basics 1", "Hiragana Dasar 1"), _u1Hira1Stars, _u1Hira1Stars >= 3 ? NodeStatus.completed : NodeStatus.current, 1, 'hiragana_1', () {
                setState(() { if (_u1Hira1Stars < 3) { _u1Hira1Stars++; _saveStarProgress('u1_hira1_stars', _u1Hira1Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Hiragana Basics 2", "Hiragana Dasar 2"), _u1Hira2Stars, _u1Hira2Stars >= 3 ? NodeStatus.completed : (_u1Hira1Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 1, 'hiragana_2', () {
                setState(() { if (_u1Hira2Stars < 3) { _u1Hira2Stars++; _saveStarProgress('u1_hira2_stars', _u1Hira2Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Hiragana Basics 3", "Hiragana Dasar 3"), _u1Hira3Stars, _u1Hira3Stars >= 3 ? NodeStatus.completed : (_u1Hira2Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 1, 'hiragana_3', () {
                setState(() { if (_u1Hira3Stars < 3) { _u1Hira3Stars++; _saveStarProgress('u1_hira3_stars', _u1Hira3Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Hiragana Basics 4", "Hiragana Dasar 4"), _u1Hira4Stars, _u1Hira4Stars >= 3 ? NodeStatus.completed : (_u1Hira3Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 1, 'hiragana_4', () {
                setState(() { if (_u1Hira4Stars < 3) { _u1Hira4Stars++; _saveStarProgress('u1_hira4_stars', _u1Hira4Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Daily Greetings", "Salam Sehari-hari"), _u1GreetStars, _u1GreetStars >= 3 ? NodeStatus.completed : (_u1Hira4Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 1, 'greetings', () {
                setState(() { if (_u1GreetStars < 3) { _u1GreetStars++; _saveStarProgress('u1_greet_stars', _u1GreetStars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Numbers & Time", "Angka & Waktu"), _u1NumStars, _u1NumStars >= 3 ? NodeStatus.completed : (_u1GreetStars >= 3 ? NodeStatus.current : NodeStatus.locked), 1, 'numbers', () {
                setState(() { if (_u1NumStars < 3) { _u1NumStars++; _saveStarProgress('u1_num_stars', _u1NumStars); } });
              }),
              _buildLeftConnector(borderColor),

              // UNIT TEST 1 (Tanpa Bintang, Langsung Tamat 1x Main)
              _buildClickableNode(
                context, _t("Unit Test\n20 min", "Ujian Unit\n20 mnt"), 0,
                _u1TestCompleted >= 1 ? NodeStatus.completed : (_u1NumStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                1, 'test', () {
                setState(() {
                  if (_u1TestCompleted == 0) {
                    _u1TestCompleted = 1;
                    _saveStarProgress('u1_test_stars', 1);
                    widget.onUnit1Completed(); // Buka gembok Unit 2
                  }
                });
              },
              ),

              const SizedBox(height: 40),
              Divider(thickness: 2, color: borderColor),
              const SizedBox(height: 20),

              // ==================== UNIT 2 (DESAIN KONSISTEN) ====================
              _buildUnit2HeaderCard(isDark, isUnit2Unlocked), // 🔥 Desain Header Baru!
              const SizedBox(height: 40),

              _buildClickableNode(context, _t("Katakana Basics 1", "Katakana Dasar 1"), _u2Kata1Stars, _u2Kata1Stars >= 3 ? NodeStatus.completed : (isUnit2Unlocked ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_1', () {
                setState(() { if (_u2Kata1Stars < 3) { _u2Kata1Stars++; _saveStarProgress('u2_kata1_stars', _u2Kata1Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Katakana Basics 2", "Katakana Dasar 2"), _u2Kata2Stars, _u2Kata2Stars >= 3 ? NodeStatus.completed : (_u2Kata1Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_2', () {
                setState(() { if (_u2Kata2Stars < 3) { _u2Kata2Stars++; _saveStarProgress('u2_kata2_stars', _u2Kata2Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Katakana Basics 3", "Katakana Dasar 3"), _u2Kata3Stars, _u2Kata3Stars >= 3 ? NodeStatus.completed : (_u2Kata2Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_3', () {
                setState(() { if (_u2Kata3Stars < 3) { _u2Kata3Stars++; _saveStarProgress('u2_kata3_stars', _u2Kata3Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Katakana Basics 4", "Katakana Dasar 4"), _u2Kata4Stars, _u2Kata4Stars >= 3 ? NodeStatus.completed : (_u2Kata3Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_4', () {
                setState(() { if (_u2Kata4Stars < 3) { _u2Kata4Stars++; _saveStarProgress('u2_kata4_stars', _u2Kata4Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Katakana Words 1", "Kosakata Katakana 1"), _u2Words1Stars, _u2Words1Stars >= 3 ? NodeStatus.completed : (_u2Kata4Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_words', () {
                setState(() { if (_u2Words1Stars < 3) { _u2Words1Stars++; _saveStarProgress('u2_words1_stars', _u2Words1Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Katakana Words 2", "Kosakata Katakana 2"), _u2Words2Stars, _u2Words2Stars >= 3 ? NodeStatus.completed : (_u2Words1Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'loanwords', () {
                setState(() { if (_u2Words2Stars < 3) { _u2Words2Stars++; _saveStarProgress('u2_words2_stars', _u2Words2Stars); } });
              }),
              _buildLeftConnector(borderColor),

              // UNIT TEST 2
              _buildClickableNode(
                context, _t("Unit 2 Test\n20 min", "Ujian Unit 2\n20 mnt"), 0,
                _u2TestCompleted >= 1 ? NodeStatus.completed : (_u2Words2Stars >= 3 ? NodeStatus.current : NodeStatus.locked),
                2, 'test', () {
                setState(() {
                  if (_u2TestCompleted == 0) {
                    _u2TestCompleted = 1;
                    _saveStarProgress('u2_test_stars', 1);
                  }
                });
              },
              ),

              const SizedBox(height: 40),
              Divider(thickness: 2, color: borderColor),
              const SizedBox(height: 20),

              // ==================== UNIT 3 (KANJI) ====================
              _buildUnit3HeaderCard(isDark, isUnit3Unlocked),
              const SizedBox(height: 40),

              _buildClickableNode(context, _t("Kanji Numbers", "Kanji Angka"), _u3NumStars, _u3NumStars >= 3 ? NodeStatus.completed : (isUnit3Unlocked ? NodeStatus.current : NodeStatus.locked), 3, 'kanji_numbers', () {
                setState(() { if (_u3NumStars < 3) { _u3NumStars++; _saveStarProgress('u3_num_stars', _u3NumStars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Nature & Elements", "Alam & Elemen"), _u3NatureStars, _u3NatureStars >= 3 ? NodeStatus.completed : (_u3NumStars >= 3 ? NodeStatus.current : NodeStatus.locked), 3, 'kanji_nature', () {
                setState(() { if (_u3NatureStars < 3) { _u3NatureStars++; _saveStarProgress('u3_nature_stars', _u3NatureStars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("People & Directions", "Orang & Arah"), _u3PeopleStars, _u3PeopleStars >= 3 ? NodeStatus.completed : (_u3NatureStars >= 3 ? NodeStatus.current : NodeStatus.locked), 3, 'kanji_people', () {
                setState(() { if (_u3PeopleStars < 3) { _u3PeopleStars++; _saveStarProgress('u3_people_stars', _u3PeopleStars); } });
              }),
              _buildLeftConnector(borderColor),

              // UNIT TEST 3
              _buildClickableNode(
                context, _t("Unit 3 Test\n20 min", "Ujian Unit 3\n20 mnt"), 0,
                _u3TestCompleted >= 1 ? NodeStatus.completed : (_u3PeopleStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                3, 'test', () {
                setState(() {
                  if (_u3TestCompleted == 0) {
                    _u3TestCompleted = 1;
                    _saveStarProgress('u3_test_stars', 1);
                  }
                });
              },
              ),

              // ==================== UNIT 4 (GRAMMAR) ====================
              _buildUnit4HeaderCard(isDark, isUnit4Unlocked),
              const SizedBox(height: 40),

              _buildClickableNode(context, _t("Basic Particles", "Partikel Dasar"), _u4ParticlesStars, _u4ParticlesStars >= 3 ? NodeStatus.completed : (isUnit4Unlocked ? NodeStatus.current : NodeStatus.locked), 4, 'grammar_particles', () {
                setState(() { if (_u4ParticlesStars < 3) { _u4ParticlesStars++; _saveStarProgress('u4_particles_stars', _u4ParticlesStars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Verb Basics 1", "Kata Kerja 1"), _u4Verbs1Stars, _u4Verbs1Stars >= 3 ? NodeStatus.completed : (_u4ParticlesStars >= 3 ? NodeStatus.current : NodeStatus.locked), 4, 'grammar_verbs_1', () {
                setState(() { if (_u4Verbs1Stars < 3) { _u4Verbs1Stars++; _saveStarProgress('u4_verbs1_stars', _u4Verbs1Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Verb Basics 2", "Kata Kerja 2"), _u4Verbs2Stars, _u4Verbs2Stars >= 3 ? NodeStatus.completed : (_u4Verbs1Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 4, 'grammar_verbs_2', () {
                setState(() { if (_u4Verbs2Stars < 3) { _u4Verbs2Stars++; _saveStarProgress('u4_verbs2_stars', _u4Verbs2Stars); } });
              }),
              _buildLeftConnector(borderColor),
              _buildClickableNode(context, _t("Adjectives", "Kata Sifat"), _u4AdjectivesStars, _u4AdjectivesStars >= 3 ? NodeStatus.completed : (_u4Verbs2Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 4, 'grammar_adjectives', () {
                setState(() { if (_u4AdjectivesStars < 3) { _u4AdjectivesStars++; _saveStarProgress('u4_adjectives_stars', _u4AdjectivesStars); } });
              }),
              _buildLeftConnector(borderColor),

              // UNIT TEST 4
              _buildClickableNode(
                context, _t("Unit 4 Test\n20 min", "Ujian Unit 4\n20 mnt"), 0,
                _u4TestCompleted >= 1 ? NodeStatus.completed : (_u4AdjectivesStars >= 3 ? NodeStatus.current : NodeStatus.locked),
                4, 'test', () {
                setState(() {
                  if (_u4TestCompleted == 0) {
                    _u4TestCompleted = 1;
                    _saveStarProgress('u4_test_stars', 1);
                  }
                });
              },
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
          },
        );
      },
    );
  }

  // --- HELPER BUILDER ---
  Widget _buildLeftConnector(Color color) => Container(alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 28), child: Container(width: 6, height: 35, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))));

  Widget _buildClickableNode(BuildContext context, String title, int stars, NodeStatus status, int unit, String diff, VoidCallback onSuccess) {
    final bool isTestNode = title.toLowerCase().contains('test') || title.toLowerCase().contains('ujian');

    return ValueListenableBuilder<int>(
      valueListenable: globalHearts,
      builder: (context, currentHearts, _) {
        return GestureDetector(
          onTap: (status == NodeStatus.locked || (status == NodeStatus.completed && (stars >= 3 || isTestNode)))
              ? null
              : () {
            if (currentHearts <= 0) { _showNoHeartsDialog(); return; }
            Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseScreen(
              unit: unit, 
              difficulty: diff, 
              currentStars: stars, 
              currentHearts: currentHearts, 
              onQuizPassed: onSuccess, 
            )));
          },
          child: PathNode(
            title: title, 
            status: status, 
            stars: stars, 
            alignment: Alignment.centerLeft, 
            onReplaySelected: (selectedStarIndex) {
              if (currentHearts <= 0) { _showNoHeartsDialog(); return; }
              Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseScreen(
                unit: unit, 
                difficulty: diff, 
                currentStars: selectedStarIndex,
                currentHearts: currentHearts,
                onQuizPassed: onSuccess,
              )));
            },
          ),
        );
      }
    );
  }

  // 🔥 FUNGSI HEADER BARU: DESAIN MIRIP UNIT 1 (KOTAK BESAR, TEKS BERTUMPUK)
  Widget _buildUnit2HeaderCard(bool isDark, bool unlocked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        // Menggunakan hijau khas Duolingo/Miraiku jika terbuka
        color: unlocked ? const Color(0xFF58CC02) : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E3DA)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'UNIT 2',
              style: TextStyle(color: unlocked ? Colors.white.withValues(alpha: 0.9) : Colors.grey, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)
          ),
          const SizedBox(height: 8),
          Text(
              _t('KATAKANA & LOANWORDS', 'KATAKANA & KATA SERAPAN'),
              style: TextStyle(color: unlocked ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontSize: 24, fontWeight: FontWeight.w900)
          ),
          const SizedBox(height: 12),
          Text(
              unlocked ? _t('Learn the second alphabet system for foreign words', 'Pelajari sistem alfabet kedua untuk kata serapan asing') : _t('Complete Unit 1 Test to unlock', 'Selesaikan Ujian Unit 1 untuk membuka akses'),
              style: TextStyle(color: unlocked ? Colors.white : (isDark ? Colors.white54 : Colors.black54), fontSize: 15, height: 1.4)
          ),
        ],
      ),
    );
  }

  Widget _buildUnit3HeaderCard(bool isDark, bool unlocked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFF1CB0F6) : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E3DA)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'UNIT 3',
              style: TextStyle(color: unlocked ? Colors.white.withValues(alpha: 0.9) : Colors.grey, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)
          ),
          const SizedBox(height: 8),
          Text(
              _t('BASIC KANJI', 'KANJI DASAR'),
              style: TextStyle(color: unlocked ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontSize: 24, fontWeight: FontWeight.w900)
          ),
          const SizedBox(height: 12),
          Text(
              unlocked ? _t('Master the essential ideograms for N5 level', 'Kuasai ideogram penting untuk level N5') : _t('Complete Unit 2 Test to unlock', 'Selesaikan Ujian Unit 2 untuk membuka akses'),
              style: TextStyle(color: unlocked ? Colors.white : (isDark ? Colors.white54 : Colors.black54), fontSize: 15, height: 1.4)
          ),
        ],
      ),
    );
  }

  Widget _buildUnit4HeaderCard(bool isDark, bool unlocked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFFF4B4B) : (isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E3DA)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'UNIT 4',
              style: TextStyle(color: unlocked ? Colors.white.withValues(alpha: 0.9) : Colors.grey, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)
          ),
          const SizedBox(height: 8),
          Text(
              _t('BASIC GRAMMAR', 'TATA BAHASA DASAR'),
              style: TextStyle(color: unlocked ? Colors.white : (isDark ? Colors.white70 : Colors.black87), fontSize: 24, fontWeight: FontWeight.w900)
          ),
          const SizedBox(height: 12),
          Text(
              unlocked ? _t('Construct sentences with particles and verbs', 'Susun kalimat dengan partikel dan kata kerja') : _t('Complete Unit 3 Test to unlock', 'Selesaikan Ujian Unit 3 untuk membuka akses'),
              style: TextStyle(color: unlocked ? Colors.white : (isDark ? Colors.white54 : Colors.black54), fontSize: 15, height: 1.4)
          ),
        ],
      ),
    );
  }

  void _showNoHeartsDialog() {
    final bool isDark = globalDarkMode.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Column(
          children: [
            const Icon(Icons.favorite_border_rounded, color: Color(0xFFE53935), size: 60),
            const SizedBox(height: 16),
            Text(
              _t('Nyawa Habis!', 'Nyawa Habis!'),
              style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF333333), fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _t(
                'Don\'t give up! Mistakes are the best teachers. Restore your hearts and keep going!',
                'Jangan menyerah! Kesalahan adalah guru terbaik. Pulihkan nyawa dan teruslah belajar!'
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF4B4B4B), height: 1.5, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flash_on, color: Colors.orange, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    "150 XP per Nyawa",
                    style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC6633),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    bool success = await GameManager.buyHeartWithXP();
                    if (!mounted) return;
                    if (success) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_t('Heart restored! Go for it!', 'Nyawa berhasil dipulihkan! Semangat!')),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_t('Not enough XP!', 'XP tidak cukup!'))),
                      );
                    }
                  },
                  child: Text(_t('RESTORE WITH XP', 'BELI DENGAN XP'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  _t('LATER', 'NANTI SAJA'),
                  style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}