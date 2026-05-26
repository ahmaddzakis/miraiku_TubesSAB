import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/game_manager.dart';

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

  bool _isLoginMode = true;
  bool _isSignUpStep2 = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red),
            const SizedBox(width: 10),
            Text(_t("Error", "Kesalahan"), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFCC6633))),
          )
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      const webClientId = '564994938710-anv76b8tkf8uoobjohct7fohm8f4ovhu.apps.googleusercontent.com';
      final GoogleSignIn googleSignIn = GoogleSignIn(serverClientId: webClientId);
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) throw 'Failed to get tokens';

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (error) {
      _showErrorDialog(_t("Google Sign-In failed: $error", "Gagal masuk dengan Google: $error"));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      if (_isLoginMode) {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('remembered_email', _emailController.text.trim());
        } else {
          await prefs.remove('remembered_email');
        }
      } else {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          data: {
            'display_name': _nameController.text.trim().isEmpty ? "Pelajar Baru" : _nameController.text.trim(),
            'bio': _descController.text.trim().isEmpty ? "Siap belajar bahasa Jepang!" : _descController.text.trim(),
          }
        );
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.message);
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = globalDarkMode.value;
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF2D2D2D) : const Color(0xFFFAF7F2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text(_t("Reset Password", "Lupa Sandi"), style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF2D2622))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_t("Enter your email to receive a reset link.", "Masukkan email untuk menerima tautan atur ulang."), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: "Email", filled: true, 
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFFB5B0A8)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)
                    )
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(_t("Cancel", "Batal"), style: const TextStyle(color: Color(0xFF8C8A87)))),
                ElevatedButton(
                  onPressed: isSending ? null : () async {
                    if (resetEmailController.text.isEmpty || !resetEmailController.text.contains('@')) return;
                    setDialogState(() => isSending = true);
                    
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    try {
                      await Supabase.instance.client.auth.resetPasswordForEmail(resetEmailController.text.trim());
                      navigator.pop();
                      scaffoldMessenger.showSnackBar(SnackBar(content: Text(_t("Reset link sent!", "Tautan telah dikirim!"))));
                    } catch (e) {
                      _showErrorDialog(e.toString());
                    } finally { 
                      if (mounted) setDialogState(() => isSending = false); 
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: isSending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_t("Send", "Kirim")),
                ),
              ],
            );
          }
        );
      }
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: globalDarkMode,
      builder: (context, isDark, _) {
        return ValueListenableBuilder(
          valueListenable: globalLanguage,
          builder: (context, lang, _) {
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
                          Hero(
                            tag: 'logo',
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(color: const Color(0xFFCC6633).withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Text("み", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFFCC6633), fontFamily: 'Serif', decoration: TextDecoration.none))
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text("MIRAIKU", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 6, color: Color(0xFFCC6633))),
                          const SizedBox(height: 40),

                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
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
                                  duration: const Duration(milliseconds: 300),
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
                                          validator: (v) => (v == null || v.length < 6) ? _t("Min. 6 chars", "Min. 6 karakter") : null,
                                        ),
                                      ] else ...[
                                        _buildTextField(
                                          controller: _nameController, label: _t("Display Name", "Nama Tampilan"), 
                                          icon: Icons.person_rounded, isDark: isDark, fieldBg: fieldBg, textColor: textColor,
                                          hints: [AutofillHints.name],
                                          validator: (v) => (v == null || v.isEmpty) ? _t("Name required", "Nama wajib diisi") : null,
                                        ),
                                        const SizedBox(height: 18),
                                        _buildTextField(
                                          controller: _descController, label: "Bio", 
                                          icon: Icons.info_outline_rounded, isDark: isDark, fieldBg: fieldBg, textColor: textColor,
                                          hints: [AutofillHints.jobTitle],
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
                                          onPressed: _isLoading ? null : () {
                                            if (!_isLoginMode && !_isSignUpStep2) {
                                              if (_formKey.currentState!.validate()) setState(() => _isSignUpStep2 = true);
                                            } else {
                                              _handleAuth();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0),
                                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3) : Text(_isLoginMode ? _t("Sign In", "Masuk") : (_isSignUpStep2 ? _t("Finish", "Selesai") : _t("Next", "Lanjut")), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
                                              children: [
                                                Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png', height: 22),
                                                const SizedBox(width: 12),
                                                Text(_t("Continue with Google", "Lanjutkan dengan Google"), style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
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
                                } else {
                                  _isLoginMode = !_isLoginMode;
                                  _isSignUpStep2 = false;
                                  _formKey.currentState?.reset();
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
    TextInputType type = TextInputType.text, List<String>? hints, String? Function(String?)? validator
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      autofillHints: hints,
      validator: validator,
      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: Color(0xFFB5B0A8), fontSize: 14, fontWeight: FontWeight.w600),
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
