import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import 'screen_settings.dart';
import 'screen_notifications.dart';

class _AchievementBadge {
  final String text;
  final bool isLabel;
  const _AchievementBadge._(this.text, this.isLabel);
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

  // Data Profil Supabase
  String _userName = "";
  String _userDesc = "";
  String _userEmail = "";
  String _avatarUrl = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200";
  bool _isSaving = false;

  // Data Statistik Dinamis (Mulai dari 0)
  int _totalXp = 0;
  int _streakDays = 0;
  int _wordsLearned = 0;

  @override
  void initState() {
    super.initState();
    _loadSupabaseUserData();
    _loadLocalStats();
  }

  void _loadSupabaseUserData() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? "";
        _userName = user.userMetadata?['display_name'] ?? _userEmail.split('@')[0];
        _userDesc = user.userMetadata?['bio'] ?? "Bandung, West Java";
      });
    }
  }

  // Memuat XP dan Statistik (Nanti ini bisa diupdate dari Learn/Kana screen)
  Future<void> _loadLocalStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalXp = prefs.getInt('total_xp') ?? 0;
      _streakDays = prefs.getInt('streak_days') ?? 0;
      _wordsLearned = prefs.getInt('words_learned') ?? 0;
    });
  }

  Future<void> _saveProfileData(String name, String desc) async {
    setState(() => _isSaving = true);
    try {
      await _supabase.auth.updateUser(UserAttributes(data: {'display_name': name, 'bio': desc}));
      setState(() { _userName = name; _userDesc = desc; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Profile updated successfully!", "Profil Berhasil Diperbarui!"))));
    } on AuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  void _showEditProfileModal() {
    final TextEditingController nameController = TextEditingController(text: _userName);
    final TextEditingController descController = TextEditingController(text: _userDesc);
    final bool isDark = globalDarkMode.value;
    final Color modalBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAF7F2);
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
    final Color fieldBg = isDark ? const Color(0xFF2D2D2D) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: modalBg, borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFF8C8A87).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
                      const SizedBox(height: 24),
                      Text(_t("Edit Profile", "Edit Profil"), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor, fontFamily: 'Serif')),
                      const SizedBox(height: 24),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(radius: 45, backgroundImage: NetworkImage(_avatarUrl)),
                          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFCC6633), shape: BoxShape.circle, border: Border.all(color: modalBg, width: 2)), child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: nameController,
                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        decoration: InputDecoration(labelText: _t("Display Name", "Nama Tampilan"), labelStyle: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold), filled: true, fillColor: fieldBg, prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFFB5B0A8)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFFE8E3DA).withValues(alpha: isDark ? 0.1 : 1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2))),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descController,
                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        decoration: InputDecoration(labelText: _t("Bio / Location", "Bio / Lokasi"), labelStyle: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold), filled: true, fillColor: fieldBg, prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFB5B0A8)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFFE8E3DA).withValues(alpha: isDark ? 0.1 : 1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2))),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : () async {
                            setModalState(() => _isSaving = true);
                            await _saveProfileData(nameController.text, descController.text);
                            if (mounted) { setModalState(() => _isSaving = false); Navigator.pop(context); }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                          child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : Text(_t("Save Changes", "Simpan Perubahan"), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = globalDarkMode.value;
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
    final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF8C8A87);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFF0EBE1);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFCC6633).withValues(alpha: 0.2), shape: BoxShape.circle), child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Color(0xFFCC6633), shape: BoxShape.circle), child: CircleAvatar(radius: 55, backgroundImage: NetworkImage(_avatarUrl)))),
                  GestureDetector(onTap: _showEditProfileModal, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, border: Border.all(color: bgColor, width: 3), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]), child: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFFCC6633)))),
                ],
              ),
              const SizedBox(height: 16),
              Text(_userName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
              const SizedBox(height: 6),
              Text(_userDesc, style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(_userEmail, style: TextStyle(color: subTextColor.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TAMPILAN ANGKA SEKARANG DINAMIS SESUAI VARIABEL
                  _buildStatCircle(value: "$_totalXp", label: "TOTAL XP", icon: Icons.bolt_rounded, iconColor: const Color(0xFFCC6633), cardColor: cardColor, textColor: textColor, subTextColor: subTextColor, borderColor: borderColor),
                  _buildStatCircle(value: "$_streakDays", label: _t("DAYS STREAK", "REKOR HARI"), icon: Icons.local_fire_department_rounded, iconColor: const Color(0xFFB85C2A), cardColor: cardColor, textColor: textColor, subTextColor: subTextColor, borderColor: borderColor),
                  _buildStatCircle(value: "$_wordsLearned/700", label: _t("WORDS (N5)", "KATA (N5)"), icon: Icons.menu_book_rounded, iconColor: const Color(0xFFE08B4B), cardColor: cardColor, textColor: textColor, subTextColor: subTextColor, borderColor: borderColor),
                ],
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor), boxShadow: [BoxShadow(color: const Color(0xFFCC6633).withValues(alpha: isDark ? 0.01 : 0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                child: Row(
                  children: [
                    Container(width: 56, height: 56, decoration: BoxDecoration(color: isDark ? const Color(0xFF3A2415) : const Color(0xFFFFF4E8), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFCC6633), size: 30)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_t("Daily Goal", "Target Harian"), style: TextStyle(fontSize: 13, color: subTextColor, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          // Target disesuaikan
                          Text(_totalXp == 0 ? _t("Start your first lesson!", "Mulai pelajaran pertamamu!") : _t("Keep it up!", "Terus berjuang!"), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textColor)),
                          const SizedBox(height: 8),
                          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: _totalXp == 0 ? 0.0 : 0.75, minHeight: 6, backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFF1EFE8), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCC6633)))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(_totalXp == 0 ? "0%" : "75%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFFCC6633))),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_t("Achievements", "Pencapaian"), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: isDark ? const Color(0xFF3A2415) : const Color(0xFFFFF4E8), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFFCC6633)), SizedBox(width: 6), Text("0 / 4", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFCC6633)))]))
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 190,
                    child: ListView(
                      scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), clipBehavior: Clip.none,
                      children: [
                        _buildAchievementCardH(badge: _AchievementBadge.text("あ"), bgColor: const Color(0xFFFFF4E8), accentColor: const Color(0xFFCC6633), title: "Hiragana\nMaster", progress: 0.0, progressLabel: "0 / 46", cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor),
                        _buildAchievementCardH(badge: _AchievementBadge.text("ア"), bgColor: const Color(0xFFFFF4E8), accentColor: const Color(0xFFCC6633), title: "Katakana\nExplorer", progress: 0.0, progressLabel: "0 / 46", cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor),
                        _buildAchievementCardH(badge: _AchievementBadge.label("N5"), bgColor: const Color(0xFFCC6633), badgeTextColor: Colors.white, accentColor: const Color(0xFFCC6633), title: "N5\nBeginner", progress: 0.0, progressLabel: "0 / 700", cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Container(
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))]),
                child: Column(
                  children: [
                    _buildMenuTile(context: context, icon: Icons.settings_rounded, title: _t("Settings", "Pengaturan"), subtitle: _t("Manage your preferences", "Kelola preferensi akunmu"), color: const Color(0xFFCC6633), textColor: textColor, subTextColor: subTextColor, isDark: isDark, onTap: () async {
                      // Tunggu Settings ditutup, lalu refresh profil barangkali ada data diubah di Settings
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                      _loadSupabaseUserData();
                    }),
                    Divider(height: 1, color: borderColor),
                    _buildMenuTile(context: context, icon: Icons.notifications_rounded, title: _t("Notifications", "Notifikasi"), subtitle: _t("Daily reminder & updates", "Pengingat harian & info"), color: const Color(0xFFE08B4B), textColor: textColor, subTextColor: subTextColor, isDark: isDark, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
                    Divider(height: 1, color: borderColor),
                    _buildMenuTile(
                      context: context, icon: Icons.logout_rounded, title: _t("Log Out", "Keluar"), subtitle: _t("Sign out from your account", "Keluar dari akun Miraiku"), color: Colors.red, textColor: textColor, subTextColor: subTextColor, isLogout: true, isDark: isDark,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            title: Text(_t("Log Out?", "Yakin Keluar?"), style: TextStyle(fontWeight: FontWeight.w900, color: textColor)),
                            content: Text(_t("Are you sure you want to log out from Miraiku?", "Apakah kamu yakin ingin keluar dari akun ini?"), style: TextStyle(color: subTextColor)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_t("Cancel", "Batal"), style: TextStyle(fontWeight: FontWeight.bold, color: subTextColor))),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  onPressed: () async {
                                    // 🧹 1. SAPU BERSIH PROGRESS LOKAL (Kecuali Setting Bahasa/Dark Mode)
                                    final prefs = await SharedPreferences.getInstance();
                                    final keys = prefs.getKeys();
                                    for (String key in keys) {
                                      if (key != 'setting_dark' && key != 'setting_lang') {
                                        await prefs.remove(key); // Hapus bintang, nyawa, XP, dll
                                      }
                                    }
                                    // 🚪 2. LOGOUT SUPABASE
                                    await _supabase.auth.signOut();
                                    if (mounted) Navigator.pop(ctx);
                                  },
                                  child: Text(_t("Log Out", "Keluar"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCircle({required String value, required String label, required IconData icon, required Color iconColor, required Color cardColor, required Color textColor, required Color subTextColor, required Color borderColor}) {
    return Container(width: 100, height: 100, decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, border: Border.all(color: borderColor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 8))]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 24, color: iconColor), const SizedBox(height: 4), Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: textColor)), const SizedBox(height: 2), Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: subTextColor, letterSpacing: 0.5))]));
  }

  Widget _buildAchievementCardH({required _AchievementBadge badge, required Color bgColor, required Color accentColor, Color badgeTextColor = Colors.black87, required String title, required double progress, String? progressLabel, bool isCompleted = false, bool isLocked = false, required Color cardColor, required Color textColor, required Color borderColor, required bool isDark, required Color subTextColor}) {
    return Opacity(opacity: isLocked ? 0.6 : 1.0, child: Container(width: 135, margin: const EdgeInsets.only(right: 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isCompleted ? const Color(0xFFC8E6C9).withValues(alpha: isDark ? 0.2 : 1) : borderColor, width: 2), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Stack(clipBehavior: Clip.none, children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: isDark ? bgColor.withValues(alpha: 0.5) : bgColor, shape: BoxShape.circle), child: Center(child: Text(badge.text, style: TextStyle(fontSize: badge.isLabel ? 18 : 28, fontWeight: FontWeight.w900, color: badgeTextColor)))), if (isCompleted) Positioned(bottom: -2, right: -2, child: Container(width: 22, height: 22, decoration: BoxDecoration(color: const Color(0xFF558B2F), shape: BoxShape.circle, border: Border.all(color: cardColor, width: 2)), child: const Icon(Icons.check_rounded, size: 14, color: Colors.white))), if (isLocked) Positioned(bottom: -2, right: -2, child: Container(width: 22, height: 22, decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, border: Border.all(color: borderColor, width: 2)), child: const Icon(Icons.lock_rounded, size: 12, color: Color(0xFF8C8A87))))]), const Spacer(), Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isLocked ? const Color(0xFF8C8A87) : textColor, height: 1.2)), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFF1EFE8), valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? const Color(0xFF558B2F) : accentColor))), const SizedBox(height: 6), if (isCompleted) Text(_t("Completed", "Selesai"), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF558B2F))) else if (progressLabel != null) Text(progressLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subTextColor))])));
  }

  Widget _buildMenuTile({required BuildContext context, required IconData icon, required String title, required String subtitle, required Color color, required Color textColor, required Color subTextColor, required VoidCallback onTap, bool isLogout = false, required bool isDark}) {
    return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isLogout ? (isDark ? Colors.red.withValues(alpha: 0.2) : const Color(0xFFFFF1F1)) : color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 22)), title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor)), subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subTextColor, fontWeight: FontWeight.w500)), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFB5B0A8)), onTap: onTap);
  }
}