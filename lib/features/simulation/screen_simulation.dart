
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_manager.dart';
import '../../core/widgets/app_snackbar.dart';
import 'screen_simulation_test.dart';

import 'screen_simulation_history.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  bool _isUnlocked = false;
  bool _isLoading = true;
  bool _isProcessing = false;

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

  Future<void> _handleSimulationAction() async {
    if (_isProcessing) return;

    if (!_isUnlocked) {
      setState(() => _isProcessing = true);
      try {
        // --- LOGIC: ONE-TIME UNLOCK (1500 XP) ---
        if (globalXP.value < 1500) {
          AppSnackbar.showError(
            context,
            _t("Not enough XP to unlock the simulation.", "XP tidak cukup untuk membuka simulasi.")
          );
          return;
        }

        // Deduct and Update Cloud Metadata
        bool success = await GameManager.spendXP(1500, extraData: {'unlocked_sim_n5': true});
        
        if (success) {
          setState(() => _isUnlocked = true);
          if (mounted) {
            AppSnackbar.showSuccess(
              context,
              _t("Simulation unlocked! Now you can start the exam for 100 XP.", "Simulasi terbuka! Sekarang kamu bisa memulai ujian seharga 100 XP.")
            );
          }
        }
      } catch (e) {
        if (mounted) AppSnackbar.showError(context, _t("Error: $e", "Kesalahan: $e"));
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    } else {
      // --- LOGIC: START EXAM WITH CONFIRMATION (100 XP) ---
      if (globalXP.value < 100) {
        AppSnackbar.showError(
          context,
          _t("Not enough XP to start the exam.", "XP tidak cukup untuk memulai ujian.")
        );
        return;
      }

      _showStartConfirmation();
    }
  }

  void _showStartConfirmation() {
    final isDark = globalDarkMode.value;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _t("Ready to Start?", "Siap untuk Mulai?"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF2D2622),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _t(
                        "Believe in yourself! You've prepared well for this. Focus and do your best!",
                        "Percayalah pada dirimu sendiri! Kamu sudah bersiap dengan baik. Fokus dan lakukan yang terbaik!"
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCC6633).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt_rounded, color: Color(0xFFCC6633), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _t("Cost: 100 XP", "Biaya: 100 XP"),
                            style: const TextStyle(
                              color: Color(0xFFCC6633),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                              ),
                            ),
                            child: Text(
                              _t("CANCEL", "BATAL"),
                              style: TextStyle(
                                color: isDark ? Colors.white60 : Colors.black45,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(dialogContext);
                              setState(() => _isProcessing = true);
                              
                              try {
                                bool success = await GameManager.spendXP(100);

                                if (success && mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SimulationTestScreen()),
                                  );
                                } else if (!success && mounted) {
                                  AppSnackbar.showError(
                                    context,
                                    _t("Not enough XP to start the exam.", "XP tidak cukup untuk memulai ujian.")
                                  );
                                }
                              } catch (e) {
                                if (mounted) AppSnackbar.showError(context, _t("Error: $e", "Kesalahan: $e"));
                              } finally {
                                if (mounted) setState(() => _isProcessing = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCC6633),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: Text(
                              _t("START", "MULAI"),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -42,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC6633),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFCC6633).withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      )
                    ],
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 42),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLatestHistory() {
    final history = globalSimulationHistory.value;
    if (history.isEmpty) {
      _showCustomDialog(
        title: _t("No History", "Tidak Ada Riwayat"),
        message: _t("You haven't completed any simulations yet.", "Kamu belum menyelesaikan simulasi apa pun."),
        icon: Icons.history_rounded,
        iconColor: Colors.grey,
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimulationHistoryScreen(),
      ),
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
                  color: iconColor.withValues(alpha: 0.1),
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
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFFCC6633)));

    final media = MediaQuery.of(context);
    final double scale = _getScale(context);
    final bool isTablet = media.size.width > 600;

    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAF7F2);
        final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
        final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF666666);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                _checkUnlockStatus();
                await GameManager.syncToCloud();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.0),
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCC6633).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  "OFFICIAL JLPT N5 STANDARD",
                                  style: TextStyle(color: const Color(0xFFCC6633), fontSize: 10 * scale, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ),
                              if (_isUnlocked) ...[
                                const SizedBox(width: 8),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(100),
                                    onTap: _showLatestHistory,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFFCC6633).withValues(alpha: 0.2)),
                                      ),
                                      child: Icon(Icons.history_rounded, color: const Color(0xFFCC6633), size: 16 * scale),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 16 * scale),
                          Text(
                            _t("JLPT N5 Mock Exam", "Simulasi Ujian JLPT N5"),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28 * scale, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
                          ),
                          SizedBox(height: 12 * scale),
                          Text(
                            _t(
                              "Professional simulation covering Language Knowledge and Reading. Test your skills under official timing constraints.",
                              "Simulasi profesional mencakup Pengetahuan Bahasa dan Membaca. Uji kemampuanmu dalam batasan waktu resmi."
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: subTextColor, fontSize: 14 * scale, height: 1.5),
                          ),
                          SizedBox(height: 32 * scale),

                          if (isTablet)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildExamStructureCard(isDark, textColor, subTextColor, scale)),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    children: [
                                      _buildGradingSystemCard(isDark, textColor, subTextColor, scale),
                                      const SizedBox(height: 20),
                                      _buildOneAttemptCard(isDark, textColor, subTextColor, scale),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildExamStructureCard(isDark, textColor, subTextColor, scale),
                            const SizedBox(height: 20),
                            _buildGradingSystemCard(isDark, textColor, subTextColor, scale),
                            const SizedBox(height: 20),
                            _buildOneAttemptCard(isDark, textColor, subTextColor, scale),
                          ],
                          
                          SizedBox(height: 32 * scale),
                          SizedBox(
                            width: double.infinity,
                            height: 64 * scale,
                            child: ElevatedButton(
                              onPressed: _isProcessing ? null : _handleSimulationAction,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isUnlocked ? const Color(0xFFCC6633) : const Color(0xFF8C8A87),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 0,
                              ),
                                  child: _isProcessing
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isUnlocked 
                                            ? _t("START SIMULATION", "MULAI SIMULASI") 
                                            : _t("UNLOCK SIMULATION", "BUKA SIMULASI"),
                                          style: TextStyle(fontSize: 18 * scale, fontWeight: FontWeight.w900, letterSpacing: 1),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22 * scale),
                                        if (!_isUnlocked) ...[
                                          const SizedBox(width: 16),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(Icons.stars_rounded, color: Colors.white, size: 18),
                                                SizedBox(width: 6),
                                                Text(
                                                  "1500 XP",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExamStructureCard(bool isDark, Color textColor, Color subTextColor, double scale) {
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color sectionColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF8F9FA);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.assignment_rounded, color: const Color(0xFFCC6633), size: 24 * scale),
              ),
              const SizedBox(width: 12),
              Text(
                _t("Test Modules", "Modul Ujian"),
                style: TextStyle(fontSize: 20 * scale, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          SizedBox(height: 24 * scale),
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
            scale: scale,
          ),
          SizedBox(height: 16 * scale),
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
            scale: scale,
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
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale, color: textColor)),
                    Text(subtitle, style: TextStyle(color: const Color(0xFFCC6633), fontSize: 12 * scale, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC6633),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: Colors.white, size: 14 * scale),
                    const SizedBox(width: 4),
                    Text("$duration mnt", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12 * scale)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Text(description, style: TextStyle(color: subTextColor, fontSize: 13 * scale, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildGradingSystemCard(bool isDark, Color textColor, Color subTextColor, double scale) {
    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF2D2622),
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: const Color(0xFF2D2622).withValues(alpha: 0.1),
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
              Icon(Icons.analytics_rounded, color: const Color(0xFFCC6633), size: 24 * scale),
              const SizedBox(width: 12),
              Text(
                _t("Grading System", "Sistem Penilaian"),
                style: TextStyle(color: Colors.white, fontSize: 18 * scale, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 24 * scale),
          Row(
            children: [
              _buildGradeStat(_t("MAX SCORE", "SKOR MAKS"), "180", Colors.white, scale),
              Container(width: 1, height: 40 * scale, color: Colors.white24, margin: EdgeInsets.symmetric(horizontal: 24 * scale)),
              _buildGradeStat(_t("PASSING GRADE", "BATAS LULUS"), "80", const Color(0xFFCC6633), scale),
            ],
          ),
          SizedBox(height: 20 * scale),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _t(
                "Pass criteria: Total score ≥ 80 AND meet minimum sectional standard. Zero score in any section results in failure.",
                "Kriteria lulus: Skor total ≥ 80 DAN memenuhi standar minimum tiap sesi. Skor nol pada sesi mana pun dianggap tidak lulus."
              ),
              style: TextStyle(color: Colors.white60, fontSize: 11 * scale, fontStyle: FontStyle.italic, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeStat(String label, String value, Color valueColor, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 10 * scale, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontSize: 28 * scale, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildOneAttemptCard(bool isDark, Color textColor, Color subTextColor, double scale) {
    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCC6633).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFCC6633).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.gavel_rounded, color: const Color(0xFFCC6633), size: 24 * scale),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t("Strict Exam Rules", "Aturan Ujian Ketat"),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16 * scale, color: textColor),
                ),
                const SizedBox(height: 4),
                Text(
                  _t("Continuous timer. No pauses. Result is final.", "Waktu berjalan terus. Tanpa jeda. Hasil bersifat final."),
                  style: TextStyle(fontSize: 12 * scale, color: subTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
