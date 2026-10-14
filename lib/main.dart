import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'pelapor/beranda_screen.dart';
import 'riwayat/riwayat_screen.dart';
import 'profile/profile_screen.dart';

void main() {
  runApp(const LautCareApp());
}

class LautCareApp extends StatelessWidget {
  const LautCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LAUTCARE',

      // Aplikasi dimulai dari Splash Screen
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/beranda': (context) => const BerandaScreen(),
        '/riwayat': (context) => const RiwayatScreen(),
        '/profil': (context) => const ProfilScreen(),
      },
    );
  }
}
