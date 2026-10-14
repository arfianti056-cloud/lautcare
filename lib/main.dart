import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'pelapor/beranda_screen.dart';
import 'pelapor/buat_laporan/laporan_screen.dart';

void main() {
  runApp(const LautCareApp());
}

class LautCareApp extends StatelessWidget {
  const LautCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LautCare',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
      ),

      initialRoute: '/',

      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/beranda': (_) => const BerandaScreen(),
        '/laporan': (context) => const LaporanScreen(),
      },
    );
  }
}
