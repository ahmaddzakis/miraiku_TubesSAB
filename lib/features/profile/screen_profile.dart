import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/game_manager.dart';
import 'screen_notifications.dart';
import 'screen_settings.dart';

class _AchievementBadge {
  final String text;
  final bool isLabel;
  _AchievementBadge._(this.text, this.isLabel);
  factory _AchievementBadge.text(String t) => _AchievementBadge._(t, false);
  factory _AchievementBadge.label(String t) => _AchievementBadge._(t, true);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;

  // Metadata User
  String _userName = 'MIRAIku User';
  String _userDesc = 'Semangat Belajar Bahasa Jepang!';
  String _userEmail = 'miraiku@example.com';

  // Local Statistics
  bool _isDailyClaimedToday = false;

  // Achievements Status
  bool _claimedHiragana = false;
  bool _claimedKatakana = false;
  bool _claimedKanji = false;
  bool _claimedAlphabetMaster = false;
  bool _claimedSim = false;
  bool _claimed3Days = false;
  bool _claimed7Days = false;
  bool _claimed14Days = false;
  bool _claimed30Days = false;
  bool _claimedMirai = false;

  late SharedPreferences prefs;
  bool _isPrefsInitialized = false;
  String _appVersion = "...";

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _initAppVersion();
  }

  Future<void> _initAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = info.version;
      });
    }
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    await _loadLocalStats();
    _loadSupabaseUserData();
    setState(() {
      _isPrefsInitialized = true;
    });
  }

  void _loadSupabaseUserData() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata;
      if (meta != null) {
        setState(() {
          _userName = meta['display_name'] ?? 'MIRAIku User';
          _userDesc = meta['bio'] ?? 'Semangat Belajar Bahasa Jepang!';
          globalAvatarUrl.value = meta['avatar_url'] ?? '';
          _userEmail = user.email ?? 'miraiku@example.com';

          // Achievements from metadata
          _claimedHiragana = meta['ach_hira'] ?? false;
          _claimedKatakana = meta['ach_kata'] ?? false;
          _claimedKanji = meta['ach_kanji'] ?? false;
          _claimedAlphabetMaster = meta['ach_alphabet'] ?? false;
          _claimedSim = meta['ach_sim'] ?? false;
          _claimed3Days = meta['ach_3d'] ?? false;
          _claimed7Days = meta['ach_7d'] ?? false;
          _claimed14Days = meta['ach_14d'] ?? false;
          _claimed30Days = meta['ach_30d'] ?? false;
          _claimedMirai = meta['ach_mirai'] ?? false;

          // Cek tanggal klaim harian dari Cloud Supabase (Anti-Cheat)
          final String today = DateTime.now().toIso8601String().substring(0, 10);
          final String? cloudLastClaim = meta['gm_last_daily_claim'];

          if (cloudLastClaim == today) {
            _isDailyClaimedToday = true;
            prefs.setString('gm_last_daily_claim', today); // Sinkronisasi ke lokal
          }
        });
      }
    }
  }

  Future<void> _loadLocalStats() async {
    // Gunakan format standar internasional YYYY-MM-DD
    final String today = DateTime.now().toIso8601String().substring(0, 10);
    final lastClaim = prefs.getString('gm_last_daily_claim');

    setState(() {
      _isDailyClaimedToday = (lastClaim == today);
    });
  }

  Future<void> _claimDailyReward() async {
    if (_isDailyClaimedToday) {
      if (mounted) {
        _showErrorDialog(
            _t("Already Claimed", "Sudah Diklaim"),
            _t("Come back tomorrow for more rewards!", "Kembali lagi besok untuk hadiah lainnya!")
        );
      }
      return;
    }

    final String today = DateTime.now().toIso8601String().substring(0, 10);

    // Manual update XP and prefs ke lokal
    globalXP.value += 50;
    await prefs.setInt('gm_xp', globalXP.value);
    await prefs.setString('gm_last_daily_claim', today);

    // Kirim satu request saja untuk cegah rate limit
    try {
      await _supabase.auth.updateUser(UserAttributes(data: {
        'gm_xp': globalXP.value,
        'gm_last_daily_claim': today,
      }));
    } catch (e) {
      debugPrint("Gagal update daily claim ke Supabase: $e");
    }

    setState(() {
      _isDailyClaimedToday = true;
    });

    if (mounted) {
      _showSuccessDialog(_t("Daily Reward: +50 XP!", "Hadiah Harian: +50 XP!"));
    }
  }

  Future<void> _claimAchievement(String key) async {
    final meta = _supabase.auth.currentUser?.userMetadata;
    if (meta != null && meta[key] == true) return;

    try {
      // 1. Eksekusi penambah XP dan simpan ke lokal untuk mencegah rate limit supabase
      globalXP.value += 200;
      await prefs.setInt('gm_xp', globalXP.value);

      // 2. Update status achievement & XP sekaligus di backend
      final response = await _supabase.auth.updateUser(UserAttributes(data: {
        'gm_xp': globalXP.value,
        key: true,
      }));

      // 3. Update state UI
      if (response.user != null) {
        final newMeta = response.user!.userMetadata;
        if (newMeta != null) {
          setState(() {
            _claimedHiragana = newMeta['ach_hira'] ?? false;
            _claimedKatakana = newMeta['ach_kata'] ?? false;
            _claimedKanji = newMeta['ach_kanji'] ?? false;
            _claimedAlphabetMaster = newMeta['ach_alphabet'] ?? false;
            _claimedSim = newMeta['ach_sim'] ?? false;
            _claimed3Days = newMeta['ach_3d'] ?? false;
            _claimed7Days = newMeta['ach_7d'] ?? false;
            _claimed14Days = newMeta['ach_14d'] ?? false;
            _claimed30Days = newMeta['ach_30d'] ?? false;
            _claimedMirai = newMeta['ach_mirai'] ?? false;
          });
        }
      }

      if (mounted) {
        _showSuccessDialog(_t("Achievement Claimed! +200 XP", "Pencapaian Diklaim! +200 XP"));
      }
    } catch (e) {
      if (mounted) _showErrorDialog(_t("Claim Failed", "Gagal Klaim"), e.toString());
    }
  }

  void _showAchievementDetailDialog({
    required String title,
    required String description,
    required _AchievementBadge badge,
    required Color accentColor,
    required bool isCompleted,
    required bool isClaimed,
    VoidCallback? onClaim,
  }) {
    final isDark = globalDarkMode.value;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge.text,
                  style: TextStyle(
                    fontSize: badge.isLabel ? 18 : 32,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : const Color(0xFF666666),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (isClaimed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFFCC6633), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _t("CLAIMED", "SUDAH DIKLAIM"),
                      style: const TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              )
            else if (isCompleted)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC6633),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onClaim != null) onClaim();
                  },
                  child: Text(
                    _t("CLAIM 200 XP", "KLAIM 200 XP"),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    _t("CLOSE", "TUTUP"),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, color: Color(0xFFE53935), size: 40),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF333333))),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFFFF1EB), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFFCC6633), size: 40),
            ),
            const SizedBox(height: 20),
            Text(_t("Success", "Berhasil"), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF333333))),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                onPressed: () => Navigator.pop(context),
                child: Text(_t("OK", "MANTAP!"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getAvatarImage(String url) {
    if (url.isNotEmpty && url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return const AssetImage('assets/images/iconUtama.png');
    }
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  void _showAboutApp(BuildContext context) {
    final isDark = globalDarkMode.value;
    showAboutDialog(
      context: context,
      applicationName: "MIRAIku",
      applicationVersion: _appVersion,
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFF1EFE8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Image.asset('assets/images/iconUtama.png', width: 48, height: 48),
      ),
      children: [
        const SizedBox(height: 16),
        Text(
          _t(
            "MIRAIku is an interactive Japanese language learning platform designed to help users efficiently master Hiragana, Katakana, and essential vocabulary. Built with engaging gamification elements, MIRAIku makes the journey to Japanese fluency enjoyable, structured, and effective.",
            "MIRAIku adalah platform pembelajaran bahasa Jepang interaktif yang dirancang untuk membantu pengguna menguasai Hiragana, Katakana, dan kosakata penting secara efisien. Dibangun dengan elemen gamifikasi yang menarik, MIRAIku membuat perjalanan menuju kemahiran bahasa Jepang menjadi menyenangkan, terstruktur, dan efektif."
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFCC6633).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFCC6633).withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: Color(0xFFCC6633),
              ),
              const SizedBox(width: 12),
              Text(
                _t("Developed by Ahmad Dzaki", "Dikembangkan oleh Ahmad Dzaki"),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFCC6633),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPrefsInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
        final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final Color textColor = isDark ? Colors.white : const Color(0xFF333333);
        final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF8C8A87);
        final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);

        // LOCAL STATS
        final int simulationCount = prefs.getInt('simulation_completed_count') ?? 0;
        final bool isUnit1Finished = (prefs.getInt('u1_test_stars') ?? 0) >= 1;
        final bool isUnit2Finished = (prefs.getInt('u2_test_stars') ?? 0) >= 1;
        final bool isUnit3Finished = (prefs.getInt('u3_test_stars') ?? 0) >= 1;
        final bool isUnit4Finished = (prefs.getInt('u4_test_stars') ?? 0) >= 1;
        final bool isAllUnitsFinished = isUnit1Finished && isUnit2Finished && isUnit3Finished && isUnit4Finished;

        final int claimedCount = [
          _claimedHiragana, _claimedKatakana, _claimedKanji, _claimedAlphabetMaster,
          _claimedSim, _claimed3Days, _claimed7Days, _claimed14Days, _claimed30Days, _claimedMirai
        ].where((c) => c).length;

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                _loadSupabaseUserData();
                await _loadLocalStats();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // PROFILE HEADER
                    Center(
                      child: ValueListenableBuilder<String>(
                        valueListenable: globalAvatarUrl,
                        builder: (context, avatarUrl, _) {
                          return Stack(
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFCC6633), width: 3),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: cardColor,
                                    backgroundImage: _getAvatarImage(avatarUrl),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(_userName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor)),
                    const SizedBox(height: 8),
                    Text(_userDesc, style: TextStyle(fontSize: 14, color: subTextColor, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(_userEmail, style: TextStyle(fontSize: 14, color: subTextColor.withValues(alpha: 0.6))),

                    const SizedBox(height: 32),

                    // DAILY LOGIN REWARDS CARD
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: _claimDailyReward,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: _isDailyClaimedToday ? borderColor : const Color(0xFFCC6633),
                              width: _isDailyClaimedToday ? 1 : 2.5,
                            ),
                            boxShadow: _isDailyClaimedToday ? [] : [
                              BoxShadow(
                                color: const Color(0xFFCC6633).withValues(alpha: 0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: (_isDailyClaimedToday ? subTextColor : const Color(0xFFCC6633)).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                    _isDailyClaimedToday ? Icons.check_circle_rounded : Icons.card_giftcard_rounded,
                                    color: _isDailyClaimedToday ? subTextColor : const Color(0xFFCC6633),
                                    size: 32
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_t("Daily Login Rewards", "Hadiah Login Harian"), style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          _isDailyClaimedToday ? _t("Already Claimed", "Sudah Diklaim") : "50",
                                          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900),
                                        ),
                                        if (!_isDailyClaimedToday) ...[
                                          const SizedBox(width: 6),
                                          const Icon(Icons.flash_on, color: Color(0xFFCC6633), size: 22),
                                          const SizedBox(width: 2),
                                          const Text("XP", style: TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.w900, fontSize: 16)),
                                        ]
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ACHIEVEMENTS SECTION
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_t("Achievements", "Pencapaian"), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCC6633).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.emoji_events_rounded, color: Color(0xFFCC6633), size: 16),
                                    const SizedBox(width: 4),
                                    Text("$claimedCount / 10", style: const TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ValueListenableBuilder<List<String>>(
                            valueListenable: globalLearnedHiragana,
                            builder: (context, learnedHira, _) {
                              return ValueListenableBuilder<List<String>>(
                                valueListenable: globalLearnedKatakana,
                                builder: (context, learnedKata, _) {
                                  return ValueListenableBuilder<List<String>>(
                                    valueListenable: globalLearnedKanji,
                                    builder: (context, learnedKanji, _) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        child: Row(
                                          children: [
                                            _buildAchievementCardH(
                                              badge: _AchievementBadge.text("あ"),
                                              bgColor: const Color(0xFFE8F5E9),
                                              accentColor: const Color(0xFFCC6633),
                                              title: _t("Hiragana Master", "Ahli Hiragana"),
                                              description: _t(
                                                  "Learn all 104 basic Hiragana characters by completing Hiragana lessons.",
                                                  "Pelajari semua 104 karakter Hiragana dasar dengan menyelesaikan pelajaran Hiragana."
                                              ),
                                              progress: (learnedHira.length / 104).clamp(0.0, 1.0),
                                              progressLabel: "${learnedHira.length}/104",
                                              isCompleted: learnedHira.length >= 104,
                                              isClaimed: _claimedHiragana,
                                              onClaim: () => _claimAchievement('ach_hira'),
                                              cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                            ),
                                            _buildAchievementCardH(
                                              badge: _AchievementBadge.text("ア"),
                                              bgColor: const Color(0xFFE3F2FD),
                                              accentColor: const Color(0xFF2196F3),
                                              title: _t("Katakana Master", "Ahli Katakana"),
                                              description: _t(
                                                  "Learn all 104 basic Katakana characters by completing Katakana lessons.",
                                                  "Pelajari semua 104 karakter Katakana dasar dengan menyelesaikan pelajaran Katakana."
                                              ),
                                              progress: (learnedKata.length / 104).clamp(0.0, 1.0),
                                              progressLabel: "${learnedKata.length}/104",
                                              isCompleted: learnedKata.length >= 104,
                                              isClaimed: _claimedKatakana,
                                              onClaim: () => _claimAchievement('ach_kata'),
                                              cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                            ),
                                            _buildAchievementCardH(
                                              badge: _AchievementBadge.text("漢"),
                                              bgColor: const Color(0xFFF3E5F5),
                                              accentColor: const Color(0xFF9C27B0),
                                              title: _t("Kanji Learner", "Pembelajar Kanji"),
                                              description: _t(
                                                  "Learn all 68 essential N5 Kanji characters across all categories.",
                                                  "Pelajari seluruh 68 karakter Kanji N5 penting di semua kategori."
                                              ),
                                              progress: (learnedKanji.length / 68).clamp(0.0, 1.0),
                                              progressLabel: "${learnedKanji.length}/68",
                                              isCompleted: learnedKanji.length >= 68,
                                              isClaimed: _claimedKanji,
                                              onClaim: () => _claimAchievement('ach_kanji'),
                                              cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                            ),
                                            _buildAchievementCardH(
                                              badge: _AchievementBadge.label("ABC"),
                                              bgColor: const Color(0xFFEFEBE9),
                                              accentColor: const Color(0xFF795548),
                                              title: _t("Alphabet Master", "Penguasa Alfabet"),
                                              description: _t(
                                                  "Master all Japanese writing systems by claiming Hiragana, Katakana, and Kanji achievements.",
                                                  "Kuasai semua sistem penulisan Jepang dengan mengklaim pencapaian Hiragana, Katakana, dan Kanji."
                                              ),
                                              progress: (_claimedHiragana && _claimedKatakana && _claimedKanji) ? 1.0 : 0.0,
                                              progressLabel: "HiraKataKanji",
                                              isCompleted: _claimedHiragana && _claimedKatakana && _claimedKanji,
                                              isClaimed: _claimedAlphabetMaster,
                                              onClaim: () => _claimAchievement('ach_alphabet'),
                                              cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                            ),
                                            _buildAchievementCardH(
                                              badge: _AchievementBadge.label("JLPT"),
                                              bgColor: const Color(0xFFFFF3E0),
                                              accentColor: const Color(0xFFFF9800),
                                              title: _t("Simulator Pro", "Pro Simulator"),
                                              description: _t(
                                                  "Put your skills to the test! Complete 10 writing and recognition simulations.",
                                                  "Uji kemampuanmu! Selesaikan 10 simulasi penulisan dan pengenalan."
                                              ),
                                              progress: (simulationCount / 10).clamp(0.0, 1.0),
                                              progressLabel: "$simulationCount/10",
                                              isCompleted: simulationCount >= 10,
                                              isClaimed: _claimedSim,
                                              onClaim: () => _claimAchievement('ach_sim'),
                                              cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                            ),
                                            ValueListenableBuilder<int>(
                                              valueListenable: globalStreak,
                                              builder: (context, streak, _) {
                                                return Row(
                                                  children: [
                                                    _buildAchievementCardH(
                                                      badge: _AchievementBadge.label("3"),
                                                      bgColor: const Color(0xFFFCE4EC),
                                                      accentColor: const Color(0xFFE91E63),
                                                      title: _t("3 Days Streak", "3 Hari Beruntun"),
                                                      description: _t(
                                                          "Keep your learning momentum! Maintain a login streak for 3 consecutive days.",
                                                          "Kasu momentum belajarmu! Pertahankan login selama 3 hari berturut-turut."
                                                      ),
                                                      progress: (streak / 3).clamp(0.0, 1.0),
                                                      progressLabel: "$streak/3",
                                                      isCompleted: streak >= 3,
                                                      isClaimed: _claimed3Days,
                                                      onClaim: () => _claimAchievement('ach_3d'),
                                                      cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                                    ),
                                                    _buildAchievementCardH(
                                                      badge: _AchievementBadge.label("7"),
                                                      bgColor: const Color(0xFFFCE4EC),
                                                      accentColor: const Color(0xFFE91E63),
                                                      title: _t("7 Days Streak", "7 Hari Beruntun"),
                                                      description: _t(
                                                          "Keep your learning momentum! Maintain a login streak for 7 consecutive days.",
                                                          "Kasu momentum belajarmu! Pertahankan login selama 7 hari berturut-turut."
                                                      ),
                                                      progress: (streak / 7).clamp(0.0, 1.0),
                                                      progressLabel: "$streak/7",
                                                      isCompleted: streak >= 7,
                                                      isClaimed: _claimed7Days,
                                                      onClaim: () => _claimAchievement('ach_7d'),
                                                      cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                                    ),
                                                    _buildAchievementCardH(
                                                      badge: _AchievementBadge.label("14"),
                                                      bgColor: const Color(0xFFFCE4EC),
                                                      accentColor: const Color(0xFFE91E63),
                                                      title: _t("14 Days Streak", "14 Hari Beruntun"),
                                                      description: _t(
                                                          "Keep your learning momentum! Maintain a login streak for 14 consecutive days.",
                                                          "Kasu momentum belajarmu! Pertahankan login selama 14 hari berturut-turut."
                                                      ),
                                                      progress: (streak / 14).clamp(0.0, 1.0),
                                                      progressLabel: "$streak/14",
                                                      isCompleted: streak >= 14,
                                                      isClaimed: _claimed14Days,
                                                      onClaim: () => _claimAchievement('ach_14d'),
                                                      cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                                    ),
                                                    _buildAchievementCardH(
                                                      badge: _AchievementBadge.label("30"),
                                                      bgColor: const Color(0xFFFCE4EC),
                                                      accentColor: const Color(0xFFE91E63),
                                                      title: _t("30 Days Streak", "30 Hari Beruntun"),
                                                      description: _t(
                                                          "Keep your learning momentum! Maintain a login streak for 30 consecutive days.",
                                                          "Kasu momentum belajarmu! Pertahankan login selama 30 hari berturut-turut."
                                                      ),
                                                      progress: (streak / 30).clamp(0.0, 1.0),
                                                      progressLabel: "$streak/30",
                                                      isCompleted: streak >= 30,
                                                      isClaimed: _claimed30Days,
                                                      onClaim: () => _claimAchievement('ach_30d'),
                                                      cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                                    ),
                                                  ],
                                                );
                                              }
                                            ),
                                            _buildAchievementCardH(
                                              badge: _AchievementBadge.label("未来"),
                                              bgColor: const Color(0xFFFCE4EC),
                                              accentColor: const Color(0xFFE91E63),
                                              title: _t("Mirai", "Mirai"),
                                              description: _t(
                                                  "The ultimate goal! Complete all level tests from Unit 1 to Unit 4.",
                                                  "Tujuan akhir! Selesaikan semua ujian level dari Unit 1 hingga Unit 4."
                                              ),
                                              progress: isAllUnitsFinished ? 1.0 : 0.0,
                                              progressLabel: isAllUnitsFinished ? "COMPLETED" : "Unit 1-4",
                                              isCompleted: isAllUnitsFinished,
                                              isClaimed: _claimedMirai,
                                              onClaim: () => _claimAchievement('ach_mirai'),
                                              cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  );
                                }
                              );
                            }
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // MENU OPTIONS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: borderColor)
                        ),
                        child: Column(
                          children: [
                            _buildMenuTile(
                                context: context,
                                icon: Icons.settings_rounded,
                                title: _t("Settings", "Pengaturan"),
                                subtitle: _t("Manage your account preferences", "Kelola preferensi akunmu"),
                                textColor: textColor,
                                subTextColor: subTextColor,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                                isDark: isDark
                            ),
                            Divider(height: 1, color: borderColor, indent: 70),
                            _buildMenuTile(
                                context: context,
                                icon: Icons.notifications_rounded,
                                title: _t("Notifications", "Notifikasi"),
                                subtitle: _t("Daily reminders & info", "Pengingat harian & info"),
                                textColor: textColor,
                                subTextColor: subTextColor,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                                isDark: isDark
                            ),
                            Divider(height: 1, color: borderColor, indent: 70),
                            _buildMenuTile(
                                context: context,
                                icon: Icons.info_outline_rounded,
                                title: _t("About", "Tentang"),
                                subtitle: _t("Learn more about MIRAIku", "Pelajari lebih lanjut tentang MIRAIku"),
                                textColor: textColor,
                                subTextColor: subTextColor,
                                onTap: () => _showAboutApp(context),
                                isDark: isDark
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // LOGOUT AS DISTINCT ACTION
                    Center(
                      child: TextButton(
                        onPressed: () => _showLogoutConfirmation(context, isDark),
                        child: Text(
                          _t("LOGOUT", "KELUAR"),
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // VERSION FOOTER
                    Center(
                      child: Text(
                        "MIRAIku Version $_appVersion",
                        style: TextStyle(
                          fontSize: 12,
                          color: subTextColor.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementCardH({
    required _AchievementBadge badge,
    required Color bgColor,
    required Color accentColor,
    required String title,
    required String description,
    required double progress,
    String? progressLabel,
    bool isCompleted = false,
    bool isClaimed = false,
    VoidCallback? onClaim,
    required Color cardColor,
    required Color textColor,
    required Color borderColor,
    required bool isDark,
    required Color subTextColor,
  }) {
    Widget bottomWidget;
    if (isClaimed) {
      bottomWidget = Row(children: [
        const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFFCC6633)),
        const SizedBox(width: 4),
        Text(_t("Already Claimed", "Sudah Diklaim"), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFCC6633)))
      ]);
    } else if (isCompleted) {
      bottomWidget = Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(color: const Color(0xFFCC6633), borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text("KLAIM 200 XP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white))),
      );
    } else {
      bottomWidget = Text(progressLabel ?? "", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subTextColor));
    }

    return GestureDetector(
      onTap: () => _showAchievementDetailDialog(
        title: title,
        description: description,
        badge: badge,
        accentColor: accentColor,
        isCompleted: isCompleted,
        isClaimed: isClaimed,
        onClaim: onClaim,
      ),
      child: Container(
          width: 150,
          height: 240,
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: isCompleted && !isClaimed ? const Color(0xFFCC6633).withValues(alpha: 0.5) : borderColor,
                width: isCompleted && !isClaimed ? 2 : 1
            ),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF333333) : const Color(0xFFF1EFE8),
                      shape: BoxShape.circle
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                          badge.text,
                          style: TextStyle(
                              fontSize: badge.isLabel ? 14 : 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white38 : Colors.black26
                          )
                      ),
                      if (isCompleted)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Color(0xFFCC6633), shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textColor, height: 1.1)
                ),
                const Spacer(),
                ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFF1EFE8),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCC6633))
                    )
                ),
                const SizedBox(height: 12),
                bottomWidget
              ]
          )
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subTextColor,
    required VoidCallback onTap,
    String? trailingText,
    required bool isDark,
  }) {
    final Color iconBg = isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F5F5);
    const Color primaryColor = Color(0xFFCC6633);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subTextColor, fontWeight: FontWeight.w500)),
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8C8A87)),
            )
          : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFB5B0A8)),
      onTap: trailingText != null ? null : onTap,
    );
  }

  void _showLogoutConfirmation(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(_t("Logout?", "Keluar?"), style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
        content: Text(_t("Are you sure you want to sign out?", "Apakah anda yakin ingin keluar dari akun?"), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t("CANCEL", "BATAL"), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              try {
                // 1. Reset local progress before sign out to prevent data leakage
                await GameManager.resetProgress();
                
                // 2. Sign out from Supabase (this will trigger AuthStateChange listener in main.dart)
                await _supabase.auth.signOut();
                
                // 3. Pop the dialog if still mounted
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                debugPrint("Error during logout: $e");
                if (context.mounted) {
                  Navigator.pop(context);
                  _showErrorDialog(_t("Logout Failed", "Gagal Keluar"), e.toString());
                }
              }
            },
            child: Text(_t("LOGOUT", "KELUAR"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
