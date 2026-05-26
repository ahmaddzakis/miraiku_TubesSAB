import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../core/game_manager.dart'; // Tempat globalXP dkk biasanya berada
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

  // Data Profil
  String _userName = "";
  String _userDesc = "";
  String _userEmail = "";
  String _avatarUrl = "";
  bool _isSaving = false;
  bool _isUploading = false;

  // Data Statistik
  int _highScoreSimulation = 0;
  int _lastClaimedStreak = 0;

  // Status Klaim Achievement (Professional: Simpan ke Cloud)
  bool _claimedHiragana = false;
  bool _claimedKatakana = false;
  bool _claimedSim = false;
  bool _claimed30Days = false;

  @override
  void initState() {
    super.initState();
    _loadSupabaseUserData();
    _loadLocalStats();
  }

  void _loadSupabaseUserData() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata ?? {};
      setState(() {
        _userEmail = user.email ?? "";
        _userName = meta['display_name'] ?? _userEmail.split('@')[0];
        _userDesc = meta['bio'] ?? "Japanese Learner";
        _avatarUrl = meta['avatar_url'] ?? "";

        // Load status klaim dari Cloud
        _claimedHiragana = meta['claim_achiev_hiragana'] ?? false;
        _claimedKatakana = meta['claim_achiev_katakana'] ?? false;
        _claimedSim = meta['claim_achiev_sim'] ?? false;
        _claimed30Days = meta['claim_achiev_30days'] ?? false;
      });
    }
  }

  Future<void> _loadLocalStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScoreSimulation = prefs.getInt('high_score_sim') ?? 0;
      _lastClaimedStreak = prefs.getInt('last_claimed_streak') ?? 0;
    });

    if (globalStreak.value < _lastClaimedStreak) {
      setState(() => _lastClaimedStreak = 0);
      await prefs.setInt('last_claimed_streak', 0);
    }
  }

  // Fungsi untuk mengklaim hadiah achievement (Professional: Hanya boleh 1x)
  Future<void> _claimAchievement(String key) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // 1. Tambah XP (Otomatis sync ke Cloud di GameManager)
    await GameManager.addXP(200);

    // 2. Tandai metadata Cloud agar tidak bisa klaim lagi selamanya
    try {
      await _supabase.auth.updateUser(UserAttributes(data: {
        key: true,
      }));

      setState(() {
        if (key == 'claim_achiev_hiragana') _claimedHiragana = true;
        if (key == 'claim_achiev_katakana') _claimedKatakana = true;
        if (key == 'claim_achiev_sim') _claimedSim = true;
        if (key == 'claim_achiev_30days') _claimed30Days = true;
      });

      _showSuccessDialog("🎉 200 XP Berhasil Diklaim!");
    } catch (e) {
      debugPrint("Gagal klaim: $e");
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFFCC6633), size: 80),
            const SizedBox(height: 24),
            Text(_t("Pencapaian!", "Achievement!"), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, fontFamily: 'Serif')),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCC6633),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("MANTAP!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Image too large! Max 5MB.", "Gambar terlalu besar! Maks 5MB.")), backgroundColor: Colors.red));
      return;
    }

    setModalState(() => _isUploading = true);
    setState(() => _isUploading = true);

    try {
      final bytes = await file.readAsBytes();
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '/$fileName';

      await _supabase.storage.from('avatars').uploadBinary(filePath, bytes);
      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      await _supabase.auth.updateUser(UserAttributes(data: {'avatar_url': imageUrl}));
      if (mounted) {
        setState(() => _avatarUrl = imageUrl);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Profile picture updated!", "Foto profil diperbarui!")), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Failed to upload image.", "Gagal mengunggah gambar.")), backgroundColor: Colors.red));
    } finally {
      setModalState(() => _isUploading = false);
      setState(() => _isUploading = false);
    }
  }

  Future<void> _saveProfileData(String name, String desc) async {
    setState(() => _isSaving = true);
    try {
      await _supabase.auth.updateUser(UserAttributes(data: {'display_name': name, 'bio': desc}));
      setState(() { _userName = name; _userDesc = desc; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Profile updated successfully!", "Profil Berhasil Diperbarui!")), backgroundColor: Colors.green));
    } on AuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _t(String en, String id) => globalLanguage.value == 'id' ? id : en;

  void _showWeeklyStreakDialog(BuildContext context, bool isDark, int currentStreak, int daysThisWeek) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setDialogState) {
                bool alreadyClaimed = _lastClaimedStreak == currentStreak && currentStreak > 0;
                bool canClaim = daysThisWeek == 7 && !alreadyClaimed;

                return AlertDialog(
                  backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF9F6F0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: Column(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 48, color: Color(0xFFFF9600)),
                      const SizedBox(height: 12),
                      Text(_t("Weekly Streak", "Rekor Mingguan"), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF333333))),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _t(
                            "You have logged in for $currentStreak days! Complete a full 7-day streak to claim a massive XP reward.",
                            "Kamu sudah belajar selama $currentStreak hari berturut-turut! Penuhi 1 minggu penuh tanpa bolong untuk mendapatkan hadiah XP besar."
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF666666), height: 1.5, fontSize: 13),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(7, (index) {
                          bool isActive = index < daysThisWeek;
                          List<String> daysIds = ['H1', 'H2', 'H3', 'H4', 'H5', 'H6', 'H7'];

                          return Column(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFFFF9600) : (isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade300),
                                  shape: BoxShape.circle,
                                  border: isActive ? Border.all(color: const Color(0xFFFFD54F), width: 2) : null,
                                ),
                                child: Icon(
                                    isActive ? Icons.local_fire_department_rounded : Icons.lock_rounded,
                                    size: 16,
                                    color: isActive ? Colors.white : (isDark ? Colors.white30 : Colors.grey.shade500)
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(daysIds[index], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.grey.shade600))
                            ],
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canClaim ? const Color(0xFF58CC02) : (isDark ? const Color(0xFF444444) : Colors.grey.shade300),
                            disabledBackgroundColor: isDark ? const Color(0xFF444444) : Colors.grey.shade300,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: canClaim ? 2 : 0,
                          ),
                          onPressed: canClaim ? () async {
                            globalXP.value += 700;
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('user_xp', globalXP.value);
                            await prefs.setInt('last_claimed_streak', currentStreak);

                            setState(() => _lastClaimedStreak = currentStreak);
                            setDialogState(() {});

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🎉 Selamat! 700 XP berhasil diklaim!"), backgroundColor: Color(0xFF58CC02)));
                            }
                          } : null,
                          icon: Icon(alreadyClaimed ? Icons.check_circle_rounded : Icons.stars_rounded, color: canClaim ? Colors.white : Colors.grey, size: 20),
                          label: Text(
                            alreadyClaimed
                                ? _t("CLAIMED!", "SUDAH DIKLAIM")
                                : (canClaim ? _t("CLAIM 700 XP", "KLAIM 700 XP") : _t("NOT YET UNLOCKED", "BELUM TERBUKA")),
                            style: TextStyle(color: canClaim ? Colors.white : Colors.grey, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
          );
        }
    );
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
                          CircleAvatar(radius: 45, backgroundImage: _getAvatarImage(), backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA)),
                          if (_isUploading)
                            const Positioned.fill(child: Center(child: CircularProgressIndicator(color: Color(0xFFCC6633))))
                          else
                            GestureDetector(
                              onTap: () => _uploadProfilePicture(setModalState),
                              child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFCC6633), shape: BoxShape.circle, border: Border.all(color: modalBg, width: 2)), child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      TextField(controller: nameController, style: TextStyle(fontWeight: FontWeight.bold, color: textColor), decoration: InputDecoration(labelText: _t("Display Name", "Nama Tampilan"), labelStyle: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold), filled: true, fillColor: fieldBg, prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFFB5B0A8)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFFE8E3DA).withValues(alpha: isDark ? 0.1 : 1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)))),
                      const SizedBox(height: 16),
                      TextField(controller: descController, style: TextStyle(fontWeight: FontWeight.bold, color: textColor), decoration: InputDecoration(labelText: "Bio", labelStyle: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold), filled: true, fillColor: fieldBg, prefixIcon: const Icon(Icons.info_outline_rounded, color: Color(0xFFB5B0A8)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: const Color(0xFFE8E3DA).withValues(alpha: isDark ? 0.1 : 1))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)))),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity, height: 54,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : () async {
                            setModalState(() => _isSaving = true);
                            await _saveProfileData(nameController.text, descController.text);

                            if (!mounted) return;

                            setModalState(() => _isSaving = false);
                            Navigator.pop(context);
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
          child: ValueListenableBuilder<int>(
              valueListenable: globalXP,
              builder: (context, currentXP, _) {
                return ValueListenableBuilder<int>(
                    valueListenable: globalStreak,
                    builder: (context, currentStreak, _) {
                      return ValueListenableBuilder<List<String>>(
                          valueListenable: globalLearnedHiragana,
                          builder: (context, learnedHiraList, _) {
                            final hiraganaCount = learnedHiraList.length;
                            return ValueListenableBuilder<List<String>>(
                                valueListenable: globalLearnedKatakana,
                                builder: (context, learnedKataList, _) {
                                  final katakanaCount = learnedKataList.length;

                                  // Status Selesai
                                  bool hiraCompleted = hiraganaCount >= 104;
                                  bool kataCompleted = katakanaCount >= 104;
                                  bool simCompleted = _highScoreSimulation >= 100;
                                  bool streakCompleted = currentStreak >= 30;

                                  int completedCount = 0;
                                  if (hiraCompleted) completedCount++;
                                  if (kataCompleted) completedCount++;
                                  if (simCompleted) completedCount++;
                                  if (streakCompleted) completedCount++;

                                  int daysThisWeek = currentStreak == 0 ? 0 : ((currentStreak - 1) % 7) + 1;
                                  double streakProgress = (daysThisWeek / 7.0).clamp(0.0, 1.0);
                                  bool isWeekCompleted = daysThisWeek == 7;
                                  bool isRewardClaimed = _lastClaimedStreak == currentStreak;

                                  return Column(
                                    children: [
                                      const SizedBox(height: 60),

                                      Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(color: const Color(0xFFCC6633).withValues(alpha: 0.2), shape: BoxShape.circle),
                                              child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: const BoxDecoration(color: Color(0xFFCC6633), shape: BoxShape.circle),
                                                  child: CircleAvatar(radius: 55, backgroundImage: _getAvatarImage(), backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA))
                                              )
                                          ),
                                          GestureDetector(
                                              onTap: _showEditProfileModal,
                                              child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle, border: Border.all(color: bgColor, width: 3), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]), child: const Icon(Icons.edit_rounded, size: 18, color: Color(0xFFCC6633)))
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(_userName, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
                                      const SizedBox(height: 6),
                                      Text(_userDesc, style: TextStyle(color: subTextColor, fontSize: 14, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(_userEmail, style: TextStyle(color: subTextColor.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 40),

                                      GestureDetector(
                                        onTap: () => _showWeeklyStreakDialog(context, isDark, currentStreak, daysThisWeek),
                                        child: Container(
                                          width: double.infinity, padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isWeekCompleted && !isRewardClaimed ? const Color(0xFFC8E6C9) : borderColor, width: isWeekCompleted && !isRewardClaimed ? 2 : 1), boxShadow: [BoxShadow(color: const Color(0xFFFF9600).withValues(alpha: isDark ? 0.02 : 0.08), blurRadius: 20, offset: const Offset(0, 10))]),
                                          child: Row(
                                            children: [
                                              Container(
                                                  width: 60, height: 60,
                                                  decoration: BoxDecoration(color: isWeekCompleted && !isRewardClaimed ? const Color(0xFF58CC02).withValues(alpha: 0.15) : (isDark ? const Color(0xFF3A2A1A) : const Color(0xFFFFF6ED)), borderRadius: BorderRadius.circular(18)),
                                                  child: Icon(isWeekCompleted && !isRewardClaimed ? Icons.redeem_rounded : Icons.local_fire_department_rounded, color: isWeekCompleted && !isRewardClaimed ? const Color(0xFF58CC02) : const Color(0xFFFF9600), size: 34)
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(_t("Days Streak", "Rekor Belajar"), style: TextStyle(fontSize: 13, color: subTextColor, fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                        isWeekCompleted && !isRewardClaimed
                                                            ? _t("Claim your 700 XP!", "Klaim Hadiah 700 XP!")
                                                            : _t("$currentStreak Days in a row!", "$currentStreak Hari Berturut-turut!"),
                                                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: isWeekCompleted && !isRewardClaimed ? const Color(0xFF58CC02) : textColor)
                                                    ),
                                                    const SizedBox(height: 8),
                                                    ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: LinearProgressIndicator(
                                                            value: streakProgress,
                                                            minHeight: 8,
                                                            backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFF1EFE8),
                                                            valueColor: AlwaysStoppedAnimation<Color>(isWeekCompleted && !isRewardClaimed ? const Color(0xFF58CC02) : const Color(0xFFFF9600))
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Text(
                                                  "$daysThisWeek/7",
                                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isWeekCompleted && !isRewardClaimed ? const Color(0xFF58CC02) : const Color(0xFFFF9600))
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 40),

                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(_t("Achievements", "Pencapaian"), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor)),
                                              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: isDark ? const Color(0xFF3A2415) : const Color(0xFFFFF4E8), borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFFCC6633)), const SizedBox(width: 6), Text("$completedCount / 4", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFCC6633)))]))
                                            ],
                                          ),
                                          const SizedBox(height: 20),
                                          SizedBox(
                                            height: 190,
                                            child: ListView(
                                              scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(), clipBehavior: Clip.none,
                                              children: [
                                                _buildAchievementCardH(
                                                    badge: _AchievementBadge.text("あ"), bgColor: const Color(0xFFFFF4E8), accentColor: const Color(0xFFCC6633), title: "Hiragana\nMaster",
                                                    progress: (hiraganaCount / 104).clamp(0.0, 1.0), progressLabel: "$hiraganaCount / 104",
                                                    isCompleted: hiraCompleted, isClaimed: _claimedHiragana,
                                                    onClaim: () => _claimAchievement('claim_achiev_hiragana'),
                                                    cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor
                                                ),
                                                _buildAchievementCardH(
                                                    badge: _AchievementBadge.text("ア"), bgColor: const Color(0xFFE8F5E9), accentColor: const Color(0xFF4CAF50), title: "Katakana\nMaster",
                                                    progress: (katakanaCount / 104).clamp(0.0, 1.0), progressLabel: "$katakanaCount / 104",
                                                    isCompleted: kataCompleted, isClaimed: _claimedKatakana,
                                                    onClaim: () => _claimAchievement('claim_achiev_katakana'),
                                                    cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor
                                                ),
                                                _buildAchievementCardH(
                                                    badge: _AchievementBadge.label("SIM"), bgColor: const Color(0xFFE3F2FD), badgeTextColor: const Color(0xFF2196F3), accentColor: const Color(0xFF2196F3), title: "Simulation\nAce",
                                                    progress: (_highScoreSimulation / 100).clamp(0.0, 1.0), progressLabel: _highScoreSimulation == 0 ? "(TBA)" : "$_highScoreSimulation / 100",
                                                    isCompleted: simCompleted, isClaimed: _claimedSim,
                                                    onClaim: () => _claimAchievement('claim_achiev_sim'),
                                                    cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor
                                                ),
                                                _buildAchievementCardH(
                                                    badge: _AchievementBadge.label("30"), bgColor: const Color(0xFFFFF8E1), badgeTextColor: const Color(0xFFFF9600), accentColor: const Color(0xFFFF9600), title: "30 Days\nStreak",
                                                    progress: (currentStreak / 30).clamp(0.0, 1.0), progressLabel: "${currentStreak > 30 ? 30 : currentStreak} / 30",
                                                    isCompleted: streakCompleted, isClaimed: _claimed30Days,
                                                    onClaim: () => _claimAchievement('claim_achiev_30days'),
                                                    cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark, subTextColor: subTextColor
                                                ),
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
                                                            Navigator.pop(ctx);
                                                            final prefs = await SharedPreferences.getInstance();
                                                            final keys = prefs.getKeys();
                                                            for (String key in keys) {
                                                              if (key != 'setting_dark' && key != 'setting_lang') {
                                                                await prefs.remove(key);
                                                              }
                                                            }
                                                            await _supabase.auth.signOut();
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
                                  );
                                }
                            );
                          }
                      );
                    }
                );
              }
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCardH({required _AchievementBadge badge, required Color bgColor, required Color accentColor, Color badgeTextColor = Colors.black87, required String title, required double progress, String? progressLabel, bool isCompleted = false, bool isClaimed = false, VoidCallback? onClaim, required Color cardColor, required Color textColor, required Color borderColor, required bool isDark, required Color subTextColor}) {

    // Tampilan tombol atau teks di bagian paling bawah
    Widget bottomWidget;
    if (isClaimed) {
      bottomWidget = Row(children: [const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF58CC02)), const SizedBox(width: 4), Text(_t("Claimed", "Sudah Diklaim"), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF58CC02)))]);
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

    return Container(width: 135, margin: const EdgeInsets.only(right: 16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(24), border: Border.all(color: isCompleted && !isClaimed ? const Color(0xFF58CC02).withValues(alpha: 0.5) : borderColor, width: isCompleted && !isClaimed ? 2 : 1), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Stack(clipBehavior: Clip.none, children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: isDark ? bgColor.withValues(alpha: 0.5) : bgColor, shape: BoxShape.circle), child: Center(child: Text(badge.text, style: TextStyle(fontSize: badge.isLabel ? 18 : 28, fontWeight: FontWeight.w900, color: badgeTextColor)))), if (isClaimed) Positioned(bottom: -2, right: -2, child: Container(width: 22, height: 22, decoration: BoxDecoration(color: const Color(0xFF58CC02), shape: BoxShape.circle, border: Border.all(color: cardColor, width: 2)), child: const Icon(Icons.check_rounded, size: 14, color: Colors.white)))]), const Spacer(), Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: textColor, height: 1.2)), const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFF1EFE8), valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? const Color(0xFF58CC02) : accentColor))), const SizedBox(height: 8), bottomWidget]));
  }

  Widget _buildMenuTile({required BuildContext context, required IconData icon, required String title, required String subtitle, required Color color, required Color textColor, required Color subTextColor, required VoidCallback onTap, bool isLogout = false, required bool isDark}) {
    return ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isLogout ? (isDark ? Colors.red.withValues(alpha: 0.2) : const Color(0xFFFFF1F1)) : color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 22)), title: Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textColor)), subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: subTextColor, fontWeight: FontWeight.w500)), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFB5B0A8)), onTap: onTap);
  }
}