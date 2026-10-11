import 'dart:async';
import 'package:flutter/material.dart';

/// SPLASH SCREEN - LautCare (latar foto pantai)
/// Letakkan di: lib/screens/splash_screen.dart
/// Foto latar : assets/images/splash.jpeg
/// Logo       : assets/images/LautCare_Ocean_Wave_Logo-removebg-preview.png (sudah terdaftar)

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Ubah durasi splash di sini
  static const Duration kSplashDuration = Duration(seconds: 6);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(kSplashDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bayangan tipis agar tulisan putih tetap terbaca di atas foto
    const bayangan = [Shadow(color: Color(0xAA000000), blurRadius: 8)];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Foto pantai sebagai latar
          Image.asset('assets/images/splash.jpeg', fit: BoxFit.cover),

          // 2. Lapisan gelap tipis agar tulisan putih terbaca
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Color(0x44000000), Color(0x88000000)],
              ),
            ),
          ),

          // 3. Logo + nama + slogan (ukuran tetap, posisi agak ke atas)
          Align(
            alignment: const Alignment(0, -0.3),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              builder: (_, nilai, child) => Opacity(opacity: nilai, child: child),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/LautCare_Ocean_Wave_Logo-removebg-preview.png',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LautCare',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: bayangan,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Jaga Laut, Jaga Masa Depan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: bayangan,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}