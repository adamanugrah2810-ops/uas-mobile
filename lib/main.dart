import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wajib untuk async sebelum runApp
  bool loggedIn = await AuthService().isLoggedIn(); // cek login user

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
        primarySwatch: Colors.green,
      ),
      home: loggedIn ? DashboardPage() : LoginPage(),
    );
  }
}
