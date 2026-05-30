import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_manager.dart';
import 'screen_simulation_test.dart';
import 'simulation_result_screen.dart';
import 'screen_simulation_history.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  bool _isUnlocked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

  void _checkUnlockStatus() {
    final user = Supabase.instance.client.auth.currentUser;
    final meta = user?.userMetadata ?? {};
    setState(() {
      _isUnlocked = meta['unlocked_sim_n5'] ?? false;
      _isLoading = false;
    });
  }

  Future<void> _handleUnlock() async {
    final bool isDark = globalDarkMode.value;
    final Color modalBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);

    // Jika sudah premium atau sudah di-unlock sebelumnya, konfirmasi mulai dengan biaya per sesi
    if (globalIsPremium.value || _isUnlocked) {
      _showStartConfirmation();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: modalBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header dengan Ikon XP
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFCC6633).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC6633),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCC6633).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ]
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  Text(
                    _t("Unlock Simulation", "Buka Simulasi"),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _t(
                      "Get access to the JLPT N5 Mock Exam for 1500 XP. Test your limits!",
                      "Dapatkan akses ke Simulasi Ujian JLPT N5 seharga 1500 XP. Uji kemampuanmu!"
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(_t("CANCEL", "BATAL"), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            if (globalXP.value >= 1500) {
                              globalXP.value -= 1500;
                              await GameManager.syncToCloud();
                              await Supabase.instance.client.auth.updateUser(UserAttributes(data: {'unlocked_sim_n5': true}));
                              setState(() => _isUnlocked = true);
                              _showSuccessUnlock();
                            } else {
                              _showInsufficientXP();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCC6633),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: Text(
                            _t("PAY 1500 XP", "BAYAR 1500 XP"),
                            style: const TextStyle(fontWeight: FontWeight.w900),
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
    );
  }

  Future<void> _showStartConfirmation() async {
    final bool isDark = globalDarkMode.value;
    final Color modalBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
    final int cost = globalIsPremium.value ? 0 : 50;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: modalBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFFCC6633).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC6633),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCC6633).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ]
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                children: [
                  Text(
                    _t("Ready to Start?", "Siap Memulai?"),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _t(
                      "Believe in yourself! You've prepared well for this. Focus and do your best!",
                      "Percayalah pada dirimu sendiri! Kamu sudah bersiap dengan baik. Fokus dan lakukan yang terbaik!"
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 14, height: 1.5),
                  ),
                  if (cost > 0) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC6633).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flash_on_rounded, color: Color(0xFFCC6633), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            _t("Cost: $cost XP", "Biaya: $cost XP"),
                            style: const TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(_t("CANCEL", "BATAL"), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            if (globalXP.value >= cost) {
                              if (cost > 0) {
                                globalXP.value -= cost;
                                await GameManager.syncToCloud();
                              }
                              _startTest();
                            } else {
                              _showInsufficientXP();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCC6633),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                          child: Text(
                            _t("START", "MULAI"),
                            style: const TextStyle(fontWeight: FontWeight.w900),
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
    );
  }

  void _showSuccessUnlock() {
    _showCustomDialog(
      title: _t("Simulation Unlocked!", "Simulasi Terbuka!"),
      message: _t("You now have access to JLPT N5 Simulation. Note: Each attempt costs 50 XP (Free for Premium). 🎉", "Kamu sekarang memiliki akses ke Simulasi JLPT N5. Catatan: Tiap percobaan butuh 50 XP (Gratis untuk Premium). 🎉"),
      icon: Icons.check_circle_outline_rounded,
      iconColor: Colors.green,
    );
  }

  void _showInsufficientXP() {
    _showCustomDialog(
      title: _t("Insufficient XP", "XP Tidak Cukup"),
      message: _t("Keep learning and completing lessons to earn more XP!", "Teruslah belajar dan selesaikan pelajaran untuk mengumpulkan lebih banyak XP!"),
      icon: Icons.error_outline_rounded,
      iconColor: Colors.red,
    );
  }

  void _showCustomDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = globalDarkMode.value;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: iconColor),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF2D2622),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC6633),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startTest() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimulationTestScreen()),
    );
  }

  void _showHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimulationHistoryScreen()),
    );
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFCC6633)));

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2);
        final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
        final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF666666);

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCC6633).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text(
                              "OFFICIAL JLPT N5 STANDARD",
                              style: TextStyle(color: Color(0xFFCC6633), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                          if (_isUnlocked) ...[
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: _showHistory,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCC6633).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFFCC6633).withOpacity(0.2)),
                                  ),
                                  child: const Icon(Icons.history_rounded, color: Color(0xFFCC6633), size: 16),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _t("JLPT N5 Mock Exam", "Simulasi Ujian JLPT N5"),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _t(
                          "Professional simulation covering Language Knowledge and Reading. Test your skills under official timing constraints.",
                          "Simulasi profesional mencakup Pengetahuan Bahasa dan Membaca. Uji kemampuanmu dalam batasan waktu resmi."
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: subTextColor, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 32),

                      _buildExamStructureCard(isDark, textColor, subTextColor),
                      const SizedBox(height: 20),
                      _buildGradingSystemCard(isDark, textColor, subTextColor),
                      const SizedBox(height: 20),
                      _buildOneAttemptCard(isDark, textColor, subTextColor),
                      const SizedBox(height: 32),
                      _buildUnlockButtonSection(subTextColor),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExamStructureCard(bool isDark, Color textColor, Color subTextColor) {
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color sectionColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC6633).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.assignment_rounded, color: Color(0xFFCC6633), size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                _t("Test Modules", "Modul Ujian"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSessionDetail(
            title: _t("Language Knowledge", "Pengetahuan Bahasa"),
            subtitle: "Moji, Goi, Bunpou",
            duration: "25",
            description: _t(
              "Kanji reading, vocabulary context, and grammar particles.",
              "Cara baca Kanji, kosakata sesuai konteks, dan partikel tata bahasa."
            ),
            isDark: isDark,
            textColor: textColor,
            subTextColor: subTextColor,
            bgColor: sectionColor,
          ),
          const SizedBox(height: 16),
          _buildSessionDetail(
            title: _t("Reading", "Membaca"),
            subtitle: "Dokkai",
            duration: "25",
            description: _t(
              "Short sentences, paragraphs, and informational texts.",
              "Kalimat pendek, paragraf, dan teks informasi (email/pengumuman)."
            ),
            isDark: isDark,
            textColor: textColor,
            subTextColor: subTextColor,
            bgColor: sectionColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetail({
    required String title,
    required String subtitle,
    required String duration,
    required String description,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                  Text(subtitle, style: const TextStyle(color: Color(0xFFCC6633), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC6633),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text("$duration mnt", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(color: subTextColor, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildGradingSystemCard(bool isDark, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2D2622),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: const Color(0xFF2D2622).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_rounded, color: Color(0xFFCC6633), size: 24),
              const SizedBox(width: 12),
              Text(
                _t("Grading System", "Sistem Penilaian"),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildGradeStat(_t("MAX SCORE", "SKOR MAKS"), "180", Colors.white),
              Container(width: 1, height: 40, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 24)),
              _buildGradeStat(_t("PASSING GRADE", "BATAS LULUS"), "80", const Color(0xFFCC6633)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _t(
                "Pass criteria: Total score ≥ 80 AND meet minimum sectional standard. Zero score in any section results in failure.",
                "Kriteria lulus: Skor total ≥ 80 DAN memenuhi standar minimum tiap sesi. Skor nol pada sesi mana pun dianggap tidak lulus."
              ),
              style: const TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 28, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildOneAttemptCard(bool isDark, Color textColor, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCC6633).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFCC6633).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.gavel_rounded, color: Color(0xFFCC6633), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t("Strict Exam Rules", "Aturan Ujian Ketat"),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  _t("Continuous timer. No pauses. Result is final.", "Waktu berjalan terus. Tanpa jeda. Hasil bersifat final."),
                  style: TextStyle(fontSize: 12, color: subTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockButtonSection(Color subTextColor) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _handleUnlock,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCC6633),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isUnlocked ? _t("START SIMULATION", "MULAI SIMULASI") : _t("UNLOCK ACCESS", "BUKA AKSES UJIAN"),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
                const SizedBox(width: 12),
                Icon(_isUnlocked ? Icons.play_arrow_rounded : Icons.lock_open_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (!_isUnlocked)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_on_rounded, color: Color(0xFFCC6633), size: 14),
              const SizedBox(width: 4),
              Text(
                _t("Cost: 1500 XP", "Biaya: 1500 XP"),
                style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w500)
              ),
            ],
          ),
      ],
    );
  }
}
