import 'package:flutter/material.dart';
import '../core/game_manager.dart';

enum NodeStatus { locked, current, completed }

class PathNode extends StatelessWidget {
  final String title;
  final NodeStatus status;
  final Alignment alignment;
  final int stars;
  final IconData? icon;
  final Function(int)? onReplaySelected;

  const PathNode({
    super.key,
    required this.title,
    required this.status,
    required this.alignment,
    required this.stars,
    this.icon,
    this.onReplaySelected,
  });

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  // 🔥 DETEKSI IKON (Lebih Dinamis & Beragam)
  IconData _getContextIcon(String text) {
    final t = text.toLowerCase();
    if (t.contains('test') || t.contains('ujian')) return Icons.emoji_events_rounded; 
    if (t.contains('hiragana')) {
      if (t.contains('1')) return Icons.create_rounded;
      if (t.contains('2')) return Icons.record_voice_over_rounded;
      if (t.contains('3')) return Icons.school_rounded;
      return Icons.translate_rounded;
    }
    if (t.contains('katakana')) {
      if (t.contains('1')) return Icons.menu_book_rounded;
      if (t.contains('2')) return Icons.auto_stories_rounded;
      if (t.contains('words')) return Icons.local_offer_rounded;
      return Icons.style_rounded;
    }
    if (t.contains('kanji')) return Icons.architecture_rounded;
    if (t.contains('grammar') || t.contains('tata bahasa')) return Icons.psychology_rounded;
    if (t.contains('angka') || t.contains('nomor') || t.contains('number')) return Icons.onetwothree_rounded;
    if (t.contains('salam') || t.contains('sapa') || t.contains('greeting')) return Icons.waving_hand_rounded;
    if (t.contains('waktu') || t.contains('jam') || t.contains('hari')) return Icons.schedule_rounded;
    return Icons.auto_awesome_rounded;
  }

  // ==========================================
  // 🍿 POP-UP PILIH BINTANG (HANYA UNTUK NODE BIASA)
  // ==========================================
  void _showReplayDialog(BuildContext context, bool isDark) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          title: Column(
            children: [
              const Icon(Icons.replay_circle_filled_rounded, color: Color(0xFFCC6633), size: 48),
              const SizedBox(height: 12),
              const Text('リプレイ?', style: TextStyle(color: Color(0xFFCC6633), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
              Text('Pilih Tahapan', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF333333), fontSize: 22), textAlign: TextAlign.center),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Materi bagian mana yang ingin kamu asah kembali?', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF666666), fontSize: 14)),
              const SizedBox(height: 24),
              _buildStarButton(context, 1, 0, isDark),
              const SizedBox(height: 12),
              _buildStarButton(context, 2, 1, isDark),
              const SizedBox(height: 12),
              _buildStarButton(context, 3, 2, isDark),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('BATAL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
            )
          ],
        )
    );
  }

  Widget _buildStarButton(BuildContext context, int starDisplay, int starIndex, bool isDark) {
    return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFFE8E3DA), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              if (onReplaySelected != null) onReplaySelected!(starIndex);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: List.generate(3, (index) => Icon(index < starDisplay ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFFFC107), size: 20))),
                const SizedBox(width: 12),
              ],
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = globalDarkMode.value;
    final bool isTestNode = title.toLowerCase().contains('test') || title.toLowerCase().contains('ujian');

    Color nodeColor;
    Color borderColor;
    List<BoxShadow>? shadows;
    Widget centerWidget;

    switch (status) {
      case NodeStatus.locked:
        nodeColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E3DA);
        borderColor = isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE8E3DA);
        centerWidget = const Icon(Icons.lock_rounded, color: Color(0xFFA6A198), size: 28);
        break;
      case NodeStatus.current:
        nodeColor = const Color(0xFFCC6633);
        borderColor = const Color(0xFFCC6633).withValues(alpha: 0.3);
        shadows = [
          BoxShadow(
            color: const Color(0xFFCC6633).withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ];
        centerWidget = Icon(icon ?? _getContextIcon(title), color: Colors.white, size: 34);
        break;
      case NodeStatus.completed:
        nodeColor = const Color(0xFFCC6633).withValues(alpha: 0.1);
        borderColor = const Color(0xFFCC6633);
        centerWidget = Icon(icon ?? _getContextIcon(title), color: const Color(0xFFCC6633), size: 32);
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: status == NodeStatus.current ? 72 : 64, 
                height: status == NodeStatus.current ? 72 : 64,
                decoration: BoxDecoration(
                  color: nodeColor, 
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: status == NodeStatus.locked ? 2 : 4),
                  boxShadow: shadows,
                ),
                child: Center(child: centerWidget),
              ),
              const SizedBox(height: 6),
              // 🔥 LOGIKA HAPUS BINTANG KHUSUS UNIT TEST
              if (!isTestNode)
                Row(
                  children: List.generate(3, (index) => Icon(
                    index < stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: status == NodeStatus.locked ? Colors.grey.shade400 : const Color(0xFFCC6633),
                    size: 14,
                  )),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status == NodeStatus.locked ? _t("LOCKED", "TERKUNCI") : (status == NodeStatus.current ? _t("IN PROGRESS", "SEDANG DIUJI") : _t("COMPLETED", "SELESAI")),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFCC6633)),
                ),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF333333))),

                // 🔥 LOGIKA MUNCULNYA TOMBOL REPLAY (BINTANG 3 ATAU MERUPAKAN UNIT TEST)
                if (status == NodeStatus.completed && (stars >= 3 || isTestNode)) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (isTestNode) {
                        // Jika Unit Test, lewati pop-up, langsung mulai ulang test!
                        if (onReplaySelected != null) onReplaySelected!(0);
                      } else {
                        // Jika Level Biasa, tampilkan pop-up pilihan bintang
                        _showReplayDialog(context, isDark);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Replay?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: isDark ? const Color(0xFFCC6633) : const Color(0xFFCC6633).withValues(alpha: 0.8))),
                        const SizedBox(width: 4),
                        Icon(Icons.replay_rounded, color: isDark ? const Color(0xFFCC6633) : const Color(0xFFCC6633).withValues(alpha: 0.8), size: 18),
                      ],
                    ),
                  ),
                ]

              ],
            ),
          ),
        ],
      ),
    );
  }
}
