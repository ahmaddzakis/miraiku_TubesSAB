import 'package:flutter/material.dart';
import '../../main.dart'; // Wajib ditambahkan untuk memanggil global state

class TopStatusBar extends StatelessWidget {
  const TopStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Membungkus dengan ValueListenableBuilder agar selalu update secara real-time!
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, child) {
        // --- VARIABEL WARNA DINAMIS ---
        final Color containerBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEFE8DD);
        final Color dividerColor = isDark ? const Color(0xFF555555) : Colors.grey;
        final Color inactiveColor = isDark ? Colors.white54 : Colors.grey;

        // Memaksa warna background Top Bar agar selalu sinkron dengan tema
        final Color barBg = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);

        return Container(
          color: barBg,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  SizedBox(width: 12),
                  Text(
                      "MIRAIKU",
                      style: TextStyle(
                          color: Color(0xFFCC6633),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontFamily: 'Serif'
                      )
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: containerBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isDark ? const Color(0xFF333333) : Colors.transparent
                    )
                ),
                child: Row(
                  children: [
                    const Text("7", style: TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.local_fire_department_rounded, color: Color(0xFFCC6633), size: 18),
                    Text("  |  ", style: TextStyle(color: dividerColor, fontSize: 10)),

                    const Text("5", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 18),
                    Text("  |  ", style: TextStyle(color: dividerColor, fontSize: 10)),

                    Icon(Icons.star_rounded, color: inactiveColor, size: 18),
                    const SizedBox(width: 4),
                    Text("450", style: TextStyle(color: inactiveColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}