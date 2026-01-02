import 'package:flutter/material.dart';
import 'package:mobile_auth/models/pengaduan.model.dart';
import 'package:mobile_auth/pages/laporan/laporan_detail_page.dart';
import 'package:mobile_auth/services/pengaduan.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  // Enhanced Executive Palette
  final Color _bgLight = const Color(0xFFF8FAFF);
  final Color _primaryBlue = const Color(0xFF0F172A); // Deep Navy
  final Color _accentBlue = const Color(0xFF3B82F6); // Royal Blue
  final Color _softBlue = const Color(0xFFEFF6FF); // Light Sky
  final Color _darkText = const Color(0xFF1E293B);

  bool _isLoading = true;
  List<Pengaduan> _reports = [];
  int _total = 0, _proses = 0, _selesai = 0, _ditolak = 0;

  @override
  void initState() {
    super.initState();
    _fetchPengaduan();
  }

  Future<void> _fetchPengaduan() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Sesi berakhir');

      final data = await PengaduanService.getPengaduanSaya(token: token);

      if (mounted) {
        setState(() {
          _reports = data;
          _total = data.length;
          _proses = data
              .where((r) => r.status == 'diajukan' || r.status == 'diproses')
              .length;
          _selesai = data.where((r) => r.status == 'selesai').length;
          _ditolak = data.where((r) => r.status == 'ditolak').length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: RefreshIndicator(
        onRefresh: _fetchPengaduan,
        color: _accentBlue,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 1. STATS BENTO GRID
                  _buildSectionLabel(
                      "Ringkasan Aktivitas", "Data terkini laporan Anda"),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 190,
                    child: _buildBentoStats(),
                  ),

                  const SizedBox(height: 32),

                  // 2. INSIGHT CARD (EFEKTIVITAS)
                  _buildInsightCard(),

                  const SizedBox(height: 32),

                  // 3. NEW: PENGUMUMAN / INFO SLIDER (KONTEN TAMBAHAN)
                  _buildSectionLabel(
                      "Informasi Penting", "Berita & prosedur terbaru"),
                  const SizedBox(height: 16),
                  _buildInfoCard(),

                  const SizedBox(height: 32),

                  // 4. FEATURED CARD
                  if (_reports.isNotEmpty) ...[
                    _buildSectionLabel(
                        "Update Terakhir", "Laporan yang baru saja diperbarui"),
                    const SizedBox(height: 16),
                    _buildFeaturedCard(_reports.first),
                    const SizedBox(height: 32),
                  ],

                  // 5. LAYANAN CEPAT
                  _buildSectionLabel(
                      "Layanan Cepat", "Akses instan kategori populer"),
                  const SizedBox(height: 16),
                  _buildQuickAccessGrid(),

                  const SizedBox(height: 32),

                  // 6. RIWAYAT LIST
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel(
                          "Semua Laporan", "Daftar riwayat lengkap"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: _accentBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "Total: $_total",
                          style: TextStyle(
                              color: _accentBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildHistoryList(),

                  const SizedBox(height: 32),

                  // 7. NEW: PANDUAN PENGGUNAAN (KONTEN TAMBAHAN)
                  _buildSectionLabel("Panduan", "Cara menggunakan aplikasi"),
                  const SizedBox(height: 16),
                  _buildGuideSection(),

                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 200,
      collapsedHeight: 0,
      toolbarHeight: 0,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryBlue, _accentBlue],
                ),
              ),
            ),
            // Decorative Circle 1
            Positioned(
              top: -50,
              right: -50,
              child: CircleAvatar(
                  radius: 100, backgroundColor: Colors.white.withOpacity(0.05)),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text("PRO VERSION",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    const Text("Manajemen\nLaporan Digital",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.1)),
                    const SizedBox(height: 8),
                    Text(
                        "Pantau pengaduan Anda dalam satu dasbor terintegrasi.",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoStats() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _statTileLarge(
              "Laporan Aktif", _proses.toString(), Icons.analytics_rounded),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children: [
              Expanded(
                  child: _statTileSmall(
                      "Selesai", _selesai.toString(), const Color(0xFF10B981))),
              const SizedBox(height: 12),
              Expanded(
                  child: _statTileSmall(
                      "Ditolak", _ditolak.toString(), const Color(0xFFEF4444))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statTileLarge(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: _primaryBlue.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: _softBlue,
            child: Icon(icon, color: _accentBlue, size: 20),
          ),
          const Spacer(),
          Text(val,
              style: TextStyle(
                  color: _darkText, fontSize: 38, fontWeight: FontWeight.w900)),
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }

  Widget _statTileSmall(String label, String val, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    double progress = _total == 0 ? 0 : _selesai / _total;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: [_accentBlue, const Color(0xFF2563EB)]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: _accentBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Tingkat Penyelesaian",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                    "Sistem telah memproses $_selesai laporan dengan status tuntas.",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            height: 65,
            width: 65,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                    value: progress,
                    color: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round),
                Text("${(progress * 100).toInt()}%",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _softBlue,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accentBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: _accentBlue, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Update Kebijakan",
                    style: TextStyle(
                        color: _primaryBlue, fontWeight: FontWeight.bold)),
                Text(
                    "Laporan di hari libur akan diproses pada jam kerja berikutnya.",
                    style: TextStyle(
                        color: _primaryBlue.withOpacity(0.6), fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Pengaduan report) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _accentBlue.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusBadge(report.status),
              Text("#${report.id.toString().padLeft(4, '0')}",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(report.judul,
              style: TextStyle(
                  color: _darkText, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.category_outlined, size: 14, color: _accentBlue),
              const SizedBox(width: 6),
              Text(report.kategori,
                  style: TextStyle(
                      color: _accentBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LaporanDetailPage(pengaduan: report))),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                  color: _primaryBlue, borderRadius: BorderRadius.circular(15)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Buka Detail Laporan",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: Colors.white),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final tools = [
      {'i': Icons.shield_outlined, 'l': 'Keamanan'},
      {'i': Icons.build_circle_outlined, 'l': 'Perbaikan'},
      {'i': Icons.wb_sunny_outlined, 'l': 'Lingkungan'},
      {'i': Icons.widgets_outlined, 'l': 'Lainnya'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tools
          .map((t) => Column(
                children: [
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ]),
                    child:
                        Icon(t['i'] as IconData, color: _accentBlue, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(t['l'] as String,
                      style: TextStyle(
                          fontSize: 11,
                          color: _darkText,
                          fontWeight: FontWeight.w700)),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator.adaptive(),
      ));
    }

    if (_reports.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: const Text("Belum ada riwayat laporan"),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reports.length > 5 ? 5 : _reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = _reports[index];
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.02))),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: _softBlue, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.description_outlined,
                    color: _accentBlue, size: 20)),
            title: Text(r.judul,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(r.status.toUpperCase(),
                style: TextStyle(
                    color: _accentBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LaporanDetailPage(pengaduan: r))),
          ),
        );
      },
    );
  }

  Widget _buildGuideSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _guideTile(Icons.add_circle_outline, "Buat Laporan",
              "Isi formulir dengan detail kejadian"),
          const Divider(height: 24),
          _guideTile(Icons.timer_outlined, "Pantau Status",
              "Cek progres secara real-time di sini"),
        ],
      ),
    );
  }

  Widget _guideTile(IconData icon, String title, String desc) {
    return Row(
      children: [
        Icon(icon, color: _accentBlue, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(desc,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        )
      ],
    );
  }

  Widget _buildSectionLabel(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: _darkText, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(subtitle,
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'selesai':
        color = const Color(0xFF10B981);
        break;
      case 'ditolak':
        color = const Color(0xFFEF4444);
        break;
      default:
        color = _accentBlue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1)),
    );
  }
}
