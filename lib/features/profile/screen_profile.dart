import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/game_manager.dart';
import '../../widgets/top_status_bar.dart';
import 'screen_settings.dart';

class _AchievementBadge {
  final String text;
  final bool isLabel;
  _AchievementBadge._(this.text, this.isLabel);
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

  // Metadata User
  String _userName = 'Miraiku User';
  String _userDesc = 'Semangat Belajar Bahasa Jepang!';
  String _userEmail = 'miraiku@example.com';
  String _avatarUrl = '';
  bool _isSaving = false;
  bool _isUploading = false;

  // Local Statistics
  int _highScoreSimulation = 0;
  int _lastClaimedStreak = 0;

  // Achievements Status
  bool _claimedHiragana = false;
  bool _claimedKatakana = false;
  bool _claimedKanji = false;
  bool _claimedSim = false;
  bool _claimed30Days = false;
  bool _claimedAllUnits = false;


  @override
  void initState() {
    super.initState();
    _loadSupabaseUserData();
    _loadLocalStats();
  }

  void _loadSupabaseUserData() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata;
      if (meta != null) {
        setState(() {
          _userName = meta['display_name'] ?? 'Miraiku User';
          _userDesc = meta['bio'] ?? 'Semangat Belajar Bahasa Jepang!';
          _avatarUrl = meta['avatar_url'] ?? '';
          _userEmail = user.email ?? 'miraiku@example.com';

          // Achievements from metadata
          _claimedHiragana = meta['ach_hira'] ?? false;
          _claimedKatakana = meta['ach_kata'] ?? false;
          _claimedKanji = meta['ach_kanji'] ?? false;
          _claimedSim = meta['ach_sim'] ?? false;
          _claimed30Days = meta['ach_30d'] ?? false;
          _claimedAllUnits = meta['ach_units'] ?? false;
        });
      }
    }
  }

  Future<void> _loadLocalStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScoreSimulation = prefs.getInt('simulation_high_score') ?? 0;
      _lastClaimedStreak = prefs.getInt('last_claimed_streak') ?? 0;
    });

    // Award bonus if first time setting up
    if (prefs.getBool('first_profile_bonus') == null) {
      await GameManager.addXP(200);
      await prefs.setBool('first_profile_bonus', true);
    }
  }

  Future<void> _claimAchievement(String key) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(data: {
        key: true,
      }));
      await GameManager.addXP(200);
      _loadSupabaseUserData(); // Refresh UI
      if (mounted) {
        _showSuccessDialog(_t("Achievement Claimed!", "Pencapaian Diklaim!"),);
      }
    } catch (e) {
      if (mounted) _showErrorDialog(_t("Claim Failed", "Gagal Klaim"), e.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
              child: const Icon(Icons.error_outline_rounded, color: Color(0xFFE53935), size: 40),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF333333))),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF4CAF50), size: 40),
            ),
            const SizedBox(height: 20),
            Text(_t("Success", "Berhasil"), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF333333))),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                onPressed: () => Navigator.pop(context),
                child: Text(_t("OK", "MANTAP!"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getAvatarImage() {
    if (_avatarUrl.isNotEmpty && _avatarUrl.startsWith('http')) {
      return NetworkImage(_avatarUrl);
    } else {
      return const AssetImage('assets/images/profileDefault.png');
    }
  }

  Future<void> _uploadProfilePicture(StateSetter setModalState) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: _t('Adjust Photo', 'Sesuaikan Foto'),
          toolbarColor: const Color(0xFFCC6633),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(title: _t('Adjust Photo', 'Sesuaikan Foto'), aspectRatioLockEnabled: true),
      ],
    );

    if (croppedFile == null) return;

    final file = File(croppedFile.path);
    final fileSizeInMB = (await file.length()) / (1024 * 1024);

    if (fileSizeInMB > 5.0) {
      if (mounted) {
        _showErrorDialog(
          _t("Image too large!", "Gambar Terlalu Besar"),
          _t("Maximum file size is 5MB.", "Ukuran file maksimal adalah 5MB.")
        );
      }
      return;
    }

    setModalState(() => _isUploading = true);
    setState(() => _isUploading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception(_t("User not authenticated.", "Pengguna tidak terautentikasi."));
      }

      final bytes = await file.readAsBytes();
      final fileExt = file.path.split('.').last.toLowerCase();
      final mimeType = fileExt == 'jpg' || fileExt == 'jpeg' ? 'image/jpeg' : 'image/$fileExt';
      
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '${user.id}/$fileName';

      // 1. Upload file ke Storage
      await _supabase.storage.from('avatars').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(
          contentType: mimeType,
          upsert: true,
        ),
      );

      // 2. Dapatkan URL Public
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      // 3. Update metadata User melalui GameManager agar sinkron
      await GameManager.syncToCloud(avatarUrl: imageUrl);
      
      if (mounted) {
        setState(() => _avatarUrl = imageUrl);
        _showSuccessDialog(_t("Profile picture updated!", "Foto profil berhasil diperbarui!"));
      }
    } on StorageException catch (e) {
      if (mounted) {
        final isRLS = e.statusCode == '403' || e.message.contains('Permission denied') || e.message.contains('new row violates row-level security');
        _showErrorDialog(
          _t("Upload Error", "Gagal Unggah"),
          isRLS 
            ? _t("Access denied (403). Please check your Supabase Storage RLS policies for the 'avatars' bucket.", 
                 "Akses ditolak (403). Pastikan kebijakan RLS Storage Supabase untuk bucket 'avatars' sudah diatur.")
            : e.message
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(_t("Upload Failed", "Gagal Unggah"), e.toString());
      }
    } finally {
      if (mounted) {
        setModalState(() => _isUploading = false);
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _saveProfileData(String name, String desc) async {
    setState(() => _isSaving = true);
    try {
      await GameManager.syncToCloud(displayName: name, bio: desc);
      if (mounted) {
        setState(() {
          _userName = name;
          _userDesc = desc;
        });
        _showSuccessDialog(_t("Profile updated successfully!", "Profil berhasil diperbarui!"));
      }
    } on AuthException catch (error) {
      if (mounted) _showErrorDialog(_t("Update Failed", "Gagal Memperbarui"), error.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _claimDailyReward() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";
    final lastClaim = prefs.getString('last_daily_xp_claim');

    if (lastClaim == today) {
      if (mounted) {
        _showErrorDialog(
          _t("Already Claimed", "Sudah Diklaim"), 
          _t("Come back tomorrow for more XP!", "Kembali lagi besok untuk XP lainnya!")
        );
      }
      return;
    }

    // LOGIKA HADIAH: 100 XP Biasa, 500 XP Jika Streak 7 Hari
    bool isWeekly = globalStreak.value > 0 && globalStreak.value % 7 == 0;
    int rewardXp = isWeekly ? 500 : 100;
    
    await GameManager.addXP(rewardXp);
    await prefs.setString('last_daily_xp_claim', today);

    if (mounted) {
      _showSuccessDialog(
        isWeekly 
          ? _t("Weekly Bonus: +$rewardXp XP!", "Bonus Mingguan: +$rewardXp XP!")
          : _t("Daily Reward: +$rewardXp XP!", "Hadiah Harian: +$rewardXp XP!")
      );
    }
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  void _showWeeklyStreakDialog(BuildContext context, bool isDark, int currentStreak, int daysThisWeek) {
    final List<String> daysIds = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final bool alreadyClaimed = _lastClaimedStreak >= currentStreak && currentStreak > 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 64),
                const SizedBox(height: 16),
                Text(_t("Weekly Streak", "Skor Mingguan"), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF333333))),
                const SizedBox(height: 8),
                Text(
                  _t("You have logged in for $currentStreak days! Keep it up for big XP rewards.", 
                     "Kamu sudah login selama $currentStreak hari! Pertahankan untuk hadiah XP besar."),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : const Color(0xFF666666), height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    bool isActive = index < daysThisWeek;
                    return Column(
                      children: [
                        Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: isActive ? Colors.orange : (isDark ? const Color(0xFF333333) : const Color(0xFFF1EFE8)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(isActive ? Icons.check_rounded : Icons.lock_rounded, size: 16, color: isActive ? Colors.white : (isDark ? Colors.white24 : Colors.black26)),
                        ),
                        const SizedBox(height: 6),
                        Text(daysIds[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black45)),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: alreadyClaimed ? (isDark ? Colors.white12 : const Color(0xFFEFEFEF)) : const Color(0xFFCC6633),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: (currentStreak > 0 && !alreadyClaimed) ? () async {
                      final prefs = await SharedPreferences.getInstance();
                      await GameManager.addXP(currentStreak * 100);
                      await prefs.setInt('last_claimed_streak', currentStreak);
                      if (context.mounted) {
                        setState(() => _lastClaimedStreak = currentStreak);
                        Navigator.pop(context);
                        _showSuccessDialog(_t("You got ${currentStreak * 100} XP!", "Kamu dapat ${currentStreak * 100} XP!"));
                      }
                    } : null,
                    icon: Icon(alreadyClaimed ? Icons.check_circle_rounded : Icons.stars_rounded, color: alreadyClaimed ? Colors.green : Colors.white),
                    label: Text(
                      alreadyClaimed ? _t("ALREADY CLAIMED", "SUDAH DIKLAIM") : (currentStreak > 0 ? _t("CLAIM XP BONUS", "KLAIM BONUS XP") : _t("NOT YET UNLOCKED", "BELUM TERBUKA")),
                      style: TextStyle(fontWeight: FontWeight.w900, color: alreadyClaimed ? Colors.green : Colors.white, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  void _showEditProfileModal() {
    final nameController = TextEditingController(text: _userName);
    final descController = TextEditingController(text: _userDesc);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE8E3DA), borderRadius: BorderRadius.circular(2)), alignment: Alignment.center),
                  const SizedBox(height: 24),
                  Text(_t("Edit Profile", "Edit Profil"), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF333333))),
                  const SizedBox(height: 32),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(radius: 50, backgroundColor: const Color(0xFFF9F6F0), backgroundImage: _getAvatarImage()),
                      if (_isUploading)
                        const Positioned.fill(child: Center(child: CircularProgressIndicator(color: Color(0xFFCC6633)))),
                      GestureDetector(
                        onTap: () => _uploadProfilePicture(setModalState),
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: _t('Display Name', 'Nama Tampilan'),
                      prefixIcon: const Icon(Icons.person_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: _t('Bio', 'Bio'),
                      prefixIcon: const Icon(Icons.info_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                      onPressed: _isSaving ? null : () async {
                        await _saveProfileData(nameController.text, descController.text);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: _isSaving 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_t("SAVE CHANGES", "SIMPAN PERUBAHAN"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
        final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
        final Color textColor = isDark ? Colors.white : const Color(0xFF333333);
        final Color subTextColor = isDark ? Colors.white70 : const Color(0xFF8C8A87);
        final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA);

        int claimedCount = 0;
        if (_claimedHiragana) claimedCount++;
        if (_claimedKatakana) claimedCount++;
        if (_claimedKanji) claimedCount++;
        if (_claimedSim) claimedCount++;
        if (_claimed30Days) claimedCount++;
        if (_claimedAllUnits) claimedCount++;

        return Scaffold(
          backgroundColor: bgColor,
          body: RefreshIndicator(
            onRefresh: () async {
              _loadSupabaseUserData();
              await _loadLocalStats();
            },
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        // PROFILE HEADER
                        Center(
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFCC6633), width: 3),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: cardColor,
                                backgroundImage: _getAvatarImage(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(_userName, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: textColor)),
                        const SizedBox(height: 8),
                        Text(_userDesc, style: TextStyle(fontSize: 14, color: subTextColor, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text(_userEmail, style: TextStyle(fontSize: 14, color: subTextColor.withOpacity(0.6))),
                        
                        const SizedBox(height: 32),
                        
                        // REKOR BELAJAR CARD
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GestureDetector(
                            onTap: _claimDailyReward,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCC6633).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(Icons.local_fire_department_rounded, color: Color(0xFFCC6633), size: 32),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(_t("Learning Record", "Rekor Belajar"), style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _t("${globalStreak.value} Days Streak!", "${globalStreak.value} Hari Berturut-turut!"),
                                              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w900),
                                            ),
                                            Text(
                                              "${globalStreak.value % 7 == 0 && globalStreak.value > 0 ? 7 : globalStreak.value % 7}/7",
                                              style: TextStyle(
                                                color: globalStreak.value > 0 && globalStreak.value % 7 == 0 ? Colors.orange : const Color(0xFFCC6633), 
                                                fontSize: 20, 
                                                fontWeight: FontWeight.w900
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: LinearProgressIndicator(
                                            value: (globalStreak.value % 7 == 0 && globalStreak.value > 0 ? 7 : globalStreak.value % 7) / 7,
                                            minHeight: 10,
                                            backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA),
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              globalStreak.value > 0 && globalStreak.value % 7 == 0 ? Colors.orange : const Color(0xFFCC6633)
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                        
                        // ACHIEVEMENTS SECTION
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_t("Achievements", "Pencapaian"), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textColor)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFCC6633).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.emoji_events_rounded, color: Color(0xFFCC6633), size: 16),
                                        const SizedBox(width: 4),
                                        Text("$claimedCount / 6", style: const TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.w900)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    _buildAchievementCardH(
                                      badge: _AchievementBadge.text("あ"),
                                      bgColor: const Color(0xFFE8F5E9),
                                      accentColor: const Color(0xFF4CAF50),
                                      title: _t("Hiragana Master", "Ahli Hiragana"),
                                      progress: (globalLearnedHiragana.value.length / 46).clamp(0.0, 1.0),
                                      progressLabel: "${globalLearnedHiragana.value.length}/46",
                                      isCompleted: globalLearnedHiragana.value.length >= 46,
                                      isClaimed: _claimedHiragana,
                                      onClaim: () => _claimAchievement('ach_hira'),
                                      cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                    ),
                                    _buildAchievementCardH(
                                      badge: _AchievementBadge.text("ア"),
                                      bgColor: const Color(0xFFE3F2FD),
                                      accentColor: const Color(0xFF2196F3),
                                      title: _t("Katakana Master", "Ahli Katakana"),
                                      progress: (globalLearnedKatakana.value.length / 46).clamp(0.0, 1.0),
                                      progressLabel: "${globalLearnedKatakana.value.length}/46",
                                      isCompleted: globalLearnedKatakana.value.length >= 46,
                                      isClaimed: _claimedKatakana,
                                      onClaim: () => _claimAchievement('ach_kata'),
                                      cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                    ),
                                    _buildAchievementCardH(
                                      badge: _AchievementBadge.text("漢"),
                                      bgColor: const Color(0xFFF3E5F5),
                                      accentColor: const Color(0xFF9C27B0),
                                      title: _t("Kanji Master", "Ahli Kanji"),
                                      progress: (globalLearnedKanji.value.length / 28).clamp(0.0, 1.0),
                                      progressLabel: "${globalLearnedKanji.value.length}/28",
                                      isCompleted: globalLearnedKanji.value.length >= 28,
                                      isClaimed: _claimedKanji,
                                      onClaim: () => _claimAchievement('ach_kanji'),
                                      cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                    ),
                                    _buildAchievementCardH(
                                      badge: _AchievementBadge.label("ALL"),
                                      bgColor: const Color(0xFFEFEBE9),
                                      accentColor: const Color(0xFF795548),
                                      title: _t("Alphabet Master", "Penguasa Alfabet"),
                                      progress: (_claimedHiragana && _claimedKatakana && _claimedKanji) ? 1.0 : 0.5,
                                      progressLabel: "Unit 1-4",
                                      isCompleted: _claimedHiragana && _claimedKatakana && _claimedKanji,
                                      isClaimed: _claimedAllUnits,
                                      onClaim: () => _claimAchievement('ach_units'),
                                      cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                    ),
                                    _buildAchievementCardH(
                                      badge: _AchievementBadge.label("SIM"),
                                      bgColor: const Color(0xFFFFF3E0),
                                      accentColor: const Color(0xFFFF9800),
                                      title: _t("Simulator Pro", "Pro Simulator"),
                                      progress: (_highScoreSimulation / 1000).clamp(0.0, 1.0),
                                      progressLabel: "$_highScoreSimulation/1000",
                                      isCompleted: _highScoreSimulation >= 1000,
                                      isClaimed: _claimedSim,
                                      onClaim: () => _claimAchievement('ach_sim'),
                                      cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                    ),
                                    _buildAchievementCardH(
                                      badge: _AchievementBadge.label("30D"),
                                      bgColor: const Color(0xFFFCE4EC),
                                      accentColor: const Color(0xFFE91E63),
                                      title: _t("30 Days Streak", "30 Hari Beruntun"),
                                      progress: (globalStreak.value / 30).clamp(0.0, 1.0),
                                      progressLabel: "${globalStreak.value}/30",
                                      isCompleted: globalStreak.value >= 30,
                                      isClaimed: _claimed30Days,
                                      onClaim: () => _claimAchievement('ach_30d'),
                                      cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        
                        // MENU OPTIONS
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor, 
                              borderRadius: BorderRadius.circular(32), 
                              border: Border.all(color: borderColor)
                            ),
                            child: Column(
                              children: [
                                _buildMenuTile(
                                  context: context, 
                                  icon: Icons.settings_rounded, 
                                  title: _t("Settings", "Pengaturan"), 
                                  subtitle: _t("Manage your account preferences", "Kelola preferensi akunmu"), 
                                  color: Colors.orange, 
                                  textColor: textColor, 
                                  subTextColor: subTextColor, 
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())), 
                                  isDark: isDark
                                ),
                                Divider(height: 1, color: borderColor, indent: 70),
                                _buildMenuTile(
                                  context: context, 
                                  icon: Icons.notifications_rounded, 
                                  title: _t("Notifications", "Notifikasi"), 
                                  subtitle: _t("Daily reminders & info", "Pengingat harian & info"), 
                                  color: Colors.orangeAccent, 
                                  textColor: textColor, 
                                  subTextColor: subTextColor, 
                                  onTap: () {}, 
                                  isDark: isDark
                                ),
                                Divider(height: 1, color: borderColor, indent: 70),
                                _buildMenuTile(
                                  context: context, 
                                  icon: Icons.logout_rounded, 
                                  title: _t("Logout", "Keluar"), 
                                  subtitle: _t("Sign out from Miraiku account", "Keluar dari akun Miraiku"), 
                                  color: Colors.redAccent, 
                                  textColor: textColor, 
                                  subTextColor: subTextColor, 
                                  onTap: () => _showLogoutConfirmation(context, isDark), 
                                  isLogout: true, 
                                  isDark: isDark
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label, ValueListenable<dynamic> notifier, Color color, bool isDark, Color cardColor, Color textColor, Color subTextColor, Color borderColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, value, _) => Text(value.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)),
            ),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: subTextColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCardH({required _AchievementBadge badge, required Color bgColor, required Color accentColor, Color badgeTextColor = Colors.black87, required String title, required double progress, String? progressLabel, bool isCompleted = false, bool isClaimed = false, VoidCallback? onClaim, required Color cardColor, required Color textColor, required Color borderColor, required bool isDark, required Color subTextColor}) {
    Widget bottomWidget;
    if (isClaimed) {
      bottomWidget = Row(children: [const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF58CC02)), const SizedBox(width: 4), Text(_t("Already Claimed", "Sudah Diklaim"), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF58CC02)))]);
    } else if (isCompleted) {
      bottomWidget = GestureDetector(
        onTap: onClaim,
        child: Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF58CC02), borderRadius: BorderRadius.circular(8)),
          child: const Center(child: Text("KLAIM 200 XP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white))),
        ),
      );
    } else {
      bottomWidget = Text(progressLabel ?? "", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subTextColor));
    }

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isCompleted && !isClaimed ? const Color(0xFF58CC02).withOpacity(0.5) : borderColor,
          width: isCompleted && !isClaimed ? 2 : 1
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFF1EFE8),
              shape: BoxShape.circle
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  badge.text,
                  style: TextStyle(
                    fontSize: badge.isLabel ? 14 : 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white38 : Colors.black26
                  )
                ),
                if (isCompleted)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Color(0xFF58CC02), shape: BoxShape.circle),
                      child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: textColor, height: 1.1)
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFF1EFE8),
              valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? const Color(0xFF58CC02) : const Color(0xFFCC6633))
            )
          ),
          const SizedBox(height: 12),
          bottomWidget
        ]
      )
    );
  }

  Widget _buildMenuTile({required BuildContext context, required IconData icon, required String title, required String subtitle, required Color color, required Color textColor, required Color subTextColor, required VoidCallback onTap, bool isLogout = false, required bool isDark}) {
    return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isLogout ? (isDark ? Colors.red.withOpacity(0.2) : const Color(0xFFFFF1F1)) : color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 22)), title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor)), subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subTextColor, fontWeight: FontWeight.w500)), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFB5B0A8)), onTap: onTap);
  }

  void _showLogoutConfirmation(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(_t("Logout?", "Keluar?"), style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
        content: Text(_t("Are you sure you want to sign out?", "Apakah anda yakin ingin keluar dari akun?"), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_t("CANCEL", "BATAL"), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              await _supabase.auth.signOut();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
              }
            },
            child: Text(_t("LOGOUT", "KELUAR"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
