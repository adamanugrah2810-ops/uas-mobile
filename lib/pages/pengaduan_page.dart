import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final TextEditingController alamatController = TextEditingController();

  String? selectedCategory;
  List<File> selectedImages = [];

  // Palette Warna Mewah (Royal Blue & Pure White)
  final Color _primaryBlue = const Color(0xFF0052D4);
  final Color _bgCanvas = const Color(0xFFF8FAFF);
  final Color _softGrey = const Color(0xFF94A3B8);
  final Color _darkSlate = const Color(0xFF1E293B);

  late AnimationController _animController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutQuart,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    judulController.dispose();
    isiController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && selectedImages.length < 3) {
      setState(() => selectedImages.add(File(file.path)));
    } else if (selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maksimal 3 foto pendukung")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCanvas,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar Modern
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            elevation: 0,
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text("Buat Laporan Baru",
                  style: TextStyle(
                    color: _darkSlate,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  )),
              background: Container(color: Colors.white),
            ),
            backgroundColor: Colors.white.withOpacity(0.9),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: _primaryBlue, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      _buildInfoBanner(),
                      const SizedBox(height: 30),
                      _buildSectionHeader(
                          "DETAIL LAPORAN", Icons.description_outlined),
                      _buildPremiumCard(
                        child: Column(
                          children: [
                            _buildModernField(
                              label: "Judul Laporan",
                              controller: judulController,
                              hint: "Misal: Jalan Berlubang di Pusat Kota",
                              icon: Icons.title_rounded,
                            ),
                            const SizedBox(height: 25),
                            _buildModernDropdown(),
                            const SizedBox(height: 25),
                            _buildModernField(
                              label: "Deskripsi Lengkap",
                              controller: isiController,
                              hint: "Jelaskan kronologi secara detail...",
                              icon: Icons.subject_rounded,
                              maxLines: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      _buildSectionHeader(
                          "LOKASI KEJADIAN", Icons.location_on_outlined),
                      _buildPremiumCard(
                        child: Column(
                          children: [
                            _buildMapPreview(), // Sudah diperbaiki dari error 404
                            const SizedBox(height: 20),
                            _buildLocationButton(),
                            const SizedBox(height: 20),
                            _buildModernField(
                              label: "Alamat Lengkap / Patokan",
                              controller: alamatController,
                              hint: "Sebutkan nama jalan atau ciri lokasi",
                              icon: Icons.map_outlined,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      _buildSectionHeader(
                          "BUKTI PENDUKUNG", Icons.camera_enhance_outlined),
                      _buildPremiumCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Lampirkan foto kondisi saat ini (Maks. 3)",
                                style: TextStyle(
                                    color: _softGrey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            const SizedBox(height: 20),
                            _buildImagePickerGrid(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: _primaryBlue, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Laporan Anda akan kami proses secara rahasia dan aman.",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF003D9E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: _primaryBlue, size: 20),
          const SizedBox(width: 12),
          Text(title,
              style: TextStyle(
                  color: _darkSlate,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.1)),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildModernField(
      {required String label,
      required TextEditingController controller,
      required String hint,
      required IconData icon,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: _darkSlate, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _softGrey.withOpacity(0.7)),
            prefixIcon: Icon(icon, color: _primaryBlue, size: 20),
            filled: true,
            fillColor: _bgCanvas,
            contentPadding: const EdgeInsets.all(18),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Kategori Laporan",
            style: TextStyle(
                color: _darkSlate, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          decoration: BoxDecoration(
              color: _bgCanvas, borderRadius: BorderRadius.circular(15)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedCategory,
              icon: Icon(Icons.arrow_drop_down_circle_outlined,
                  color: _primaryBlue, size: 20),
              hint: Text("Pilih Kategori",
                  style: TextStyle(color: _softGrey.withOpacity(0.7))),
              items: ["Infrastruktur", "Keamanan", "Kesehatan", "Lingkungan"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v),
            ),
          ),
        ),
      ],
    );
  }

  // FIX: Menggunakan Placeholder Lokal agar tidak error 404
  Widget _buildMapPreview() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_rounded,
              color: _primaryBlue.withOpacity(0.3), size: 50),
          const SizedBox(height: 10),
          Text(
            "Pratinjau Peta",
            style: TextStyle(
                color: _primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text("Ketuk tombol di bawah untuk set lokasi",
              style: TextStyle(color: _softGrey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.my_location_rounded, size: 18),
      label: const Text("Gunakan Lokasi Saat Ini",
          style: TextStyle(fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        foregroundColor: _primaryBlue,
        side: BorderSide(color: _primaryBlue.withOpacity(0.3)),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildImagePickerGrid() {
    return Row(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border:
                  Border.all(color: _primaryBlue.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: _primaryBlue, size: 24),
                const SizedBox(height: 4),
                Text("Pilih",
                    style: TextStyle(
                        color: _primaryBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                            image: FileImage(selectedImages[index]),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedImages.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // Logika kirim
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: const Text("KIRIM LAPORAN SEKARANG",
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}
