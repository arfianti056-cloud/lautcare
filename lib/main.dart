import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'admin/dasboard_admin_screen.dart';
import 'pelapor/beranda_screen.dart';
import 'riwayat/riwayat_screen.dart';
import 'pelapor/buat_laporan/laporan_screen.dart';
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
      initialRoute: '/',

      // Daftar halaman aplikasi
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/beranda': (context) => const BerandaScreen(),
        '/laporan': (context) => const LaporanScreen(),
        '/riwayat': (context) => const RiwayatScreen(),
        '/profil': (context) => const ProfilScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/admin') {
          final args = settings.arguments;

          if (args is! Map ||
              args['token'] is! String ||
              (args['token'] as String).isEmpty) {
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          }

          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DashboardAdmin(token: args['token'] as String),
          );
        }

        return null;
      },
    );
  }
}
