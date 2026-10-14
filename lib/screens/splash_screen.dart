import 'dart:async';

import 'package:flutter/material.dart';

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
    _timer = Timer(const Duration(seconds: 6), () {
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
    const putih = TextStyle(color: Colors.white, fontWeight: FontWeight.w700);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Foto pantai, digelapkan sedikit agar tulisan terbaca
          Image.asset(
            'assets/images/splash.jpeg',
            fit: BoxFit.cover,
            color: Colors.black38,
            colorBlendMode: BlendMode.darken,
          ),
          Align(
            alignment: const Alignment(0, -0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
                const SizedBox(height: 16),
                Text('LautCare', style: putih.copyWith(fontSize: 34)),
                const SizedBox(height: 6),
                Text(
                  'Jaga Laut, Jaga Masa Depan',
                  style: putih.copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
