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
  // --- PALETTE WARNA ULTRA PREMIUM ---
  final Color _primaryBlue = const Color(0xFF0052D4);
  final Color _royalAzure = const Color(0xFF4364F7);
  final Color _bgLight = const Color(0xFFF4F7FE);
  final Color _textDark = const Color(0xFF1E293B);
  final Color _accentBlue = const Color(0xFF3B82F6);

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
            _recentData = data.take(3).toList(); // Ambil 3 data terbaru
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
      // TOMBOL AKSI CEPAT (FLOATING)
      floatingActionButton: _isLoading ? null : _buildFabCustom(),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: _primaryBlue,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildExecutiveHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 25),
                          _buildSectionLabel(
                              "Ringkasan Real-time", "Live Database"),
                          const SizedBox(height: 16),
                          _buildBentoGrid(),

                          const SizedBox(height: 30),
                          _buildSectionLabel("Distribusi Kategori", "Trending"),
                          const SizedBox(height: 12),
                          _buildCategoryTags(),

                          const SizedBox(height: 30),
                          _buildSectionLabel(
                              "Efisiensi Penyelesaian", "Target 100%"),
                          const SizedBox(height: 16),
                          _buildProgressInsight(),

                          const SizedBox(height: 30),
                          _buildSectionLabel("Aktivitas Terbaru", "History"),
                          const SizedBox(height: 16),
                          _buildRecentActivityList(),

                          const SizedBox(height: 30),
                          _buildSectionLabel(
                              "Volume Laporan", "6 Bulan Terakhir"),
                          const SizedBox(height: 16),
                          _buildPremiumChart(),

                          const SizedBox(height: 30),
                          _buildInfoBanner(),
                          const SizedBox(height: 120), // Space for FAB
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  // --- WIDGET BARU: FAB CUSTOM ---
  Widget _buildFabCustom() {
    return GestureDetector(
      onTap: () => print("Navigasi ke Form Tambah Laporan"),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_primaryBlue, _royalAzure]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: _primaryBlue.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text("Buat Laporan",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BARU: CATEGORY TAGS ---
  Widget _buildCategoryTags() {
    final categories = ["Infrastruktur", "Keamanan", "Kesehatan", "Sosial"];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories
          .map((cat) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _primaryBlue.withOpacity(0.1)),
                ),
                child: Text(cat,
                    style: TextStyle(
                        color: _textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ))
          .toList(),
    );
  }

  // --- WIDGET BARU: RECENT ACTIVITY ---
  Widget _buildRecentActivityList() {
    if (_recentData.isEmpty) {
      return const Text("Belum ada laporan terbaru",
          style: TextStyle(color: Colors.grey));
    }
    return Column(
      children: _recentData
          .map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          color: _bgLight,
                          borderRadius: BorderRadius.circular(12)),
                      child:
                          Icon(Icons.description_outlined, color: _primaryBlue),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.judul,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(item.status,
                              style: TextStyle(
                                  color: _primaryBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // --- WIDGET EXISTIN YANG DIOPTIMALKAN ---
  Widget _buildLoadingState() => Center(
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primaryBlue)));

  Widget _buildExecutiveHeader() {
    return Stack(
      children: [
        Container(
          height: 230,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [_primaryBlue, _royalAzure],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius:
                const BorderRadius.only(bottomRight: Radius.circular(60)),
          ),
        ),
        Positioned(
            top: -40,
            right: -40,
            child: CircleAvatar(
                radius: 80, backgroundColor: Colors.white.withOpacity(0.05))),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("SELAMAT DATANG,",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 2,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(_userName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white12,
                        child: Icon(Icons.person_outline_rounded,
                            color: Colors.white))
                  ],
                ),
                const SizedBox(height: 35),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      color: Colors.white.withOpacity(0.1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.storage_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 10),
                          Text("Total $_total Laporan Terdaftar",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildBentoGrid() {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: _bentoTile("Selesai", _selesai.toString(),
                  Icons.verified_rounded, Colors.green, true)),
          const SizedBox(width: 12),
          Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                      child: _bentoTile("Proses", _proses.toString(),
                          Icons.bolt_rounded, _primaryBlue, false)),
                  const SizedBox(height: 12),
                  Expanded(
                      child: _bentoTile("Baru", _diajukan.toString(),
                          Icons.whatshot_rounded, Colors.orange, false)),
                ],
              ))
        ],
      ),
    );
  }

  Widget _bentoTile(
      String title, String val, IconData icon, Color color, bool isLarge) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: isLarge ? 28 : 20),
          const Spacer(),
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(val,
                  style: TextStyle(
                      color: _textDark,
                      fontSize: isLarge ? 32 : 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1))),
          Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProgressInsight() {
    double percent = _total == 0 ? 0 : (_selesai / _total);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_primaryBlue, _royalAzure]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
                color: _primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ]),
      child: Row(
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text("Tingkat Resolusi",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 6),
                Text("$_selesai dari $_total laporan selesai.",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ])),
          SizedBox(
              height: 50,
              width: 50,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 5,
                    color: Colors.white,
                    backgroundColor: Colors.white24),
                FittedBox(
                    child: Text("${(percent * 100).toInt()}%",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold))),
              ]))
        ],
      ),
    );
  }

  Widget _buildPremiumChart() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
        AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.elasticOut,
          height: 100 * pct,
          width: 14,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_accentBlue, _primaryBlue]),
              borderRadius: BorderRadius.circular(20)),
        ),
        const SizedBox(height: 8),
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
                color: _textDark, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(sub,
            style: TextStyle(
                color: _primaryBlue,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _primaryBlue.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(Icons.insights_rounded, color: _primaryBlue, size: 24),
          const SizedBox(width: 15),
          const Expanded(
              child: Text(
                  "Analisis: Tren laporan meningkat 12% pada sektor fasilitas umum.",
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey, height: 1.4))),
        ],
      ),
    );
  }
}
