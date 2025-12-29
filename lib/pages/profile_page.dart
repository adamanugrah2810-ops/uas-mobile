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
  // --- PALETTE WARNA AZURE LUXURY ---
  final Color primaryBlue = const Color(0xFF1E40AF);
  final Color lightBlue = const Color(0xFFDBEAFE);
  final Color accentCyan = const Color(0xFF0EA5E9);
  final Color pureWhite = Colors.white;
  final Color textMain = const Color(0xFF1E293B);

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

  // FUNGSI GANTI FOTO
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("profileImage", image.path);
      setState(() => profilePath = image.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil diperbarui!")),
      );
    }
  }

  // DIALOG EDIT DATA
  void _showEditDialog() {
    final nameController = TextEditingController(text: username);
    final phoneController = TextEditingController(text: phone);
    final bioController = TextEditingController(text: bio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Edit Profil",
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: "Nama Lengkap", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                    labelText: "Nomor Telepon", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(
                controller: bioController,
                decoration: const InputDecoration(
                    labelText: "Bio", border: OutlineInputBorder())),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString("userName", nameController.text);
                  await prefs.setString("userPhone", phoneController.text);
                  await prefs.setString("userBio", bioController.text);
                  _loadUserData();
                  Navigator.pop(context);
                },
                child: const Text("Simpan Perubahan",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryBlue))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildLuxuryHeader(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        _buildSectionHeader("DATA PERSONAL"),
                        _buildPremiumCard(),
                        const SizedBox(height: 30),
                        _buildSectionHeader("AKTIVITAS TERBARU"),
                        _buildRecentActivity(),
                        const SizedBox(height: 30),
                        _buildSectionHeader("AKSES CEPAT"),
                        _buildGridMenu(),
                        const SizedBox(height: 40),
                        _buildLogoutButton(),
                        const SizedBox(height: 30),
                        Text("BANTEN DIGITAL CONNECT v2.5",
                            style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[400],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2)),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildLuxuryHeader() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryBlue, accentCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
                top: -50, right: -50, child: _blurCircle(180, Colors.white10)),
            Positioned(
                bottom: 20, left: -30, child: _blurCircle(100, Colors.white12)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildAvatarFrame(),
                const SizedBox(height: 15),
                Text(username,
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                Text(email,
                    style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                        letterSpacing: 0.5)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFrame() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
              color: Colors.white30, shape: BoxShape.circle),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 55,
              backgroundColor: lightBlue,
              backgroundImage:
                  profilePath != null ? FileImage(File(profilePath!)) : null,
              child: profilePath == null
                  ? Icon(Icons.person_outline_rounded,
                      size: 50, color: primaryBlue)
                  : null,
            ),
          ),
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4))
                ]),
            child: Icon(Icons.camera_alt_rounded, size: 18, color: primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: primaryBlue.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          _infoTile(Icons.phone_iphone_rounded, "Telepon", phone),
          _divider(),
          _infoTile(Icons.info_outline_rounded, "Biografi", bio),
          _divider(),
          InkWell(
            onTap: _showEditDialog,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(28)),
            child: _infoTile(Icons.edit_note_rounded, "Pengaturan Akun",
                "Klik untuk edit data diri",
                isAction: true),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value,
      {bool isAction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: lightBlue.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold)),
                Text(value,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isAction ? primaryBlue : textMain)),
              ],
            ),
          ),
          if (isAction)
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: primaryBlue),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _activityItem("Laporan Dikirim", "Laporan infrastruktur jalan rusak",
              "2 jam yang lalu", Icons.description_rounded),
          const Divider(),
          _activityItem("Login Berhasil", "Masuk melalui perangkat baru",
              "Kemarin", Icons.security_rounded),
        ],
      ),
    );
  }

  Widget _activityItem(String title, String sub, String time, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
          backgroundColor: lightBlue,
          child: Icon(icon, color: primaryBlue, size: 20)),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing:
          Text(time, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
    );
  }

  Widget _buildGridMenu() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _gridItem("Layanan", Icons.apps_rounded, Colors.blue, () {}),
        _gridItem("Notifikasi", Icons.notifications_active_rounded,
            Colors.orange, () {}),
        _gridItem("Keamanan", Icons.admin_panel_settings_rounded, Colors.indigo,
            () {}),
        _gridItem("Bantuan", Icons.headset_mic_rounded, Colors.blueGrey, () {}),
      ],
    );
  }

  Widget _gridItem(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
            color: pureWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: lightBlue.withOpacity(0.5))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textMain)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        // Logika Logout Anda di sini
      },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
                colors: [Color(0xFFEF4444), Color(0xFFB91C1C)]),
            boxShadow: [
              BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8))
            ]),
        child: Center(
          child: Text("KELUAR SISTEM",
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
        ),
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }

  Widget _divider() =>
      Divider(height: 1, thickness: 1, color: lightBlue.withOpacity(0.3));

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, bottom: 15),
        child: Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: primaryBlue,
                letterSpacing: 1.5)),
      ),
    );
  }
}
