import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/game_manager.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_snackbar.dart';
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

  final List<String> _motivationalMessagesEn = [
    "One step closer to Japan! 🎌",
    "Ganbatte kudasai! You can do it! 🔥",
    "Take a deep breath... Let's collect some XP! ✨",
    "Focus for a moment, let's conquer this! 🚀",
    "A journey of a thousand miles begins with a single step! 🗺️",
  ];

  final List<String> _motivationalMessagesId = [
    "Satu langkah lebih dekat ke Jepang! 🎌",
    "Ganbatte kudasai! Kamu pasti bisa! 🔥",
    "Tarik napas panjang... Ayo kumpulkan XP! ✨",
    "Fokus sejenak, mari taklukkan materi ini! 🚀",
    "Perjalanan seribu mil dimulai dengan satu langkah! 🗺️",
  ];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _u1Hira1Stars = prefs.getInt('u1_hira1_stars') ?? 0; // Default 0 untuk user baru agar tidak "Replay"
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
    // Langsung cadangkan ke Cloud agar tidak hilang saat login ulang
    await GameManager.syncToCloud();
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  IconData _getIconForLevel(String title) {
    final t = title.toLowerCase();
    if (t.contains("basics 1") || t.contains("vowels")) return Icons.abc_rounded;
    if (t.contains("basics 2")) return Icons.text_fields_rounded;
    if (t.contains("greetings")) return Icons.handshake_rounded;
    if (t.contains("numbers")) return Icons.format_list_numbered_rounded;
    if (t.contains("quiz") || t.contains("exam") || t.contains("test") || t.contains("ujian")) return Icons.quiz_rounded;
    return Icons.menu_book_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    final Color borderColor = colorScheme.outline;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Kunci Pembuka Unit 2 & 3 & 4
    bool isUnit2Unlocked = widget.isUnit1Completed || _u1TestCompleted >= 1;
    bool isUnit3Unlocked = _u2TestCompleted >= 1;
    bool isUnit4Unlocked = _u3TestCompleted >= 1;

    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadProgress();
          await GameManager.syncToCloud();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const UnitHeaderCard(),
                const SizedBox(height: 40),

                _buildUnit1(borderColor),

                const SizedBox(height: 40),
                Divider(thickness: 2, color: borderColor),
                const SizedBox(height: 20),

                _buildUnit2(isDark, borderColor, isUnit2Unlocked),

                const SizedBox(height: 40),
                Divider(thickness: 2, color: borderColor),
                const SizedBox(height: 20),

                _buildUnit3(isDark, borderColor, isUnit3Unlocked),

                const SizedBox(height: 40),
                Divider(thickness: 2, color: borderColor),
                const SizedBox(height: 20),

                _buildUnit4(isDark, borderColor, isUnit4Unlocked),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnit1(Color borderColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildClickableNode(context, _t("Hiragana Basics 1", "Hiragana Dasar 1"), _u1Hira1Stars, _u1Hira1Stars >= 3 ? NodeStatus.completed : NodeStatus.current, 1, 'hiragana_1', () {
          setState(() { if (_u1Hira1Stars < 3) { _u1Hira1Stars++; _saveStarProgress('u1_hira1_stars', _u1Hira1Stars); } });
        }),
        _buildVerticalConnector(borderColor, _u1Hira1Stars >= 3 && _u1Hira2Stars >= 3),
        _buildClickableNode(context, _t("Hiragana Basics 2", "Hiragana Dasar 2"), _u1Hira2Stars, _u1Hira2Stars >= 3 ? NodeStatus.completed : (_u1Hira1Stars == 3 ? NodeStatus.current : NodeStatus.locked), 1, 'hiragana_2', () {
          setState(() { if (_u1Hira2Stars < 3) { _u1Hira2Stars++; _saveStarProgress('u1_hira2_stars', _u1Hira2Stars); } });
        }),
        _buildVerticalConnector(borderColor, _u1Hira2Stars >= 3 && _u1Hira3Stars >= 3),
        _buildClickableNode(context, _t("Hiragana Basics 3", "Hiragana Dasar 3"), _u1Hira3Stars, _u1Hira3Stars >= 3 ? NodeStatus.completed : (_u1Hira2Stars == 3 ? NodeStatus.current : NodeStatus.locked), 1, 'hiragana_3', () {
          setState(() { if (_u1Hira3Stars < 3) { _u1Hira3Stars++; _saveStarProgress('u1_hira3_stars', _u1Hira3Stars); } });
        }),
        _buildVerticalConnector(borderColor, _u1Hira3Stars >= 3 && _u1Hira4Stars >= 3),
        _buildClickableNode(context, _t("Hiragana Basics 4", "Hiragana Dasar 4"), _u1Hira4Stars, _u1Hira4Stars >= 3 ? NodeStatus.completed : (_u1Hira3Stars == 3 ? NodeStatus.current : NodeStatus.locked), 1, 'hiragana_4', () {
          setState(() { if (_u1Hira4Stars < 3) { _u1Hira4Stars++; _saveStarProgress('u1_hira4_stars', _u1Hira4Stars); } });
        }),
        _buildVerticalConnector(borderColor, _u1Hira4Stars >= 3 && _u1GreetStars >= 3),
        _buildClickableNode(context, _t("Daily Greetings", "Salam Sehari-hari"), _u1GreetStars, _u1GreetStars >= 3 ? NodeStatus.completed : (_u1Hira4Stars == 3 ? NodeStatus.current : NodeStatus.locked), 1, 'greetings', () {
          setState(() { if (_u1GreetStars < 3) { _u1GreetStars++; _saveStarProgress('u1_greet_stars', _u1GreetStars); } });
        }),
        _buildVerticalConnector(borderColor, _u1GreetStars >= 3 && _u1NumStars >= 3),
        _buildClickableNode(context, _t("Numbers & Time", "Angka & Waktu"), _u1NumStars, _u1NumStars >= 3 ? NodeStatus.completed : (_u1GreetStars == 3 ? NodeStatus.current : NodeStatus.locked), 1, 'numbers', () {
          setState(() { if (_u1NumStars < 3) { _u1NumStars++; _saveStarProgress('u1_num_stars', _u1NumStars); } });
        }),
        _buildVerticalConnector(borderColor, _u1NumStars >= 3 && _u1TestCompleted >= 1),

        _buildClickableNode(
          context, _t("Unit Test\n15 min", "Ujian Unit\n15 mnt"), 0,
          _u1TestCompleted >= 1 ? NodeStatus.completed : (_u1NumStars == 3 ? NodeStatus.current : NodeStatus.locked),
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
      ],
    );
  }

  Widget _buildUnit2(bool isDark, Color borderColor, bool isUnit2Unlocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnitHeaderCard(
          unitNumber: 2,
          titleEn: 'KATAKANA & LOANWORDS',
          titleId: 'KATAKANA & KATA SERAPAN',
          subtitleEn: isUnit2Unlocked
              ? 'Learn the second alphabet system for foreign words'
              : 'Complete Unit 1 Test to unlock',
          subtitleId: isUnit2Unlocked
              ? 'Pelajari sistem alfabet kedua untuk kata serapan asing'
              : 'Selesaikan Ujian Unit 1 untuk membuka akses',
          isUnlocked: isUnit2Unlocked,
        ),
        const SizedBox(height: 40),

        _buildClickableNode(context, _t("Katakana Basics 1", "Katakana Dasar 1"), _u2Kata1Stars, _u2Kata1Stars >= 3 ? NodeStatus.completed : (isUnit2Unlocked ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_1', () {
          setState(() { if (_u2Kata1Stars < 3) { _u2Kata1Stars++; _saveStarProgress('u2_kata1_stars', _u2Kata1Stars); } });
        }, hintEn: "Learn Katakana: A, I, U, E, O, KA, KI, KU, KE, KO, SA, SHI", hintId: "Pelajari Katakana: A, I, U, E, O, KA, KI, KU, KE, KO, SA, SHI"),
        _buildVerticalConnector(borderColor, _u2Kata1Stars >= 3 && _u2Kata2Stars >= 3),
        _buildClickableNode(context, _t("Katakana Basics 2", "Katakana Dasar 2"), _u2Kata2Stars, _u2Kata2Stars >= 3 ? NodeStatus.completed : (_u2Kata1Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_2', () {
          setState(() { if (_u2Kata2Stars < 3) { _u2Kata2Stars++; _saveStarProgress('u2_kata2_stars', _u2Kata2Stars); } });
        }, hintEn: "Learn Katakana: SU, SE, SO, TA, CHI, TSU, TE, TO, NA, NI, NU, NE", hintId: "Pelajari Katakana: SU, SE, SO, TA, CHI, TSU, TE, TO, NA, NI, NU, NE"),
        _buildVerticalConnector(borderColor, _u2Kata2Stars >= 3 && _u2Kata3Stars >= 3),
        _buildClickableNode(context, _t("Katakana Basics 3", "Katakana Dasar 3"), _u2Kata3Stars, _u2Kata3Stars >= 3 ? NodeStatus.completed : (_u2Kata2Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_3', () {
          setState(() { if (_u2Kata3Stars < 3) { _u2Kata3Stars++; _saveStarProgress('u2_kata3_stars', _u2Kata3Stars); } });
        }, hintEn: "Learn Katakana: NO, HA, HI, FU, HE, HO, MA, MI, MU, ME, MO, YA", hintId: "Pelajari Katakana: NO, HA, HI, FU, HE, HO, MA, MI, MU, ME, MO, YA"),
        _buildVerticalConnector(borderColor, _u2Kata3Stars >= 3 && _u2Kata4Stars >= 3),
        _buildClickableNode(context, _t("Katakana Basics 4", "Katakana Dasar 4"), _u2Kata4Stars, _u2Kata4Stars >= 3 ? NodeStatus.completed : (_u2Kata3Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_4', () {
          setState(() { if (_u2Kata4Stars < 3) { _u2Kata4Stars++; _saveStarProgress('u2_kata4_stars', _u2Kata4Stars); } });
        }, hintEn: "Learn Katakana: YU, YO, RA, RI, RU, RE, RO, WA, WO, N, GA, PA", hintId: "Pelajari Katakana: YU, YO, RA, RI, RU, RE, RO, WA, WO, N, GA, PA"),
        _buildVerticalConnector(borderColor, _u2Kata4Stars >= 3 && _u2Words1Stars >= 3),
        _buildClickableNode(context, _t("Katakana Words 1", "Kosakata Katakana 1"), _u2Words1Stars, _u2Words1Stars >= 3 ? NodeStatus.completed : (_u2Kata4Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'katakana_words', () {
          setState(() { if (_u2Words1Stars < 3) { _u2Words1Stars++; _saveStarProgress('u2_words1_stars', _u2Words1Stars); } });
        }, hintEn: "Common Katakana words: Camera, TV, Hotel, Bus, Toilet...", hintId: "Kata Katakana umum: Kamera, TV, Hotel, Bus, Toilet..."),
        _buildVerticalConnector(borderColor, _u2Words1Stars >= 3 && _u2Words2Stars >= 3),
        _buildClickableNode(context, _t("Katakana Words 2", "Kosakata Katakana 2"), _u2Words2Stars, _u2Words2Stars >= 3 ? NodeStatus.completed : (_u2Words1Stars >= 3 ? NodeStatus.current : NodeStatus.locked), 2, 'loanwords', () {
          setState(() { if (_u2Words2Stars < 3) { _u2Words2Stars++; _saveStarProgress('u2_words2_stars', _u2Words2Stars); } });
        }, hintEn: "More loanwords: Restaurant, Supermarket, Department Store, Pizza...", hintId: "Lebih banyak kata serapan: Restoran, Supermarket, Toserba, Pizza..."),
        _buildVerticalConnector(borderColor, _u2Words2Stars >= 3 && _u2TestCompleted >= 1),

        _buildClickableNode(
          context, _t("Unit 2 Test\n15 min", "Ujian Unit 2\n15 mnt"), 0,
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
      ],
    );
  }

  Widget _buildUnit3(bool isDark, Color borderColor, bool isUnit3Unlocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnitHeaderCard(
          unitNumber: 3,
          titleEn: 'BASIC KANJI',
          titleId: 'KANJI DASAR',
          subtitleEn: isUnit3Unlocked
              ? 'Master the essential ideograms for N5 level'
              : 'Complete Unit 2 Test to unlock',
          subtitleId: isUnit3Unlocked
              ? 'Kuasai ideogram penting untuk level N5'
              : 'Selesaikan Ujian Unit 2 untuk membuka akses',
          isUnlocked: isUnit3Unlocked,
        ),
        const SizedBox(height: 40),

        _buildClickableNode(context, _t("Kanji Numbers", "Kanji Angka"), _u3NumStars, _u3NumStars >= 3 ? NodeStatus.completed : (isUnit3Unlocked ? NodeStatus.current : NodeStatus.locked), 3, 'kanji_numbers', () {
          setState(() { if (_u3NumStars < 3) { _u3NumStars++; _saveStarProgress('u3_num_stars', _u3NumStars); } });
        }, hintEn: "Learn Kanji for numbers 1-10, 100, and 1000", hintId: "Pelajari Kanji untuk angka 1-10, 100, dan 1000"),
        _buildVerticalConnector(borderColor, _u3NumStars >= 3 && _u3NatureStars >= 3),
        _buildClickableNode(context, _t("Nature & Elements", "Alam & Elemen"), _u3NatureStars, _u3NatureStars >= 3 ? NodeStatus.completed : (_u3NumStars >= 3 ? NodeStatus.current : NodeStatus.locked), 3, 'kanji_nature', () {
          setState(() { if (_u3NatureStars < 3) { _u3NatureStars++; _saveStarProgress('u3_nature_stars', _u3NatureStars); } });
        }, hintEn: "Kanji for Sun, Moon, Fire, Water, Wood, Gold, Earth, Mountain, River...", hintId: "Kanji untuk Matahari, Bulan, Api, Air, Kayu, Logam, Tanah, Gunung, Sungai..."),
        _buildVerticalConnector(borderColor, _u3NatureStars >= 3 && _u3PeopleStars >= 3),
        _buildClickableNode(context, _t("People & Directions", "Orang & Arah"), _u3PeopleStars, _u3PeopleStars >= 3 ? NodeStatus.completed : (_u3NatureStars >= 3 ? NodeStatus.current : NodeStatus.locked), 3, 'kanji_people', () {
          setState(() { if (_u3PeopleStars < 3) { _u3PeopleStars++; _saveStarProgress('u3_people_stars', _u3PeopleStars); } });
        }, hintEn: "Kanji for Person, Child, Woman, Man, Eye, Mouth, Ear, Hand, Foot...", hintId: "Kanji untuk Orang, Anak, Wanita, Pria, Mata, Mulut, Telinga, Tangan, Kaki..."),
        _buildVerticalConnector(borderColor, _u3PeopleStars >= 3 && _u3TestCompleted >= 1),

        _buildClickableNode(
          context, _t("Unit 3 Test\n15 min", "Ujian Unit 3\n15 mnt"), 0,
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
      ],
    );
  }

  Widget _buildUnit4(bool isDark, Color borderColor, bool isUnit4Unlocked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UnitHeaderCard(
          unitNumber: 4,
          titleEn: 'BASIC GRAMMAR',
          titleId: 'TATA BAHASA DASAR',
          subtitleEn: isUnit4Unlocked
              ? 'Construct sentences with particles and verbs'
              : 'Complete Unit 3 Test to unlock',
          subtitleId: isUnit4Unlocked
              ? 'Susun kalimat dengan partikel dan kata kerja'
              : 'Selesaikan Ujian Unit 3 untuk membuka akses',
          isUnlocked: isUnit4Unlocked,
        ),
        const SizedBox(height: 40),

        _buildClickableNode(context, _t("Basic Particles", "Partikel Dasar"), _u4ParticlesStars, _u4ParticlesStars >= 3 ? NodeStatus.completed : (isUnit4Unlocked ? NodeStatus.current : NodeStatus.locked), 4, 'grammar_particles', () {
          setState(() { if (_u4ParticlesStars < 3) { _u4ParticlesStars++; _saveStarProgress('u4_particles_stars', _u4ParticlesStars); } });
        }, hintEn: "Master essential particles: wa, wo, mo, ni, he, de, to, no, ga...", hintId: "Kuasai partikel penting: wa, wo, mo, ni, he, de, to, no, ga..."),
        _buildVerticalConnector(borderColor, _u4ParticlesStars >= 3 && _u4Verbs1Stars >= 3),
        _buildClickableNode(context, _t("Verb Basics 1", "Kata Kerja 1"), _u4Verbs1Stars, _u4Verbs1Stars >= 3 ? NodeStatus.completed : (_u4ParticlesStars == 3 ? NodeStatus.current : NodeStatus.locked), 4, 'grammar_verbs_1', () {
          setState(() { if (_u4Verbs1Stars < 3) { _u4Verbs1Stars++; _saveStarProgress('u4_verbs1_stars', _u4Verbs1Stars); } });
        }, hintEn: "Common verbs: taberu, nomu, iku, kuru, suru, kau, wakaru...", hintId: "Kata kerja umum: taberu, nomu, iku, kuru, suru, kau, wakaru..."),
        _buildVerticalConnector(borderColor, _u4Verbs1Stars >= 3 && _u4Verbs2Stars >= 3),
        _buildClickableNode(context, _t("Verb Basics 2", "Kata Kerja 2"), _u4Verbs2Stars, _u4Verbs2Stars >= 3 ? NodeStatus.completed : (_u4Verbs1Stars == 3 ? NodeStatus.current : NodeStatus.locked), 4, 'grammar_verbs_2', () {
          setState(() { if (_u4Verbs2Stars < 3) { _u4Verbs2Stars++; _saveStarProgress('u4_verbs2_stars', _u4Verbs2Stars); } });
        }, hintEn: "More verbs: miru, kiku, kaku, yomu, oyogu, matsu, kaeru...", hintId: "Lebih banyak kata kerja: miru, kiku, kaku, yomu, oyogu, matsu, kaeru..."),
        _buildVerticalConnector(borderColor, _u4Verbs2Stars >= 3 && _u4AdjectivesStars >= 3),
        _buildClickableNode(context, _t("Adjectives", "Kata Sifat"), _u4AdjectivesStars, _u4AdjectivesStars >= 3 ? NodeStatus.completed : (_u4Verbs2Stars == 3 ? NodeStatus.current : NodeStatus.locked), 4, 'grammar_adjectives', () {
          setState(() { if (_u4AdjectivesStars < 3) { _u4AdjectivesStars++; _saveStarProgress('u4_adjectives_stars', _u4AdjectivesStars); } });
        }, hintEn: "Common adjectives: oishii, takai, yasui, ookii, chiisai, ii, warui...", hintId: "Kata sifat umum: oishii, takai, yasui, ookii, chiisai, ii, warui..."),
        _buildVerticalConnector(borderColor, _u4AdjectivesStars >= 3 && _u4TestCompleted >= 1),

        _buildClickableNode(
          context, _t("Unit 4 Test\n15 min", "Ujian Unit 4\n15 mnt"), 0,
          _u4TestCompleted >= 1 ? NodeStatus.completed : (_u4AdjectivesStars == 3 ? NodeStatus.current : NodeStatus.locked),
          4, 'test', () {
          setState(() {
            if (_u4TestCompleted == 0) {
              _u4TestCompleted = 1;
              _saveStarProgress('u4_test_stars', 1);
            }
          });
        },
        ),
      ],
    );
  }

  // --- HELPER BUILDER ---
  Widget _buildVerticalConnector(Color color, bool isCompleted) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 28),
      child: Container(
        width: 6,
        height: 35,
        decoration: BoxDecoration(
          color: isCompleted ? colorScheme.primary : color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildClickableNode(BuildContext context, String title, int stars, NodeStatus status, int unit, String diff, VoidCallback onSuccess, {String? hintEn, String? hintId}) {
    final bool isTestNode = title.toLowerCase().contains('test') || title.toLowerCase().contains('ujian');

    return ValueListenableBuilder<int>(
      valueListenable: globalHearts,
      builder: (context, currentHearts, _) {
        return GestureDetector(
          onTap: (status == NodeStatus.locked || (status == NodeStatus.completed && (stars >= 3 || isTestNode)))
              ? null
              : () {
            if (currentHearts <= 0) { _showNoHeartsDialog(); return; }
            _showMotivationalPopup(
              context: context,
              title: title,
              onStart: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseScreen(
                  unit: unit, 
                  difficulty: diff, 
                  currentStars: stars, 
                  currentHearts: currentHearts, 
                  onQuizPassed: onSuccess,
                  isReplay: status == NodeStatus.completed,
                  hint: globalLanguage.value == 'id' ? hintId : hintEn,
                )));
              },
            );
          },
          child: PathNode(
            title: title, 
            status: status, 
            stars: stars, 
            alignment: Alignment.centerLeft, 
            icon: _getIconForLevel(title),
            onReplaySelected: (selectedStarIndex) {
              if (currentHearts <= 0) { _showNoHeartsDialog(); return; }
              _showMotivationalPopup(
                context: context,
                title: title,
                onStart: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExerciseScreen(
                    unit: unit, 
                    difficulty: diff, 
                    currentStars: selectedStarIndex,
                    currentHearts: currentHearts,
                    onQuizPassed: onSuccess,
                    isReplay: true,
                    hint: globalLanguage.value == 'id' ? hintId : hintEn,
                  )));
                },
              );
            },
          ),
        );
      }
    );
  }

  void _showMotivationalPopup({
    required BuildContext context,
    required String title,
    required VoidCallback onStart,
  }) {
    final bool isId = globalLanguage.value == 'id';
    final List<String> messages =
        isId ? _motivationalMessagesId : _motivationalMessagesEn;
    final String randomMessage = messages[Random().nextInt(messages.length)];
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        backgroundColor: colorScheme.surface,
        title: Column(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: colorScheme.primary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          randomMessage,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _t('CANCEL', 'BATAL'),
                  variant: AppButtonVariant.text,
                  height: 48,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton(
                  label: _t('START', 'MULAI'),
                  height: 48,
                  borderRadius: AppSpacing.radiusMd,
                  onPressed: () {
                    Navigator.pop(context);
                    onStart();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNoHeartsDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        backgroundColor: colorScheme.surface,
        title: Column(
          children: [
            const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.heartCrimson,
              size: 60,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _t('Out of Hearts!', 'Nyawa Habis!'),
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
                'Don\'t give up! Mistakes are the best teachers. Restore your hearts and keep going!',
                'Jangan menyerah! Kesalahan adalah guru terbaik. Pulihkan nyawa dan teruslah belajar!',
              ),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.streakFlame.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.flash_on,
                    color: AppColors.streakFlame,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _t("150 XP per Heart", "150 XP per Nyawa"),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.streakFlame,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        actions: [
          Column(
            children: [
              AppButton(
                label: _t('RESTORE WITH XP', 'BELI DENGAN XP'),
                height: 50,
                borderRadius: AppSpacing.radiusMd,
                onPressed: () async {
                  final bool success = await GameManager.buyHeartWithXP();
                  if (!context.mounted) return;
                  if (success) {
                    Navigator.pop(context);
                    AppSnackbar.showSuccess(
                      context,
                      _t(
                        'Heart restored! Go for it!',
                        'Nyawa berhasil dipulihkan! Semangat!',
                      ),
                    );
                  } else {
                    AppSnackbar.showError(
                      context,
                      _t('Not enough XP!', 'XP tidak cukup!'),
                    );
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: _t('LATER', 'NANTI SAJA'),
                variant: AppButtonVariant.text,
                height: 48,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
