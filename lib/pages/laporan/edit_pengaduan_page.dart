import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_auth/models/pengaduan.model.dart'; // Sesuaikan nama file model Anda
import 'package:mobile_auth/services/pengaduan.service.dart';

class EditPengaduanPage extends StatefulWidget {
  final Pengaduan pengaduan;

  const EditPengaduanPage({super.key, required this.pengaduan});

  @override
  State<EditPengaduanPage> createState() => _EditPengaduanPageState();
}

class _EditPengaduanPageState extends State<EditPengaduanPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  late String _selectedKategori;

  File? _imageFile;
  bool _isLoading = false;

  // Warna Tema Custom
  final Color primaryBlue = const Color(0xFF0D47A1);
  final Color lightBlue = const Color(0xFFE3F2FD);
  final Color accentBlue = const Color(0xFF1976D2);

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.pengaduan.judul);
    _deskripsiController =
        TextEditingController(text: widget.pengaduan.deskripsi);
    _selectedKategori = widget.pengaduan.kategori;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  void _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await PengaduanService.updatePengaduan(
      token: token ?? '',
      id: widget.pengaduan.id,
      judul: _judulController.text,
      deskripsi: _deskripsiController.text,
      kategori: _selectedKategori,
      provinsi: widget.pengaduan.provinsi,
      kota: widget.pengaduan.kota,
      kecamatan: widget.pengaduan.kecamatan,
      kelurahan: widget.pengaduan.kelurahan,
      foto: _imageFile,
    );

    setState(() => _isLoading = false);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message']), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(response['message']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        title: const Text("Edit Laporan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background Biru di bagian atas
          Container(
            height: MediaQuery.of(context).size.height * 0.2,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(),
                        const SizedBox(height: 25),
                        _buildInputSection(),
                        const SizedBox(height: 30),
                        _buildSubmitButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          const Text("Foto Laporan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: _imageFile != null
                ? Image.file(_imageFile!,
                    height: 180, width: double.infinity, fit: BoxFit.cover)
                : widget.pengaduan.fotoUrl != null
                    ? Image.network(widget.pengaduan.fotoUrl!,
                        height: 180, width: double.infinity, fit: BoxFit.cover)
                    : Container(
                        height: 180,
                        width: double.infinity,
                        color: lightBlue,
                        child: Icon(Icons.image_not_supported,
                            size: 50, color: accentBlue),
                      ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text("Ubah Gambar"),
            style: OutlinedButton.styleFrom(
              foregroundColor: accentBlue,
              side: BorderSide(color: accentBlue),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: lightBlue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _judulController,
            label: "Judul Pengaduan",
            icon: Icons.title,
            hint: "Masukkan judul...",
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _deskripsiController,
            label: "Deskripsi Detail",
            icon: Icons.description_outlined,
            hint: "Ceritakan detail kejadian...",
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: accentBlue),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(15),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: lightBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: (v) => v!.isEmpty ? "Field ini wajib diisi" : null,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _handleUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          shadowColor: primaryBlue.withOpacity(0.4),
        ),
        child: const Text(
          "SIMPAN PERUBAHAN",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2),
        ),
      ),
    );
  }
}
