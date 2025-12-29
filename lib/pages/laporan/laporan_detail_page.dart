import 'package:flutter/material.dart';
import 'package:mobile_auth/models/pengaduan.model.dart';
import 'package:mobile_auth/services/pengaduan.service.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Import halaman edit di bagian paling atas file detail
import 'package:mobile_auth/pages/laporan/edit_pengaduan_page.dart';

class LaporanDetailPage extends StatelessWidget {
  final Pengaduan pengaduan;

  const LaporanDetailPage({super.key, required this.pengaduan});

  // Sapphire & Pearl Palette
  final Color _sapphireBlue = const Color(0xFF0056FF);
  final Color _royalBlue = const Color(0xFF003CC5);
  final Color _pearlWhite = const Color(0xFFF0F5FF);
  final Color _deepText = const Color(0xFF0A1D47);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT HEADER
          Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_sapphireBlue, _royalBlue],
              ),
            ),
          ),

          // 2. MAIN CONTENT SCROLLABLE
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildModernAppBar(context),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.fromLTRB(25, 30, 25, 120),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 30),
                      _buildTrackingTimeline(),
                      const SizedBox(height: 35),
                      _buildDetailCard(),
                      const SizedBox(height: 35),
                      _buildAssignedOfficer(), // Konten tambahan
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. FLOATING PREMIUM ACTIONS
          _buildFloatingActions(context),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildModernAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 70,
      leading: Container(
        margin: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20, top: 10, bottom: 10),
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child:
              const Icon(Icons.share_outlined, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _sapphireBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            pengaduan.kategori.toUpperCase(),
            style: TextStyle(
                color: _sapphireBlue,
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 1.5),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          pengaduan.judul,
          style: TextStyle(
              color: _deepText,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1),
        ),
        const SizedBox(height: 10),
        Text(
          "Dilaporkan pada ${pengaduan.createdAt}",
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTrackingTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("PROGRES LAPORAN",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1,
                color: Colors.grey)),
        const SizedBox(height: 20),
        Row(
          children: [
            _timelineNode(Icons.send_rounded, "Diajukan", true),
            _timelineConnector(pengaduan.status != 'diajukan'),
            _timelineNode(
                Icons.sync_rounded,
                "Diproses",
                pengaduan.status == 'diproses' ||
                    pengaduan.status == 'selesai'),
            _timelineConnector(pengaduan.status == 'selesai'),
            _timelineNode(Icons.check_circle_rounded, "Selesai",
                pengaduan.status == 'selesai'),
          ],
        ),
      ],
    );
  }

  Widget _timelineNode(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? _sapphireBlue : Colors.grey[200],
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: _sapphireBlue.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: Icon(icon,
              color: isActive ? Colors.white : Colors.grey[400], size: 20),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? _deepText : Colors.grey)),
      ],
    );
  }

  Widget _timelineConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isActive ? _sapphireBlue : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: _pearlWhite,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _sapphireBlue.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded, color: _sapphireBlue),
              const SizedBox(width: 10),
              const Text("Deskripsi Laporan",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Laporan ini sedang dalam tahap ${pengaduan.status}. Kami menjamin privasi dan keamanan data pelaporan Anda dalam sistem kami.",
            style: TextStyle(
                color: _deepText.withOpacity(0.7), fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedOfficer() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Color(0xFFE0E7FF),
          child: Icon(Icons.person_pin_rounded, color: Color(0xFF4338CA)),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Petugas Penanggung Jawab",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
            Text("Admin Pusat Layanan",
                style: TextStyle(
                    color: _deepText,
                    fontSize: 15,
                    fontWeight: FontWeight.w900)),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.chat_bubble_outline_rounded, color: _sapphireBlue),
        )
      ],
    );
  }

  Widget _buildFloatingActions(BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 25,
      right: 25,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: _sapphireBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Navigasi ke halaman Edit dengan membawa data pengaduan saat ini
                  bool? isUpdated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EditPengaduanPage(pengaduan: pengaduan),
                    ),
                  );

                  // Jika setelah edit user menekan 'Simpan' (mengembalikan nilai true)
                  if (isUpdated == true) {
                    // Kembali ke halaman daftar laporan dan suruh daftar tersebut refresh
                    Navigator.pop(context, true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sapphireBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("EDIT DATA LAPORAN",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
              ),
            ),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () => _handleDelete(context),
            child: Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: const Icon(Icons.delete_forever_rounded,
                  color: Colors.redAccent, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context) async {
    // Implementasi dialog konfirmasi bisa ditambahkan di sini
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      await PengaduanService.deletePengaduan(token: token, id: pengaduan.id);
      Navigator.pop(context, true);
    }
  }
}
