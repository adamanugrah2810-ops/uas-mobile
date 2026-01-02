import 'package:flutter/material.dart';
import 'package:mobile_auth/models/pengaduan.model.dart';
import 'package:mobile_auth/services/pengaduan.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- PALETTE WARNA LUXURY BEYOND ---
  final Color _primaryBlue = const Color(0xFF0A58ED); // Deep Electric Blue
  final Color _royalAzure = const Color(0xFF2D79FF); // Soft Royal
  final Color _bgLight = const Color(0xFFF8FAFF); // Ultra Light Blue-White
  final Color _textDark = const Color(0xFF0F172A); // Navy Slate
  final Color _accentBlue = const Color(0xFF60A5FA); // Sky Accent

  bool _isLoading = true;
  String _userName = "User";
  List<Pengaduan> _recentData = [];

  // Variabel Statistik
  int _total = 0;
  int _diajukan = 0;
  int _proses = 0;
  int _selesai = 0;
  int _ditolak = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final name = prefs.getString('userName');

      if (token != null) {
        final List<Pengaduan> data =
            await PengaduanService.getPengaduanSaya(token: token);

        if (mounted) {
          setState(() {
            _userName = name ?? "Eksekutif";
            _recentData = data.take(3).toList();
            _total = data.length;
            _diajukan =
                data.where((r) => r.status.toLowerCase() == 'diajukan').length;
            _proses =
                data.where((r) => r.status.toLowerCase() == 'diproses').length;
            _selesai =
                data.where((r) => r.status.toLowerCase() == 'selesai').length;
            _ditolak =
                data.where((r) => r.status.toLowerCase() == 'ditolak').length;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      extendBodyBehindAppBar: true,
      floatingActionButton: _isLoading ? null : _buildFabCustom(),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              edgeOffset: 100,
              color: _primaryBlue,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildExecutiveHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          _buildSectionLabel("Analisis Data", "Statistik Live"),
                          const SizedBox(height: 18),
                          _buildBentoGrid(),
                          const SizedBox(height: 32),
                          _buildSectionLabel("Layanan Prioritas", "Kategori"),
                          const SizedBox(height: 14),
                          _buildCategoryTags(),
                          const SizedBox(height: 32),
                          _buildSectionLabel("Monitor Resolusi", "Target 100%"),
                          const SizedBox(height: 18),
                          _buildProgressInsight(),
                          const SizedBox(height: 32),
                          _buildSectionLabel("Aktivitas Terbaru", "Riwayat"),
                          const SizedBox(height: 18),
                          _buildRecentActivityList(),
                          const SizedBox(height: 32),
                          _buildSectionLabel(
                              "Volume Pelaporan", "Grafik 6 Bulan"),
                          const SizedBox(height: 18),
                          _buildPremiumChart(),
                          const SizedBox(height: 32),
                          _buildSystemHealthCard(),
                          const SizedBox(height: 32),
                          _buildInfoBanner(),
                          const SizedBox(height: 140),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  // --- WIDGET 1: FAB CUSTOM ---
  Widget _buildFabCustom() {
    return InkWell(
      onTap: () => debugPrint("Navigasi ke Form"),
      child: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryBlue, _royalAzure],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
                color: _primaryBlue.withOpacity(0.4),
                blurRadius: 25,
                offset: const Offset(0, 12))
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text("BUAT LAPORAN",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // --- WIDGET 2: EXECUTIVE HEADER (FIXED ICON) ---
  Widget _buildExecutiveHeader() {
    // Kita hapus SafeArea dari dalam Stack agar warna biru naik ke paling atas
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(45),
          bottomRight: Radius.circular(45),
        ),
        // Tambahkan shadow halus agar transisi ke konten bawah lebih mewah
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // Lingkaran dekoratif (Glassmorphism effect)
          Positioned(
            top: -60,
            right: -60,
            child: CircleAvatar(
                radius: 120, backgroundColor: Colors.white.withOpacity(0.05)),
          ),
          Positioned(
            top: 100,
            left: -30,
            child: CircleAvatar(
                radius: 50, backgroundColor: Colors.white.withOpacity(0.03)),
          ),

          // Gunakan Padding Top berdasarkan media query agar tidak tertutup notch/status bar
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top +
                  20, // Menyesuaikan tinggi status bar
              left: 25,
              right: 25,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("DASHBOARD EKSEKUTIF",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Text("Halo, $_userName",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    // Profile Icon dengan Border Glow
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white30, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person_rounded,
                            color: Colors.white, size: 30),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 35),
                _buildGlassStatCard(),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                        child: _heroButton(
                            icon: Icons.send_rounded,
                            label: "Lapor",
                            filled: true,
                            onTap: () {})),
                    const SizedBox(width: 15),
                    Expanded(
                        child: _heroButton(
                            icon: Icons.grid_view_rounded,
                            label: "Arsip",
                            filled: false,
                            onTap: () {})),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassStatCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _heroStat("DATABASE", _total),
              _heroStat("PROSES", _proses),
              _heroStat("DONE", _selesai),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET 3: BENTO GRID ---
  // --- PERBAIKAN WIDGET BENTO GRID ---
  // --- MODIFIKASI WARNA BARU ---
  final Color _royalPurple = const Color(0xFF6366F1); // Indigo/Purple
  final Color _warningOrange = const Color(0xFFF59E0B); // Amber
  final Color _deepBlue = const Color(0xFF1E40AF); // Deep Navy

  Widget _buildBentoGrid() {
    return SizedBox(
      height: 250, // Sedikit ditinggikan agar lebih mewah
      child: Row(
        children: [
          Expanded(
              flex: 1,
              // Mengganti Hijau dengan Indigo/Purple Gradient
              child: _bentoTile(
                  "Selesai",
                  _selesai.toString(),
                  Icons.auto_awesome_rounded,
                  _royalPurple,
                  true,
                  [const Color(0xFF818CF8), const Color(0xFF6366F1)])),
          const SizedBox(width: 16),
          Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                      child: _bentoTile(
                          "Proses",
                          _proses.toString(),
                          Icons.rocket_launch_rounded,
                          _primaryBlue,
                          false,
                          [const Color(0xFF60A5FA), const Color(0xFF2563EB)])),
                  const SizedBox(height: 16),
                  Expanded(
                      child: _bentoTile(
                          "Antrean",
                          _diajukan.toString(),
                          Icons.bolt_rounded,
                          _warningOrange,
                          false,
                          [const Color(0xFFFBBF24), const Color(0xFFF59E0B)])),
                ],
              ))
        ],
      ),
    );
  }

  Widget _bentoTile(String title, String val, IconData icon, Color color,
      bool isLarge, List<Color> gradientColors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.05), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12), // Padding dikurangi sedikit
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bagian Ikon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradientColors),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon,
                        color: Colors.white, size: isLarge ? 22 : 16),
                  ),

                  // Spacer agar teks terdorong ke bawah
                  const Spacer(),

                  // Bagian Teks
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          val,
                          style: TextStyle(
                            color: _textDark,
                            fontSize: isLarge ? 32 : 20, // Diperkecil lagi
                            fontWeight: FontWeight.w900,
                            height: 1.1, // Mengurangi spasi antar baris
                          ),
                        ),
                      ),
                      Text(
                        title.toUpperCase(),
                        maxLines: 1,
                        style: TextStyle(
                          color: _textDark.withOpacity(0.4),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET 4: PROGRESS INSIGHT ---
  Widget _buildProgressInsight() {
    double percent = _total == 0 ? 0 : (_selesai / _total);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_textDark, const Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
                color: _textDark.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 15))
          ]),
      child: Row(
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text("Resolution Rate",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                    "Optimasi sistem saat ini berjalan di angka ${(percent * 100).toInt()}% dari total laporan.",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        height: 1.5)),
              ])),
          const SizedBox(width: 20),
          _buildCircularIndicator(percent),
        ],
      ),
    );
  }

  Widget _buildCircularIndicator(double pct) {
    return SizedBox(
      height: 70,
      width: 70,
      child: Stack(alignment: Alignment.center, children: [
        CircularProgressIndicator(
            value: pct,
            strokeWidth: 8,
            strokeCap: StrokeCap.round,
            color: _accentBlue,
            backgroundColor: Colors.white10),
        Text("${(pct * 100).toInt()}%",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900)),
      ]),
    );
  }

  // --- WIDGET 5: SYSTEM HEALTH ---
  Widget _buildSystemHealthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _primaryBlue.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _statusIndicator(true),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("System Status",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Semua server berjalan optimal",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Colors.blueAccent),
        ],
      ),
    );
  }

  Widget _statusIndicator(bool active) {
    return Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
          color: active ? Colors.green : Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.green.withOpacity(0.4), blurRadius: 10)
          ]),
    );
  }

  // --- PEMBANTU LAINNYA ---
  Widget _heroStat(String label, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value.toString().padLeft(2, '0'),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1)),
      ],
    );
  }

  Widget _heroButton(
      {required IconData icon,
      required String label,
      required bool filled,
      required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: filled ? _primaryBlue : Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
          backgroundColor: filled ? Colors.white : Colors.transparent,
          foregroundColor: filled ? _primaryBlue : Colors.white,
          elevation: 0,
          side: filled ? null : const BorderSide(color: Colors.white38),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
    );
  }

  Widget _buildCategoryTags() {
    final categories = ["Infrastruktur", "Keamanan", "Kesehatan", "Sosial"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map((cat) => Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _primaryBlue.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10)
                      ]),
                  child: Text(cat,
                      style: TextStyle(
                          color: _textDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    if (_recentData.isEmpty) {
      return Center(
          child: Text("Tidak ada aktivitas",
              style: TextStyle(color: Colors.grey.shade400)));
    }
    return Column(
      children: _recentData
          .map((item) => Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.02), blurRadius: 15)
                    ]),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: _bgLight,
                          borderRadius: BorderRadius.circular(15)),
                      child:
                          Icon(Icons.file_present_rounded, color: _primaryBlue),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.judul,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                  fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(item.status.toUpperCase(),
                              style: TextStyle(
                                  color: _primaryBlue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Colors.grey.shade300)
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPremiumChart() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)
          ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _chartBar("Jan", 0.4),
          _chartBar("Feb", 0.7),
          _chartBar("Mar", 0.5),
          _chartBar("Apr", 0.9),
          _chartBar("Mei", 0.6),
          _chartBar("Jun", 1.0)
        ],
      ),
    );
  }

  Widget _chartBar(String label, double pct) {
    return Column(
      children: [
        Container(
          height: 120 * pct,
          width: 16,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_accentBlue, _primaryBlue]),
              borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 12),
        Text(label,
            style: const TextStyle(
                color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionLabel(String main, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(main,
            style: TextStyle(
                color: _textDark, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(sub,
            style: TextStyle(
                color: _primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [_primaryBlue.withOpacity(0.05), Colors.white]),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _primaryBlue.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: _primaryBlue),
          const SizedBox(width: 15),
          const Expanded(
              child: Text(
                  "Saran: Selesaikan laporan tertunda untuk meningkatkan skor indeks pelayanan.",
                  style: TextStyle(
                      fontSize: 13, color: Colors.black87, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(strokeWidth: 2, color: _primaryBlue),
            const SizedBox(height: 20),
            Text("MENYIAPKAN DATA...",
                style: TextStyle(
                    color: _primaryBlue,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    fontSize: 12))
          ],
        ),
      ),
    );
  }
}
