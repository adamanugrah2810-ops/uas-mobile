import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_auth/pages/login_page.dart';

void main() {
  testWidgets('LoginPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(),
      ),
    );

    // Cek jika field Email ada
    expect(find.byType(TextField), findsNWidgets(2)); // email + password

    // Cek jika tombol Login ada
    expect(find.text('Login'), findsOneWidget);

    // Cek tombol Register ada
    expect(find.text('Belum punya akun? Register'), findsOneWidget);
  });
}
