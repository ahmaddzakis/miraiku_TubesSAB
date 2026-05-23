import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F6F0),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2D2622)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Notifications", style: TextStyle(color: Color(0xFF2D2622), fontWeight: FontWeight.w900, fontFamily: 'Serif')),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const Text("TODAY", style: TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          _buildNotifCard(
            title: "Streak Saved!",
            message: "You practiced Hiragana today. Keep the fire burning tomorrow!",
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFCC6633),
            time: "2h ago",
            isUnread: true,
          ),
          const SizedBox(height: 12),
          _buildNotifCard(
            title: "Achievement Unlocked 🏆",
            message: "Congratulations! You've earned the 'Hiragana Master' badge.",
            icon: Icons.emoji_events_rounded,
            iconColor: const Color(0xFFE08B4B),
            time: "5h ago",
            isUnread: false,
          ),
          const SizedBox(height: 32),
          const Text("YESTERDAY", style: TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          _buildNotifCard(
            title: "New Lesson Available",
            message: "Unit 2: Katakana Expansion is now unlocked for you.",
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFF558B2F),
            time: "1d ago",
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard({required String title, required String message, required IconData icon, required Color iconColor, required String time, required bool isUnread}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : const Color(0xFFF0EBE1).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUnread ? const Color(0xFFCC6633).withOpacity(0.3) : Colors.transparent),
        boxShadow: isUnread ? [BoxShadow(color: const Color(0xFFCC6633).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isUnread ? const Color(0xFF2D2622) : const Color(0xFF8C8A87)))),
                    Text(time, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB5B0A8))),
                  ],
                ),
                const SizedBox(height: 6),
                Text(message, style: TextStyle(fontSize: 13, height: 1.4, color: isUnread ? const Color(0xFF8C8A87) : const Color(0xFFB5B0A8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}