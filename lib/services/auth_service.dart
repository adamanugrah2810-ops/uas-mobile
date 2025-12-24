import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Gunakan 10.0.2.2 untuk emulator Android ke localhost PC
  final String baseUrl = 'http://10.0.2.2:8000/api';

  /// LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      var response = await http.post(
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

      var data = jsonDecode(response.body);

      // Jika login berhasil
      if (response.statusCode == 200 && data["success"] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Simpan status login
        await prefs.setBool("isLoggedIn", true);

        // PENTING: Key harus "userName" agar terbaca di HomePage
        // Pastikan struktur response API Anda adalah data["data"]["name"]
        await prefs.setString("userName", data["data"]["name"].toString());
        await prefs.setString("userEmail", data["data"]["email"].toString());
      }

      return data;
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  /// REGISTER
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      var response = await http.post(
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

      var data = jsonDecode(response.body);

      // Jika register berhasil (biasanya status 201 atau 200)
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data["success"] == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        await prefs.setBool("isLoggedIn", true);
        // Samakan key dengan yang di atas
        await prefs.setString("userName", data["data"]["name"].toString());
        await prefs.setString("userEmail", data["data"]["email"].toString());
      }

      return data;
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Menghapus semua data sesi
    await prefs.clear();
  }

  /// CEK STATUS LOGIN
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Cek apakah key isLoggedIn ada dan bernilai true
    return prefs.getBool("isLoggedIn") ?? false;
  }
}
