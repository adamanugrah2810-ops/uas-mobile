import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan ini
import '../services/auth_service.dart';
import 'dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController(); // Baru

  bool loading = false;
  bool obscurePass = true;
  bool obscureConfirmPass = true; // Baru

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
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose(); // Dispose controller baru
    super.dispose();
  }

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    // 1. Validasi Input Kosong
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnackBar("Semua field harus diisi.", Colors.orange);
      return;
    }

    // 2. Validasi Kecocokan Password
    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Konfirmasi kata sandi tidak cocok!", Colors.redAccent);
      return;
    }

    setState(() => loading = true);

    try {
      var res = await AuthService().register(
          nameController.text, emailController.text, passwordController.text);

      if (res["success"] == true) {
        // 3. SIMPAN SESI & NAMA KE DATABASE
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString(
            "userName", nameController.text); // Simpan nama asli

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardPage()),
          );
        }
      } else {
        if (mounted) _showSnackBar(res["message"], Colors.redAccent);
      }
    } catch (e) {
      if (mounted)
        _showSnackBar("Terjadi kesalahan koneksi.", Colors.redAccent);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
                        const SizedBox(height: 40),
                        _buildHeaderSection(),
                        const SizedBox(height: 30),
                        _buildInputCard(),
                        const SizedBox(height: 24),
                        _buildFooter(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textDark),
              onPressed: () => Navigator.pop(context),
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
          top: -50,
          left: -50,
          child: _blob(250, primaryBlue.withOpacity(0.05)),
        ),
        Positioned(
          bottom: -100,
          right: -50,
          child: _blob(300, accentBlue.withOpacity(0.05)),
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

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Icon(Icons.app_registration_rounded, size: 70, color: primaryBlue),
        const SizedBox(height: 16),
        Text(
          "Buat Akun",
          style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w900, color: textDark),
        ),
        const SizedBox(height: 8),
        Text(
          "Daftar untuk menikmati akses penuh",
          style: TextStyle(fontSize: 14, color: textDark.withOpacity(0.5)),
        ),
      ],
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
            controller: nameController,
            label: "Nama Lengkap",
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: emailController,
            label: "Email",
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: passwordController,
            label: "Password",
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isConfirmField: false,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: confirmPasswordController,
            label: "Konfirmasi Password",
            icon: Icons.lock_reset_rounded,
            isPassword: true,
            isConfirmField: true, // Untuk toggle mata yang terpisah
          ),
          const SizedBox(height: 24),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmField = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword
          ? (isConfirmField ? obscureConfirmPass : obscurePass)
          : false,
      keyboardType: keyboardType,
      style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: textDark.withOpacity(0.3), fontSize: 13),
        prefixIcon: Icon(icon, color: primaryBlue, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                    (isConfirmField ? obscureConfirmPass : obscurePass)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                    size: 20),
                onPressed: () {
                  setState(() {
                    if (isConfirmField) {
                      obscureConfirmPass = !obscureConfirmPass;
                    } else {
                      obscurePass = !obscurePass;
                    }
                  });
                },
              )
            : null,
        filled: true,
        fillColor: bgCanvas,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              BorderSide(color: primaryBlue.withOpacity(0.2), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(colors: [primaryBlue, accentBlue]),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : const Text(
                "DAFTAR SEKARANG",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    letterSpacing: 1),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: RichText(
        text: TextSpan(
          text: "Sudah punya akun? ",
          style: TextStyle(color: textDark.withOpacity(0.5), fontSize: 14),
          children: [
            TextSpan(
              text: "Masuk",
              style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
