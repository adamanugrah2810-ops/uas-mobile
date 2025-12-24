import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageUltraState();
}

class _ProfilePageUltraState extends State<ProfilePage> {
  // --- PALETTE WARNA LUXURY ---
  final Color primaryDark = const Color(0xFF0F172A);
  final Color accentGold = const Color(0xFFC5A059);
  final Color accentBlue = const Color(0xFF3B82F6);
  final Color bgCanvas = const Color(0xFFF8FAFC);

  String username = "Warga Banten";
  String email = "user@banten.go.id";
  String bio = "Masyarakat Sadar Hukum";
  String phone = "Belum diatur";
  String? profilePath;
  bool isLoading = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // MEMUAT DATA DARI STORAGE
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("userName") ?? "Warga Banten";
      email = prefs.getString("userEmail") ?? "user@banten.go.id";
      bio = prefs.getString("userBio") ?? "Masyarakat Sadar Hukum";
      phone = prefs.getString("userPhone") ?? "Belum diatur";
      profilePath = prefs.getString("profileImage");
      isLoading = false;
    });
  }

  // FUNGSI UPDATE DATA (EDIT PROFILE)
  Future<void> _updateProfile(
      String newName, String newBio, String newPhone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userName", newName);
    await prefs.setString("userBio", newBio);
    await prefs.setString("userPhone", newPhone);
    _loadUserData(); // Refresh tampilan
  }

  // FUNGSI PICK IMAGE
  Future<void> _pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("profileImage", image.path);
      setState(() => profilePath = image.path);
    }
  }

  // FUNGSI LOGOUT
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryDark))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
                    child: Column(
                      children: [
                        _buildSectionHeader("INFORMASI PRIBADI"),
                        _buildInfoCard(),
                        const SizedBox(height: 30),
                        _buildSectionHeader("PENGATURAN & KEAMANAN"),
                        _buildActionMenu(),
                        const SizedBox(height: 40),
                        _buildLogoutButton(),
                        const SizedBox(height: 25),
                        Text("Versi 2.0.2 • Banten Digital System",
                            style: GoogleFonts.inter(
                                color: Colors.grey[400],
                                fontSize: 10,
                                letterSpacing: 0.8)),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: primaryDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [primaryDark, const Color(0xFF1E293B)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildLuxuryAvatar(),
              const SizedBox(height: 15),
              Text(username,
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              Text(email,
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.6), fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuxuryAvatar() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentGold.withOpacity(0.5), width: 2)),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF334155),
            backgroundImage:
                profilePath != null ? FileImage(File(profilePath!)) : null,
            child: profilePath == null
                ? const Icon(Icons.person_rounded,
                    size: 50, color: Colors.white24)
                : null,
          ),
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: accentGold,
                shape: BoxShape.circle,
                border: Border.all(color: primaryDark, width: 3)),
            child: const Icon(Icons.camera_alt_rounded,
                size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.phone_iphone_rounded, "Telepon", phone),
          _divider(),
          _infoRow(Icons.notes_rounded, "Bio Singkat", bio),
          _divider(),
          _infoRow(Icons.verified_user_rounded, "Status Akun", "Terverifikasi",
              isVerified: true),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool isVerified = false}) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Icon(icon, size: 20, color: accentBlue.withOpacity(0.7)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: Colors.grey[500])),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isVerified ? Colors.green[700] : primaryDark)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionMenu() {
    return Column(
      children: [
        _luxuryMenuTile("Edit Profile", "Ubah data diri Anda",
            Icons.person_outline_rounded, accentBlue, () {
          _showEditDialog();
        }),
        _luxuryMenuTile("Keamanan Akun", "Kata sandi & privasi",
            Icons.lock_open_rounded, const Color(0xFF10B981), () {}),
        _luxuryMenuTile("Pengaturan Aplikasi", "Notifikasi & bahasa",
            Icons.settings_suggest_rounded, accentGold, () {}),
      ],
    );
  }

  Widget _luxuryMenuTile(String title, String sub, IconData icon, Color color,
      VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, fontSize: 14, color: primaryDark)),
        subtitle: Text(sub,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _showLogoutConfirmDialog,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: Center(
          child: Text("KELUAR APLIKASI",
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1.2)),
        ),
      ),
    );
  }

  // --- DIALOG EDIT PROFILE ---
  void _showEditDialog() {
    final nameCtrl = TextEditingController(text: username);
    final bioCtrl = TextEditingController(text: bio);
    final phoneCtrl = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Data Diri"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Nama")),
              TextField(
                  controller: bioCtrl,
                  decoration: const InputDecoration(labelText: "Bio")),
              TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: "Telepon")),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              _updateProfile(nameCtrl.text, bioCtrl.text, phoneCtrl.text);
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // --- DIALOG LOGOUT ---
  void _showLogoutConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Konfirmasi"),
          content: const Text("Yakin ingin keluar dari akun ini?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal")),
            TextButton(
                onPressed: _handleLogout,
                child: const Text("Ya, Keluar",
                    style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, thickness: 0.5, color: Colors.grey[100], indent: 50);
  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 15),
        child: Text(title,
            style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.grey[400],
                letterSpacing: 1.5)),
      ),
    );
  }
}
