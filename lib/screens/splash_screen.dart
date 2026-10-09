import 'dart:async';
import 'package:flutter/material.dart';

/// SPLASH SCREEN - LautCare
/// Letakkan di: lib/screens/splash_screen.dart

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    return Scaffold(
      body: SizedBox.expand(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 1),
          builder: (_, nilai, child) => Opacity(opacity: nilai, child: child),
          child: Image.asset(
            'assets/images/splash.png',
            fit: BoxFit.fill, // Memaksa gambar ditarik pas memenuhi layar HP
          ),
        ),
      ),
    );
  }
}