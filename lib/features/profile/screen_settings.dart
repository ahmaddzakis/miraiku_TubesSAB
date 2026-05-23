import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart'; // Package baru untuk auto-version
import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _supabase = Supabase.instance.client;

  bool _soundEffects = true;
  bool _darkMode = false;
  String _language = 'en';

  String _userName = "";
  String _userDesc = "";
  String _avatarUrl = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200";

  String _appVersion = "Memuat..."; // Variabel dinamis untuk versi aplikasi

  @override
  void initState() {
    super.initState();
    _initAppVersion();
    _loadUserDataAndSettings();
  }

  // --- 1. MENGAMBIL VERSI DARI PUBSPEC.YAML ---
  Future<void> _initAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = info.version; // Otomatis terbaca dari pubspec.yaml
    });
  }

  // --- 2. LOAD DATA PROFIL & PREFERENSI DARI SUPABASE ---
  Future<void> _loadUserDataAndSettings() async {
    final user = _supabase.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      final meta = user.userMetadata ?? {};
      setState(() {
        _userName = meta['display_name'] ?? user.email?.split('@')[0] ?? "User";
        _userDesc = meta['bio'] ?? "Bandung, West Java";

        // Ambil preferensi dari Cloud Supabase, kalau tidak ada, pakai lokal
        _language = meta['setting_lang'] ?? prefs.getString('setting_lang') ?? 'en';
        _darkMode = meta['setting_dark'] ?? prefs.getBool('setting_dark') ?? false;
        _soundEffects = meta['setting_sound'] ?? prefs.getBool('setting_sound') ?? true;
      });

      // Sinkronkan ke UI utama
      globalLanguage.value = _language;
      globalDarkMode.value = _darkMode;
    }
  }

  // --- 3. SIMPAN PREFERENSI KE SUPABASE & LOKAL ---
  Future<void> _updatePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan ke lokal agar saat aplikasi baru dibuka langsung terbaca
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);

    // Simpan ke Cloud Supabase agar terikat dengan Akun
    try {
      await _supabase.auth.updateUser(UserAttributes(data: {key: value}));
    } catch (e) {
      debugPrint("Gagal menyimpan pengaturan ke Cloud: $e");
    }
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  // ==================== POP-UP GANTI BAHASA ====================
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
              ListTile(title: Text("English", style: TextStyle(color: _darkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)), trailing: _language == 'en' ? const Icon(Icons.check_circle_rounded, color: Color(0xFFCC6633)) : null, onTap: () {
                setState(() => _language = 'en');
                globalLanguage.value = 'en';
                _updatePreference('setting_lang', 'en');
                Navigator.pop(context);
              }),
              ListTile(title: Text("Bahasa Indonesia", style: TextStyle(color: _darkMode ? Colors.white70 : Colors.black87, fontWeight: FontWeight.bold)), trailing: _language == 'id' ? const Icon(Icons.check_circle_rounded, color: Color(0xFFCC6633)) : null, onTap: () {
                setState(() => _language = 'id');
                globalLanguage.value = 'id';
                _updatePreference('setting_lang', 'id');
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  // ==================== EDIT PROFIL ====================
  void _showEditProfileModal() {
    final TextEditingController nameController = TextEditingController(text: _userName);
    final TextEditingController descController = TextEditingController(text: _userDesc);
    final Color modalBg = _darkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF7F2);
    final Color textColor = _darkMode ? Colors.white : const Color(0xFF2D2622);
    final Color fieldBg = _darkMode ? const Color(0xFF2D2D2D) : Colors.white;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
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
                Stack(alignment: Alignment.bottomRight, children: [CircleAvatar(radius: 45, backgroundImage: NetworkImage(_avatarUrl)), Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFCC6633), shape: BoxShape.circle, border: Border.all(color: modalBg, width: 2)), child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white))]),
                const SizedBox(height: 32),
                TextField(controller: nameController, style: TextStyle(fontWeight: FontWeight.bold, color: textColor), decoration: InputDecoration(labelText: _t("Display Name", "Nama Tampilan"), labelStyle: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold), filled: true, fillColor: fieldBg, prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFFB5B0A8)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFFE8E3DA).withValues(alpha: _darkMode ? 0.1 : 1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)))),
                const SizedBox(height: 16),
                TextField(controller: descController, style: TextStyle(fontWeight: FontWeight.bold, color: textColor), decoration: InputDecoration(labelText: _t("Bio / Location", "Bio / Lokasi"), labelStyle: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold), filled: true, fillColor: fieldBg, prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFB5B0A8)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFFE8E3DA).withValues(alpha: _darkMode ? 0.1 : 1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)))),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await _supabase.auth.updateUser(UserAttributes(data: {'display_name': nameController.text, 'bio': descController.text}));
                        setState(() { _userName = nameController.text; _userDesc = descController.text; });
                        if(mounted) Navigator.pop(context);
                      } catch(e) {
                        // Error handling jika butuh
                      }
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

  // ==================== UBAH PASSWORD (SUPABASE AUTH) ====================
  void _showChangePasswordModal() {
    final TextEditingController pwController = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: _darkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF7F2), borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 40, height: 5, decoration: BoxDecoration(color: const Color(0xFF8C8A87).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10))),
                      const SizedBox(height: 24),
                      Text(_t("Change Password", "Ubah Kata Sandi"), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _darkMode ? Colors.white : const Color(0xFF2D2622), fontFamily: 'Serif')),
                      const SizedBox(height: 24),
                      TextField(
                        controller: pwController, obscureText: true,
                        style: TextStyle(fontWeight: FontWeight.bold, color: _darkMode ? Colors.white : const Color(0xFF2D2622)),
                        decoration: InputDecoration(labelText: _t("New Password (Min 6 chars)", "Sandi Baru (Min. 6 Karakter)"), filled: true, fillColor: _darkMode ? const Color(0xFF2D2D2D) : Colors.white, prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFFB5B0A8)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFFE8E3DA).withValues(alpha: _darkMode ? 0.1 : 1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2))),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : () async {
                            if (pwController.text.length < 6) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Password too short!", "Kata sandi terlalu pendek!")), backgroundColor: Colors.red));
                              return;
                            }
                            setModalState(() => isSaving = true);
                            try {
                              await _supabase.auth.updateUser(UserAttributes(password: pwController.text));
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Password updated successfully!", "Kata sandi berhasil diubah!"))));
                              }
                            } on AuthException catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
                            } finally {
                              setModalState(() => isSaving = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                          child: isSaving ? const CircularProgressIndicator(color: Colors.white) : Text(_t("Update Password", "Perbarui Sandi"), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  // ==================== PRIVACY POLICY & TOS ====================
  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _darkMode ? const Color(0xFF2D2D2D) : const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: _darkMode ? Colors.white : const Color(0xFF2D2622))),
        content: SingleChildScrollView(child: Text(content, style: TextStyle(color: _darkMode ? Colors.white70 : Colors.black87, height: 1.5))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t("I Understand", "Saya Mengerti"), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFCC6633)))
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _darkMode ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
    final Color cardColor = _darkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = _darkMode ? Colors.white : const Color(0xFF2D2622);
    final Color borderColor = _darkMode ? const Color(0xFF333333) : const Color(0xFFF0EBE1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(backgroundColor: bgColor, elevation: 0, centerTitle: true, leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: textColor), onPressed: () => Navigator.pop(context)), title: Text(_t("Settings", "Pengaturan"), style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontFamily: 'Serif'))),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_t("PREFERENCES", "PREFERENSI"), style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            _buildSettingsContainer(cardColor: cardColor, borderColor: borderColor, children: [
              _buildLanguageTile(title: _t("Language", "Bahasa"), textColor: textColor),
              Divider(height: 1, color: borderColor),
              _buildSwitchTile(title: _t("Sound Effects", "Efek Suara"), icon: Icons.volume_up_rounded, textColor: textColor, value: _soundEffects, onChanged: (val) {
                setState(() => _soundEffects = val);
                _updatePreference('setting_sound', val);
              }),
              Divider(height: 1, color: borderColor),
              _buildSwitchTile(title: _t("Dark Mode", "Mode Gelap"), icon: Icons.dark_mode_rounded, textColor: textColor, value: _darkMode, onChanged: (val) {
                setState(() => _darkMode = val);
                globalDarkMode.value = val;
                _updatePreference('setting_dark', val);
              })
            ]),
            const SizedBox(height: 32),

            Text(_t("ACCOUNT", "AKUN"), style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            _buildSettingsContainer(cardColor: cardColor, borderColor: borderColor, children: [
              _buildLinkTile(title: _t("Edit Profile", "Edit Profil"), icon: Icons.person_outline_rounded, textColor: textColor, onTap: _showEditProfileModal),
              Divider(height: 1, color: borderColor),
              _buildLinkTile(title: _t("Change Password", "Ubah Kata Sandi"), icon: Icons.lock_outline_rounded, textColor: textColor, onTap: _showChangePasswordModal)
            ]),
            const SizedBox(height: 32),

            Text(_t("ABOUT", "TENTANG"), style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            const SizedBox(height: 12),
            _buildSettingsContainer(cardColor: cardColor, borderColor: borderColor, children: [
              _buildLinkTile(title: _t("Privacy Policy", "Kebijakan Privasi"), icon: Icons.privacy_tip_outlined, textColor: textColor, onTap: () => _showInfoDialog(_t("Privacy Policy", "Kebijakan Privasi"), _t("We collect minimal data such as your email and learning progress solely to improve your experience in the Miraiku app. Your personal data is securely stored and will never be sold to any third parties.", "Kami mengumpulkan data minimal seperti email dan progres belajarmu semata-mata untuk meningkatkan pengalaman di aplikasi Miraiku. Data pribadimu disimpan dengan aman dan tidak akan pernah dijual ke pihak ketiga mana pun."))),
              Divider(height: 1, color: borderColor),
              _buildLinkTile(title: _t("Terms of Service", "Syarat Ketentuan"), icon: Icons.description_outlined, textColor: textColor, onTap: () => _showInfoDialog(_t("Terms of Service", "Syarat Ketentuan"), _t("By using Miraiku, you agree to engage in the learning platform responsibly. Any misuse of the app or attempting to cheat the learning progress systems may result in account termination.", "Dengan menggunakan Miraiku, kamu setuju untuk belajar dengan bertanggung jawab. Segala bentuk penyalahgunaan aplikasi atau kecurangan pada sistem progres belajar dapat mengakibatkan penghapusan akun."))),
              Divider(height: 1, color: borderColor),
              _buildLinkTile(title: _t("Version", "Versi"), icon: Icons.info_outline_rounded, trailingText: _appVersion, textColor: textColor) // VERSI OTOMATIS
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsContainer({required List<Widget> children, required Color cardColor, required Color borderColor}) { return Container(decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: borderColor), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(children: children)); }
  Widget _buildLanguageTile({required String title, required Color textColor}) { return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), leading: const Icon(Icons.language_rounded, color: Color(0xFFCC6633), size: 24), title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: textColor)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(_language == 'en' ? "English" : "Indonesia", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8C8A87))), const SizedBox(width: 8), const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF8C8A87))]), onTap: _showLanguageDialog); }
  Widget _buildSwitchTile({required String title, required IconData icon, required bool value, required ValueChanged<bool> onChanged, required Color textColor}) { return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), leading: Icon(icon, color: const Color(0xFFCC6633), size: 24), title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: textColor)), trailing: Switch(value: value, onChanged: onChanged, activeColor: Colors.white, activeTrackColor: const Color(0xFFCC6633), inactiveTrackColor: const Color(0xFF8C8A87).withValues(alpha: 0.3))); }
  Widget _buildLinkTile({required String title, required IconData icon, String? trailingText, required Color textColor, VoidCallback? onTap}) { return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4), leading: Icon(icon, color: const Color(0xFF8C8A87), size: 24), title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: textColor)), trailing: trailingText != null ? Text(trailingText, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8C8A87))) : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF8C8A87)), onTap: trailingText == null ? onTap : null); }
}