import 'package:flutter/material.dart';

class LaporanPage extends StatelessWidget {
  // Skema warna mewah, konsisten dengan DashboardPage & HomePage
  final Color _primaryColor = const Color(0xFF0077B6); // Biru yang dalam
  final Color _deepBlue = const Color(0xFF023E8A); // Biru yang lebih tua
  final Color _darkBackgroundColor =
      const Color(0xFF0A192F); // Latar belakang gelap
  final Color _accentColor = const Color(0xFFFFC300);
  final Color _textColor = Colors.white;

  // Mock Data untuk Laporan
  final List<Map<String, dynamic>> mockReports = [
    {
      'id': 'L001',
      'title': 'Kerusakan Sistem Server Utama',
      'status': 'Selesai',
      'date': '2024-11-28',
      'color': Colors.green.shade500
    },
    {
      'id': 'L002',
      'title': 'Permintaan Upgrade Lisensi Software',
      'status': 'Proses',
      'date': '2024-11-30',
      'color': Colors.orange.shade700
    },
    {
      'id': 'L003',
      'title': 'Kebutuhan Pelatihan Keamanan Siber',
      'status': 'Ditunda',
      'date': '2024-12-01',
      'color': Colors.red.shade700
    },
    {
      'id': 'L004',
      'title': 'Evaluasi Kinerja Q4 2024',
      'status': 'Selesai',
      'date': '2024-12-02',
      'color': Colors.green.shade500
    },
  ];

  // Fungsi untuk membuat kartu statistik ringkas
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F304E), // Latar belakang kartu gelap
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: _textColor.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              Icon(icon, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
                color: _textColor, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membuat kartu laporan detail
  Widget _buildReportTile(Map<String, dynamic> report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1F304E), // Latar belakang kartu gelap
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        leading:
            Icon(Icons.description_rounded, color: report['color'], size: 30),
        title: Text(
          report['title'],
          style: TextStyle(
              color: _textColor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "ID: ${report['id']}",
              style:
                  TextStyle(color: _textColor.withOpacity(0.6), fontSize: 12),
            ),
            Text(
              "Tanggal: ${report['date']}",
              style:
                  TextStyle(color: _textColor.withOpacity(0.6), fontSize: 12),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: report['color'].withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: report['color'], width: 1),
          ),
          child: Text(
            report['status'],
            style: TextStyle(
                color: report['color'],
                fontWeight: FontWeight.bold,
                fontSize: 12),
          ),
        ),
        onTap: () {
          // Aksi ketika laporan diklik
          print("Laporan ${report['id']} diklik");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung statistik mock
    int totalReports = mockReports.length;
    int pendingReports =
        mockReports.where((r) => r['status'] == 'Proses').length;
    int completedReports =
        mockReports.where((r) => r['status'] == 'Selesai').length;

    return Scaffold(
      backgroundColor: _darkBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Halaman
            Text(
              "Ringkasan Laporan Anda",
              style: TextStyle(
                  color: _accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text(
              "Ikhtisar status laporan yang telah Anda ajukan.",
              style:
                  TextStyle(color: _textColor.withOpacity(0.7), fontSize: 14),
            ),
            const SizedBox(height: 30),

            // GRID STATISTIK
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard("Total Laporan", totalReports.toString(),
                    Icons.layers_rounded, _primaryColor),
                _buildStatCard("Selesai", completedReports.toString(),
                    Icons.check_circle_rounded, Colors.green.shade500),
                _buildStatCard("Dalam Proses", pendingReports.toString(),
                    Icons.access_time_filled_rounded, Colors.orange.shade700),
                _buildStatCard(
                    "Baru", "1", Icons.add_box_rounded, _accentColor),
              ],
            ),
            const SizedBox(height: 40),

            // BAGIAN DAFTAR LAPORAN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Daftar Laporan Terkini",
                  style: TextStyle(
                      color: _textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Aksi untuk melihat semua laporan
                  },
                  icon: Icon(Icons.sort, color: _accentColor),
                  label: Text(
                    "Sortir",
                    style: TextStyle(color: _accentColor),
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),

            // DAFTAR KARTU LAPORAN
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockReports.length,
              itemBuilder: (context, index) {
                return _buildReportTile(mockReports[index]);
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                "Semua data Laporan telah dimuat.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
