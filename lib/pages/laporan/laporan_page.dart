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
  // Executive White-Blue Palette
  final Color _bgLight = const Color(0xFFF4F7FE);
  final Color _primaryBlue = const Color(0xFF1E40AF);
  final Color _accentBlue = const Color(0xFF3B82F6);
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
        color: _primaryBlue,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. HEADER YANG HILANG SAAT SCROLL
            _buildSliverHeader(),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 2. STATS BENTO GRID (DIBUNGKUS SIZEDBOX UNTUK TINGGI)
                  _buildSectionLabel("Ringkasan Aktivitas"),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180, // Penentu tinggi agar tidak error
                    child: _buildBentoStats(),
                  ),

                  const SizedBox(height: 32),

                  // 3. INSIGHT CARD
                  _buildInsightCard(),

                  const SizedBox(height: 32),

                  // 4. FEATURED CARD
                  if (_reports.isNotEmpty) ...[
                    _buildSectionLabel("Update Terakhir"),
                    const SizedBox(height: 16),
                    _buildFeaturedCard(_reports.first),
                    const SizedBox(height: 32),
                  ],

                  // 5. LAYANAN CEPAT
                  _buildSectionLabel("Layanan Cepat"),
                  const SizedBox(height: 16),
                  _buildQuickAccessGrid(),

                  const SizedBox(height: 32),

                  // 6. RIWAYAT LIST
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionLabel("Semua Laporan"),
                      Text(
                        "Total: $_total",
                        style: TextStyle(
                            color: _primaryBlue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildHistoryList(),
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
      expandedHeight: 180,
      collapsedHeight: 0,
      toolbarHeight: 0,
      pinned: false, // Membuatnya hilang saat di-scroll
      floating: false,
      backgroundColor: _primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_primaryBlue, _accentBlue],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("DASHBOARD EKSEKUTIF",
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text("Manajemen\nLaporan Anda",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.1)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBentoStats() {
    return Row(
      children: [
        // Kiri: Card Besar
        Expanded(
          flex: 2,
          child: _statTileLarge(
              "Aktif", _proses.toString(), Icons.bubble_chart_rounded),
        ),
        const SizedBox(width: 12),
        // Kanan: Stack Card Kecil
        Expanded(
          child: Column(
            children: [
              Expanded(
                  child: _statTileSmall(
                      "Selesai", _selesai.toString(), Colors.green)),
              const SizedBox(height: 12),
              Expanded(
                  child: _statTileSmall(
                      "Ditolak", _ditolak.toString(), Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statTileLarge(String label, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primaryBlue, size: 30),
          const Spacer(),
          Text(val,
              style: TextStyle(
                  color: _darkText, fontSize: 32, fontWeight: FontWeight.w900)),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statTileSmall(String label, String val, Color color) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(val,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    double progress = _total == 0 ? 0 : _selesai / _total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [_primaryBlue, _primaryBlue.withOpacity(0.8)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Efektivitas Laporan",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("$_selesai laporan berhasil diselesaikan",
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            width: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                    value: progress,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                    strokeWidth: 5),
                Text("${(progress * 100).toInt()}%",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
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
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statusBadge(report.status),
          const SizedBox(height: 16),
          Text(report.judul,
              style: TextStyle(
                  color: _darkText, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(report.kategori,
              style: TextStyle(color: _accentBlue, fontSize: 13)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LaporanDetailPage(pengaduan: report))),
            child: Row(
              children: [
                Text("Lihat rincian laporan",
                    style: TextStyle(
                        color: _primaryBlue, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded,
                    size: 16, color: _primaryBlue),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    final tools = [
      {'i': Icons.verified_user_rounded, 'l': 'Keamanan'},
      {'i': Icons.home_repair_service_rounded, 'l': 'Perbaikan'},
      {'i': Icons.eco_rounded, 'l': 'Lingkungan'},
      {'i': Icons.grid_view_rounded, 'l': 'Lainnya'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: tools
          .map((t) => Column(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18)),
                    child: Icon(t['i'] as IconData, color: _primaryBlue),
                  ),
                  const SizedBox(height: 8),
                  Text(t['l'] as String,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoading)
      return const Center(child: CircularProgressIndicator.adaptive());
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reports.length > 3 ? 3 : _reports.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = _reports[index];
        return Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: _bgLight,
                child: Icon(Icons.receipt_long_rounded,
                    color: _primaryBlue, size: 18)),
            title: Text(r.judul,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(r.status,
                style: TextStyle(color: _accentBlue, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => LaporanDetailPage(pengaduan: r))),
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text,
        style: TextStyle(
            color: _darkText, fontSize: 16, fontWeight: FontWeight.w900));
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: _primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(),
          style: TextStyle(
              color: _primaryBlue, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }
}
