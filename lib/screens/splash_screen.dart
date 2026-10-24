import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 8), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background foto pantai
          Image.asset(
            'assets/images/splash.jpeg',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),

          // Gradasi biru agar tulisan tetap jelas
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF003B5C)
                      .withValues(alpha: 0.20),
                  const Color(0xFF003B5C)
                      .withValues(alpha: 0.10),
                  const Color(0xFF002B45)
                      .withValues(alpha: 0.55),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),

          // Konten utama splash screen
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 4),

                // Logo asli LautCare tanpa lingkaran putih
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),

                const SizedBox(height: 20),

                // Nama aplikasi
                const Text(
                  'LautCare',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Color(0x66000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Tagline LautCare
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: Text(
                    'Jaga Laut, Jaga Masa Depan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Color(0x66000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
