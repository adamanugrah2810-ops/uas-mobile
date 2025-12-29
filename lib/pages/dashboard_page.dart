import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

// Import halaman-halaman Anda
import 'home_page.dart';
import 'profile_page.dart';
import 'laporan/laporan_page.dart';
import 'pengaduan_page.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Ultra-Premium Palette
  final Color _primaryBlue = const Color(0xFF0052D4);
  final Color _royalAzure = const Color(0xFF4364F7);
  final Color _lightSky = const Color(0xFF6FB1FC);
  final Color _bgColor = const Color(0xFFF8FAFF);

  int _selectedIndex = 0;
  String userName = "Memuat...";
  String userEmail = "Memuat...";

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      const LaporanPage(),
      const PengaduanPage(),
      const ProfilePage(),
    ];
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("userName") ?? "User";
      userEmail = prefs.getString("userEmail") ?? "Email tidak tersedia";
    });
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBody: true, // PENTING: Agar konten meluncur di belakang navbar
      appBar: _buildPremiumAppBar(context),
      drawer: _buildModernDrawer(),
      body: PageTransitionSwitcher(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  // --- FLOATING NAVBAR ULTRA LUXURY ---
  Widget _buildFloatingNavbar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Background Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryBlue.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(Icons.grid_view_rounded, 0, "Beranda"),
                    _navItem(Icons.assignment_rounded, 1, "Laporan"),
                    const SizedBox(
                        width: 50), // Ruang kosong untuk tombol tengah
                    _navItem(Icons.notifications_rounded, 2, "Notif"),
                    _navItem(Icons.person_rounded, 3, "Profil"),
                  ],
                ),
              ),
            ),
          ),
          // Tombol Tengah Melayang (Aduan)
          Positioned(
            top: 0,
            child: _buildCenterAduanButton(),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index, String label) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? _primaryBlue.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? _primaryBlue : Colors.grey.shade400,
              size: 26,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 4,
                width: 4,
                decoration:
                    BoxDecoration(color: _primaryBlue, shape: BoxShape.circle),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAduanButton() {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 2), // Index PengaduanPage
      child: Container(
        height: 58,
        width: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryBlue, _royalAzure, _lightSky],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: _primaryBlue.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 35),
      ),
    );
  }

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
        IconButton(
          padding: const EdgeInsets.only(right: 15),
          icon: Icon(Icons.notifications_none_rounded,
              color: _primaryBlue, size: 26),
          onPressed: () {},
        ),
      ],
    );
  }

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
                Tween<Offset>(begin: const Offset(0.02, 0), end: Offset.zero)
                    .animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
