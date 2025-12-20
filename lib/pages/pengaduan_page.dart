import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PengaduanPage extends StatefulWidget {
  @override
  State<PengaduanPage> createState() => _PengaduanPageState();
}

class _PengaduanPageState extends State<PengaduanPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  final Color _primaryColor = const Color(0xFF0077B6);
  final Color _accentColor = const Color(0xFFFFC300);
  final Color _darkBg = const Color(0xFF0A192F);

  String? selectedCategory;
  File? selectedImage;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    judulController.dispose();
    deskripsiController.dispose();
    super.dispose();
  }

  // ========================= Upload Foto =========================

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => selectedImage = File(file.path));
    }
  }

  // ========================= Submit =========================

  void submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Pengaduan berhasil dikirim 🎉"),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(Duration(seconds: 2), () {
        judulController.clear();
        deskripsiController.clear();
        setState(() {
          selectedCategory = null;
          selectedImage = null;
        });
      });
    }
  }

  // ========================= UI =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 25),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 10),

                  // HEADER ICON
                  Container(
                    padding: EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        )
                      ],
                    ),
                    child: Icon(Icons.campaign_rounded,
                        size: 50, color: _accentColor),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Ajukan Pengaduan",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "Silakan isi formulir berikut dengan lengkap",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  SizedBox(height: 30),

                  // INPUT JUDUL
                  _inputField(
                    controller: judulController,
                    label: "Judul Pengaduan",
                    hint: "Contoh: Lampu jalan rusak",
                    icon: Icons.edit,
                  ),

                  SizedBox(height: 20),

                  // DROPDOWN KATEGORI
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    decoration: _fieldDecoration(),
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: _darkBg,
                      icon:
                          Icon(Icons.keyboard_arrow_down, color: _accentColor),
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: "Kategori Pengaduan",
                        labelStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                      items: [
                        "Pelayanan Publik",
                        "Infrastruktur",
                        "Lingkungan",
                        "Keamanan",
                        "Lainnya"
                      ]
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(item,
                                    style: TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                      validator: (value) => value == null
                          ? "Pilih kategori terlebih dahulu"
                          : null,
                      onChanged: (value) =>
                          setState(() => selectedCategory = value),
                    ),
                  ),

                  SizedBox(height: 20),

                  // DESKRIPSI
                  _inputField(
                    controller: deskripsiController,
                    label: "Deskripsi",
                    hint: "Jelaskan kronologi kejadian...",
                    icon: Icons.description_rounded,
                    maxLines: 5,
                  ),

                  SizedBox(height: 20),

                  // FOTO PREVIEW
                  if (selectedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        selectedImage!,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),

                  SizedBox(height: 12),

                  // BUTTON UPLOAD
                  ElevatedButton.icon(
                    onPressed: pickImage,
                    icon: Icon(Icons.photo_camera_back_rounded, color: _darkBg),
                    label: Text("Lampirkan Foto",
                        style: TextStyle(
                            color: _darkBg, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 25),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  SizedBox(height: 35),

                  // BUTTON SUBMIT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submit,
                      child: Text("Kirim Pengaduan",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 10,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Style field
  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
    );
  }

  // Custom TextField
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? "$label tidak boleh kosong" : null,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: _accentColor),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white30)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _accentColor)),
      ),
    );
  }
}
