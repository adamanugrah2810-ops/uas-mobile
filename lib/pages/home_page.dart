import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  // Palette Warna Biru Profesional (Clean & Modern)
  final Color _primaryBlue = const Color(0xFF0052D4);
  final Color _softBlue = const Color(0xFFE8F0FF);
  final Color _bgLight = const Color(0xFFF8FAFD);
  final Color _textDark = const Color(0xFF0F172A);
  final Color _textGrey = const Color(0xFF64748B);

  HomePage({super.key});

  // Fungsi untuk mengambil nama user yang tersimpan di sesi
  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    // Default "User" jika nama tidak ditemukan
    return prefs.getString("userName") ?? "User";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserName(),
      builder: (context, snapshot) {
        // Menggunakan nama dari database/sesi
        String name = snapshot.data ?? "Loading...";

        return Scaffold(
          backgroundColor: _bgLight,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                //============== HEADER ==============
                _buildSimpleHeader(name),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      //--- SECTION 1: RINGKASAN LAPORAN ---
                      _buildSectionTitle("Ringkasan Laporan", "Bulan ini"),
                      const SizedBox(height: 12),
                      _buildMainStatsCard(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _buildSmallMetricCard(
                                  "Diajukan", "45", "+12%", Colors.orange)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildSmallMetricCard(
                                  "Diproses", "120", "+5%", _primaryBlue)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStatusStrip(Icons.check_circle, "Selesai", "1,075",
                          "98% Resolved", Colors.green),

                      const SizedBox(height: 25),

                      //--- SECTION 2: TARGET WAKTU RESPONS ---
                      _buildSectionTitle("Target Waktu Respons", "2 Hari"),
                      const SizedBox(height: 12),
                      _buildTargetResponseCard(),

                      const SizedBox(height: 25),

                      //--- SECTION 3: DAFTAR LAPORAN MENDESAK ---
                      _buildSectionTitle(
                          "Daftar Laporan Mendesak", "Lihat Semua"),
                      const SizedBox(height: 12),
                      _buildUrgentItem("Jalan Rusak Parah", "Infrastruktur",
                          "Prioritas Tinggi", Colors.red),
                      _buildUrgentItem("Kekurangan Tenaga Medis", "Kesehatan",
                          "Prioritas Tinggi", Colors.red),

                      const SizedBox(height: 25),

                      //--- SECTION 4: STATISTIK BULANAN ---
                      _buildSectionTitle("Statistik Bulanan", "Volume masuk"),
                      const SizedBox(height: 12),
                      _buildBarChartCard(),

                      const SizedBox(height: 25),

                      //--- SECTION 5: KATEGORI LAPORAN ---
                      _buildSectionTitle(
                          "Kategori Laporan", "Distribusi jenis"),
                      const SizedBox(height: 12),
                      _buildKategoriCard(),

                      const SizedBox(height: 25),

                      //--- SECTION 6: ANALISIS INFO ---
                      _buildAnalisisInfoCard(),

                      // Spacer agar tidak tertutup BottomNavbar
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //---------------------------------------------------------------------
  // WIDGET HELPERS
  //---------------------------------------------------------------------

  Widget _buildSimpleHeader(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Halo, Selamat Datang",
              style: TextStyle(color: _textGrey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(name,
              style: TextStyle(
                  color: _textDark, fontWeight: FontWeight.bold, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                color: _textDark, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(subtitle,
            style: TextStyle(
                color: _primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMainStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [_primaryBlue, const Color(0xFF4364F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: _primaryBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Total Laporan Masuk",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("1,240",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold)),
              Icon(Icons.analytics_rounded,
                  color: Colors.white.withOpacity(0.3), size: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetricCard(
      String label, String val, String trend, Color col) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(val,
                  style: TextStyle(
                      color: _textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: col.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(trend,
                    style: TextStyle(
                        color: col, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: _textGrey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatusStrip(
      IconData icon, String label, String val, String status, Color col) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, color: col, size: 24),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: _textGrey, fontSize: 14)),
          const SizedBox(width: 8),
          Text(val,
              style: TextStyle(
                  color: _textDark, fontWeight: FontWeight.bold, fontSize: 15)),
          const Spacer(),
          Text(status,
              style: TextStyle(
                  color: col, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTargetResponseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("1.8 Hari (Rata-rata)",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Lebih cepat 5% dari bulan lalu",
                      style: TextStyle(color: Colors.green[600], fontSize: 12)),
                ],
              ),
              const Icon(Icons.bolt_rounded, color: Colors.amber, size: 32),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
                value: 0.85,
                minHeight: 10,
                backgroundColor: _softBlue,
                color: _primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentItem(String title, String cat, String prio, Color col) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: col.withOpacity(0.1))),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                  color: col, borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _textDark)),
                Text(cat, style: TextStyle(color: _textGrey, fontSize: 12))
              ])),
          Text(prio,
              style: TextStyle(
                  color: col, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(40, "Jan"),
          _bar(60, "Feb"),
          _bar(90, "Mar"),
          _bar(70, "Apr"),
          _bar(100, "Mei"),
          _bar(120, "Jun")
        ],
      ),
    );
  }

  Widget _bar(double h, String label) => Column(children: [
        Container(
            width: 16,
            height: h,
            decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 10),
        Text(label, style: TextStyle(fontSize: 11, color: _textGrey))
      ]);

  Widget _buildKategoriCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 10,
                  color: _primaryBlue,
                  backgroundColor: _softBlue)),
          const SizedBox(width: 30),
          Expanded(
              child: Column(children: [
            _legend("Infra", "45%", _primaryBlue),
            _legend("Kesehatan", "25%", Colors.pink),
            _legend("Sosial", "30%", Colors.orange)
          ]))
        ],
      ),
    );
  }

  Widget _legend(String l, String v, Color c) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        CircleAvatar(radius: 5, backgroundColor: c),
        const SizedBox(width: 10),
        Expanded(child: Text(l, style: const TextStyle(fontSize: 13))),
        Text(v,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))
      ]));

  Widget _buildAnalisisInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _primaryBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryBlue.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: _primaryBlue, size: 28),
          const SizedBox(width: 16),
          const Expanded(
              child: Text(
                  "Tips: Optimalkan penanganan pada kategori Infrastruktur untuk meningkatkan skor kepuasan publik.",
                  style: TextStyle(fontSize: 12, height: 1.5))),
        ],
      ),
    );
  }
}
