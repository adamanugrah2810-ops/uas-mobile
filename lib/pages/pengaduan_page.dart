import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_auth/services/pengaduan.service.dart';
// Pastikan import home_page kamu benar di sini:
import 'package:mobile_auth/pages/home_page.dart';

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
      "Cikupa": ["Sukamulya", "Talaga"],
      "Cibodas": ["Cibodas Baru", "Cibodas Megah", "Panunggangan Barat"]
    },
    "Kota Tangerang": {
      "Ciledug": ["Paninggilan", "Sudimara Barat"]
    },
    "Kota Serang": {
      "Serang": ["Cipocok Jaya", "Kasemen", "Curug"]
    },
    "Kota Tangerang Selatan": {
      "Pamulang": [
        "Pamulang",
        "Benda Baru",
        "Pondok Benda",
        "Bambu Apus",
        "Kedaung",
        "Pamulang Barat",
        "Pamulang Timur",
        "Pondok Cabe Udik",
        "Pondok Cabe Ilir"
      ]
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
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() {
    judulController.dispose();
    isiController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _showSuccessDialog() {
    HapticFeedback.vibrate();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeInOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 60, color: Color(0xFF2196F3)),
                  ),
                  const SizedBox(height: 24),
                  const Text("Laporan Terkirim",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0))),
                  const SizedBox(height: 12),
                  const Text(
                    "Terima kasih. Laporan Anda telah kami terima dan akan segera ditindaklanjuti.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.blueGrey, height: 1.5, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF64B5F6)]),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          // PERBAIKAN UTAMA:
                          // Menghapus semua tumpukan navigasi dan kembali ke Home
                          // Ini mencegah error !history.isNotEmpty
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                            (route) => false,
                          );
                        },
                        child: const Text("SELESAI",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      setState(() => selectedImages = [File(file.path)]);
    }
  }

  InputDecoration _mewahInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF1976D2), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF2196F3), size: 22),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFBBDEFB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: const Text("Buat Pengaduan",
            style: TextStyle(
                fontWeight: FontWeight.w800, color: Color(0xFF0D47A1))),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _sectionHeader("Detail Laporan"),
                    _buildFormCard([
                      TextFormField(
                        controller: judulController,
                        decoration:
                            _mewahInput("Judul Laporan", Icons.campaign),
                        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: _mewahInput("Kategori", Icons.category),
                        items: _categories
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) => setState(() => selectedCategory = v),
                        validator: (v) => v == null ? "Pilih kategori" : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: isiController,
                        maxLines: 4,
                        decoration: _mewahInput("Deskripsi", Icons.description),
                        validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _sectionHeader("Lokasi"),
                    _buildFormCard([
                      DropdownButtonFormField(
                        decoration:
                            _mewahInput("Kota/Kabupaten", Icons.location_city),
                        value: selectedKota,
                        items: kotaList
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            selectedKota = v;
                            kecamatanList = wilayahBanten[v!]!.keys.toList();
                            selectedKecamatan = null;
                            selectedKelurahan = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField(
                              decoration: _mewahInput("Kecamatan", Icons.map),
                              value: selectedKecamatan,
                              items: kecamatanList
                                  .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e,
                                          style:
                                              const TextStyle(fontSize: 12))))
                                  .toList(),
                              onChanged: (v) {
                                setState(() {
                                  selectedKecamatan = v;
                                  kelurahanList =
                                      wilayahBanten[selectedKota!]![v!]!;
                                  selectedKelurahan = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField(
                              decoration:
                                  _mewahInput("Kelurahan", Icons.pin_drop),
                              value: selectedKelurahan,
                              items: kelurahanList
                                  .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e,
                                          style:
                                              const TextStyle(fontSize: 12))))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedKelurahan = v),
                            ),
                          ),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _sectionHeader("Bukti Foto"),
                    _buildImageUploader(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.8),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2196F3)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
              letterSpacing: 1.1)),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildImageUploader() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFBBDEFB), width: 2),
        ),
        child: selectedImages.isEmpty
            ? const Center(
                child: Icon(Icons.add_a_photo_rounded,
                    size: 40, color: Color(0xFF2196F3)))
            : ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.file(selectedImages.first, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF2196F3)]),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2196F3).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: _isLoading ? null : _submitPengaduan,
        child: const Text("KIRIM LAPORAN",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white)),
      ),
    );
  }

  Future<void> _submitPengaduan() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedKota == null ||
        selectedKecamatan == null ||
        selectedKelurahan == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lengkapi lokasi")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token == null) throw Exception("Token null");
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
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(res['message'] ?? "Gagal")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
