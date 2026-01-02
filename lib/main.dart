import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'services/auth_service.dart';
import 'dart:io'; // Tambahkan import ini

// 1. Tambahkan class ini di luar fungsi main
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Aktifkan HttpOverrides sebelum mengecek login atau menjalankan app
  HttpOverrides.global = MyHttpOverrides();

  bool loggedIn = await AuthService().isLoggedIn();

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({Key? key, required this.loggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Layanan Pengaduan Banten',
      theme: ThemeData(
        primaryColor:
            const Color(0xFF0A58ED), // Sesuaikan dengan tema luxury Anda
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A58ED)),
      ),
      home: loggedIn ? const DashboardPage() : const LoginPage(),
    );
  }
}
