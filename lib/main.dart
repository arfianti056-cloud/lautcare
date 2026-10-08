import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

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
        // Sementara placeholder, nanti diganti halaman Login dari teman satu tim
        '/login': (_) => const Scaffold(
              body: Center(child: Text('Halaman Login (belum dibuat)')),
            ),
      },
    );
  }
}