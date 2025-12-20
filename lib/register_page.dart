import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/auth_service.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;
  bool obscurePass = true;

  Future register() async {
    FocusScope.of(context).unfocus();
    setState(() => loading = true);

    var res = await AuthService().register(
        nameController.text, emailController.text, passwordController.text);

    print("Register Response: $res");

    if (res["success"] == true) {
      // Simpan user langsung jika mau auto-login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("user", res["data"]["name"]);

      // Navigate ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["message"]),
          backgroundColor: Colors.redAccent,
        ),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nama"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: obscurePass,
                decoration: InputDecoration(
                  labelText: "Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscurePass ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() => obscurePass = !obscurePass);
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: loading ? null : register,
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Daftar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
