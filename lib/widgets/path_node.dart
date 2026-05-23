import 'package:flutter/material.dart';
import '../main.dart'; // Wajib ditambahkan untuk memanggil global state

// Enum untuk status node
enum NodeStatus { locked, current, completed }

class PathNode extends StatelessWidget {
  final String title;
  final NodeStatus status;
  final Alignment alignment;
  final int stars;

  const PathNode({
    super.key,
    required this.title,
    required this.status,
    required this.alignment,
    required this.stars,
  });

  // --- FUNGSI TRANSLATE OTOMATIS ---
  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  @override
  Widget build(BuildContext context) {
    // --- BACA STATUS DARK MODE ---
    final bool isDark = globalDarkMode.value;

    // Menentukan warna dan dekorasi berdasarkan status node
    Color nodeColor;
    Color borderColor;
    Widget centerWidget;

    switch (status) {
      case NodeStatus.locked:
        nodeColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E3DA);
        borderColor = isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE8E3DA);
        centerWidget = const Icon(Icons.lock_rounded, color: Color(0xFFA6A198), size: 28);
        break;
      case NodeStatus.current:
        nodeColor = const Color(0xFFCC6633);
        borderColor = isDark ? const Color(0xFF5A3A29) : const Color(0xFFF6E7DC);
        centerWidget = const Icon(Icons.star_half_rounded, color: Colors.white, size: 32);
        break;
      case NodeStatus.completed:
        nodeColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEFEBE1);
        borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);
        centerWidget = const Icon(Icons.check_rounded, color: Color(0xFFCC6633), size: 30);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ================= KIRI: LINGKARAN NODE & BINTANG =================
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lingkaran Utama Node
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  boxShadow: status != NodeStatus.locked
                      ? [
                    BoxShadow(
                      color: const Color(0xFFCC6633).withValues(alpha: isDark ? 0.1 : 0.2), // withOpacity diganti agar bebas warning!
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : null,
                  border: Border.all(color: borderColor, width: status == NodeStatus.current ? 4 : 2),
                ),
                child: Center(child: centerWidget),
              ),
              const SizedBox(height: 6),
              // Visualisasi Bintang Kecil di Bawah Lingkaran
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: status == NodeStatus.locked
                        ? (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFDCD8CF))
                        : const Color(0xFFCC6633),
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // ================= KANAN: TEKS MATERI / JUDUL LESSON =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status == NodeStatus.locked
                      ? _t("LOCKED", "TERKUNCI")
                      : (status == NodeStatus.current ? _t("IN PROGRESS", "SEDANG DIPELAJARI") : _t("COMPLETED", "SELESAI")),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: status == NodeStatus.locked
                        ? const Color(0xFFA6A198)
                        : const Color(0xFFCC6633),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: status == NodeStatus.locked
                        ? const Color(0xFFA6A198)
                        : (isDark ? Colors.white : const Color(0xFF333333)), // Teks berubah putih saat Dark Mode
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}