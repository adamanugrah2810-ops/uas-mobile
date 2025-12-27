import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PengaduanService {
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// Kirim pengaduan (multipart)
  static Future<Map<String, dynamic>> kirimPengaduan({
    required String token,
    required String judul,
    required String deskripsi,
    required String kategori,
    required String wilayah,
    required String kecamatan,
    required String desa,
    required String latitude,
    required String longitude,
    File? foto,
  }) async {
    final uri = Uri.parse('$baseUrl/pengaduan');

    final request = http.MultipartRequest('POST', uri);

    /// Header autentikasi Sanctum
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    /// Field text
    request.fields.addAll({
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'wilayah': wilayah,
      'kecamatan': kecamatan,
      'desa': desa,
      'latitude': latitude,
      'longitude': longitude,
    });

    /// File upload (1 foto sesuai backend)
    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          foto.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    final decoded = jsonDecode(responseBody);

    if (streamedResponse.statusCode == 201) {
      return {
        'success': true,
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

  /// Ambil pengaduan milik user
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
