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
      "Balaraja": [
        "Saga",
        "Sentul",
        "Tobat",
        "Talagasari",
        "Cibadak",
        "Gembong"
      ],
      "Cikupa": [
        "Sukamulya",
        "Talaga",
        "Bojong",
        "Bunder",
        "Bunder Sari",
        "Cikupa",
        "Dukuh",
        "Pasir Gadung",
        "Sukadamai"
      ],
      "Cibodas": [
        "Cibodas",
        "Cibodas Baru",
        "Cibodas Megah",
        "Panunggangan Barat",
        "Panunggangan Timur",
        "Uwung Jaya"
      ],
      "Curug": ["Curug Kulon", "Curug Wetan", "Kadu", "Sukabakti", "Binong"],
      "Kelapa Dua": [
        "Kelapa Dua",
        "Bojong Nangka",
        "Pakualam",
        "Bencongan",
        "Bencongan Indah"
      ],
      "Pasar Kemis": [
        "Pasar Kemis",
        "Kutabumi",
        "Kutabaru",
        "Sukaasih",
        "Sindangsari"
      ],
      "Rajeg": ["Rajeg", "Rajeg Mulya", "Rajeg Mekar", "Tanjakan", "Sukatani"],
      "Tigaraksa": [
        "Tigaraksa",
        "Pasir Nangka",
        "Pete",
        "Matagara",
        "Margasari"
      ]
    },
    "Kota Cilegon": {
      "Cibeber": ["Cibeber", "Kalitimbang", "Kedaleman"],
      "Cilegon": ["Bagendung", "Ketileng", "Sukmajaya"],
      "Citangkil": ["Citangkil", "Lebakdenok", "Warnasari"],
      "Ciwandan": ["Ciwandan", "Banjarnegara", "Kubangsari"],
      "Gerogol": ["Gerogol", "Kotasari", "Rawa Arum"],
      "Jombang": ["Jombang Wetan", "Masigit", "Panggungrawi"],
      "Pulomerak": ["Pulomerak", "Tamansari", "Suralaya"]
    },
    "Kab. Serang": {
      "Anyar": ["Anyar", "Bandulu", "Kosambironyok"],
      "Bojonegara": ["Bojonegara", "Margagiri", "Pulo Ampel"],
      "Cikande": ["Cikande", "Cikande Permai", "Parigi"],
      "Ciruas": ["Ciruas", "Pelawad", "Ranjeng"],
      "Kibin": ["Kibin", "Nambo Ilir", "Tambak"],
      "Kramatwatu": ["Kramatwatu", "Pejaten", "Terate"],
      "Pontang": ["Pontang", "Singarajan", "Kubang Puji"],
      "Tanara": ["Tanara", "Cerukcuk", "Lontar"]
    },
    "Kab. Lebak": {
      "Bayah": ["Bayah Barat", "Bayah Timur", "Sawarna"],
      "Cibadak": ["Cibadak", "Kaduagung", "Pasar Keong"],
      "Cileles": ["Cileles", "Gumuruh", "Pasir Keong"],
      "Leuwidamar": ["Leuwidamar", "Cibarani", "Lebaksitu"],
      "Maja": ["Maja", "Binong", "Sangiang"],
      "Rangkasbitung": [
        "Rangkasbitung Barat",
        "Rangkasbitung Timur",
        "Cijoro Lebak"
      ],
      "Warunggunung": ["Warunggunung", "Cigelam", "Sindangsari"]
    },
    "Kab. Pandeglang": {
      "Labuan": ["Labuan", "Kalanganyar", "Teluk"],
      "Mandalawangi": ["Mandalawangi", "Cikoneng", "Parakan"],
      "Menes": ["Menes", "Purwaraja", "Cipicung"],
      "Panimbang": ["Panimbang", "Mekarsari", "Tanjungjaya"],
      "Pandeglang": ["Pandeglang", "Kabayan", "Sukaresmi"],
      "Sumur": ["Sumur", "Kertajaya", "Sumberjaya"]
    },
    "Kota Tangerang": {
      "Batuceper": [
        "Batuceper",
        "Batujaya",
        "Batusari",
        "Poris Gaga",
        "Poris Gaga Baru",
        "Poris Plawad",
        "Poris Plawad Indah"
      ],
      "Benda": [
        "Benda",
        "Belendung",
        "Jurumudi",
        "Jurumudi Baru",
        "Pajang",
        "Periuk Jaya"
      ],
      "Cibodas": [
        "Cibodas",
        "Cibodas Baru",
        "Jatiuwung",
        "Panunggangan Barat",
        "Panunggangan Timur"
      ],
      "Ciledug": [
        "Paninggilan",
        "Paninggilan Utara",
        "Sudimara Barat",
        "Sudimara Selatan",
        "Sudimara Timur",
        "Sudimara Jaya"
      ],
      "Cipondoh": [
        "Cipondoh",
        "Cipondoh Indah",
        "Cipondoh Makmur",
        "Gondrong",
        "Kenanga",
        "Ketapang",
        "Petir"
      ],
      "Jatiuwung": [
        "Alam Jaya",
        "Gandasari",
        "Jatiuwung",
        "Manis Jaya",
        "Pasir Jaya"
      ],
      "Karangtengah": [
        "Karang Tengah",
        "Karang Mulya",
        "Karang Timur",
        "Pedurenan",
        "Pondok Bahar"
      ],
      "Karawaci": [
        "Bojong Jaya",
        "Bugel",
        "Cimone",
        "Cimone Jaya",
        "Gerendeng",
        "Karawaci Baru",
        "Karawaci Lama",
        "Margasari",
        "Nambo Jaya",
        "Pasar Baru",
        "Pabuaran"
      ],
      "Larangan": [
        "Gaga",
        "Kreo",
        "Kreo Selatan",
        "Larangan Indah",
        "Larangan Selatan",
        "Larangan Utara"
      ],
      "Neglasari": [
        "Karangsari",
        "Kedaung Baru",
        "Mekarsari",
        "Neglasari",
        "Selapajang Jaya"
      ],
      "Periuk": ["Gebang Raya", "Periuk", "Periuk Jaya", "Sangiang Jaya"],
      "Pinang": [
        "Cipete",
        "Kunciran",
        "Kunciran Indah",
        "Kunciran Jaya",
        "Panunggangan",
        "Panunggangan Utara"
      ],
      "Tangerang": [
        "Babakan",
        "Buaran Indah",
        "Sukaasih",
        "Sukasari",
        "Tanah Tinggi"
      ]
    },
    "Kota Serang": {
      "Serang": [
        "Cipare",
        "Cimuncang",
        "Kota Baru",
        "Lopang",
        "Sumur Pecung",
        "Unyur"
      ],
      "Cipocok Jaya": [
        "Banjaragung",
        "Banjarasri",
        "Banjarsari",
        "Cipocok Jaya",
        "Gelam",
        "Karundang",
        "Panancangan"
      ],
      "Curug": ["Curug", "Cilaku", "Kemanisan", "Sukawana", "Tinggar"],
      "Kasemen": [
        "Kasemen",
        "Banten",
        "Margaluyu",
        "Mesjid Priyayi",
        "Sawah Luhur",
        "Terumbu",
        "Warung Jaud"
      ],
      "Taktakan": [
        "Taktakan",
        "Kuranji",
        "Drangong",
        "Kalang Anyar",
        "Lontarbaru",
        "Pancur",
        "Panggungjati"
      ],
      "Walantaka": [
        "Walantaka",
        "Cigoong",
        "Kepuren",
        "Lebakwangi",
        "Nyapah",
        "Pabuaran",
        "Pengampelan"
      ]
    },
    "Kota Tangerang Selatan": {
      "Pamulang": [
        "Pamulang Barat",
        "Pamulang Timur",
        "Bambu Apus",
        "Kedaung",
        "Pondok Benda",
        "Pondok Cabe Ilir",
        "Pondok Cabe Udik",
        "Benda Baru"
      ],
      "Ciputat": [
        "Ciputat",
        "Cipayung",
        "Sawah Baru",
        "Sawah Lama",
        "Serua",
        "Serua Indah",
        "Jombang"
      ],
      "Ciputat Timur": [
        "Cempaka Putih",
        "Cireundeu",
        "Pisangan",
        "Pisangan Timur",
        "Rengas",
        "Rempoa"
      ],
      "Serpong": ["Serpong", "Buaran", "Ciater", "Cilenggang", "Rawa Buntu"],
      "Serpong Utara": [
        "Pakulonan",
        "Pakulonan Barat",
        "Pondok Jagung",
        "Pondok Jagung Timur",
        "Lengkong Karya"
      ],
      "Setu": ["Setu", "Keranggan", "Babakan", "Bakti Jaya", "Muncul"],
      "Pondok Aren": [
        "Pondok Aren",
        "Pondok Kacang Barat",
        "Pondok Kacang Timur",
        "Pondok Jaya",
        "Jurang Mangu Barat",
        "Jurang Mangu Timur",
        "Parigi",
        "Parigi Baru",
        "Pondok Betung",
        "Pondok Pucung",
        "Perigi Lama"
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
