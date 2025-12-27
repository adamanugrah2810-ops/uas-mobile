class Pengaduan {
  final int id;
  final String judul;
  final String kategori;
  final String status;
  final String createdAt;

  Pengaduan({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.status,
    required this.createdAt,
  });

  factory Pengaduan.fromJson(Map<String, dynamic> json) {
    return Pengaduan(
      id: json['id'],
      judul: json['judul'],
      kategori: json['kategori'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
