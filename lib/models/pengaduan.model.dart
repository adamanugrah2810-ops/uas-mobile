class Pengaduan {
  final int id;
  final String judul;
  final String deskripsi;
  final String kategori;
  final String provinsi;
  final String kota;
  final String kecamatan;
  final String kelurahan;
  final String? foto;
  final String status;
  final String createdAt;

  Pengaduan({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    required this.provinsi,
    required this.kota,
    required this.kecamatan,
    required this.kelurahan,
    this.foto,
    required this.status,
    required this.createdAt,
  });

  // Getter untuk URL foto
  String? get fotoUrl =>
      foto != null ? "http://10.0.2.2:8000/storage/$foto" : null;

  factory Pengaduan.fromJson(Map<String, dynamic> json) {
    return Pengaduan(
      // Pastikan ID dikonversi ke int secara aman
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      judul: json['judul']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString() ?? '',
      kategori: json['kategori']?.toString() ?? '',
      provinsi: json['provinsi']?.toString() ?? '',
      kota: json['kota']?.toString() ?? '',
      kecamatan: json['kecamatan']?.toString() ?? '',
      kelurahan: json['kelurahan']?.toString() ?? '',
      foto: json['foto']?.toString(), // Foto tetap String?
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
