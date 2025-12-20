import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        var prefs = snapshot.data as SharedPreferences;
        var name = prefs.getString("user") ?? "Guest";

        return Scaffold(
          appBar: AppBar(title: Text("Home")),
          body: Center(child: Text("Selamat datang, $name!")),
        );
      },
    );
  }
}
