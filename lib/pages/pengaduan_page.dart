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

  // === WILAYAH BANTEN ===
  final String selectedProvinsi = "Banten";
  String? selectedKota;
  String? selectedKecamatan;
  String? selectedKelurahan;

  // === DATA STATIC BANTEN (CONTOH) ===
  final Map<String, Map<String, List<String>>> wilayahBanten = {
    "Kota Serang": {
      "Serang": ["Cipocok Jaya", "Kasemen", "Curug"]
    },
    "Kab. Tangerang": {
      "Balaraja": ["Saga", "Sentul"],
      "Cikupa": ["Sukamulya", "Talaga"]
    },
    "Kota Tangerang": {
      "Ciledug": ["Paninggilan", "Sudimara Barat"]
    }
  };

  List<String> kotaList = [];
  List<String> kecamatanList = [];
  List<String> kelurahanList = [];

  List<File> selectedImages = [];

  // === UI ===
  final Color _primaryBlue = const Color(0xFF0052D4);
  final Color _bgCanvas = const Color(0xFFF1F5F9);
  final Color _darkSlate = const Color(0xFF0F172A);
  final Color _softGrey = const Color(0xFF94A3B8);

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
        CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    judulController.dispose();
    isiController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && selectedImages.length < 3) {
      setState(() => selectedImages.add(File(file.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCanvas,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection("INFORMASI UTAMA"),
                      _buildCard(
                        Column(
                          children: [
                            _buildField(
                              "Judul Laporan",
                              judulController,
                              "Contoh: Jalan rusak",
                              validator: (v) =>
                                  v!.isEmpty ? "Judul wajib diisi" : null,
                            ),
                            const SizedBox(height: 20),
                            _buildCategory(),
                            const SizedBox(height: 20),
                            _buildField(
                              "Deskripsi",
                              isiController,
                              "Detail kejadian...",
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSection("LOKASI KEJADIAN"),
                      _buildCard(
                        Column(
                          children: [
                            _buildStaticField("Provinsi", selectedProvinsi),
                            const SizedBox(height: 20),
                            _buildSelect(
                              "Kota / Kabupaten",
                              selectedKota,
                              kotaList,
                              (v) {
                                setState(() {
                                  selectedKota = v;
                                  selectedKecamatan = null;
                                  selectedKelurahan = null;
                                  kecamatanList =
                                      wilayahBanten[v!]!.keys.toList();
                                  kelurahanList = [];
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildSelect(
                              "Kecamatan",
                              selectedKecamatan,
                              kecamatanList,
                              (v) {
                                setState(() {
                                  selectedKecamatan = v;
                                  selectedKelurahan = null;
                                  kelurahanList =
                                      wilayahBanten[selectedKota!]![v!]!;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildSelect(
                              "Kelurahan",
                              selectedKelurahan,
                              kelurahanList,
                              (v) => setState(() => selectedKelurahan = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _buildSection("DOKUMENTASI"),
                      _buildCard(_buildImages()),
                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ================= WIDGET =================

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      title: const Text("Buat Laporan",
          style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
              color: _darkSlate)),
    );
  }

  Widget _buildCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: child,
    );
  }

  Widget _buildField(String label, TextEditingController c, String hint,
      {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildStaticField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text("$label : $value",
          style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSelect(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
      ),
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildCategory() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      hint: const Text("Pilih Kategori"),
      items: _categories
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => setState(() => selectedCategory = v),
      validator: (v) => v == null ? "Kategori wajib dipilih" : null,
    );
  }

  Widget _buildImages() {
    return Row(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _primaryBlue.withOpacity(0.1),
            ),
            child: Icon(Icons.add_a_photo, color: _primaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          if (selectedKota == null ||
              selectedKecamatan == null ||
              selectedKelurahan == null) {
            _showSnackBar("Lengkapi lokasi");
            return;
          }

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token");
          if (token == null) return;

          final res = await PengaduanService.kirimPengaduan(
            token: token,
            judul: judulController.text,
            deskripsi: isiController.text,
            kategori: selectedCategory!,
            provinsi: selectedProvinsi,
            kota: selectedKota!,
            kecamatan: selectedKecamatan!,
            kelurahan: selectedKelurahan!,
            foto: selectedImages.isNotEmpty ? selectedImages.first : null,
          );

          _showSnackBar(res['message']);
        },
        child: const Text("KIRIM LAPORAN"),
      ),
    );
  }
}
