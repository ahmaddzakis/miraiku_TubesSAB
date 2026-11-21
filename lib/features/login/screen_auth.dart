import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/game_manager.dart';
import '../../core/notification_service.dart';
import '../../core/settings_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_snackbar.dart';
import 'screen_login_success.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoginMode = true;
  bool _isSignUpStep2 = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _googleIdToken;
  String? _googleAccessToken;

  @override
  void initState() {
    super.initState();
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  /// Developer Quick Login (Active in debug mode).
  ///
  /// Attempts to sign in with saved developer credentials or user input,
  /// and gracefully falls back to offline local state hydration so the
  /// developer can immediately enter and test all screens of the app.
  Future<void> _handleDevQuickLogin() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final typedEmail = _emailController.text.trim();
      final typedPassword = _passwordController.text.trim();
      final savedEmail = prefs.getString('dev_quick_email') ?? '';
      final savedPassword = prefs.getString('dev_quick_password') ?? '';

      final emailToUse = typedEmail.isNotEmpty ? typedEmail : savedEmail;
      final passwordToUse =
          typedPassword.isNotEmpty ? typedPassword : savedPassword;

      if (emailToUse.isNotEmpty && passwordToUse.isNotEmpty) {
        try {
          await Supabase.instance.client.auth.signInWithPassword(
            email: emailToUse,
            password: passwordToUse,
          );
          await prefs.setString('dev_quick_email', emailToUse);
          await prefs.setString('dev_quick_password', passwordToUse);
        } catch (e) {
          debugPrint('Dev Quick Login: Supabase auth bypassed ($e)');
        }
      }

      await GameManager.fetchAndHydrateState();

      // Seed starter XP & shields in local state if empty so dev can test all features
      if (globalXP.value < 500) {
        await GameManager.addXP(1500);
      }
      if (globalStreakShields.value == 0) {
        globalStreakShields.value = 1;
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginSuccessScreen()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = globalDarkMode.value;
        final textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final subColor =
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.errorLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.errorLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                _t("Error", "Kesalahan"),
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: subColor),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: "OK",
                onPressed: () => Navigator.pop(dialogContext),
                height: 48,
                borderRadius: AppSpacing.radiusMd,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog({required String title, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = globalDarkMode.value;
        final textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final subColor =
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.successLight.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48,
                  color: AppColors.successLight,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: subColor),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: "OK",
                onPressed: () => Navigator.pop(dialogContext),
                height: 48,
                borderRadius: AppSpacing.radiusMd,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccountExistsDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = globalDarkMode.value;
        final primaryColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;
        final textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final subColor =
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_search_rounded,
                  size: 48,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                _t("Account Already Exists", "Akun Sudah Terdaftar"),
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _t(
                  "Email $email is already registered. Would you like to sign in instead?",
                  "Email $email sudah terdaftar. Ingin masuk ke akun tersebut?",
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: subColor),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: _t("Cancel", "Batal"),
                      variant: AppButtonVariant.text,
                      foregroundColor: subColor,
                      height: 48,
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: _t("Sign In", "Masuk Sekarang"),
                      height: 48,
                      borderRadius: AppSpacing.radiusMd,
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        setState(() {
                          _isLoginMode = true;
                          _isSignUpStep2 = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAccountNotFoundDialog(
    String email,
    String? idToken,
    String? accessToken,
    Map<String, dynamic> meta,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = globalDarkMode.value;
        final primaryColor =
            isDark ? AppColors.primaryDark : AppColors.primaryLight;
        final textColor =
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
        final subColor =
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  size: 48,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                _t("Account Not Found", "Akun Tidak Ditemukan"),
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(color: textColor),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _t(
                  "We couldn't find an account for $email. Would you like to create a new one now?",
                  "Kami tidak menemukan akun untuk $email. Apakah Anda ingin mendaftar sebagai pengguna baru?",
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: subColor),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: _t("Cancel", "Batal"),
                      variant: AppButtonVariant.text,
                      foregroundColor: subColor,
                      height: 48,
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: _t("Sign Up", "Daftar Sekarang"),
                      height: 48,
                      borderRadius: AppSpacing.radiusMd,
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        setState(() {
                          _isLoginMode = false;
                          _isSignUpStep2 = true;
                          _googleIdToken = idToken;
                          _googleAccessToken = accessToken;
                          _emailController.text = email;
                          _nameController.text = meta['full_name'] ?? "";
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final selectedLanguage = globalLanguage.value;
    final selectedDarkMode = globalDarkMode.value;
    setState(() => _isLoading = true);

    try {
      const webClientId = AppConfig.googleWebClientId;
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'Failed to get ID Token from Google';

      final res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = res.user;
      if (user != null) {
        final meta = user.userMetadata ?? {};
        final bool isAlreadyRegistered = meta.containsKey('display_name');

        if (_isLoginMode && !isAlreadyRegistered) {
          await Supabase.instance.client.auth.signOut();
          if (mounted) {
            _showAccountNotFoundDialog(
              user.email ?? "",
              idToken,
              accessToken,
              meta,
            );
          }
        } else if (!_isLoginMode && isAlreadyRegistered) {
          await Supabase.instance.client.auth.signOut();
          if (mounted) {
            setState(() {
              _googleIdToken = null;
              _googleAccessToken = null;
              _emailController.text = user.email ?? "";
            });
            _showAccountExistsDialog(user.email ?? "");
          }
        } else if (!_isLoginMode && !isAlreadyRegistered) {
          await Supabase.instance.client.auth.signOut();
          if (mounted) {
            setState(() {
              _isSignUpStep2 = true;
              _googleIdToken = idToken;
              _googleAccessToken = accessToken;
              _emailController.text = user.email ?? "";
              _nameController.text = meta['full_name'] ?? "";
            });
          }
        } else if (_isLoginMode && isAlreadyRegistered) {
          final existingAvatar = meta['avatar_url'] as String?;
          final googleAvatar = user.userMetadata?['avatar_url'] as String?;

          final Map<String, dynamic> updateData = {
            'setting_lang': selectedLanguage,
            'setting_dark': selectedDarkMode,
          };

          if ((existingAvatar == null || existingAvatar.isEmpty) &&
              (googleAvatar != null && googleAvatar.isNotEmpty)) {
            updateData['avatar_url'] = googleAvatar;
          }

          await Supabase.instance.client.auth.updateUser(
            UserAttributes(data: updateData),
          );

          await GameManager.fetchAndHydrateState();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginSuccessScreen(),
              ),
            );
          }
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Google Sign-In PlatformException: ${e.code} - ${e.message}");
      if (mounted) {
        AppSnackbar.showError(
          context,
          "Google Sign-In Error [${e.code}]: ${e.message ?? 'Unknown error'}",
        );
      }
    } catch (error) {
      debugPrint("Google Sign-In Error: $error");
      if (mounted) {
        setState(() {
          _googleIdToken = null;
          _googleAccessToken = null;
        });
        _showErrorDialog(
          _t(
            "Google Sign-In failed. Please check your connection or try again.",
            "Gagal masuk dengan Google. Periksa koneksi atau coba lagi.",
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedLanguage = globalLanguage.value;
    final selectedDarkMode = globalDarkMode.value;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      if (_isLoginMode) {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (kDebugMode) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('dev_quick_email', email);
          await prefs.setString('dev_quick_password', password);
        }

        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'setting_lang': selectedLanguage,
              'setting_dark': selectedDarkMode,
            },
          ),
        );

        await GameManager.fetchAndHydrateState();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginSuccessScreen()),
          );
        }
      } else {
        final newUserMetadata = {
          'display_name': _nameController.text.trim().isEmpty
              ? "Pelajar Baru"
              : _nameController.text.trim(),
          'bio': _descController.text.trim().isEmpty
              ? "Siap belajar bahasa Jepang!"
              : _descController.text.trim(),
          'setting_lang': selectedLanguage,
          'setting_dark': selectedDarkMode,
          'gm_xp': 0,
          'gm_hearts': 5,
          'gm_streak': 1,
          'gm_streak_shields': 1,
          'is_premium': false,
        };

        if (_googleIdToken != null) {
          await supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: _googleIdToken!,
            accessToken: _googleAccessToken,
          );

          await supabase.auth.updateUser(UserAttributes(data: newUserMetadata));
          await GameManager.initializeNewAccount();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginSuccessScreen(),
              ),
            );
          }
        } else {
          final email = _emailController.text.trim();
          final password = _passwordController.text.trim();
          final response = await supabase.auth.signUp(
            email: email,
            password: password,
            data: newUserMetadata,
          );

          if (mounted) {
            final identities = response.user?.identities;
            if (identities != null && identities.isEmpty) {
              _showAccountExistsDialog(email);
              return;
            }

            if (response.session == null) {
              // Attempt immediate sign-in when Supabase does not return a session directly
              await supabase.auth.signInWithPassword(
                email: email,
                password: password,
              );
            }

            if (kDebugMode) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('dev_quick_email', email);
              await prefs.setString('dev_quick_password', password);
            }

            await GameManager.initializeNewAccount();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginSuccessScreen(),
                ),
              );
            }
          }
        }
      }
    } on AuthException catch (error) {
      final msg = error.message.toLowerCase();
      if (msg.contains("invalid login credentials")) {
        _showErrorDialog(
          _t("Invalid email or password", "Email atau kata sandi salah"),
        );
      } else if (msg.contains("email not confirmed")) {
        _showErrorDialog(
          _t(
            "Supabase still requires email confirmation. Please disable 'Confirm email' in Supabase Dashboard → Authentication → Providers → Email to allow instant sign-up.",
            "Supabase masih mengaktifkan konfirmasi email. Nonaktifkan 'Confirm email' di Supabase Dashboard → Authentication → Providers → Email agar akun bisa langsung masuk & menyimpan progres.",
          ),
        );
      } else if (error.statusCode == '429' || msg.contains("rate limit")) {
        _showErrorDialog(
          _t(
            "Too many requests. Please wait a while before trying again.",
            "Terlalu banyak permintaan pengiriman email. Silakan tunggu beberapa saat lalu coba lagi.",
          ),
        );
      } else if (msg.contains("already registered") ||
          msg.contains("already exists") ||
          msg.contains("user_already_exists") ||
          msg.contains("already in use") ||
          msg.contains("sudah terdaftar")) {
        _showAccountExistsDialog(_emailController.text.trim());
        if (!_isLoginMode) setState(() => _isSignUpStep2 = false);
      } else {
        _showErrorDialog(error.message);
      }
    } catch (error) {
      _showErrorDialog(
        _t(
          "An unexpected error occurred",
          "Terjadi kesalahan tidak terduga",
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );
    bool isSending = false;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setDialogState) {
            final isDark = globalDarkMode.value;
            final primaryColor =
                isDark ? AppColors.primaryDark : AppColors.primaryLight;
            final textColor =
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
            final subColor = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;
            return AlertDialog(
              backgroundColor:
                  isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      size: 48,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    _t("Reset Password", "Lupa Sandi"),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    _t(
                      "Enter your email to receive a reset link.",
                      "Masukkan email untuk menerima tautan atur ulang.",
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: subColor),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyMedium.copyWith(color: textColor),
                    decoration: InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      prefixIcon: Icon(Icons.email_rounded, color: subColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: _t("Cancel", "Batal"),
                          variant: AppButtonVariant.text,
                          foregroundColor: subColor,
                          height: 48,
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          label: _t("Send", "Kirim"),
                          isLoading: isSending,
                          height: 48,
                          borderRadius: AppSpacing.radiusMd,
                          onPressed: isSending
                              ? null
                              : () async {
                                  if (resetEmailController.text.isEmpty ||
                                      !resetEmailController.text.contains(
                                        '@',
                                      )) {
                                    return;
                                  }
                                  setDialogState(() => isSending = true);

                                  try {
                                    await Supabase.instance.client.auth
                                        .resetPasswordForEmail(
                                          resetEmailController.text.trim(),
                                        );
                                    if (statefulContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }
                                    _showSuccessDialog(
                                      title: _t("Email Sent", "Email Terkirim"),
                                      message: _t(
                                        "A reset link has been sent to your inbox. Please check your email.",
                                        "Tautan atur ulang telah dikirim. Silakan periksa kotak masuk email Anda.",
                                      ),
                                    );
                                  } on AuthException catch (e) {
                                    String errorMsg = e.message;
                                    if (e.statusCode == '429' ||
                                        e.message.toLowerCase().contains(
                                          "rate limit",
                                        )) {
                                      errorMsg = _t(
                                        "Too many requests. Please wait a while before trying again.",
                                        "Terlalu banyak permintaan pengiriman email. Silakan tunggu beberapa saat lalu coba lagi.",
                                      );
                                    }
                                    _showErrorDialog(errorMsg);
                                  } catch (e) {
                                    _showErrorDialog(
                                      _t(
                                        "An unexpected error occurred",
                                        "Terjadi kesalahan tidak terduga",
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setDialogState(() => isSending = false);
                                    }
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkMode,
      builder: (listenableContext, isDark, _) {
        return ValueListenableBuilder<String>(
          valueListenable: globalLanguage,
          builder: (listenableContext2, lang, _) {
            final Color bgColor = isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight;
            final Color textColor = isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight;
            final Color subColor = isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight;
            final Color cardColor = isDark
                ? AppColors.surfaceDark
                : AppColors.surfaceLight;
            final Color fieldBg = isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariantLight;
            final Color primaryColor = isDark
                ? AppColors.primaryDark
                : AppColors.primaryLight;

            return Scaffold(
              backgroundColor: bgColor,
              resizeToAvoidBottomInset: true,
              body: SafeArea(
                bottom: true,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Stack(
                        children: [
                          Positioned(
                            top: -40,
                            right: -20,
                            child: CircleAvatar(
                              radius: 110,
                              backgroundColor: primaryColor.withValues(
                                alpha: 0.06,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 100,
                            left: -60,
                            child: CircleAvatar(
                              radius: 100,
                              backgroundColor: AppColors.primaryDark.withValues(
                                alpha: 0.04,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxl,
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 50),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                      vertical: AppSpacing.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.black.withValues(
                                              alpha: 0.04,
                                            ),
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusPill,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await SettingsController.instance
                                                .toggleLanguage();
                                            final prefs =
                                                await SharedPreferences.getInstance();
                                            if (prefs.getBool(
                                                  'is_daily_reminder_on',
                                                ) ??
                                                false) {
                                              NotificationService()
                                                  .scheduleDailyStudyReminder(
                                                    globalLanguage.value,
                                                  );
                                            }
                                          },
                                          child: Text(
                                            lang.toUpperCase(),
                                            style: AppTextStyles.labelLarge
                                                .copyWith(color: primaryColor),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Container(
                                          width: 1.5,
                                          height: 16,
                                          color: isDark
                                              ? AppColors.outlineDark
                                              : AppColors.outlineLight,
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        GestureDetector(
                                          onTap: () async {
                                            await SettingsController.instance
                                                .toggleTheme();
                                          },
                                          child: Icon(
                                            isDark
                                                ? Icons.light_mode_rounded
                                                : Icons.dark_mode_rounded,
                                            color: isDark
                                                ? AppColors.accentDark
                                                : AppColors.secondaryLight,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Text(
                                  "MIRAIku",
                                  style: AppTextStyles.displayLarge.copyWith(
                                    color: primaryColor,
                                    fontSize: 42,
                                    letterSpacing: 1.5,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 40),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusXxl,
                                    ),
                                    boxShadow: AppShadows.card(isDark),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xxl,
                                    vertical: AppSpacing.xxxl,
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: AppSpacing.sm),
                                        Text(
                                          _isLoginMode
                                              ? _t(
                                                  "Welcome Back",
                                                  "Selamat Datang",
                                                )
                                              : (_isSignUpStep2
                                                    ? _t(
                                                        "Almost Done!",
                                                        "Sedikit Lagi!",
                                                      )
                                                    : _t(
                                                        "Create Account",
                                                        "Buat Akun",
                                                      )),
                                          style: AppTextStyles.displayMedium
                                              .copyWith(color: textColor),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          _isLoginMode
                                              ? _t(
                                                  "Login to continue your journey.",
                                                  "Masuk untuk lanjut belajar.",
                                                )
                                              : (_isSignUpStep2
                                                    ? _t(
                                                        "Let's personalize your profile.",
                                                        "Ayo lengkapi profilmu.",
                                                      )
                                                    : _t(
                                                        "Join us to start learning Japanese.",
                                                        "Daftar untuk mulai belajar.",
                                                      )),
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(color: subColor),
                                        ),
                                        const SizedBox(height: AppSpacing.xxxl),
                                        if (_isLoginMode ||
                                            !_isSignUpStep2) ...[
                                          _buildTextField(
                                            controller: _emailController,
                                            label: "Email",
                                            icon: Icons.email_rounded,
                                            isDark: isDark,
                                            fieldBg: fieldBg,
                                            textColor: textColor,
                                            primaryColor: primaryColor,
                                            type: TextInputType.emailAddress,
                                            hints: const [AutofillHints.email],
                                            validator: (v) =>
                                                (v == null ||
                                                    !RegExp(
                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                    ).hasMatch(v))
                                                ? _t(
                                                    "Invalid email",
                                                    "Email tidak valid",
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(height: AppSpacing.xl),
                                          _buildTextField(
                                            controller: _passwordController,
                                            label: _t(
                                              "Password",
                                              "Kata Sandi",
                                            ),
                                            icon: Icons.lock_rounded,
                                            isDark: isDark,
                                            fieldBg: fieldBg,
                                            textColor: textColor,
                                            primaryColor: primaryColor,
                                            isPassword: true,
                                            obscure: _obscurePassword,
                                            hints: const [
                                              AutofillHints.password,
                                            ],
                                            onToggle: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                            validator: (v) {
                                              if (v == null || v.length < 6) {
                                                return _t(
                                                  "Min. 6 chars",
                                                  "Min. 6 karakter",
                                                );
                                              }
                                              if (!v.contains(
                                                RegExp(r'[0-9]'),
                                              )) {
                                                return _t(
                                                  "Must include a number",
                                                  "Wajib mengandung angka",
                                                );
                                              }
                                              return null;
                                            },
                                          ),
                                        ] else ...[
                                          _buildTextField(
                                            controller: _nameController,
                                            label: _t(
                                              "Display Name",
                                              "Nama Tampilan",
                                            ),
                                            icon: Icons.person_rounded,
                                            isDark: isDark,
                                            fieldBg: fieldBg,
                                            textColor: textColor,
                                            primaryColor: primaryColor,
                                            hints: const [AutofillHints.name],
                                            maxLength: 25,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[a-zA-Z\s]'),
                                              ),
                                            ],
                                            validator: (v) {
                                              if (v == null ||
                                                  v.trim().isEmpty) {
                                                return _t(
                                                  "Name required",
                                                  "Nama wajib diisi",
                                                );
                                              }
                                              if (!RegExp(
                                                r'^[a-zA-Z\s]+$',
                                              ).hasMatch(v)) {
                                                return _t(
                                                  "Letters and spaces only",
                                                  "Hanya huruf dan spasi",
                                                );
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: AppSpacing.xl),
                                          _buildTextField(
                                            controller: _descController,
                                            label: "Bio",
                                            icon: Icons.info_outline_rounded,
                                            isDark: isDark,
                                            fieldBg: fieldBg,
                                            textColor: textColor,
                                            primaryColor: primaryColor,
                                            hints: const [
                                              AutofillHints.jobTitle,
                                            ],
                                            maxLength: 50,
                                            validator: (v) =>
                                                (v == null || v.trim().isEmpty)
                                                ? _t(
                                                    "Bio required",
                                                    "Bio wajib diisi",
                                                  )
                                                : null,
                                          ),
                                        ],
                                        if (_isLoginMode) ...[
                                          const SizedBox(height: AppSpacing.lg),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              GestureDetector(
                                                onTap:
                                                    _showForgotPasswordDialog,
                                                child: Text(
                                                  _t("Forgot?", "Lupa?"),
                                                  style: AppTextStyles
                                                      .labelMedium
                                                      .copyWith(
                                                        color: primaryColor,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: AppSpacing.xxxl),
                                        AppButton(
                                          label: _isLoginMode
                                              ? _t("Sign In", "Masuk")
                                              : (_isSignUpStep2
                                                    ? _t("Finish", "Selesai")
                                                    : _t("Next", "Lanjut")),
                                          isLoading: _isLoading,
                                          borderRadius: 18,
                                          onPressed: _isLoading
                                              ? null
                                              : () async {
                                                  if (!_isLoginMode &&
                                                      !_isSignUpStep2) {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      FocusScope.of(
                                                        context,
                                                      ).unfocus();
                                                      setState(
                                                        () => _isSignUpStep2 =
                                                            true,
                                                      );
                                                    }
                                                  } else {
                                                    _handleAuth();
                                                  }
                                                },
                                        ),
                                        if (_isLoginMode ||
                                            !_isSignUpStep2) ...[
                                          const SizedBox(height: 28),
                                          Row(
                                            children: [
                                              const Expanded(child: Divider()),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: AppSpacing.lg,
                                                    ),
                                                child: Text(
                                                  _t("OR", "ATAU"),
                                                  style: AppTextStyles
                                                      .labelSmall
                                                      .copyWith(
                                                        color: subColor
                                                            .withValues(
                                                              alpha: 0.6,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w900,
                                                      ),
                                                ),
                                              ),
                                              const Expanded(child: Divider()),
                                            ],
                                          ),
                                          const SizedBox(height: 28),
                                          AppButton(
                                            label: _t(
                                              "Continue with Google",
                                              "Lanjutkan dengan Google",
                                            ),
                                            variant: AppButtonVariant.secondary,
                                            borderRadius: 18,
                                            onPressed: _isLoading
                                                ? null
                                                : _handleGoogleSignIn,
                                            customChild: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.network(
                                                    'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
                                                    height: 20,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.g_mobiledata,
                                                          color: Colors.red,
                                                          size: 28,
                                                        ),
                                                  ),
                                                  const SizedBox(
                                                    width: AppSpacing.md,
                                                  ),
                                                  Text(
                                                    _t(
                                                      "Continue with Google",
                                                      "Lanjutkan dengan Google",
                                                    ),
                                                    style: AppTextStyles
                                                        .labelLarge
                                                        .copyWith(
                                                          color: textColor,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                        if (kDebugMode) ...[
                                          const SizedBox(height: AppSpacing.lg),
                                          AppButton(
                                            label: _t(
                                              "Developer Quick Login",
                                              "Login Cepat Developer",
                                            ),
                                            variant: AppButtonVariant.secondary,
                                            icon: Icons.developer_mode_rounded,
                                            height: 48,
                                            borderRadius: 14,
                                            backgroundColor: primaryColor
                                                .withValues(alpha: 0.08),
                                            borderColor: primaryColor
                                                .withValues(alpha: 0.5),
                                            foregroundColor: primaryColor,
                                            onPressed: _isLoading
                                                ? null
                                                : _handleDevQuickLogin,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxxl),
                                AppButton(
                                  label: "",
                                  variant: AppButtonVariant.text,
                                  expand: false,
                                  onPressed: () {
                                    setState(() {
                                      if (!_isLoginMode && _isSignUpStep2) {
                                        _isSignUpStep2 = false;
                                        _googleIdToken = null;
                                        _googleAccessToken = null;
                                      } else {
                                        _isLoginMode = !_isLoginMode;
                                        _isSignUpStep2 = false;
                                        _googleIdToken = null;
                                        _googleAccessToken = null;
                                        _passwordController.clear();
                                        _confirmPasswordController.clear();
                                      }
                                    });
                                  },
                                  customChild: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: RichText(
                                      text: TextSpan(
                                        text: (_isSignUpStep2)
                                            ? ""
                                            : (_isLoginMode
                                                  ? _t(
                                                      "New here? ",
                                                      "Baru di sini? ",
                                                    )
                                                  : _t(
                                                      "Have an account? ",
                                                      "Sudah punya akun? ",
                                                    )),
                                        style: AppTextStyles.labelLarge
                                            .copyWith(color: subColor),
                                        children: [
                                          TextSpan(
                                            text: (_isSignUpStep2)
                                                ? _t(
                                                    "← Back to Account Info",
                                                    "← Kembali ke Info Akun",
                                                  )
                                                : (_isLoginMode
                                                      ? _t("Sign Up", "Daftar")
                                                      : _t("Sign In", "Masuk")),
                                            style: AppTextStyles.labelLarge
                                                .copyWith(
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color fieldBg,
    required Color textColor,
    required Color primaryColor,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
    TextInputType type = TextInputType.text,
    List<String>? hints,
    String? Function(String?)? validator,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final hintColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      autofillHints: hints,
      validator: validator,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: hintColor),
        counterText: "",
        filled: true,
        fillColor: fieldBg,
        prefixIcon: Icon(icon, color: hintColor, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: hintColor,
                  size: 20,
                ),
                onPressed: onToggle,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: AppSpacing.xl,
        ),
      ),
    );
  }
}
