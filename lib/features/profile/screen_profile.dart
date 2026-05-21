import 'package:flutter/material.dart';

class _AchievementBadge {
  final String text;
  final bool isLabel;

  const _AchievementBadge._(this.text, this.isLabel);

  factory _AchievementBadge.text(String t) =>
      _AchievementBadge._(t, false);

  factory _AchievementBadge.label(String t) =>
      _AchievementBadge._(t, true);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [

            const SizedBox(height: 30),

            // ================= AVATAR =================
            _buildAvatarSection(),

            const SizedBox(height: 16),

            const Text(
              "Ahmad Dzaki",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Bandung, West Java",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

            // ================= STATS =================
            _buildStatsRow(),

            const SizedBox(height: 24),

            // ================= DAILY GOAL =================
            _buildDailyGoalCard(),

            const SizedBox(height: 40),

            // ================= ACHIEVEMENTS =================
            _buildAchievementsSection(),

            const SizedBox(height: 28),

            // ================= SETTINGS / LOGOUT =================
            _buildProfileMenu(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // AVATAR
  // =====================================================

  Widget _buildAvatarSection() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFFCC6633),
            shape: BoxShape.circle,
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200',
            ),
          ),
        ),

        // Edit Button
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.edit,
            size: 16,
            color: Color(0xFFCC6633),
          ),
        ),
      ],
    );
  }

  // =====================================================
  // STATS
  // =====================================================

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCircle(
          value: "12,500",
          label: "TOTAL XP",
          icon: Icons.bolt_rounded,
          iconColor: const Color(0xFFCC6633),
        ),

        _buildStatCircle(
          value: "32",
          label: "DAYS STREAK",
          icon: Icons.local_fire_department_rounded,
          iconColor: const Color(0xFFB85C2A),
        ),

        _buildStatCircle(
          value: "450/700",
          label: "WORDS (N5)",
          icon: Icons.menu_book_rounded,
          iconColor: const Color(0xFFE08B4B),
        ),
      ],
    );
  }

  Widget _buildStatCircle({
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: iconColor),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // DAILY GOAL CARD
  // =====================================================

  Widget _buildDailyGoalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD7B8),
        ),
      ),
      child: Row(
        children: [

          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFCC6633),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [

                Text(
                  "Daily Goal",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "You're 75% done today!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Text(
            "75%",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFFCC6633),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ACHIEVEMENTS
  // =====================================================

  Widget _buildAchievementsSection() {
    return Column(
      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            const Text(
              "Achievements",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5EFE6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [

                  Icon(
                    Icons.emoji_events_rounded,
                    size: 14,
                    color: Color(0xFFCC6633),
                  ),

                  SizedBox(width: 4),

                  Text(
                    "3 / 4",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFCC6633),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [

              _buildAchievementCardH(
                badge: _AchievementBadge.text("あ"),
                bgColor: const Color(0xFFEBE5DB),
                accentColor: const Color(0xFF7A6652),
                title: "Hiragana\nMaster",
                progress: 1.0,
                isCompleted: true,
              ),

              _buildAchievementCardH(
                badge: _AchievementBadge.text("ア"),
                bgColor: const Color(0xFFF0DEC9),
                accentColor: const Color(0xFFCC6633),
                title: "Katakana\nExplorer",
                progress: 0.6,
                progressLabel: "60 / 100",
              ),

              _buildAchievementCardH(
                badge: _AchievementBadge.label("N5"),
                bgColor: const Color(0xFFCC6633),
                badgeTextColor: Colors.white,
                accentColor: const Color(0xFFCC6633),
                title: "N5\nBeginner",
                progress: 0.45,
                progressLabel: "450 / 700",
              ),

              _buildAchievementCardH(
                badge: _AchievementBadge.text("日"),
                bgColor: const Color(0xFFE8E3DA),
                accentColor: const Color(0xFFB4B2A9),
                title: "Kanji N5\nPioneer",
                progress: 0.0,
                progressLabel: "0 / 100",
                isLocked: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCardH({
    required _AchievementBadge badge,
    required Color bgColor,
    required Color accentColor,
    Color badgeTextColor = Colors.black87,
    required String title,
    required double progress,
    String? progressLabel,
    bool isCompleted = false,
    bool isLocked = false,
  }) {
    return Opacity(
      opacity: isLocked ? 0.45 : 1.0,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCompleted
                ? const Color(0xFFC8E6C9)
                : const Color(0xFFEDE8DF),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Stack(
              clipBehavior: Clip.none,
              children: [

                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badge.text,
                      style: TextStyle(
                        fontSize: badge.isLabel ? 18 : 26,
                        fontWeight: FontWeight.w900,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ),

                if (isCompleted)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B6D11),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),

                if (isLocked)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFFEDE8DF),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock,
                        size: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),

            const Spacer(),

            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isLocked ? Colors.grey : Colors.black87,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: const Color(0xFFF1EFE8),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted
                      ? const Color(0xFF3B6D11)
                      : accentColor,
                ),
              ),
            ),

            const SizedBox(height: 6),

            if (isCompleted)
              const Text(
                "Completed ✓",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3B6D11),
                ),
              )
            else if (progressLabel != null)
              Text(
                progressLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // PROFILE MENU / LOGOUT
  // =====================================================

  Widget _buildProfileMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF0E7DD),
        ),
      ),
      child: Column(
        children: [

          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: "Settings",
            subtitle: "Manage your preferences",
            color: const Color(0xFFCC6633),
          ),

          const Divider(height: 1),

          _buildMenuTile(
            icon: Icons.notifications_none_rounded,
            title: "Notifications",
            subtitle: "Daily reminder & updates",
            color: const Color(0xFFE08B4B),
          ),

          const Divider(height: 1),

          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),

            title: const Text(
              "Log Out",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),

            subtitle: const Text(
              "Sign out from your account",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),

            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text(
                    "Log Out?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    "Are you sure you want to log out?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        "Log Out",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),

      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),

      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey,
      ),
    );
  }
}