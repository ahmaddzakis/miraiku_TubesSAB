import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  bool _isLoginMode = true;
  bool _isLoading = false;

  // Fitur Baru
  bool _obscurePassword = true; // Untuk fitur intip password (ikon mata)
  bool _rememberMe = false;     // Untuk fitur "Ingat Saya"

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  // --- MEMUAT EMAIL JIKA "REMEMBER ME" SEBELUMNYA DICENTANG ---
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

  // --- FUNGSI TRANSLATE ---
  String _t(String en, String id) {
    return globalLanguage.value == 'id' ? id : en;
  }

  // --- EKSEKUSI AUTH (SUPABASE) ---
  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      if (_isLoginMode) {
        // Logika Login
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Simpan atau Hapus email dari memori lokal berdasarkan centang
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('remembered_email', _emailController.text.trim());
        } else {
          await prefs.remove('remembered_email');
        }

      } else {
        // Logika Register
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_t("Registration successful! You can now log in.", "Pendaftaran berhasil! Silakan masuk."))),
          );
        }
        setState(() => _isLoginMode = true);
      }
    } on AuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_t("An unexpected error occurred", "Terjadi kesalahan tidak terduga")), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FITUR FORGOT PASSWORD ---
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
                      TextField(
                        controller: resetEmailController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          hintText: "Email",
                          filled: true,
                          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFFB5B0A8)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(_t("Cancel", "Batal"), style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8C8A87))),
                    ),
                    ElevatedButton(
                      onPressed: isSending ? null : () async {
                        if (resetEmailController.text.isEmpty || !resetEmailController.text.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Enter a valid email", "Masukkan email yang valid")), backgroundColor: Colors.red));
                          return;
                        }
                        setDialogState(() => isSending = true);
                        try {
                          await Supabase.instance.client.auth.resetPasswordForEmail(resetEmailController.text.trim());
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t("Password reset link sent to your email!", "Tautan reset telah dikirim ke emailmu!"))));
                          }
                        } on AuthException catch (e) {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
                        } finally {
                          setDialogState(() => isSending = false);
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: isSending
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_t("Send Link", "Kirim Tautan"), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = globalDarkMode.value;
    final Color bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F6F0);
    final Color textColor = isDark ? Colors.white : const Color(0xFF2D2622);
    final Color cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color fieldBg = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFF9F6F0);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // --- ELEMEN DEKORASI BACKGROUND (Membuat tampilan jauh lebih menarik) ---
          Positioned(
            top: -100, right: -80,
            child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFCC6633).withValues(alpha: isDark ? 0.05 : 0.1))),
          ),
          Positioned(
            bottom: -50, left: -100,
            child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE08B4B).withValues(alpha: isDark ? 0.05 : 0.1))),
          ),

          // --- KONTEN UTAMA ---
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Inisial Aplikasi
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: const Color(0xFFCC6633).withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Text("み", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFCC6633), fontFamily: 'Serif')),
                  ),
                  const SizedBox(height: 16),
                  Text("MIRAIKU", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor, letterSpacing: 4)),
                  const SizedBox(height: 40),

                  // KARTU FORM LOGIN (Membuat form terlihat melayang/rapi)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                      border: Border.all(color: isDark ? const Color(0xFF333333) : Colors.transparent),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLoginMode ? _t("Welcome Back", "Selamat Datang") : _t("Create Account", "Buat Akun Baru"),
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: textColor, fontFamily: 'Serif'),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLoginMode ? _t("Log in to continue your progress.", "Masuk untuk melanjutkan progresmu.") : _t("Sign up to start learning Japanese.", "Daftar untuk mulai belajar bahasa Jepang."),
                            style: const TextStyle(color: Color(0xFF8C8A87), fontSize: 13),
                          ),
                          const SizedBox(height: 32),

                          // Input Email
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              filled: true,
                              fillColor: fieldBg,
                              prefixIcon: const Icon(Icons.email_rounded, color: Color(0xFFB5B0A8)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF333333) : Colors.transparent)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)),
                            ),
                            validator: (value) => value == null || !value.contains('@') ? _t("Enter a valid email", "Email tidak valid") : null,
                          ),
                          const SizedBox(height: 16),

                          // Input Password
                          TextFormField(
                            controller: _passwordController,
                            style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                            obscureText: _obscurePassword, // Diatur oleh tombol mata
                            decoration: InputDecoration(
                              labelText: _t("Password", "Kata Sandi"),
                              filled: true,
                              fillColor: fieldBg,
                              prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFFB5B0A8)),

                              // FITUR MATA (SHOW/HIDE PASSWORD)
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: const Color(0xFFB5B0A8)),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),

                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: isDark ? const Color(0xFF333333) : Colors.transparent)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCC6633), width: 2)),
                            ),
                            validator: (value) => value == null || value.length < 6 ? _t("Min. 6 characters", "Minimal 6 karakter") : null,
                          ),

                          // BARIS: REMEMBER ME & FORGOT PASSWORD
                          if (_isLoginMode) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 24, height: 24,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: const Color(0xFFCC6633),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        side: const BorderSide(color: Color(0xFFB5B0A8)),
                                        onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(_t("Remember me", "Ingat saya"), style: const TextStyle(fontSize: 12, color: Color(0xFF8C8A87), fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                TextButton(
                                  onPressed: _showForgotPasswordDialog,
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                  child: Text(_t("Forgot Password?", "Lupa Sandi?"), style: const TextStyle(fontSize: 12, color: Color(0xFFCC6633), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 32),

                          // Tombol Submit
                          SizedBox(
                            width: double.infinity, height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleAuth,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCC6633), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                _isLoginMode ? _t("Sign In", "Masuk") : _t("Sign Up", "Daftar"),
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Pindah Mode (Login / Register)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                        _formKey.currentState?.reset(); // Reset form saat ganti mode
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        text: _isLoginMode ? _t("Don't have an account? ", "Belum punya akun? ") : _t("Already have an account? ", "Sudah punya akun? "),
                        style: const TextStyle(color: Color(0xFF8C8A87), fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: _isLoginMode ? _t("Sign Up", "Daftar") : _t("Sign In", "Masuk"),
                            style: const TextStyle(color: Color(0xFFCC6633), fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
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
}