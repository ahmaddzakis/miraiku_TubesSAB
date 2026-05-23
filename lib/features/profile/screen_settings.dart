import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart'; // Pastikan jalur ini sudah benar (mengarah ke file main.dart)

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Pengaturan
  bool _soundEffects = true;
  bool _darkMode = false;
  String _language = 'en'; // 'en' untuk English, 'id' untuk Indonesia

  // Data Profil
  String _userName = "Ahmad Dzaki";
  String _userDesc = "Bandung, West Java";
  String _avatarUrl = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200";

  @override
  void initState() {
    super.initState();
    _loadSettingsData();
  }

  // --- MEMUAT DATA DARI STORAGE ---
  Future<void> _loadSettingsData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEffects = prefs.getBool('setting_sound') ?? true;
      _darkMode = prefs.getBool('setting_dark') ?? false;
      _language = prefs.getString('setting_lang') ?? 'en';

      _userName = prefs.getString('profile_name') ?? "Ahmad Dzaki";
      _userDesc = prefs.getString('profile_desc') ?? "Bandung, West Java";
      _avatarUrl = prefs.getString('profile_avatar') ?? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200";
    });
  }

  // --- FUNGSI TRANSLATE SEDERHANA ---
  // Jika _language == 'id', gunakan teks bahasa Indonesia, jika tidak gunakan English
  String _t(String en, String id) {
    return _language == 'id' ? id : en;
  }

  // --- LOGIKA UBAH BAHASA ---
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _darkMode ? const Color(0xFF2D2D2D) : const Color(0xFFFAF7F2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(_t("Select Language", "Pilih Bahasa"), style: TextStyle(fontWeight: FontWeight.w900, color: _darkMode ? Colors.white : const Color(0xFF2D2622))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("English", style: TextStyle(color: _darkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                trailing: _language == 'en' ? const Icon(Icons.check_circle_rounded, color: Color(0xFFCC6633)) : null,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('setting_lang', 'en');
                  setState(() => _language = 'en');

                  // POIN 3: Update Global State Bahasa
                  globalLanguage.value = 'en';

                  if (mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Bahasa Indonesia", style: TextStyle(color: _darkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)),
                trailing: _language == 'id' ? const Icon(Icons.check_circle_rounded, color: Color(0xFFCC6633)) : null,
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('setting_lang', 'id');
                  setState(() => _language = 'id');

                  // POIN 3: Update Global State Bahasa
                  globalLanguage.value = 'id';

                  if (mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // --- LOGIKA EDIT PROFIL (Dari Profile Screen) ---
  Future<void> _saveProfileData(String name, String desc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
    await prefs.setString('profile_desc', desc);
    setState(() {
      _userName = name;
      _userDesc = desc;
    });
  }

  void _showEditProfileModal() {
    final TextEditingController nameController = TextEditingController(text: _userName);
    final TextEditingController descController = TextEditingController(text: _userDesc);

    // Penyesuaian warna bottom sheet mengikuti dark mode
    final Color modalBg = _darkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF7F2);
    final Color textColor = _darkMode ? Colors.white : const Color(0xFF2D2622);
    final Color fieldBg = _darkMode ? const Color(0xFF2D2D2D) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: modalBg,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            ),
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
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFFCC6633), shape: BoxShape.circle, border: Border.all(color: modalBg, width: 2)),
                      child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: nameController,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  decoration: InputDecoration(
                    labelText: _t("Display Name", "Nama Tampilan"),
                    labelStyle: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: fieldBg,
                    prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFFB5B0A8)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFFE8E3DA).withValues(alpha: _darkMode ? 0.1 : 1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: descController,
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  decoration: InputDecoration(
                    labelText: _t("Bio / Location", "Bio / Lokasi"),
                    labelStyle: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: fieldBg,
                    prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFB5B0A8)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFFE8E3DA).withValues(alpha: _darkMode ? 0.1 : 1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      _saveProfileData(nameController.text, descController.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                    child: Text(_t("Save Changes", "Simpan Perubahan"), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- VARIABEL WARNA DINAMIS (DARK MODE) ---
    final Color bgColor = _darkMode ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
    final Color cardColor = _darkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = _darkMode ? Colors.white : const Color(0xFF2D2622);
    final Color borderColor = _darkMode ? const Color(0xFF333333) : const Color(0xFFF0EBE1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_t("Settings", "Pengaturan"), style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontFamily: 'Serif')),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t("PREFERENCES", "PREFERENSI"), style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            _buildSettingsContainer(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _buildLanguageTile(title: _t("Language", "Bahasa"), textColor: textColor),
                Divider(height: 1, color: borderColor),
                _buildSwitchTile(
                  title: _t("Sound Effects", "Efek Suara"),
                  icon: Icons.volume_up_rounded,
                  textColor: textColor,
                  value: _soundEffects,
                  onChanged: (val) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('setting_sound', val);
                    setState(() => _soundEffects = val);
                  },
                ),
                Divider(height: 1, color: borderColor),

                // POIN 4: Update Global State Dark Mode
                _buildSwitchTile(
                  title: _t("Dark Mode", "Mode Gelap"),
                  icon: Icons.dark_mode_rounded,
                  textColor: textColor,
                  value: _darkMode,
                  onChanged: (val) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('setting_dark', val);
                    setState(() => _darkMode = val);

                    // Memanggil state global dari main.dart
                    globalDarkMode.value = val;
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            Text(_t("ACCOUNT", "AKUN"), style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            _buildSettingsContainer(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _buildLinkTile(title: _t("Edit Profile", "Edit Profil"), icon: Icons.person_outline_rounded, textColor: textColor, onTap: _showEditProfileModal),
                Divider(height: 1, color: borderColor),
                _buildLinkTile(title: _t("Change Password", "Ubah Kata Sandi"), icon: Icons.lock_outline_rounded, textColor: textColor, onTap: (){}),
              ],
            ),
            const SizedBox(height: 32),

            Text(_t("ABOUT", "TENTANG"), style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            _buildSettingsContainer(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                _buildLinkTile(title: _t("Privacy Policy", "Kebijakan Privasi"), icon: Icons.privacy_tip_outlined, textColor: textColor, onTap: (){}),
                Divider(height: 1, color: borderColor),
                _buildLinkTile(title: _t("Terms of Service", "Syarat Ketentuan"), icon: Icons.description_outlined, textColor: textColor, onTap: (){}),
                Divider(height: 1, color: borderColor),
                _buildLinkTile(title: _t("Version", "Versi"), icon: Icons.info_outline_rounded, trailingText: "1.0.0", textColor: textColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContainer({required List<Widget> children, required Color cardColor, required Color borderColor}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLanguageTile({required String title, required Color textColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: const Icon(Icons.language_rounded, color: Color(0xFFCC6633), size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: textColor)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_language == 'en' ? "English" : "Indonesia", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8C8A87))),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF8C8A87)),
        ],
      ),
      onTap: _showLanguageDialog,
    );
  }

  Widget _buildSwitchTile({required String title, required IconData icon, required bool value, required ValueChanged<bool> onChanged, required Color textColor}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: const Color(0xFFCC6633), size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: textColor)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFFCC6633),
        inactiveTrackColor: const Color(0xFF8C8A87).withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildLinkTile({required String title, required IconData icon, String? trailingText, required Color textColor, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: const Color(0xFF8C8A87), size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: textColor)),
      trailing: trailingText != null
          ? Text(trailingText, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8C8A87)))
          : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF8C8A87)),
      onTap: trailingText == null ? onTap : null,
    );
  }
}