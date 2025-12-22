import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Wajib ada untuk efek blur (BackdropFilter)

// Pastikan file-file ini ada di project Anda
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
  // Palette Warna Premium
  final Color _primaryBlue = const Color(0xFF0052D4);
  final Color _royalAzure = const Color(0xFF4364F7);
  final Color _lightSky = const Color(0xFF6FB1FC);
  final Color _bgColor = const Color(0xFFF8FAFF);

  int _selectedIndex = 0;
  String userName = "Memuat...";
  String userEmail = "Memuat...";

  // List halaman utama
  final List<Widget> _pages = [
    HomePage(),
    LaporanPage(),
    PengaduanPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("userName") ?? "Adam Anugrah";
      userEmail = prefs.getString("userEmail") ?? "adamanugrah1012@gmail.com";
    });
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      extendBody: true, // Membuat konten mengalir di belakang navbar
      appBar: _buildPremiumAppBar(context),
      drawer: _buildModernDrawer(),
      body: PageTransitionSwitcher(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  // --- APP BAR MINIMALIS & MEWAH ---
  PreferredSizeWidget _buildPremiumAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          // Menggunakan icon notes agar tidak error merah
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
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.notifications_none_rounded,
                color: _primaryBlue, size: 24),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
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
              boxShadow: isSpecial
                  ? [
                      BoxShadow(
                          color: _primaryBlue.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ]
                  : [],
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
      elevation: 0,
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
                  child: Divider(color: Colors.black12, thickness: 1),
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
        gradient: LinearGradient(
          colors: [_primaryBlue, _royalAzure],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(
              radius: 38,
              backgroundColor: Color(0xFFE2E8F0),
              backgroundImage: AssetImage('assets/images/logo_banten.jpg'),
            ),
          ),
          const SizedBox(height: 20),
          Text(userName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(userEmail,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.8), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _drawerMenu(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isSelected ? _primaryBlue.withOpacity(0.08) : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isSelected ? _primaryBlue : Colors.grey[600], size: 22),
        title: Text(title,
            style: TextStyle(
                color: isSelected ? _primaryBlue : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14)),
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildLogoutAction() {
    return InkWell(
      onTap: logout,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 22),
            SizedBox(width: 15),
            Text("Keluar Aplikasi",
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// Widget untuk transisi halus antar halaman
class PageTransitionSwitcher extends StatelessWidget {
  final Widget child;
  const PageTransitionSwitcher({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutQuart,
      switchOutCurve: Curves.easeInQuart,
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
