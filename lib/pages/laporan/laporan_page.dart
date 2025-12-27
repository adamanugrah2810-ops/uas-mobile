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
  // Palette Warna Premium
  final Color _primaryBlue = const Color(0xFF0052D4);
  final Color _royalAzure = const Color(0xFF4364F7);
  final Color _bgLight = const Color(0xFFF8FAFF);
  final Color _textDark = const Color(0xFF1E293B);
  final Color _textGrey = const Color(0xFF64748B);

  bool _isLoading = true;
  String? _error;
  List<Pengaduan> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetchPengaduan();
  }

  Future<void> _fetchPengaduan() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final data = await PengaduanService.getPengaduanSaya(token: token);

      setState(() {
        _reports = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double _progress(String status) {
    switch (status) {
      case 'diajukan':
        return 0.25;
      case 'diproses':
        return 0.6;
      case 'selesai':
        return 1.0;
      case 'ditolak':
        return 0.0;
      default:
        return 0.0;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'diajukan':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPremiumReportList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_reports.isEmpty) {
      return const Center(
        child: Text("Belum ada pengaduan"),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final report = _reports[index];
        final color = _statusColor(report.status);
        final progress = _progress(report.status);

        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LaporanDetailPage(pengaduan: report),
              ),
            );

            if (result == true) {
              _fetchPengaduan(); // refresh setelah delete
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.judul,
                    style: TextStyle(
                      color: _textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${report.kategori} • ${report.createdAt}",
                    style: TextStyle(color: _textGrey, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        report.status.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: _bgLight,
                    color: color,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Data Mock yang lebih banyak

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      // floatingActionButton: _buildFab(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 25),
                  _buildStatCards(),
                  const SizedBox(height: 30),
                  _buildQuickCategories(),
                  const SizedBox(height: 30),
                  _buildSearchAndFilter(),
                  const SizedBox(height: 30),
                  _buildProTipCard(),
                  const SizedBox(height: 30),
                  _buildSectionHeader("Daftar Progres"),
                  const SizedBox(height: 15),
                  _buildPremiumReportList(),
                  const SizedBox(height: 30),
                  _buildSummaryFooter(),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW: FLOATING ACTION BUTTON ---
  Widget _buildFab() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_primaryBlue, _royalAzure]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: _primaryBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text("Buat Laporan",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: _primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text("PUSAT KENDALI",
                    style: TextStyle(
                        color: _primaryBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 1.5)),
              ),
              const Icon(Icons.notifications_active_outlined,
                  color: Colors.black54),
            ],
          ),
          const SizedBox(height: 15),
          Text("Laporan & Aduan",
              style: TextStyle(
                  color: _textDark, fontSize: 32, fontWeight: FontWeight.w900)),
          Text("Pantau semua status pengajuan Anda",
              style: TextStyle(color: _textGrey, fontSize: 14)),
        ],
      ),
    );
  }

  // --- STAT CARDS ---
  Widget _buildStatCards() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _statItem(
              "Aktif", "05", Icons.bolt_rounded, [_primaryBlue, _royalAzure]),
          const SizedBox(width: 15),
          _statItem("Selesai", "128", Icons.task_alt_rounded,
              [const Color(0xFF11998E), const Color(0xFF38EF7D)]),
          const SizedBox(width: 15),
          _statItem("Ditolak", "02", Icons.cancel_outlined,
              [const Color(0xFFFF416C), const Color(0xFFFF4B2B)]),
        ],
      ),
    );
  }

  Widget _statItem(
      String label, String value, IconData icon, List<Color> colors) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              color: colors[0].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(height: 20),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  // --- NEW: QUICK CATEGORIES ---
  Widget _buildQuickCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Kategori Populer",
            style: TextStyle(
                color: _textDark, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _quickCatItem(Icons.apartment_rounded, "Bangunan", Colors.blue),
            _quickCatItem(Icons.bolt_rounded, "Listrik", Colors.amber),
            _quickCatItem(Icons.water_drop_rounded, "Air Bersih", Colors.cyan),
            _quickCatItem(Icons.shield_rounded, "Keamanan", Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _quickCatItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                color: _textDark, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // --- SEARCH & FILTER ---
  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
              ]),
          child: const TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search_rounded, color: Color(0xFF0052D4)),
              hintText: "Cari ID Laporan atau judul...",
              border: InputBorder.none,
              hintStyle: TextStyle(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _filterChip("Semua", true),
            _filterChip("Dalam Proses", false),
            _filterChip("Selesai", false),
          ],
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? _primaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isActive ? _primaryBlue : Colors.black12),
      ),
      child: Text(label,
          style: TextStyle(
              color: isActive ? Colors.white : _textGrey,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }

  // --- PRO TIP ---
  Widget _buildProTipCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.amber.withOpacity(0.2))),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tahukah Anda?",
                    style: TextStyle(
                        color: _textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(
                    "Laporan dengan koordinat GPS akurat diproses 2x lebih cepat oleh tim lapangan.",
                    style: TextStyle(color: _textGrey, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTION HEADER ---
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
                color: _textDark, fontSize: 20, fontWeight: FontWeight.w900)),
        Text("Sortir v",
            style: TextStyle(
                color: _primaryBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  // --- NEW: SUMMARY FOOTER ---
  Widget _buildSummaryFooter() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.verified_user_rounded,
              color: Colors.black12, size: 40),
          const SizedBox(height: 10),
          Text("Semua data terenkripsi dan aman",
              style:
                  TextStyle(color: _textGrey.withOpacity(0.5), fontSize: 11)),
          const SizedBox(height: 5),
          Text("Banten Connect v2.4.0",
              style:
                  TextStyle(color: _textGrey.withOpacity(0.3), fontSize: 10)),
        ],
      ),
    );
  }
}
