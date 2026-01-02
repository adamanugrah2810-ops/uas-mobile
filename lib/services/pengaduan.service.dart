import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobile_auth/models/pengaduan.model.dart';

class PengaduanService {
  /// BASE URL (WAJIB STATIC)
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // static const String baseUrl = 'http://127.0.0.1:8000/api';
  // static const String baseUrl = 'https://backend-mobile.projecttkuuu.my.id/api';

  /// ===============================
  /// KIRIM PENGADUAN (MULTIPART)
  /// ===============================
  static Future<Map<String, dynamic>> kirimPengaduan({
    required String token,
    required String judul,
    required String deskripsi,
    required String kategori,
    required String provinsi,
    required String kota,
    required String kecamatan,
    required String kelurahan,
    File? foto,
  }) async {
    final uri = Uri.parse('$baseUrl/pengaduan');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields.addAll({
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'provinsi': provinsi,
      'kota': kota,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
    });

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
  static Future<List<Pengaduan>> getPengaduanSaya({
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
      return (decoded['data'] as List)
          .map((e) => Pengaduan.fromJson(e))
          .toList();
    } else {
      throw Exception(decoded['message'] ?? 'Gagal mengambil data');
    }
  }

  /// ===============================
  /// UPDATE PENGADUAN
  /// ===============================
  static Future<Map<String, dynamic>> updatePengaduan({
    required String token,
    required int id,
    required String judul,
    required String deskripsi,
    required String kategori,
    required String provinsi,
    required String kota,
    required String kecamatan,
    required String kelurahan,
    File? foto,
  }) async {
    final uri = Uri.parse('$baseUrl/pengaduan-update/$id');
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields.addAll({
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'provinsi': provinsi,
      'kota': kota,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
    });

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

    if (streamedResponse.statusCode == 200) {
      return {
        'success': true,
        'message': decoded['message'] ?? 'Pengaduan berhasil diperbarui',
        'data': decoded['data'],
      };
    } else {
      return {
        'success': false,
        'message': decoded['message'] ?? 'Gagal memperbarui pengaduan',
        'errors': decoded['errors'],
      };
    }
  }

  /// ===============================
  /// HAPUS PENGADUAN
  /// ===============================
  static Future<void> deletePengaduan({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/pengaduan/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus pengaduan');
    }
  }
}
