import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageLuxState();
}

class _ProfilePageLuxState extends State<ProfilePage> {
  // ✨ Skema Warna Mewah: Dark Teal/Black dan Aksen Emas
  final Color _deepBlack = const Color(0xFF000000);
  final Color _background =
      const Color(0xFF0C192C);
  final Color _primaryColor = const Color(0xFF0B466C);
  final Color _accentColor = const Color(0xFFFFD700);
  final Color _cardColor =
      const Color(0xFF1B2A41);
  final Color _textColor = Colors.white;

  String userName = "Memuat...";
  String userEmail = "Memuat...";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // --- LOGIC: Memuat Data dari SharedPreferences ---
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulasi penundaan
    setState(() {
      userName = prefs.getString("userName") ?? "Adam Anugrah";
      userEmail = prefs.getString("userEmail") ?? "adamanugrah1012@gmail.com";
    });
  }

  // --- WIDGET KOMPONEN TERPISAH (MODULAR) ---

  // 1. Header Profil Mewah (Menggunakan Glassmorphism Ringan)
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        // Gradien yang lebih dalam
        gradient: LinearGradient(
          colors: [_deepBlack.withOpacity(0.8), _primaryColor.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30), // Sudut yang lebih membulat
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Foto Profil Emas dengan Efek Cahaya
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _accentColor, width: 5),
              boxShadow: [
                BoxShadow(
                  color: _accentColor.withOpacity(0.7),
                  blurRadius: 25,
                )
              ],
            ),
            child: CircleAvatar(
              backgroundColor: _cardColor.withOpacity(0.8),
              child: Icon(Icons.person_pin_circle_rounded,
                  size: 100, color: _accentColor),
            ),
          ),
          const SizedBox(height: 20),
          // Nama Pengguna
          Text(
            userName,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: _textColor,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          // Email
          Text(
            userEmail,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                color: _textColor.withOpacity(0.6),
                fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 15),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Akun Premium Verified",
              style: TextStyle(
                  color: _background,
                  fontWeight: FontWeight.w900,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Tile Menu Mewah (Dengan InkWell untuk Efek Sentuh)
  Widget _buildMenuTileLux(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20), // Sudut yang lebih lembut
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Aksi saat diklik
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$title diklik")),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
            child: Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        color: _textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 24, color: _textColor.withOpacity(0.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- BUILD METHOD UTAMA ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50), // Ruang atas yang lebih besar

            // HEADER PROFIL
            _buildProfileHeader(),

            const SizedBox(height: 40),

            // JUDUL MENU
            Text(
              "Pengaturan Akun",
              style: TextStyle(
                  color: _textColor, fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            // MENU ACTION MEWAH
            _buildMenuTileLux(
                "Edit Profil", Icons.person_rounded, _primaryColor),
            _buildMenuTileLux(
                "Ganti Password", Icons.lock_open_rounded, Colors.red.shade600),
            _buildMenuTileLux("Privasi & Keamanan", Icons.verified_user_rounded,
                Colors.green.shade400),
            _buildMenuTileLux("Tentang Aplikasi",
                Icons.app_settings_alt_rounded, _accentColor),
            const SizedBox(height: 30),

            // TOMBOL LOGOUT
            _actionButton("Log Out", Icons.logout_rounded, Colors.red.shade900),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // Widget Tombol Aksi Keren
  Widget _actionButton(String title, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$title diklik")),
        );
      },
      icon: Icon(icon, color: _textColor),
      label: Text(
        title,
        style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        minimumSize: const Size(double.infinity, 50),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
      ),
    );
  }
}
