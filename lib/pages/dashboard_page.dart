import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui'; // Diperlukan untuk efek blur (Glassmorphism)

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
  // Palette Warna Premium (Putih - Biru Royal)
  final Color _primaryBlue = const Color(0xFF0052D4);
  final Color _royalAzure = const Color(0xFF4364F7);
  final Color _lightSky = const Color(0xFF6FB1FC);
  final Color _bgColor = const Color(0xFFF8FAFF); // Putih salju kebiruan

  int _selectedIndex = 0;
  String userName = "Memuat...";
  String userEmail = "Memuat...";

  // List halaman
  final List<Widget> _pages = [
    HomePage(),
    LaporanPage(),
    PengaduanPage(),
    ProfilePage(),
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
      extendBody: true, // Membuat body meluas di bawah navbar melayang
      appBar: _buildPremiumAppBar(),
      drawer: _buildModernDrawer(),
      body: PageTransitionSwitcher(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  // --- APP BAR MEWAH ---
  PreferredSizeWidget _buildPremiumAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.align_left_rounded, color: _primaryBlue, size: 30),
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
              letterSpacing: 1.5,
            ),
          ),
          const Text(
            "Layanan Publik Digital",
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: _primaryBlue.withOpacity(0.1),
            child: Icon(Icons.notifications_none_rounded,
                color: _primaryBlue, size: 22),
          ),
        ),
      ],
    );
  }

  // --- FLOATING NAVBAR (GLASSMORPHISM) ---
  Widget _buildFloatingNavbar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
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
              size: isSpecial ? 30 : 26,
            ),
          ),
          if (!isSpecial) const SizedBox(height: 4),
          if (!isSpecial && isSelected)
            Container(
                width: 4,
                height: 4,
                decoration:
                    BoxDecoration(color: _primaryBlue, shape: BoxShape.circle))
        ],
      ),
    );
  }

  // --- DRAWER MODERN ---
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
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                _drawerMenu(Icons.dashboard_customize_outlined, "Dashboard", 0),
                _drawerMenu(Icons.history_edu_rounded, "Riwayat Laporan", 1),
                _drawerMenu(Icons.gpp_maybe_outlined, "Panduan Layanan", 2),
                _drawerMenu(Icons.settings_outlined, "Pengaturan Akun", 3),
                const Divider(height: 40, thickness: 1),
                _buildLogoutAction(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryBlue, _royalAzure],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: const CircleAvatar(
                radius: 35,
                backgroundImage: AssetImage('assets/images/logo_banten.jpg')),
          ),
          const SizedBox(height: 15),
          Text(userName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(userEmail,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _drawerMenu(IconData icon, String title, int index) {
    bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? _primaryBlue : Colors.grey),
      title: Text(title,
          style: TextStyle(
              color: isSelected ? _primaryBlue : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      selected: isSelected,
      selectedTileColor: _primaryBlue.withOpacity(0.05),
      onTap: () {
        setState(() => _selectedIndex = index);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLogoutAction() {
    return InkWell(
      onTap: logout,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Icon(Icons.power_settings_new_rounded, color: Colors.red),
            SizedBox(width: 15),
            Text("Keluar Aplikasi",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                    .animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
