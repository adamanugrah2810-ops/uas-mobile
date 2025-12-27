import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_auth/services/pengaduan.service.dart';

class PengaduanPage extends StatefulWidget {
  const PengaduanPage({super.key});

  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController judulController = TextEditingController();
  final TextEditingController isiController = TextEditingController();

  String? selectedCategory;
  final String selectedProvinsi = "Banten";
  String? selectedKota;
  String? selectedKecamatan;
  String? selectedKelurahan;

  final Map<String, Map<String, List<String>>> wilayahBanten = {
    "Kab. Tangerang": {
      "Balaraja": ["Saga", "Sentul"],
      "Cikupa": ["Sukamulya", "Talaga"]
    },
    "Kota Tangerang": {
      "Ciledug": ["Paninggilan", "Sudimara Barat"]
    },
    "Kota Serang": {
      "Serang": ["Cipocok Jaya", "Kasemen", "Curug"]
    }
  };

  List<String> kotaList = [];
  List<String> kecamatanList = [];
  List<String> kelurahanList = [];

  List<File> selectedImages = [];
  bool _isLoading = false;

  final List<String> _categories = [
    "Infrastruktur & Jalan",
    "Keamanan & Ketertiban",
    "Kesehatan Masyarakat",
    "Kebersihan & Sampah",
    "Lingkungan Hidup",
    "Fasilitas Publik",
    "Lain-lain"
  ];

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    kotaList = wilayahBanten.keys.toList();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    judulController.dispose();
    isiController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // MODAL BERHASIL YANG KEREN
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 80, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  "Laporan Terkirim!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Terima kasih atas laporan Anda. Kami akan segera menindaklanjutinya.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Tutup dialog
                      Navigator.pop(context); // Kembali ke dashboard
                    },
                    child: const Text("Selesai",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => selectedImages = [File(file.path)]);
    }
  }

  Future<void> _submitPengaduan() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedKota == null ||
        selectedKecamatan == null ||
        selectedKelurahan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Lengkapi lokasi kejadian")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    if (token == null || token.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final res = await PengaduanService.kirimPengaduan(
        token: token,
        judul: judulController.text.trim(),
        deskripsi: isiController.text.trim(),
        kategori: selectedCategory!,
        provinsi: selectedProvinsi,
        kota: selectedKota!,
        kecamatan: selectedKecamatan!,
        kelurahan: selectedKelurahan!,
        foto: selectedImages.isNotEmpty ? selectedImages.first : null,
      );

      if (res['success'] == true) {
        _showSuccessDialog(); // PANGGIL DIALOG BERHASIL
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res['message'] ?? "Gagal")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Reusable Input Decoration
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Buat Laporan",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Informasi Laporan",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: judulController,
                  decoration: _inputStyle("Judul Laporan", Icons.title),
                  validator: (v) => v!.isEmpty ? "Judul wajib diisi" : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: _inputStyle("Pilih Kategori", Icons.category),
                  items: _categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCategory = v),
                  validator: (v) => v == null ? "Kategori wajib dipilih" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: isiController,
                  maxLines: 4,
                  decoration:
                      _inputStyle("Deskripsi Kejadian", Icons.description),
                  validator: (v) => v!.isEmpty ? "Deskripsi wajib diisi" : null,
                ),
                const SizedBox(height: 24),
                const Text("Lokasi Kejadian",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  decoration:
                      _inputStyle("Kota / Kabupaten", Icons.location_city),
                  value: selectedKota,
                  items: kotaList
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      selectedKota = v;
                      kecamatanList = wilayahBanten[v!]!.keys.toList();
                      selectedKecamatan = null;
                      selectedKelurahan = null;
                      kelurahanList = [];
                    });
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: _inputStyle("Kecamatan", Icons.map),
                        value: selectedKecamatan,
                        items: kecamatanList
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedKecamatan = v;
                            kelurahanList = wilayahBanten[selectedKota!]![v!]!;
                            selectedKelurahan = null;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField(
                        decoration: _inputStyle("Kelurahan", Icons.pin_drop),
                        value: selectedKelurahan,
                        items: kelurahanList
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedKelurahan = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text("Lampiran Foto",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: selectedImages.isEmpty
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo,
                                  size: 40, color: Colors.grey),
                              Text("Klik untuk tambah foto",
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(selectedImages.first,
                                fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    onPressed: _isLoading ? null : _submitPengaduan,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "KIRIM LAPORAN SEKARANG",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
