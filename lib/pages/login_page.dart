import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'dashboard_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;
  bool obscurePass = true;

  // Palette Premium (Putih - Biru Luxury)
  final Color bgCanvas = const Color(0xFFF8FAFD);
  final Color primaryBlue = const Color(0xFF0052D4);
  final Color accentBlue = const Color(0xFF4364F7);
  final Color textDark = const Color(0xFF0F172A);

  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    checkSession();
  }

  Future<void> checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isLoggedIn") == true && mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      body: Stack(
        children: [
          _buildBackgroundDecor(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        _buildLogoSection(),
                        const SizedBox(height: 40),
                        _buildInputCard(),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecor() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: _blob(300, primaryBlue.withOpacity(0.05)),
        ),
        Positioned(
          bottom: -80,
          left: -60,
          child: _blob(250, accentBlue.withOpacity(0.05)),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          height: 100,
          width: 100,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child:
              Image.asset("assets/images/logo_banten.jpg", fit: BoxFit.contain),
        ),
        const SizedBox(height: 24),
        Text(
          "Selamat Datang",
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w900, color: textDark),
        ),
        const SizedBox(height: 8),
        Text(
          "Masuk ke akun untuk melanjutkan",
          style: TextStyle(fontSize: 14, color: textDark.withOpacity(0.5)),
        ),
      ],
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: emailController,
            label: "Email",
            icon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: passwordController,
            label: "Password",
            icon: Icons.lock_open_rounded,
            isPassword: true,
          ),
          const SizedBox(height: 32),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? obscurePass : false,
      style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textDark.withOpacity(0.3), fontSize: 14),
        prefixIcon: Icon(icon, color: primaryBlue, size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    obscurePass ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey),
                onPressed: () => setState(() => obscurePass = !obscurePass),
              )
            : null,
        filled: true,
        fillColor: bgCanvas,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
              BorderSide(color: primaryBlue.withOpacity(0.2), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: [primaryBlue, accentBlue]),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: loading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Text(
                "MASUK",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 1.2),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return TextButton(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const RegisterPage())),
      child: RichText(
        text: TextSpan(
          text: "Belum punya akun? ",
          style: TextStyle(color: textDark.withOpacity(0.5)),
          children: [
            TextSpan(
              text: "Daftar",
              style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // LOGIC LOGIN YANG TELAH DIPERBAIKI
  Future<void> login() async {
    FocusScope.of(context).unfocus();

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Email dan password wajib diisi"),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => loading = true);

    try {
      var res = await AuthService()
          .login(emailController.text, passwordController.text);

      if (res["success"] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // 1. Simpan Status Login
        await prefs.setBool("isLoggedIn", true);

        // 2. Simpan Nama dari Database (Sesuaikan key 'name' dengan response backend Anda)
        // Jika response backend adalah { "user": { "name": "Adam", ... } }
        if (res["user"] != null && res["user"]["name"] != null) {
          await prefs.setString("userName", res["user"]["name"]);
        } else {
          await prefs.setString("userName", "User");
        }

        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DashboardPage()));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(res["message"] ?? "Email atau Password salah"),
              backgroundColor: Colors.redAccent));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Koneksi gagal, silakan coba lagi"),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
