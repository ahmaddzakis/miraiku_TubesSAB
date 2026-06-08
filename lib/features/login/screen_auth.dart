import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

// Pastikan file globals ini sesuai dengan path aslimu
 // atau file tempat globalLanguage dan globalDarkMode berada
import '../../core/game_manager.dart';
import '../../core/notification_service.dart';

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
  bool _rememberMe = false;

  String? _googleIdToken;
  String? _googleAccessToken;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = globalDarkMode.value;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
              ),
              const SizedBox(height: 24),
              Text(
                _t("Error", "Kesalahan"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF2D2622),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC6633),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("OK"),
                ),
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
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.green),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF2D2622),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCC6633),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("OK"),
                ),
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
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_search_rounded, size: 48, color: Color(0xFFCC6633)),
              ),
              const SizedBox(height: 24),
              Text(
                _t("Account Already Exists", "Akun Sudah Terdaftar"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF2D2622),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _t(
                    "Email $email is already registered. Would you like to sign in instead?",
                    "Email $email sudah terdaftar. Ingin masuk ke akun tersebut?"
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(_t("Cancel", "Batal"), style: const TextStyle(color: Color(0xFF8C8A87))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        setState(() {
                          _isLoginMode = true;
                          _isSignUpStep2 = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC6633),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(_t("Sign In", "Masuk Sekarang")),
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

  void _showAccountNotFoundDialog(String email, String? idToken, String? accessToken, Map<String, dynamic> meta) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final isDark = globalDarkMode.value;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add_outlined, size: 48, color: Color(0xFFCC6633)),
              ),
              const SizedBox(height: 24),
              Text(
                _t("Account Not Found", "Akun Tidak Ditemukan"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF2D2622),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _t(
                    "We couldn't find an account for $email. Would you like to create a new one now?",
                    "Kami tidak menemukan akun untuk $email. Apakah Anda ingin mendaftar sebagai pengguna baru?"
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(_t("Cancel", "Batal"), style: const TextStyle(color: Color(0xFF8C8A87))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCC6633),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(_t("Sign Up", "Daftar Sekarang")),
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
      // TODO: Verify this matches the 'Web client ID' in Google Cloud Console
      const webClientId = '564994938710-anv76b8tkf8uoobjohct7fohm8f4ovhu.apps.googleusercontent.com';
      final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: webClientId);

      // Reset sign-in state to ensure the account picker always appears
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
            _showAccountNotFoundDialog(user.email ?? "", idToken, accessToken, meta);
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
          // Sync current Auth Screen settings to the existing account
          await Supabase.instance.client.auth.updateUser(UserAttributes(data: {
            'setting_lang': selectedLanguage,
            'setting_dark': selectedDarkMode,
          }));
          globalLanguage.value = selectedLanguage;
          globalDarkMode.value = selectedDarkMode;
          if (mounted) Navigator.pop(context);
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Google Sign-In PlatformException: ${e.code} - ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign-In Error [${e.code}]: ${e.message ?? 'Unknown error'}"),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      debugPrint("Google Sign-In Error: $error");
      if (mounted) {
        setState(() {
          _googleIdToken = null;
          _googleAccessToken = null;
        });
        _showErrorDialog(_t(
            "Google Sign-In failed. Please check your connection or try again.",
            "Gagal masuk dengan Google. Periksa koneksi atau coba lagi."
        ));
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
        // --- LOGIN ---
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Sync current Auth Screen settings (lang & theme) to the existing account
        await supabase.auth.updateUser(UserAttributes(data: {
          'setting_lang': selectedLanguage,
          'setting_dark': selectedDarkMode,
        }));
        
        globalLanguage.value = selectedLanguage;
        globalDarkMode.value = selectedDarkMode;

        if (mounted) Navigator.pop(context);

        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('remembered_email', _emailController.text.trim());
        } else {
          await prefs.remove('remembered_email');
        }
      } else {
        // --- CLEAN STATE FOR NEW USERS ---
        // Explicitly setting these values ensures a clean start and prevents legacy XP bugs.
        final newUserMetadata = {
          'display_name': _nameController.text.trim().isEmpty ? "Pelajar Baru" : _nameController.text.trim(),
          'bio': _descController.text.trim().isEmpty ? "Siap belajar bahasa Jepang!" : _descController.text.trim(),
          'setting_lang': selectedLanguage,
          'setting_dark': selectedDarkMode,
          'gm_xp': 0,
          'gm_hearts': 5,
          'gm_streak': 1, // First day login
          'is_premium': false,
        };

        if (_googleIdToken != null) {
          // Google Sign Up Final Step
          await supabase.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: _googleIdToken!,
            accessToken: _googleAccessToken,
          );
          
          await supabase.auth.updateUser(UserAttributes(data: newUserMetadata));
          
          // Force initialize game state for new user
          await GameManager.initializeNewAccount();

          if (mounted) Navigator.pop(context);
        } else {
          // Email Sign Up
          final response = await supabase.auth.signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              data: newUserMetadata,
          );

          if (mounted) {
            final identities = response.user?.identities;
            if (identities != null && identities.isEmpty) {
              _showAccountExistsDialog(_emailController.text.trim());
              return;
            }

            if (response.session != null) {
              // User is automatically signed in (email confirmation disabled)
              await GameManager.initializeNewAccount();
              if (mounted) Navigator.pop(context);
            } else {
              _showSuccessDialog(
                title: _t("Verify Your Email", "Verifikasi Email Anda"),
                message: _t(
                    "We've sent a link to your email. Please confirm it to finish your registration.",
                    "Kami telah mengirimkan tautan ke email Anda. Silakan konfirmasi untuk menyelesaikan pendaftaran."
                ),
              );
            }
          }
        }
      }
    } on AuthException catch (error) {
      final msg = error.message.toLowerCase();
      if (msg.contains("invalid login credentials")) {
        _showErrorDialog(_t("Invalid email or password", "Email atau kata sandi salah"));
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
      _showErrorDialog(_t("An unexpected error occurred", "Terjadi kesalahan tidak terduga"));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    bool isSending = false;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setDialogState) {
            final isDark = globalDarkMode.value;
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCC6633).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded, size: 48, color: Color(0xFFCC6633)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _t("Reset Password", "Lupa Sandi"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF2D2622),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _t("Enter your email to receive a reset link.", "Masukkan email untuk menerima tautan atur ulang."),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                      prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFFB5B0A8)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(_t("Cancel", "Batal"), style: const TextStyle(color: Color(0xFF8C8A87))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isSending ? null : () async {
                            if (resetEmailController.text.isEmpty || !resetEmailController.text.contains('@')) return;
                            setDialogState(() => isSending = true);

                            try {
                              await Supabase.instance.client.auth.resetPasswordForEmail(resetEmailController.text.trim());
                              if (statefulContext.mounted) Navigator.pop(dialogContext);
                              _showSuccessDialog(
                                title: _t("Email Sent", "Email Terkirim"),
                                message: _t(
                                    "A reset link has been sent to your inbox. Please check your email.",
                                    "Tautan atur ulang telah dikirim. Silakan periksa kotak masuk email Anda."
                                ),
                              );
                            } catch (e) {
                              _showErrorDialog(e.toString());
                            } finally {
                              if (mounted) setDialogState(() => isSending = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFCC6633),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isSending
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(_t("Send", "Kirim")),
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
                final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
                final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
                final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
                final Color fieldBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF9F6F0);

                return Scaffold(
                  backgroundColor: bgColor,
                  body: Stack(
                    children: [
                      // Decorative Orbs
                      Positioned(top: -50, right: -50, child: CircleAvatar(radius: 100, backgroundColor: const Color(0xFFCC6633).withValues(alpha: 0.1))),
                      Positioned(bottom: -80, left: -40, child: CircleAvatar(radius: 120, backgroundColor: const Color(0xFFE08B4B).withValues(alpha: 0.1))),

                      Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                          child: Column(
                            children: [
                              // --- TOMBOL TOGGLE BAHASA DAN TEMA (Scrollable) ---
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 24), // Jarak ke logo
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final newLang = globalLanguage.value == 'en' ? 'id' : 'en';
                                          globalLanguage.value = newLang;
                                          // Update notification language if reminder is enabled
                                          SharedPreferences.getInstance().then((prefs) {
                                            if (prefs.getBool('is_daily_reminder_on') ?? false) {
                                              NotificationService().scheduleDailyStudyReminder(newLang);
                                            }
                                          });
                                          final prefs = await SharedPreferences.getInstance();
                                          await prefs.setString('app_language', newLang);
                                          await prefs.setString('setting_lang', newLang); // Sync with GameManager key
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFCC6633).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            lang.toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFFCC6633),
                                              fontWeight: FontWeight.w900,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 1,
                                        height: 20,
                                        color: isDark ? Colors.white38 : Colors.black26,
                                      ),
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () async {
                                          final newDark = !globalDarkMode.value;
                                          globalDarkMode.value = newDark;
                                          final prefs = await SharedPreferences.getInstance();
                                          await prefs.setBool('is_dark_mode', newDark);
                                          await prefs.setBool('setting_dark', newDark); // Sync with GameManager key
                                        },
                                        child: Icon(
                                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                          color: isDark ? Colors.amberAccent : const Color(0xFF5D4037),
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // --- SELESAI TOMBOL TOGGLE ---

                              Hero(
                                tag: 'logo',
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.redAccent, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/iconUtama.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFFCC6633), Color(0xFFFF9600)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: const Text(
                                  "MIRAIku",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              AnimatedSize(
                                duration: const Duration(milliseconds: 100),
                                curve: Curves.easeInOut,
                                child: Container(
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                      color: cardColor, borderRadius: BorderRadius.circular(32),
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06), blurRadius: 30, offset: const Offset(0, 15))],
                                      border: Border.all(color: isDark ? const Color(0xFF333333) : Colors.transparent)
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 100),
                                      child: Column(
                                        key: ValueKey("${_isLoginMode}_$_isSignUpStep2"),
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              _isLoginMode ? _t("Welcome Back", "Selamat Datang") : (_isSignUpStep2 ? _t("Almost Done!", "Sedikit Lagi!") : _t("Create Account", "Buat Akun")),
                                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor, fontFamily: 'Serif')
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                              _isLoginMode ? _t("Login to continue your journey.", "Masuk untuk lanjut belajar.") : (_isSignUpStep2 ? _t("Let's personalize your profile.", "Ayo lengkapi profilmu.") : _t("Join us to start learning Japanese.", "Daftar untuk mulai belajar.")),
                                              style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 13, fontWeight: FontWeight.w500)
                                          ),
                                          const SizedBox(height: 32),

                                          if (_isLoginMode || !_isSignUpStep2) ...[
                                            _buildTextField(
                                              controller: _emailController, label: "Email",
                                              icon: Icons.email_rounded, isDark: isDark, fieldBg: fieldBg, textColor: textColor,
                                              type: TextInputType.emailAddress,
                                              hints: [AutofillHints.email],
                                              validator: (v) => (v == null || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) ? _t("Invalid email", "Email tidak valid") : null,
                                            ),
                                            const SizedBox(height: 18),
                                            _buildTextField(
                                              controller: _passwordController, label: _t("Password", "Kata Sandi"),
                                              icon: Icons.lock_rounded, isDark: isDark, fieldBg: fieldBg, textColor: textColor,
                                              isPassword: true, obscure: _obscurePassword,
                                              hints: [AutofillHints.password],
                                              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                                              validator: (v) {
                                                if (v == null || v.length < 6) return _t("Min. 6 chars", "Min. 6 karakter");
                                                if (!v.contains(RegExp(r'[0-9]'))) return _t("Must include a number", "Wajib mengandung angka");
                                                return null;
                                              },
                                            ),
                                            if (!_isLoginMode && !_isSignUpStep2) ...[
                                              const SizedBox(height: 18),
                                              _buildTextField(
                                                controller: _confirmPasswordController, label: _t("Confirm Password", "Konfirmasi Sandi"),
                                                icon: Icons.lock_clock_rounded, isDark: isDark, fieldBg: fieldBg, textColor: textColor,
                                                isPassword: true, obscure: _obscurePassword,
                                                validator: (v) => (v != _passwordController.text) ? _t("Passwords don't match", "Sandi tidak cocok") : null,
                                              ),
                                            ],
                                          ] else ...[
                                            _buildTextField(
                                              controller: _nameController, label: _t("Display Name", "Nama Tampilan"),
                                              icon: Icons.person_rounded, isDark: isDark, fieldBg: fieldBg, textColor: textColor,
                                              hints: [AutofillHints.name],
                                              maxLength: 25,
                                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                                              validator: (v) {
                                                if (v == null || v.trim().isEmpty) return _t("Name required", "Nama wajib diisi");
                                                if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v)) return _t("Letters and spaces only", "Hanya huruf dan spasi");
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 18),
                                            _buildTextField(
                                              controller: _descController, label: "Bio",
                                              icon: Icons.info_outline_rounded, isDark: isDark, fieldBg: fieldBg, textColor: textColor,
                                              hints: [AutofillHints.jobTitle],
                                              maxLength: 50,
                                              validator: (v) => (v == null || v.trim().isEmpty) ? _t("Bio required", "Bio wajib diisi") : null,
                                            ),
                                          ],

                                          if (_isLoginMode) ...[
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(children: [SizedBox(width: 24, child: Checkbox(value: _rememberMe, activeColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), onChanged: (v) => setState(() => _rememberMe = v ?? false))), const SizedBox(width: 8), Text(_t("Remember Me", "Ingat Saya"), style: const TextStyle(fontSize: 12, color: Color(0xFF8C8A87), fontWeight: FontWeight.bold))]),
                                                GestureDetector(onTap: _showForgotPasswordDialog, child: Text(_t("Forgot?", "Lupa?"), style: const TextStyle(fontSize: 12, color: Color(0xFFCC6633), fontWeight: FontWeight.w900))),
                                              ],
                                            ),
                                          ],

                                          const SizedBox(height: 32),
                                          SizedBox(
                                            width: double.infinity, height: 58,
                                            child: ElevatedButton(
                                              onPressed: _isLoading ? null : () async {
                                                if (!_isLoginMode && !_isSignUpStep2) {
                                                  if (_formKey.currentState!.validate()) {
                                                    FocusScope.of(context).unfocus();
                                                    setState(() => _isSignUpStep2 = true);
                                                  }
                                                } else {
                                                  _handleAuth();
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFCC6633),
                                                  disabledBackgroundColor: const Color(0xFFCC6633).withValues(alpha: 0.6),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                                  elevation: 0
                                              ),
                                              child: _isLoading
                                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                                                  : Text(
                                                  _isLoginMode ? _t("Sign In", "Masuk") : (_isSignUpStep2 ? _t("Finish", "Selesai") : _t("Next", "Lanjut")),
                                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)
                                              ),
                                            ),
                                          ),

                                          if (_isLoginMode || !_isSignUpStep2) ...[
                                            const SizedBox(height: 20),
                                            Row(children: [const Expanded(child: Divider()), Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(_t("OR", "ATAU"), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFB5B0A8)))), const Expanded(child: Divider())]),
                                            const SizedBox(height: 20),
                                            SizedBox(
                                              width: double.infinity, height: 58,
                                              child: OutlinedButton(
                                                onPressed: _isLoading ? null : _handleGoogleSignIn,
                                                style: OutlinedButton.styleFrom(side: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA), width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Image.network(
                                                      'https://www.gstatic.com/images/branding/product/1x/gsa_512dp.png',
                                                      height: 22,
                                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.red, size: 28),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Flexible(
                                                      child: Text(
                                                        _t("Continue with Google", "Lanjutkan dengan Google"),
                                                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                              TextButton(
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
                                child: RichText(
                                    text: TextSpan(
                                        text: (_isSignUpStep2) ? "" : (_isLoginMode ? _t("New here? ", "Baru di sini? ") : _t("Have an account? ", "Sudah punya akun? ")),
                                        style: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold),
                                        children: [
                                          TextSpan(
                                              text: (_isSignUpStep2) ? _t("← Back to Account Info", "← Kembali ke Info Akun") : (_isLoginMode ? _t("Sign Up", "Daftar") : _t("Sign In", "Masuk")),
                                              style: const TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.w900)
                                          )
                                        ]
                                    )
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
          );
        }
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, required String label, required IconData icon,
    required bool isDark, required Color fieldBg, required Color textColor,
    bool isPassword = false, bool obscure = false, VoidCallback? onToggle,
    TextInputType type = TextInputType.text, List<String>? hints, String? Function(String?)? validator,
    int? maxLength, List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      autofillHints: hints,
      validator: validator,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: isDark ? Colors.white38 : const Color(0xFFB5B0A8), fontSize: 14, fontWeight: FontWeight.w500),
        counterText: "",
        filled: true, fillColor: fieldBg,
        prefixIcon: Icon(icon, color: const Color(0xFFB5B0A8), size: 20),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: const Color(0xFFB5B0A8), size: 20), onPressed: onToggle) : null,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF333333) : Colors.transparent)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }
}
