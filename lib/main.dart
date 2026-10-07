import 'package:flutter/material.dart';
import 'screen/login_screen.dart';

void main() {
  runApp(const LautCareApp());
}

class LautCareApp extends StatelessWidget {
  const LautCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LautCare',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4FBFF),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}