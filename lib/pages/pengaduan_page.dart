import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import Maps
import 'package:geolocator/geolocator.dart'; // Import GPS

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

  // Variabel untuk Google Maps
  GoogleMapController? mapController;
  LatLng _initialLocation =
      const LatLng(-6.200000, 106.816666); // Default Jakarta
  Set<Marker> _markers = {};
  bool _isLoadingLocation = false;

  // Palette Warna Mewah
  final Color _primaryBlue = const Color(0xFF0052D4);
  final Color _bgCanvas = const Color(0xFFF1F5F9);
  final Color _softGrey = const Color(0xFF94A3B8);
  final Color _darkSlate = const Color(0xFF0F172A);

  final List<String> _categories = [
    "Infrastruktur & Jalan",
    "Keamanan & Ketertiban",
    "Kesehatan Masyarakat",
    "Kebersihan & Sampah",
    "Lingkungan Hidup",
    "Layanan Perizinan",
    "Fasilitas Publik",
    "Gangguan Listrik/Air",
    "Lain-lain"
  ];

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
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

  // FUNGSI DETEKSI LOKASI (GPS)
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah layanan GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      _showSnackBar("Layanan lokasi tidak aktif.");
      return;
    }

    // Cek izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        _showSnackBar("Izin lokasi ditolak.");
        return;
      }
    }

    // Ambil koordinat
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId("user_loc"),
          position: currentLatLng,
          infoWindow: const InfoWindow(title: "Lokasi Laporan"),
        )
      };
      _isLoadingLocation = false;
      alamatController.text = "${position.latitude}, ${position.longitude}";
    });

    // Animasikan Kamera Peta ke Lokasi Baru
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLatLng, zoom: 16),
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && selectedImages.length < 3) {
      setState(() => selectedImages.add(File(file.path)));
    } else if (selectedImages.length >= 3) {
      _showSnackBar("Maksimal 3 foto pendukung");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgCanvas,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildInfoBanner(),
                      const SizedBox(height: 30),
                      _buildSectionHeader(
                          "INFORMASI UTAMA", Icons.assignment_outlined),
                      _buildPremiumCard(
                        child: Column(
                          children: [
                            _buildModernField(
                              label: "Judul Laporan",
                              controller: judulController,
                              hint: "Misal: Lampu jalan mati",
                              icon: Icons.title_rounded,
                              validator: (v) =>
                                  v!.isEmpty ? "Judul wajib diisi" : null,
                            ),
                            const SizedBox(height: 25),
                            _buildModernDropdown(),
                            const SizedBox(height: 25),
                            _buildModernField(
                              label: "Deskripsi Kejadian",
                              controller: isiController,
                              hint: "Detail kejadian...",
                              icon: Icons.subject_rounded,
                              maxLines: 5,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      _buildSectionHeader("LOKASI KEJADIAN", Icons.map_rounded),
                      _buildPremiumCard(
                        child: Column(
                          children: [
                            _buildMapPreview(), // Peta Interaktif
                            const SizedBox(height: 20),
                            _buildLocationButton(),
                            const SizedBox(height: 20),
                            _buildModernField(
                              label: "Alamat / Koordinat",
                              controller: alamatController,
                              hint: "Klik tombol di atas untuk isi otomatis",
                              icon: Icons.pin_drop_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 35),
                      _buildSectionHeader(
                          "DOKUMENTASI FOTO", Icons.camera_enhance_outlined),
                      _buildPremiumCard(child: _buildImagePickerGrid()),
                      const SizedBox(height: 40),
                      _buildSubmitButton(),
                      const SizedBox(height: 140),
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

  // --- SUB-WIDGETS ---

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: _primaryBlue, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text("Buat Laporan Baru",
            style: TextStyle(
                color: _darkSlate, fontWeight: FontWeight.w900, fontSize: 18)),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryBlue.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GoogleMap(
          initialCameraPosition:
              CameraPosition(target: _initialLocation, zoom: 14),
          onMapCreated: (controller) => mapController = controller,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    return InkWell(
      onTap: _isLoadingLocation ? null : _getCurrentLocation,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _primaryBlue.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoadingLocation
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.gps_fixed_rounded, color: _primaryBlue, size: 18),
            const SizedBox(width: 12),
            Text(
              _isLoadingLocation ? "Mendeteksi..." : "Deteksi Lokasi Otomatis",
              style: TextStyle(
                  color: _primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [_primaryBlue.withOpacity(0.1), Colors.white]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _primaryBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user_rounded, color: _primaryBlue, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Laporan Anda aman dan rahasia.",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
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
          Icon(icon, color: _primaryBlue, size: 18),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  color: _darkSlate,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 24,
              offset: const Offset(0, 12))
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
      int maxLines = 1,
      String? Function(String?)? validator}) {
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
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: _primaryBlue, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
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
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedCategory,
              icon:
                  Icon(Icons.keyboard_arrow_down_rounded, color: _primaryBlue),
              hint: const Text("Pilih Kategori"),
              items: _categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Lampirkan foto bukti (Maks. 3)",
            style: TextStyle(color: _softGrey, fontSize: 13)),
        const SizedBox(height: 20),
        Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  color: _primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _primaryBlue.withOpacity(0.2), width: 1.5),
                ),
                child: Icon(Icons.add_photo_alternate_outlined,
                    color: _primaryBlue, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 85,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 85,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                                image: FileImage(selectedImages[index]),
                                fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 17,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => selectedImages.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
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
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient:
            LinearGradient(colors: [_primaryBlue, const Color(0xFF4364F7)]),
        boxShadow: [
          BoxShadow(
              color: _primaryBlue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _showSnackBar("Laporan Berhasil Terkirim!");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: const Text("KIRIM LAPORAN SEKARANG",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1)),
      ),
    );
  }
}
