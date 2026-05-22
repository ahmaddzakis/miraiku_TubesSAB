import 'package:flutter/material.dart';

// Enum untuk status node
enum NodeStatus { locked, current, completed }

class PathNode extends StatelessWidget {
  final String title;
  final NodeStatus status;
  final Alignment alignment; // Tetap dipertahankan agar tidak error di screen_learn
  final int stars;

  const PathNode({
    super.key,
    required this.title,
    required this.status,
    required this.alignment,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    // Menentukan warna dan dekorasi berdasarkan status node
    Color nodeColor;
    Widget centerWidget;

    switch (status) {
      case NodeStatus.locked:
        nodeColor = const Color(0xFFE8E3DA);
        centerWidget = const Icon(Icons.lock_rounded, color: Color(0xFFA6A198), size: 28);
        break;
      case NodeStatus.current:
        nodeColor = const Color(0xFFCC6633);
        centerWidget = const Icon(Icons.star_half_rounded, color: Colors.white, size: 32); // Bisa diganti ikon tangan/belajar Anda
        break;
      case NodeStatus.completed:
        nodeColor = const Color(0xFFEFEBE1);
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
                      color: const Color(0xFFCC6633).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : null,
                  border: status == NodeStatus.current
                      ? Border.all(color: const Color(0xFFF6E7DC), width: 4)
                      : Border.all(color: const Color(0xFFE8E3DA), width: 2),
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
                        ? const Color(0xFFDCD8CF)
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
                      ? "TERKUNCI"
                      : (status == NodeStatus.current ? "SEDANG DIPELAJARI" : "SELESAI"),
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
                        : const Color(0xFF333333),
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