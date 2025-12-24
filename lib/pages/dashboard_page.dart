import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Wajib untuk efek Glassmorphism

// Pastikan file-file ini sudah Anda buat di folder project
import 'home_page.dart';
import 'profile_page.dart';
import 'laporan_page.dart';
import 'pengaduan_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Palette Warna Premium (Konsisten dengan Login & Home)
  final Color _primaryBlue = const Color(0xFF0052D4);
  final Color _royalAzure = const Color(0xFF4364F7);
  final Color _lightSky = const Color(0xFF6FB1FC);
  final Color _bgColor = const Color(0xFFF8FAFF);

  int _selectedIndex = 0;
  String userName = "Memuat...";
  String userEmail = "Memuat...";

  // List halaman utama sesuai urutan Bottom Nav
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi halaman
    _pages = [
      HomePage(),
      LaporanPage(),
      PengaduanPage(),
      const ProfilePage(),
    ];
    _loadUser();
  }

  // Mengambil data user dari session (Shared Preferences)
  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // Key harus sama dengan yang ada di AuthService
      userName = prefs.getString("userName") ?? "User";
      userEmail = prefs.getString("userEmail") ?? "Email tidak tersedia";
    });
  }

  // Fungsi Logout
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua sesi
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) =>
          false, // Hapus semua history navigasi agar tidak bisa "back" ke dashboard
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBody: true, // Membuat konten scrolling di belakang navbar floating
      appBar: _buildPremiumAppBar(context),
      drawer: _buildModernDrawer(),
      body: PageTransitionSwitcher(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  // --- APP BAR MINIMALIS ---
  PreferredSizeWidget _buildPremiumAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      centerTitle: true,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.notes_rounded, color: _primaryBlue, size: 28),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Column(
        children: [
          Text(
            "BANTEN CONNECT",
            style: TextStyle(
              color: _primaryBlue,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const Text(
            "Pelayanan Publik Digital",
            style: TextStyle(
                color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 15),
          child: IconButton(
            icon: Icon(Icons.notifications_none_rounded,
                color: _primaryBlue, size: 26),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  // --- FLOATING NAVBAR (GLASSMORPHISM) ---
  Widget _buildFloatingNavbar() {
    return Container(
      height: 75,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.grid_view_rounded, 0, "Home"),
                _navItem(Icons.assignment_outlined, 1, "Laporan"),
                _navItem(Icons.add_circle_rounded, 2, "Aduan", isSpecial: true),
                _navItem(Icons.person_outline_rounded, 3, "Profil"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label,
      {bool isSpecial = false}) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isSpecial ? 12 : 8),
            decoration: BoxDecoration(
              gradient: isSpecial
                  ? LinearGradient(colors: [_primaryBlue, _lightSky])
                  : null,
              color: isSelected && !isSpecial
                  ? _primaryBlue.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSpecial
                  ? Colors.white
                  : (isSelected ? _primaryBlue : Colors.grey.shade400),
              size: isSpecial ? 28 : 24,
            ),
          ),
          if (!isSpecial && isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 5,
              height: 5,
              decoration:
                  BoxDecoration(color: _primaryBlue, shape: BoxShape.circle),
            )
        ],
      ),
    );
  }

  // --- DRAWER (SIDEBAR) MODERN ---
  Widget _buildModernDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          _drawerHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _drawerMenu(Icons.dashboard_outlined, "Dashboard", 0),
                _drawerMenu(Icons.history_rounded, "Riwayat Laporan", 1),
                _drawerMenu(Icons.info_outline_rounded, "Panduan Layanan", 2),
                _drawerMenu(
                    Icons.manage_accounts_outlined, "Pengaturan Akun", 3),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: Colors.black12),
                ),
                _buildLogoutAction(),
              ],
            ),
          ),
          const Text("Versi 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primaryBlue, _royalAzure]),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 35,
              backgroundImage: AssetImage('assets/images/logo_banten.jpg'),
            ),
          ),
          const SizedBox(height: 20),
          Text(userName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(userEmail,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _drawerMenu(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? _primaryBlue : Colors.grey[600]),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? _primaryBlue : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLogoutAction() {
    return ListTile(
      leading: const Icon(Icons.logout_rounded, color: Colors.red),
      title: const Text("Keluar Aplikasi",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      onTap: logout,
    );
  }
}

// Efek transisi antar halaman
class PageTransitionSwitcher extends StatelessWidget {
  final Widget child;
  const PageTransitionSwitcher({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0.01, 0), end: Offset.zero)
                    .animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
