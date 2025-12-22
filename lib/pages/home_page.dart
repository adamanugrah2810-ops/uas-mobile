import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  // Palette Warna Biru Profesional (Clean & Modern)
  final Color _primaryBlue = const Color(0xFF246BFE);
  final Color _softBlue = const Color(0xFFE8F0FF);
  final Color _bgLight = const Color(0xFFF8FAFC);
  final Color _textDark = const Color(0xFF1E293B);
  final Color _textGrey = const Color(0xFF64748B);

  HomePage({super.key});

  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userName") ??
        prefs.getString("name") ??
        "Admin Banten";
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserName(),
      builder: (context, snapshot) {
        String name = snapshot.data ?? "Admin Banten";

        return Scaffold(
          backgroundColor: _bgLight,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                //============== HEADER ==============
                _buildHeader(name),

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

                      //--- SECTION 6: WAKTU RESPONS (Wave Chart) ---
                      _buildSectionTitle(
                          "Waktu Respons", "-5% dari minggu lalu"),
                      const SizedBox(height: 12),
                      _buildWaveChartCard(),

                      const SizedBox(height: 25),

                      //--- TAMBAHAN BARU: SECTION 7: PROGRES RESOLUSI (Hijau) ---
                      _buildSectionTitle(
                          "Progres Resolusi Bulanan", "Tren volume"),
                      const SizedBox(height: 12),
                      _buildResolutionProgressBarChart(),

                      const SizedBox(height: 25),

                      //--- TAMBAHAN BARU: SECTION 8: ANALISIS CARD ---
                      _buildAnalisisInfoCard(),

                      const SizedBox(
                          height: 100), // Spacer agar tidak tertutup navbar
                    ],
                  ),
                ),
              ],
            ),
          ),
          //============== NAVBAR BAWAH (Melayang & Modern) ==============
          bottomNavigationBar: _buildBottomNavbar(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: _primaryBlue,
            elevation: 4,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  //---------------------------------------------------------------------
  // WIDGET HELPERS (KOMPONEN UI)
  //---------------------------------------------------------------------

  Widget _buildHeader(String name) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFE2E8F0),
              child: Icon(Icons.person, color: Color(0xFF64748B))),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Selamat Datang,",
                  style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              Text(name,
                  style: TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.notifications_none_rounded,
              color: Colors.black, size: 28),
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
        Text(subtitle, style: TextStyle(color: _textGrey, fontSize: 11)),
      ],
    );
  }

  Widget _buildMainStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _primaryBlue,
        borderRadius: BorderRadius.circular(20),
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
          const Text("Total Laporan",
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("1,240",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              Icon(Icons.folder_shared_rounded,
                  color: Colors.white.withOpacity(0.3), size: 45),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetricCard(
      String label, String val, String trend, Color col) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(val,
                  style: TextStyle(
                      color: _textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(trend,
                  style: TextStyle(
                      color: col, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(label, style: TextStyle(color: _textGrey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatusStrip(
      IconData icon, String label, String val, String status, Color col) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: col, size: 20),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: _textGrey, fontSize: 13)),
          const SizedBox(width: 8),
          Text(val,
              style: TextStyle(
                  color: _textDark, fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          Text(status,
              style: TextStyle(
                  color: col, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTargetResponseCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("1.8 Hari (Avg)",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Lebih cepat 5% dari bulan lalu",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              Icon(Icons.speed_rounded, color: _primaryBlue, size: 30),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
                value: 0.8,
                minHeight: 8,
                backgroundColor: _softBlue,
                color: _primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgentItem(String title, String cat, String prio, Color col) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: col.withOpacity(0.1))),
      child: Row(
        children: [
          Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                  color: col, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(cat, style: TextStyle(color: _textGrey, fontSize: 11))
              ])),
          Text(prio,
              style: TextStyle(
                  color: col, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
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
            width: 14,
            height: h,
            decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4))),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, color: _textGrey))
      ]);

  Widget _buildKategoriCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                  value: 0.7,
                  strokeWidth: 10,
                  color: Color(0xFF246BFE),
                  backgroundColor: Color(0xFFF1F5F9))),
          const SizedBox(width: 25),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        CircleAvatar(radius: 4, backgroundColor: c),
        const SizedBox(width: 8),
        Expanded(child: Text(l, style: const TextStyle(fontSize: 11))),
        Text(v,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))
      ]));

  Widget _buildWaveChartCard() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: CustomPaint(painter: WavePainter(_primaryBlue)),
    );
  }

  // --- WIDGET TAMBAHAN BARU (BAWAH) ---

  Widget _buildResolutionProgressBarChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _progressColumn(0.4, "Jan"),
          _progressColumn(0.6, "Feb"),
          _progressColumn(0.5, "Mar"),
          _progressColumn(0.8, "Apr"),
          _progressColumn(0.7, "Mei"),
          _progressColumn(0.9, "Jun"),
        ],
      ),
    );
  }

  Widget _progressColumn(double pct, String label) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
                width: 25,
                height: 120,
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6))),
            Container(
                width: 25,
                height: 120 * pct,
                decoration: BoxDecoration(
                    color: Colors.green[400],
                    borderRadius: BorderRadius.circular(6))),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, color: _textGrey)),
      ],
    );
  }

  Widget _buildAnalisisInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _softBlue.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primaryBlue.withOpacity(0.1))),
      child: Row(
        children: [
          Icon(Icons.analytics_outlined, color: _primaryBlue),
          const SizedBox(width: 12),
          const Expanded(
              child: Text(
                  "Analisis: Laporan jalan rusak di Mar-Mei meningkat. Penanganan rata-rata memakan waktu 1.8 hari.",
                  style: TextStyle(fontSize: 11, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildBottomNavbar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: Icon(Icons.grid_view_rounded, color: _primaryBlue),
                onPressed: () {}),
            IconButton(
                icon: Icon(Icons.assignment_outlined, color: _textGrey),
                onPressed: () {}),
            const SizedBox(width: 40),
            IconButton(
                icon: Icon(Icons.notifications_none_rounded, color: _textGrey),
                onPressed: () {}),
            IconButton(
                icon: Icon(Icons.person_outline_rounded, color: _textGrey),
                onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  WavePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.9,
        size.width * 0.5, size.height * 0.6);
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.3, size.width, size.height * 0.5);
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, paint);
    canvas.drawPath(path, strokePaint);
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.6), 5, Paint()..color = color);
    canvas.drawCircle(
        Offset(size.width, size.height * 0.5), 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
