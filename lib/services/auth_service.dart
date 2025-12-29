import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://backend-mobile.projecttkuuu.my.id/api';
  // final String baseUrl = 'https://10.0.2.2:8000/api';
  // static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// =========================
  /// LOGIN
  /// =========================
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "email": email,
          "password": password,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', data['token']);

        await prefs.setString('userName', data['data']['name']);
        await prefs.setString('userEmail', data['data']['email']);
      } else {
        await logout(); // bersihkan token jika gagal
      }

      return data;
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  /// =========================
  /// REGISTER
  /// =========================
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "name": name,
          "email": email,
          "password": password,
        },
      );

      final data = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool('isLoggedIn', true);

        // 🔴 WAJIB: SIMPAN TOKEN
        await prefs.setString('token', data['token']);

        await prefs.setString('userName', data['data']['name']);
        await prefs.setString('userEmail', data['data']['email']);
      }

      return data;
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  /// =========================
  /// LOGOUT
  /// =========================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// =========================
  /// GET TOKEN (PENTING)
  /// =========================
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  /// =========================
  /// CEK LOGIN
  /// =========================
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
