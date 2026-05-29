import 'package:flutter/material.dart';
import '../core/game_manager.dart';

class TopStatusBar extends StatelessWidget {
  const TopStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, child) {

        final Color containerBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEFE8DD);
        final Color dividerColor = isDark ? const Color(0xFF555555) : const Color(0xFFC7C1B5);
        final Color barBg = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
        final Color textColor = isDark ? Colors.white : const Color(0xFF4B4B4B);

        return Container(
          color: barBg,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Padding disesuaikan
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ==========================================
              // 👑 BAGIAN KIRI: LOGO MIRAIKU GANTENG
              // ==========================================
              Row(
                children: [
                  const SizedBox(width: 12),
                  // Teks Gradient tanpa Hiragana, font lebih modern
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFCC6633), Color(0xFFFF9600)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                    child: const Text(
                      "MIRAIku",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        fontStyle: FontStyle.italic, // Bikin miring biar ganteng & dinamis
                      ),
                    ),
                  ),
                ],
              ),

              // ==========================================
              // 📊 BAGIAN KANAN: STATUS BAR KLIKABEL
              // ==========================================
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: containerBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: isDark ? const Color(0xFF333333) : Colors.transparent
                  ),
                ),
                child: ValueListenableBuilder<int>(
                  valueListenable: globalStreak,
                  builder: (context, streak, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: globalHearts,
                      builder: (context, hearts, _) {
                        return ValueListenableBuilder<int>(
                          valueListenable: globalXP,
                          builder: (context, xp, _) {
                            return ValueListenableBuilder<String>(
                              valueListenable: globalTimerText,
                              builder: (context, timerText, _) {

                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // --- 1. STREAK (KLIKABEL) ---
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _showStatDialog(context, 'streak', isDark),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF8A00), size: 20),
                                          const SizedBox(width: 4),
                                          Text("$streak", style: const TextStyle(color: Color(0xFFFF8A00), fontWeight: FontWeight.w900, fontSize: 14)),
                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Text("|", style: TextStyle(color: dividerColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),

                                    // --- 2. NYAWA & TIMER (KLIKABEL) ---
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _showStatDialog(context, 'hearts', isDark),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.favorite_rounded, color: Color(0xFFE53935), size: 20),
                                          const SizedBox(width: 4),
                                          Text("$hearts", style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w900, fontSize: 14)),
                                        ],
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6),
                                      child: Text("|", style: TextStyle(color: dividerColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),

                                    // --- 3. XP (KLIKABEL) ---
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () => _showStatDialog(context, 'xp', isDark),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.stars_rounded, color: Color(0xFFFFC107), size: 20),
                                          const SizedBox(width: 4),
                                          Text("$xp", style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  ],
                                );

                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 🍿 FUNGSI POP-UP DETAILS (DIALOG)
  // ==========================================
  void _showStatDialog(BuildContext context, String type, bool isDark) {
    String title = "";
    IconData icon = Icons.info;
    Color iconColor = Colors.grey;

    if (type == 'streak') {
      title = "Runtutan Belajar";
      icon = Icons.local_fire_department_rounded;
      iconColor = const Color(0xFFFF8A00);
    } else if (type == 'hearts') {
      title = "Nyawa Anda";
      icon = Icons.favorite_rounded;
      iconColor = const Color(0xFFE53935);
    } else if (type == 'xp') {
      title = "Poin Pengalaman (XP)";
      icon = Icons.stars_rounded;
      iconColor = const Color(0xFFFFC107);
    }

    showDialog(
        context: context,
        builder: (context) {
          // Gunakan ValueListenableBuilder di dalam dialog agar data update real-time
          return ValueListenableBuilder<int>(
              valueListenable: globalHearts,
              builder: (context, currentHearts, _) {
                return ValueListenableBuilder<int>(
                    valueListenable: globalXP,
                    builder: (context, currentXP, _) {
                      return AlertDialog(
                        backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF9F6F0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Column(
                          children: [
                            Icon(icon, size: 48, color: iconColor),
                            const SizedBox(height: 12),
                            Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF333333))
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // KONTEN STREAK
                            if (type == 'streak') ...[
                              Text(
                                "Kamu sudah membuka aplikasi selama ${globalStreak.value} hari berturut-turut! Jangan sampai terlewat 1 hari pun atau runtutanmu akan kembali ke 0.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF666666), height: 1.5),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: const Text("🎁 Login setiap hari untuk klaim 50 XP & bonus Mingguan di Profil!", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              )
                            ],

                            // KONTEN NYAWA & TOMBOL BELI
                            if (type == 'hearts') ...[
                              Text(
                                "Sisa nyawa: $currentHearts / ${GameManager.maxHearts}\nNyawa berkurang setiap kamu salah menjawab kuis. 1 nyawa akan pulih secara otomatis setiap 20 menit.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF666666), height: 1.5),
                              ),
                              const SizedBox(height: 12),

                              // 🔥 TIMER MUNCUL DI SINI JIKA NYAWA KURANG DARI 5
                              if (currentHearts < GameManager.maxHearts)
                                ValueListenableBuilder<String>(
                                    valueListenable: globalTimerText,
                                    builder: (context, timerText, _) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFE53935).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12)
                                        ),
                                        child: Text(
                                            "⏳ +1 Nyawa dalam: $timerText",
                                            style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w900, fontSize: 14)
                                        ),
                                      );
                                    }
                                ),

                              const SizedBox(height: 20),

                              // TOMBOL BELI NYAWA PAKAI XP
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFCC6633),
                                    disabledBackgroundColor: isDark ? const Color(0xFF444444) : const Color(0xFFE8E3DA),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: (currentHearts >= GameManager.maxHearts || currentXP < 150)
                                      ? null
                                      : () {
                                    // Hanya panggil pop-up konfirmasinya saja.
                                    // Logika memotong XP dan menambah nyawa sudah diurus di dalam tombol "YAKIN".
                                    _showBuyConfirmationDialog(context, isDark);
                                  },
                                  icon: const Icon(Icons.stars_rounded, color: Colors.white, size: 20),
                                  label: Text(
                                    currentHearts >= GameManager.maxHearts
                                        ? "NYAWA PENUH"
                                        : (currentXP < 150 ? "XP TIDAK CUKUP (Butuh 150)" : "BELI 1 NYAWA (150 XP)"),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              )
                            ],

                            // KONTEN XP
                            if (type == 'xp') ...[
                              Text(
                                "Total XP kamu saat ini: $currentXP\nKamu akan mendapatkan 25 XP setiap kali berhasil menjawab soal latihan dengan benar.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF666666), height: 1.5),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: const Text("🎯 Kumpulkan 500 XP untuk membuka mode Simulasi JLPT N5!", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              )
                            ],
                          ],
                        ),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("TUTUP", style: TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold, letterSpacing: 1)),
                          )
                        ],
                      );
                    }
                );
              }
          );
        }
    );
  }
  // ==========================================
  // 🛒 POP-UP KONFIRMASI BELI NYAWA (UKURAN LEBIH KECIL)
  // ==========================================
  void _showBuyConfirmationDialog(BuildContext parentContext, bool isDark) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

        // 1. MENEKAN KOTAK AGAR LEBIH RAMPING DAN KECIL
        insetPadding: const EdgeInsets.symmetric(horizontal: 56),
        contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 20),
        titlePadding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 0),

        title: Column(
          children: [
            const Icon(Icons.shopping_cart_rounded, color: Color(0xFFCC6633), size: 40), // Ukuran ikon disesuaikan
            const SizedBox(height: 8),
            const Text('本当ですか?', style: TextStyle(color: Color(0xFFCC6633), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Text('Konfirmasi', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF333333), fontSize: 20), textAlign: TextAlign.center),
          ],
        ),
        content: Text(
          'Yakin ingin menukarkan 150 XP dengan 1 Nyawa?', // Teks diringkas agar lebih pas
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF666666), height: 1.4, fontSize: 14),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20), // Merapikan jarak tombol bawah
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? const Color(0xFF8C8A87) : const Color(0xFFB5B0A8), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context), // Batal beli
                  child: Text('BATAL', style: TextStyle(color: isDark ? const Color(0xFF8C8A87) : const Color(0xFF8C8A87), fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC6633),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    Navigator.pop(context); // Tutup dialog konfirmasi
                    bool success = await GameManager.buyHeartWithXP();
                    // Jika sukses beli, tutup juga dialog detail statusnya
                    if (success && parentContext.mounted) {
                      Navigator.pop(parentContext);
                    }
                  },
                  child: const Text('YAKIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 12)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}