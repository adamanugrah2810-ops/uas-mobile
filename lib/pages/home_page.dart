import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  final Color _primaryColor = const Color(0xFF0077B6);
  final Color _deepBlue = const Color(0xFF023E8A);
  final Color _darkBackgroundColor = const Color(0xFF0A192F);
  final Color _cardColor = const Color(0xFF1F304E);
  final Color _accentColor = const Color(0xFFFFC300);
  final Color _textColor = Colors.white;

  HomePage({super.key});

  //============= WIDGET CARD STATISTIK =============
  Widget _buildStatCard(
      String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border(top: BorderSide(color: iconColor, width: 3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                  color: _textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  //============= WIDGET MENU CARD =============
  Widget _featureCard(IconData icon, String title, String subtitle, Color color,
      BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Anda memilih: $title"),
            backgroundColor: _accentColor));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                    color: _textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //============= UI UTAMA =============
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: _darkBackgroundColor,
            body: Center(child: CircularProgressIndicator(color: _accentColor)),
          );
        }

        String userName =
            snapshot.data!.getString("userName") ?? "Adam Anugrah";

        return Scaffold(
          backgroundColor: _darkBackgroundColor,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //============== HEADER ==============
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [_deepBlue, _primaryColor],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Selamat Datang 👋",
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 18)),
                              const SizedBox(height: 8),
                              Text(
                                userName,
                                style: TextStyle(
                                    color: _accentColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Kelola & pantau pengaduan masyarakat dengan mudah.",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              )
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        //============== STATISTIK ==============
                        Text("Statistik Pengaduan",
                            style: TextStyle(
                                color: _textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),

                        LayoutBuilder(builder: (context, constraints) {
                          int columns = constraints.maxWidth > 500 ? 4 : 2;

                          return SizedBox(
                            width: double.infinity,
                            child: GridView.count(
                              crossAxisCount: columns,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 18,
                              mainAxisSpacing: 18,
                              childAspectRatio: 1.1,
                              children: [
                                _buildStatCard("Total", "124", Icons.analytics,
                                    _primaryColor),
                                _buildStatCard("Diproses", "14",
                                    Icons.hourglass_top, _accentColor),
                                _buildStatCard("Selesai", "110",
                                    Icons.check_circle, Colors.greenAccent),
                                _buildStatCard("Ditolak", "5", Icons.cancel,
                                    Colors.redAccent.shade200),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 30),

                        //============== MENU UTAMA ==============
                        Text("Menu Utama",
                            style: TextStyle(
                                color: _textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),

                        SizedBox(
                          width: double.infinity,
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.1,
                            children: [
                              _featureCard(
                                  Icons.campaign,
                                  "Buat Pengaduan",
                                  "Laporkan masalah anda",
                                  Colors.orange,
                                  context),
                              _featureCard(
                                  Icons.history,
                                  "Riwayat",
                                  "Pantau status laporan",
                                  _primaryColor,
                                  context),
                              _featureCard(
                                  Icons.person,
                                  "Profil",
                                  "Kelola data anda",
                                  Colors.greenAccent,
                                  context),
                              _featureCard(Icons.settings, "Pengaturan",
                                  "Sesuaikan aplikasi", Colors.grey, context),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Center(
                          child: Text("Versi Aplikasi 1.0.0",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
