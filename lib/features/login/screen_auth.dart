import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart'; // IMPORT GOOGLE SIGN IN
import '../../main.dart';

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

  // ========================================================
  // 🚀 FUNGSI LOGIN GOOGLE (BARU)
  // ========================================================
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // WAJIB DIGANTI: Masukkan Web Client ID dari Google Cloud Console
      const webClientId = '564994938710-anv76b8tkf8uoobjohct7fohm8f4ovhu.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Login dibatalkan oleh pengguna.';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'Gagal mendapatkan token dari Google.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Jika sukses, StreamBuilder di main.dart akan otomatis mendeteksi
      // dan melempar user ke halaman utama.
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Google Sign-In: $error'), backgroundColor: Colors.red),
        );
      }
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message), backgroundColor: Colors.red));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("An unexpected error occurred", "Terjadi kesalahan tidak terduga")), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ... (Fungsi _showForgotPasswordDialog tetap sama seperti sebelumnya) ...
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
                  title: Text(_t("Reset Password", "Atur Ulang Sandi"), style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF2D2622))),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_t("Enter your email address to receive a password reset link.", "Masukkan alamat emailmu untuk menerima tautan atur ulang kata sandi."), style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 13)),
                      const SizedBox(height: 16),
                      TextField(controller: resetEmailController, style: TextStyle(color: isDark ? Colors.white : Colors.black), decoration: InputDecoration(hintText: "Email", filled: true, fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white, prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFFB5B0A8)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(_t("Cancel", "Batal"), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8C8A87)))),
                    ElevatedButton(
                      onPressed: isSending ? null : () async {
                        if (resetEmailController.text.isEmpty || !resetEmailController.text.contains('@')) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Enter a valid email", "Masukkan email yang valid")), backgroundColor: Colors.red)); return; }
                        setDialogState(() => isSending = true);
                        try {
                          await Supabase.instance.client.auth.resetPasswordForEmail(resetEmailController.text.trim());
                          if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Password reset link sent!", "Tautan reset telah dikirim!")))); }
                        } on AuthException catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
                        } finally { setDialogState(() => isSending = false); }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: isSending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_t("Send Link", "Kirim Tautan"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
    final bool isDark = globalDarkMode.value;
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color fieldBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF9F6F0);

    String getTitle() {
      if (_isLoginMode) return _t("Welcome Back", "Selamat Datang");
      if (_isSignUpStep2) return _t("Complete Profile", "Lengkapi Profil");
      return _t("Create Account", "Buat Akun Baru");
    }

    String getSubtitle() {
      if (_isLoginMode) return _t("Log in to continue your progress.", "Masuk untuk melanjutkan progresmu.");
      if (_isSignUpStep2) return _t("Tell us a bit about yourself.", "Beritahu kami sedikit tentang dirimu.");
      return _t("Sign up to start learning Japanese.", "Daftar untuk mulai belajar bahasa Jepang.");
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned(top: -100, right: -80, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFCC6633).withValues(alpha: isDark ? 0.05 : 0.1)))),
          Positioned(bottom: -50, left: -100, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE08B4B).withValues(alpha: isDark ? 0.05 : 0.1)))),

          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFCC6633).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Text("み", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFCC6633), fontFamily: 'Serif'))),
                  const SizedBox(height: 16),
                  Text("MIRAIKU", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 4)),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 20, offset: const Offset(0, 10))], border: Border.all(color: isDark ? const Color(0xFF333333) : Colors.transparent)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("いらっしゃいませ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCC6633))),
                          const SizedBox(height: 2),
                          const Text("(Irasshaimase)", style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF8C8A87), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),

                          Text(getTitle(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor, fontFamily: 'Serif')),
                          const SizedBox(height: 8),
                          Text(getSubtitle(), style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 13)),
                          const SizedBox(height: 32),

                          if (_isLoginMode || !_isSignUpStep2) ...[
                            TextFormField(controller: _emailController, style: TextStyle(fontWeight: FontWeight.bold, color: textColor), keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: "Email", filled: true, fillColor: fieldBg, prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFFB5B0A8)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF333333) : Colors.transparent)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2))), validator: (value) => value == null || !value.contains('@') ? _t("Enter a valid email", "Email tidak valid") : null),
                            const SizedBox(height: 16),
                            TextFormField(controller: _passwordController, style: TextStyle(fontWeight: FontWeight.bold, color: textColor), obscureText: _obscurePassword, decoration: InputDecoration(labelText: _t("Password", "Kata Sandi"), filled: true, fillColor: fieldBg, prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFFB5B0A8)), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: const Color(0xFFB5B0A8)), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF333333) : Colors.transparent)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2))), validator: (value) => value == null || value.length < 6 ? _t("Min. 6 characters", "Minimal 6 karakter") : null),
                          ] else ...[
                            TextFormField(controller: _nameController, style: TextStyle(fontWeight: FontWeight.bold, color: textColor), decoration: InputDecoration(labelText: _t("Display Name", "Nama Tampilan"), filled: true, fillColor: fieldBg, prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFFB5B0A8)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF333333) : Colors.transparent)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2))), validator: (value) => value == null || value.isEmpty ? _t("Name is required", "Nama wajib diisi") : null),
                            const SizedBox(height: 16),
                            TextFormField(controller: _descController, style: TextStyle(fontWeight: FontWeight.bold, color: textColor), decoration: InputDecoration(labelText: "Bio", filled: true, fillColor: fieldBg, prefixIcon: const Icon(Icons.info_outline_rounded, color: Color(0xFFB5B0A8)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF333333) : Colors.transparent)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)))),
                          ],

                          if (_isLoginMode) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(children: [SizedBox(width: 24, height: 24, child: Checkbox(value: _rememberMe, activeColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), side: const BorderSide(color: Color(0xFFB5B0A8)), onChanged: (val) => setState(() => _rememberMe = val ?? false))), const SizedBox(width: 8), Text(_t("Remember me", "Ingat saya"), style: const TextStyle(fontSize: 12, color: Color(0xFF8C8A87), fontWeight: FontWeight.bold))]),
                                TextButton(onPressed: _showForgotPasswordDialog, style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap), child: Text(_t("Forgot Password?", "Lupa Sandi?"), style: const TextStyle(fontSize: 12, color: Color(0xFFCC6633), fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ],
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity, height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () {
                                if (_isLoginMode) { _handleAuth(); } else { if (!_isSignUpStep2) { if (_formKey.currentState!.validate()) { setState(() => _isSignUpStep2 = true); } } else { if (_formKey.currentState!.validate()) { _handleAuth(); } } }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text(_isLoginMode ? _t("Sign In", "Masuk") : (!_isSignUpStep2 ? _t("Next", "Lanjut") : _t("Sign Up", "Daftar")), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),

                          // ========================================================
                          // 🚀 TOMBOL LOGIN GOOGLE
                          // ========================================================
                          if (_isLoginMode || !_isSignUpStep2) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: Divider(color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA))),
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("ATAU", style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFFB5B0A8), fontSize: 12, fontWeight: FontWeight.bold))),
                                Expanded(child: Divider(color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA))),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity, height: 56,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _handleGoogleSignIn,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                                  side: BorderSide(color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E3DA), width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                // Icon 'G' statis untuk Google
                                icon: const Text("G", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                                label: Text(
                                  _isLoginMode ? _t("Continue with Google", "Lanjutkan dengan Google") : _t("Sign up with Google", "Daftar dengan Google"),
                                  style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: () { setState(() { if (!_isLoginMode && _isSignUpStep2) { _isSignUpStep2 = false; } else { _isLoginMode = !_isLoginMode; _isSignUpStep2 = false; _formKey.currentState?.reset(); } }); },
                    child: RichText(text: TextSpan(text: (!_isLoginMode && _isSignUpStep2) ? "" : (_isLoginMode ? _t("Don't have an account? ", "Belum punya akun? ") : _t("Already have an account? ", "Sudah punya akun? ")), style: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold), children: [TextSpan(text: (!_isLoginMode && _isSignUpStep2) ? _t("← Back to Email", "← Kembali ke Email") : (_isLoginMode ? _t("Sign Up", "Daftar") : _t("Sign In", "Masuk")), style: const TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.w900))])),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}