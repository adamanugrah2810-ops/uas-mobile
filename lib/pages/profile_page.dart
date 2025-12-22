import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageUltraLuxState();
}

class _ProfilePageUltraLuxState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  // ========================= COLOR PALETTE =========================
  final Color bgColor = const Color(0xFF0C192C);
  final Color darkBlack = const Color(0xFF000000);
  final Color primaryBlue = const Color(0xFF0B466C);
  final Color gold = const Color(0xFFFFD700);
  final Color cardColor = const Color(0xFF1B2A41);
  final Color textWhite = Colors.white;

  // ========================= USER DATA =========================
  String username = "";
  String email = "";
  bool isLoading = true;

  // ========================= ANIMATION =========================
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadUserFromDatabase();
  }

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();
  }

  // ========================= LOAD USER =========================
  Future<void> _loadUserFromDatabase() async {
    final prefs = await SharedPreferences.getInstance();

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      username = prefs.getString("userName") ?? "User";
      email = prefs.getString("userEmail") ?? "-";
      isLoading = false;
    });
  }

  // ========================= LOGOUT =========================
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  // ========================= HEADER =========================
  Widget _luxHeader() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                darkBlack.withOpacity(0.95),
                primaryBlue.withOpacity(0.95),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: gold.withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            children: [
              // ================= AVATAR =================
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: gold, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.8),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: cardColor,
                  child: Icon(
                    Icons.person_pin,
                    size: 85,
                    color: gold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ================= NAME =================
              Text(
                username,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textWhite,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),

              const SizedBox(height: 6),

              // ================= EMAIL =================
              Text(
                email,
                style: TextStyle(
                  color: textWhite.withOpacity(0.6),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 15),

              // ================= BADGE =================
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gold, Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "ULTRA PREMIUM MEMBER",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================= MENU TILE =========================
  Widget _luxMenu(String title, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            cardColor,
            cardColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title diklik")),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: textWhite.withOpacity(0.5),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ========================= BUILD =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),

                  _luxHeader(),

                  const SizedBox(height: 45),

                  Text(
                    "Account Settings",
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 15),

                  _luxMenu("Edit Profile", Icons.edit, primaryBlue),
                  _luxMenu("Change Password", Icons.lock, Colors.redAccent),
                  _luxMenu(
                      "Security & Privacy", Icons.security, Colors.greenAccent),
                  _luxMenu("About Application", Icons.info, gold),

                  const SizedBox(height: 35),

                  // ================= LOGOUT =================
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("LOG OUT"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 12,
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
