import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final Color _primaryColor = const Color(0xFF0077B6);
  final Color _deepBlue = const Color(0xFF023E8A);
  final Color _darkBackground = const Color(0xFF0A192F);
  final Color _accentColor = const Color(0xFFFFC300);
  final Color _textColor = Colors.white;

  String title = "Home";
  Widget currentPage = HomePage();
  String userName = "Memuat...";
  String userEmail = "Memuat...";

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

  void navigateTo(Widget page, String newTitle) {
    setState(() {
      currentPage = page;
      title = newTitle;
    });
    Navigator.pop(context);
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        title: Text(
          "Layanan Pengaduan Masyarakat Banten",
          style: TextStyle(fontWeight: FontWeight.bold, color: _textColor),
        ),
        backgroundColor: _darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: _accentColor),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: currentPage,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: _darkBackground,
        child: SafeArea(
          child: Column(
            children: [
              _drawerHeader(),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _drawerItem(Icons.home_filled, "Home",
                          () => navigateTo(HomePage(), "Home"),
                          isSelected: title == "Home"),
                      _drawerItem(Icons.assignment_turned_in_rounded, "Laporan",
                          () => navigateTo(LaporanPage(), "Laporan"),
                          isSelected: title == "Laporan"),
                      _drawerItem(Icons.campaign_rounded, "Pengaduan",
                          () => navigateTo(PengaduanPage(), "Pengaduan"),
                          isSelected: title == "Pengaduan"),
                      _drawerItem(Icons.person_2_rounded, "Profile",
                          () => navigateTo(ProfilePage(), "Profile"),
                          isSelected: title == "Profile"),
                      const SizedBox(height: 20),
                      Divider(
                          color: Colors.white24,
                          thickness: 1,
                          indent: 16,
                          endIndent: 16),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _logoutButton(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerHeader() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _deepBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Avatar Glassmorphism style
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _accentColor, width: 3),
                gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.1), Colors.white12]),
                boxShadow: [
                  BoxShadow(
                    color: _accentColor.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo_banten.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.person, size: 60, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text("Pemerintah Provinsi Banten",
                style: TextStyle(
                    color: _accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(userName,
                style: TextStyle(
                    color: _textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(userEmail,
                style: TextStyle(color: Colors.white70, fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? _accentColor.withOpacity(0.25) : Colors.transparent,
        border: isSelected
            ? Border.all(color: _accentColor.withOpacity(0.8), width: 1)
            : null,
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? _accentColor : _textColor),
        title: Text(title,
            style: TextStyle(
                color: isSelected ? _accentColor : _textColor,
                fontWeight: FontWeight.w500)),
        onTap: onTap,
        hoverColor: _accentColor.withOpacity(0.1),
      ),
    );
  }

  Widget _logoutButton() {
    return ElevatedButton.icon(
      onPressed: logout,
      icon: Icon(Icons.logout, color: _darkBackground),
      label: Text("Logout",
          style:
              TextStyle(color: _darkBackground, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 10,
        shadowColor: _accentColor.withOpacity(0.6),
      ),
    );
  }
}
