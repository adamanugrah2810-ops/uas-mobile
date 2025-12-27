import 'package:flutter/material.dart';
import 'package:mobile_auth/models/pengaduan.model.dart';
import 'package:mobile_auth/services/pengaduan.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LaporanDetailPage extends StatelessWidget {
  final Pengaduan pengaduan;

  const LaporanDetailPage({super.key, required this.pengaduan});

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

  Future<void> _deletePengaduan(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    await PengaduanService.deletePengaduan(
      token: token,
      id: pengaduan.id,
    );

    Navigator.pop(context, true); // kembali + refresh list
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(pengaduan.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Pengaduan"),
        backgroundColor: color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pengaduan.judul,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Chip(
              label: Text(pengaduan.status.toUpperCase()),
              backgroundColor: color.withOpacity(0.15),
              labelStyle: TextStyle(color: color),
            ),
            const SizedBox(height: 20),
            _item("Kategori", pengaduan.kategori),
            _item("Tanggal", pengaduan.createdAt),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    onPressed: () {
                      // navigasi ke halaman edit
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text("Hapus"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Konfirmasi"),
                          content: const Text(
                              "Yakin ingin menghapus pengaduan ini?"),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Batal")),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Hapus")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _deletePengaduan(context);
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
              width: 90,
              child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
