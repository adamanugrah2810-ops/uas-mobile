import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PengaduanService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// ===============================
  /// KIRIM PENGADUAN (MULTIPART)
  /// ===============================
  static Future<Map<String, dynamic>> kirimPengaduan({
    required String token,
    required String judul,
    required String deskripsi,
    required String kategori,
    required String provinsi, // Provinsi
    required String kota, // ✅ TAMBAHAN
    required String kecamatan,
    required String kelurahan,
    File? foto,
  }) async {
    final uri = Uri.parse('$baseUrl/pengaduan');
    final request = http.MultipartRequest('POST', uri);

    /// Header Auth (Laravel Sanctum)
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    /// Field text (sinkron backend)
    request.fields.addAll({
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'provinsi': provinsi,
      'kota': kota, // ✅
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
    });

    /// Upload foto (optional)
    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          foto.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    /// Send request
    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    final decoded = jsonDecode(responseBody);

    if (streamedResponse.statusCode == 201 ||
        streamedResponse.statusCode == 200) {
      return {
        'success': true,
        'message': decoded['message'] ?? 'Pengaduan berhasil dikirim',
        'data': decoded['data'],
      };
    } else {
      return {
        'success': false,
        'message': decoded['message'] ?? 'Gagal mengirim pengaduan',
        'errors': decoded['errors'],
      };
    }
  }

  /// ===============================
  /// AMBIL PENGADUAN SAYA
  /// ===============================
  static Future<List<dynamic>> getPengaduanSaya({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pengaduan-saya'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return decoded['data'];
    } else {
      throw Exception(decoded['message'] ?? 'Gagal mengambil data');
    }
  }
}
