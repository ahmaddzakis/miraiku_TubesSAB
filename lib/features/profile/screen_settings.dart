import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/game_manager.dart';
import '../../core/notification_service.dart';
import '../../core/repository/local_repository.dart';
import '../../core/settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_dialogs.dart';
import '../../core/widgets/app_snackbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _supabase = Supabase.instance.client;

  bool _soundEffects = true;
  bool _isDailyReminderOn = false;

  String _userName = "MIRAIku User";
  String _userDesc = "Semangat Belajar Bahasa Jepang!";
  String _appVersion = "";

  @override
  void initState() {
    super.initState();
    _appVersion = _t("Loading...", "Memuat...");
    _initAppVersion();
    _loadUserDataAndSettings();
  }

  Future<void> _initAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${info.version}';
      });
    }
  }

  Future<void> _loadUserDataAndSettings() async {
    final user = _supabase.auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final meta = user?.userMetadata ?? await LocalRepository.getUserProgress();

    if (!mounted) return;
    setState(() {
      _userName = meta['display_name'] ??
          prefs.getString('cache_display_name') ??
          user?.email?.split('@')[0] ??
          "MIRAIku User";
      _userDesc = meta['bio'] ??
          prefs.getString('cache_bio') ??
          "Semangat Belajar Bahasa Jepang!";
      _soundEffects =
          meta['setting_sound'] ?? prefs.getBool('setting_sound') ?? true;
      _isDailyReminderOn = prefs.getBool('is_daily_reminder_on') ?? false;
    });
  }

  Future<void> _updatePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is String) await prefs.setString(key, value);

    await LocalRepository.queueAction(key, value);
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  void _showAlertDialog(String title, String message) {
    final isDark = globalDarkMode.value;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        title: Text(
          title,
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          AppButton(
            label: "OK",
            variant: AppButtonVariant.text,
            expand: false,
            height: 48,
            foregroundColor: primaryColor,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(
    StateSetter setModalState,
    void Function(bool) setLoading,
  ) async {
    final picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: _t('Edit Photo', 'Edit Foto'),
          toolbarColor: AppColors.primaryLight,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: true,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: _t('Edit Photo', 'Edit Foto'),
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          cropStyle: CropStyle.circle,
        ),
      ],
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    if (croppedFile == null) return;

    setModalState(() => setLoading(true));
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final file = File(croppedFile.path);
      final fileExt = croppedFile.path.split('.').last;
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage.from('avatars').upload(fileName, file);
      final String publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(fileName);

      globalAvatarUrl.value = publicUrl;
      await LocalRepository.queueAction('avatar_url', publicUrl);

      if (mounted) {
        setModalState(() {});
        _showAlertDialog(
          _t("Success", "Berhasil"),
          _t(
            "Profile photo has been updated!",
            "Foto profil berhasil diperbarui!",
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showAlertDialog(_t("Upload Failed", "Gagal Unggah"), e.toString());
      }
    } finally {
      setModalState(() => setLoading(false));
    }
  }

  Future<void> _removeProfilePicture(
    StateSetter setModalState,
    void Function(bool) setLoading,
  ) async {
    setModalState(() => setLoading(true));
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      globalAvatarUrl.value = "";
      await LocalRepository.queueAction('avatar_url', '');

      if (mounted) {
        setModalState(() {});
        _showAlertDialog(
          _t("Success", "Berhasil"),
          _t(
            "Profile photo has been removed!",
            "Foto profil berhasil dihapus!",
          ),
        );
      }
    } catch (e) {
      if (mounted) _showAlertDialog(_t("Error", "Gagal"), e.toString());
    } finally {
      setModalState(() => setLoading(false));
    }
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: globalReminderTime.value,
      builder: (context, child) {
        final isDark = globalDarkMode.value;
        final primaryColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;
        final surfaceColor =
            isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
        final textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryColor,
                    onPrimary: AppColors.onPrimaryDark,
                    surface: surfaceColor,
                    onSurface: textColor,
                  )
                : ColorScheme.light(
                    primary: primaryColor,
                    onPrimary: AppColors.onPrimaryLight,
                    surface: surfaceColor,
                    onSurface: textColor,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      globalReminderTime.value = picked;
      await _updatePreference('reminder_hour', picked.hour);
      await _updatePreference('reminder_minute', picked.minute);
      NotificationService().scheduleDailyStudyReminder(globalLanguage.value);
    }
  }

  void _showLanguageDialog() {
    final isDark = globalDarkMode.value;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          ),
          title: Text(
            _t("Select Language", "Pilih Bahasa"),
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  "English",
                  style: AppTextStyles.titleMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: globalLanguage.value == 'en'
                    ? Icon(Icons.check_circle_rounded, color: primaryColor)
                    : null,
                onTap: () async {
                  await SettingsController.instance.setLanguage('en');
                  NotificationService().scheduleDailyStudyReminder('en');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  "Bahasa Indonesia",
                  style: AppTextStyles.titleMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: globalLanguage.value == 'id'
                    ? Icon(Icons.check_circle_rounded, color: primaryColor)
                    : null,
                onTap: () async {
                  await SettingsController.instance.setLanguage('id');
                  NotificationService().scheduleDailyStudyReminder('id');
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileModal() {
    final TextEditingController nameController =
        TextEditingController(text: _userName);
    final TextEditingController descController =
        TextEditingController(text: _userDesc);
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = globalDarkMode.value;
            final Color modalBg =
                isDark ? AppColors.surfaceDark : AppColors.backgroundLight;
            final Color textColor =
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final Color subTextColor = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;
            final Color fieldBg = isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceLight;
            final Color borderColor =
                isDark ? AppColors.borderDark : AppColors.borderLight;
            final Color primaryColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;
            final Color errorColor =
                isDark ? AppColors.errorDark : AppColors.errorLight;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: modalBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusXxl),
                    topRight: Radius.circular(AppSpacing.radiusXxl),
                  ),
                  boxShadow: AppShadows.dialog(isDark),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: subTextColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          _t("Edit Profile", "Edit Profil"),
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ValueListenableBuilder<String>(
                        valueListenable: globalAvatarUrl,
                        builder: (context, avatarUrl, _) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.25),
                                    width: 4,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusXl,
                                  ),
                                  child: Image(
                                    image: _getAvatarImage(avatarUrl),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (isSaving)
                                Positioned.fill(
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black26,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              if (avatarUrl.isNotEmpty && !isSaving)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () => _removeProfilePicture(
                                      setModalState,
                                      (v) => isSaving = v,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              errorColor.withValues(alpha: 0.2),
                                        ),
                                        boxShadow:
                                            AppShadows.buttonSecondary(isDark),
                                      ),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        size: 20,
                                        color: errorColor,
                                      ),
                                    ),
                                  ),
                                ),
                              if (!isSaving)
                                Positioned(
                                  bottom: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () => _pickAndUploadImage(
                                      setModalState,
                                      (v) => isSaving = v,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        boxShadow:
                                            AppShadows.buttonSecondary(isDark),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      TextFormField(
                        controller: nameController,
                        maxLength: 25,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          labelText: _t("Display Name", "Nama Tampilan"),
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color: subTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: fieldBg,
                          prefixIcon: Icon(
                            Icons.person_rounded,
                            color: subTextColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(color: errorColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return _t("Name required", "Nama wajib diisi");
                          }
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) {
                            return _t(
                              "Letters and spaces only",
                              "Hanya huruf dan spasi",
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: descController,
                        maxLength: 50,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          labelText: _t("Bio", "Bio"),
                          labelStyle: AppTextStyles.bodyMedium.copyWith(
                            color: subTextColor,
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: fieldBg,
                          prefixIcon: Icon(
                            Icons.info_outline_rounded,
                            color: subTextColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(color: errorColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? _t("Bio required", "Bio wajib diisi")
                            : null,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppButton(
                        label: _t("Save Changes", "Simpan Perubahan"),
                        isLoading: isSaving,
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            setModalState(() => isSaving = true);
                            try {
                              final newName = nameController.text.trim();
                              final newBio = descController.text.trim();

                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('display_name', newName);
                              await prefs.setString('bio', newBio);

                              await LocalRepository.queueActionsBatch({
                                'display_name': newName,
                                'bio': newBio,
                              });

                              if (context.mounted) {
                                setState(() {
                                  _userName = newName;
                                  _userDesc = newBio;
                                });
                                Navigator.pop(context);
                                _showAlertDialog(
                                  _t("Success", "Berhasil"),
                                  _t(
                                    "Profile has been updated!",
                                    "Profil berhasil diperbarui!",
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                _showAlertDialog(
                                  _t("Update Failed", "Gagal Memperbarui"),
                                  e.toString(),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setModalState(() => isSaving = false);
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordModal() {
    final formKey = GlobalKey<FormState>();
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool isSaving = false;
    bool obscureText = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = globalDarkMode.value;
            final Color modalBg =
                isDark ? AppColors.surfaceDark : AppColors.backgroundLight;
            final Color textColor =
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final Color subTextColor = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;
            final Color fieldBg = isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceLight;
            final Color borderColor =
                isDark ? AppColors.borderDark : AppColors.borderLight;
            final Color primaryColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;
            final Color errorColor =
                isDark ? AppColors.errorDark : AppColors.errorLight;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: modalBg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusXxl),
                    topRight: Radius.circular(AppSpacing.radiusXxl),
                  ),
                  boxShadow: AppShadows.dialog(isDark),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: subTextColor.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          _t("Change Password", "Ubah Kata Sandi"),
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextFormField(
                        controller: oldPasswordController,
                        obscureText: obscureText,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          labelText: _t("Old Password", "Sandi Lama"),
                          filled: true,
                          fillColor: fieldBg,
                          prefixIcon: Icon(
                            Icons.lock_open_rounded,
                            color: subTextColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(color: errorColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _t(
                              "Old password is required",
                              "Sandi lama wajib diisi",
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureText,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          labelText: _t("New Password", "Sandi Baru"),
                          hintText: _t(
                            "Min. 6 characters & 1 number",
                            "Min. 6 karakter & 1 angka",
                          ),
                          hintStyle: AppTextStyles.labelMedium.copyWith(
                            color: subTextColor,
                          ),
                          filled: true,
                          fillColor: fieldBg,
                          prefixIcon: Icon(
                            Icons.lock_rounded,
                            color: subTextColor,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: subTextColor,
                            ),
                            onPressed: () =>
                                setModalState(() => obscureText = !obscureText),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(color: errorColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return _t(
                              "Min. 6 characters",
                              "Minimal 6 karakter",
                            );
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return _t(
                              "Must contain at least 1 number",
                              "Sandi harus mengandung minimal 1 angka",
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureText,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          labelText:
                              _t("Confirm Password", "Konfirmasi Sandi"),
                          filled: true,
                          fillColor: fieldBg,
                          prefixIcon: Icon(
                            Icons.lock_clock_rounded,
                            color: subTextColor,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide: BorderSide(color: errorColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusMd),
                            borderSide:
                                BorderSide(color: errorColor, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value != newPasswordController.text) {
                            return _t(
                              "Password mismatch",
                              "Konfirmasi sandi tidak sesuai",
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppButton(
                        label: _t("Update Password", "Perbarui Sandi"),
                        isLoading: isSaving,
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (oldPasswordController.text.trim() ==
                                newPasswordController.text.trim()) {
                              AppSnackbar.showError(
                                context,
                                _t(
                                  "New password cannot be the same as old password!",
                                  "Sandi baru tidak boleh sama dengan sandi lama!",
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSaving = true);
                            try {
                              final String currentUserEmail =
                                  _supabase.auth.currentUser?.email ?? "";

                              await _supabase.auth.signInWithPassword(
                                email: currentUserEmail,
                                password: oldPasswordController.text.trim(),
                              );

                              setModalState(() => isSaving = false);

                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                    backgroundColor: isDark
                                        ? AppColors.surfaceDark
                                        : AppColors.surfaceLight,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusXl,
                                      ),
                                    ),
                                    title: Text(
                                      _t("Confirmation", "Konfirmasi"),
                                      style: AppTextStyles.headlineMedium
                                          .copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                      ),
                                    ),
                                    content: Text(
                                      _t(
                                        "Are you sure you want to update your password?",
                                        "Apakah Anda yakin ingin memperbarui kata sandi?",
                                      ),
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: subTextColor,
                                      ),
                                    ),
                                    actions: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: AppButton(
                                              label: _t("Cancel", "Batal"),
                                              variant: AppButtonVariant.text,
                                              height: 48,
                                              onPressed: () =>
                                                  Navigator.pop(dialogContext),
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Expanded(
                                            child: AppButton(
                                              label: _t("Sure", "Yakin"),
                                              height: 48,
                                              borderRadius: AppSpacing.radiusMd,
                                              onPressed: () async {
                                                try {
                                                  await _supabase.auth
                                                      .updateUser(
                                                        UserAttributes(
                                                          password:
                                                              newPasswordController
                                                                  .text
                                                                  .trim(),
                                                        ),
                                                      );

                                                  if (context.mounted) {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );
                                                    Navigator.pop(context);
                                                    AppSnackbar.showSuccess(
                                                      context,
                                                      _t(
                                                        "Password updated successfully!",
                                                        "Sandi berhasil diperbarui!",
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    Navigator.pop(
                                                      dialogContext,
                                                    );
                                                  }
                                                  _showAlertDialog(
                                                    _t("Error", "Kesalahan"),
                                                    e.toString(),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } on AuthException catch (_) {
                              setModalState(() => isSaving = false);
                              if (context.mounted) {
                                _showAlertDialog(
                                  _t("Failed", "Gagal"),
                                  _t(
                                    "The old password you entered is incorrect!",
                                    "Sandi lama yang Anda masukkan salah!",
                                  ),
                                );
                              }
                            } finally {
                              if (context.mounted) {
                                setModalState(() => isSaving = false);
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
              ),
            );
          },
        );
      },
    );
  }

  ImageProvider _getAvatarImage(String url) {
    if (url.isNotEmpty && url.startsWith('http')) {
      return NetworkImage(url);
    } else {
      return const AssetImage('assets/images/iconUtama.png');
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      if (mounted) {
        _showAlertDialog(
          _t("Error", "Kesalahan"),
          _t("Could not open the link", "Gagal membuka tautan"),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
            final Color bgColor =
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
            final Color textColor =
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final Color subTextColor = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;
            final Color borderColor =
                isDark ? AppColors.borderDark : AppColors.borderLight;
            final Color primaryColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;

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
                title: Text(
                  _t("Settings", "Pengaturan"),
                  style: AppTextStyles.titleLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              body: SafeArea(
                bottom: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Profil (matching screen_profile.dart avatar border)
                      Row(
                        children: [
                          ValueListenableBuilder<String>(
                            valueListenable: globalAvatarUrl,
                            builder: (context, avatarUrl, _) {
                              return Container(
                                width: 82,
                                height: 82,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusXxl,
                                  ),
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 3,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusXl,
                                    ),
                                    child: Image(
                                      image: _getAvatarImage(avatarUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  _userDesc,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: subTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text(
                        _t("PREFERENCES", "PREFERENSI"),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: subTextColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildSettingsContainer(
                        children: [
                          _buildLanguageTile(
                            title: _t("Language", "Bahasa"),
                            textColor: textColor,
                            subTextColor: subTextColor,
                            primaryColor: primaryColor,
                          ),
                          Divider(height: 1, color: borderColor),
                          _buildSwitchTile(
                            title: _t("Sound Effects", "Efek Suara"),
                            icon: Icons.volume_up_rounded,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            primaryColor: primaryColor,
                            value: _soundEffects,
                            onChanged: (val) {
                              setState(() => _soundEffects = val);
                              _updatePreference('setting_sound', val);
                            },
                          ),
                          Divider(height: 1, color: borderColor),
                          _buildSwitchTile(
                            title: _t("Dark Mode", "Mode Gelap"),
                            icon: Icons.dark_mode_rounded,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            primaryColor: primaryColor,
                            value: isDark,
                            onChanged: (val) async {
                              await SettingsController.instance.setTheme(val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text(
                        _t("NOTIFICATIONS", "NOTIFIKASI"),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: subTextColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildSettingsContainer(
                        children: [
                          _buildSwitchTile(
                            title: _t("Daily Reminder", "Pengingat Harian"),
                            icon: Icons.notifications_active_rounded,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            primaryColor: primaryColor,
                            value: _isDailyReminderOn,
                            onChanged: (val) async {
                              setState(() => _isDailyReminderOn = val);
                              await _updatePreference(
                                'is_daily_reminder_on',
                                val,
                              );
                              if (val) {
                                await NotificationService()
                                    .requestPermissions();
                                await NotificationService()
                                    .scheduleDailyStudyReminder(
                                  globalLanguage.value,
                                );
                              } else {
                                await NotificationService().cancelAll();
                              }
                            },
                          ),
                          if (_isDailyReminderOn) ...[
                            Divider(height: 1, color: borderColor),
                            ValueListenableBuilder<TimeOfDay>(
                              valueListenable: globalReminderTime,
                              builder: (context, time, _) {
                                return _buildLinkTile(
                                  title: _t(
                                    "Reminder Time",
                                    "Waktu Pengingat",
                                  ),
                                  icon: Icons.access_time_rounded,
                                  trailingText: time.format(context),
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                  onTap: _showTimePicker,
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text(
                        _t("ACCOUNT", "AKUN"),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: subTextColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildSettingsContainer(
                        children: [
                          _buildLinkTile(
                            title: _t("Edit Profile", "Edit Profil"),
                            icon: Icons.person_outline_rounded,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            onTap: _showEditProfileModal,
                          ),
                          Divider(height: 1, color: borderColor),
                          _buildLinkTile(
                            title: _t("Change Password", "Ubah Kata Sandi"),
                            icon: Icons.lock_outline_rounded,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            onTap: _showChangePasswordModal,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text(
                        _t("ABOUT", "TENTANG"),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: subTextColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildSettingsContainer(
                        children: [
                          _buildLinkTile(
                            title: _t("Privacy Policy", "Kebijakan Privasi"),
                            icon: Icons.privacy_tip_outlined,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            onTap: () => _launchURL(
                              'https://docs.google.com/document/d/1dHd-bNOgvIbwXgsnybjV2q1dr1Hom_0isMcH8wNFBSk/edit?usp=sharing',
                            ),
                          ),
                          Divider(height: 1, color: borderColor),
                          _buildLinkTile(
                            title: _t("Terms of Service", "Syarat Ketentuan"),
                            icon: Icons.description_outlined,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            onTap: () => _launchURL(
                              'https://docs.google.com/document/d/1SSYXoZW_yu2ngBsUNEWN-SP5ELtPK9ZOi9bfW-Ww5u4/edit?usp=sharing',
                            ),
                          ),
                          Divider(height: 1, color: borderColor),
                          _buildLinkTile(
                            title: _t("About", "Tentang"),
                            icon: Icons.info_outline_rounded,
                            textColor: textColor,
                            subTextColor: subTextColor,
                            onTap: () => AppDialogs.showAboutApp(context),
                          ),
                          Divider(height: 1, color: borderColor),
                          _buildLinkTile(
                            title: _t("Version", "Versi"),
                            icon: Icons.verified_outlined,
                            trailingText: _appVersion,
                            textColor: textColor,
                            subTextColor: subTextColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsContainer({required List<Widget> children}) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _buildLanguageTile({
    required String title,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      leading: Icon(Icons.language_rounded, color: primaryColor, size: 24),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            globalLanguage.value == 'en' ? "English" : "Indonesia",
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: subTextColor,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: subTextColor),
        ],
      ),
      onTap: _showLanguageDialog,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required Color subTextColor,
    required Color primaryColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      leading: Icon(icon, color: primaryColor, size: 24),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: primaryColor,
        inactiveTrackColor: subTextColor.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildLinkTile({
    required String title,
    required IconData icon,
    String? trailingText,
    required Color textColor,
    required Color subTextColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      leading: Icon(icon, color: subTextColor, size: 24),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: subTextColor,
              ),
            )
          : Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: subTextColor,
            ),
      onTap: onTap,
    );
  }
}
