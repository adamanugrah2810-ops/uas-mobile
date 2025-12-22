import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageWhiteBlueState();
}

class _ProfilePageWhiteBlueState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  // ========================= LUXURY PALETTE =========================
  final Color bgCanvas = const Color(0xFFF0F4F8);
  final Color primaryBlue = const Color(0xFF0052D4);
  final Color accentBlue = const Color(0xFF4364F7);
  final Color cardWhite = Colors.white;
  final Color textDark = const Color(0xFF1E293B);

  // ========================= USER DATA =========================
  String username = "";
  String email = "";
  bool isLoading = true;

  // ========================= ANIMATION =========================
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadUserFromDatabase();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  Future<void> _loadUserFromDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      username = prefs.getString("userName") ?? "User Not Found";
      email = prefs.getString("userEmail") ?? "email@database.com";
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // ========================= ACTION FUNCTIONS =========================

  void _showProfileInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Informasi Pribadi"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nama: $username",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Email: $email"),
            const SizedBox(height: 8),
            const Text("Status: Elite Member"),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"))
        ],
      ),
    );
  }

  void _showSecuritySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("Keamanan Akun",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textDark)),
            const SizedBox(height: 20),
            ListTile(
              leading:
                  const Icon(Icons.lock_reset_rounded, color: Colors.indigo),
              title: const Text("Ubah Kata Sandi"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.phonelink_lock_rounded,
                  color: Colors.indigo),
              title: const Text("Autentikasi Dua Faktor"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Menghubungkan ke Pusat Bantuan..."),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ========================= UI COMPONENTS =========================

  Widget _luxHeader() {
    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          decoration: BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                          LinearGradient(colors: [primaryBlue, accentBlue]),
                    ),
                  ),
                  Container(
                    width: 130,
                    height: 130,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: CircleAvatar(
                        backgroundColor: bgCanvas,
                        child: Icon(Icons.person_rounded,
                            size: 80, color: primaryBlue),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 15),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 25),
              Text(username,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: textDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 5),
              Text(email,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: primaryBlue.withOpacity(0.2)),
                ),
                child: Text("ELITE MEMBER",
                    style: TextStyle(
                        color: primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _luxMenu(
      String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15)),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Text(title,
                        style: TextStyle(
                            color: textDark,
                            fontSize: 17,
                            fontWeight: FontWeight.bold))),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCanvas,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("P R O F I L E",
            style: TextStyle(
                color: textDark,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2)),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue)))
          : Stack(
              children: [
                Positioned(
                    top: -100,
                    right: -100,
                    child: CircleAvatar(
                        radius: 150,
                        backgroundColor: primaryBlue.withOpacity(0.05))),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 120, 20, 40),
                  child: Column(
                    children: [
                      _luxHeader(),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Pengaturan Akun",
                              style: TextStyle(
                                  color: textDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900)),
                          Text("Lihat Semua",
                              style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // IMPLEMENTASI MENU FUNGSIONAL
                      _luxMenu(
                          "Informasi Pribadi",
                          Icons.person_outline_rounded,
                          primaryBlue,
                          _showProfileInfo),
                      _luxMenu("Keamanan Akun", Icons.shield_moon_outlined,
                          Colors.indigo, _showSecuritySheet),
                      _luxMenu("Notifikasi", Icons.notifications_none_rounded,
                          Colors.orange, () {}),
                      _luxMenu("Pusat Bantuan", Icons.help_outline_rounded,
                          Colors.teal, _contactSupport),

                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: _logout,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.red.shade400,
                              Colors.red.shade700
                            ]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8))
                            ],
                          ),
                          child: const Center(
                              child: Text("LOGOUT ACCOUNT",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1))),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
