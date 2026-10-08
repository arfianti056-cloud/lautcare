import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// SPLASH SCREEN - LautCare 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Ubah durasi splash di sini (contoh: Duration(minutes: 2))
  static const Duration kSplashDuration = Duration(minutes: 1);
  static const Color kBlue = Color(0xFF1565C0);

  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Animasi masuk logo & teks (sekali jalan)
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    // Pindah ke Login setelah durasi selesai
    _timer = Timer(kSplashDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Latar pemandangan (diam)
          const CustomPaint(painter: _SceneryPainter()),

          // Logo + nama + slogan
          SafeArea(
            child: Align(
              alignment: const Alignment(0, -0.38),
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: const SizedBox(
                        width: 130,
                        height: 130,
                        child: CustomPaint(painter: _LogoPainter()),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'LautCare',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: kBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Peduli Laut, Mulai dari Kita',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: kBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// LOGO: lingkaran biru dengan gelombang putih
class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Rect.fromLTWH(0, 0, w, h);

    canvas.save();
    canvas.clipPath(Path()..addOval(rect));

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        ).createShader(rect),
    );

    // Swoosh putih
    final white = Path()
      ..moveTo(w * 0.05, h * 0.45)
      ..cubicTo(w * 0.30, h * 0.18, w * 0.78, h * 0.10, w, h * 0.42)
      ..cubicTo(w * 0.80, h * 0.36, w * 0.50, h * 0.40, w * 0.38, h * 0.58)
      ..cubicTo(w * 0.28, h * 0.72, w * 0.50, h * 0.80, w * 0.70, h * 0.70)
      ..cubicTo(w * 0.45, h * 0.92, w * 0.10, h * 0.78, w * 0.05, h * 0.45)
      ..close();
    canvas.drawPath(white, Paint()..color = Colors.white);

    // Dua lapis gelombang biru di bawah
    for (final wv in [
      [0.72, 0.60, 0.88, 0.66, 0xFF42A5F5],
      [0.82, 0.72, 0.96, 0.78, 0xFF1E88E5],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(0, h * wv[0])
          ..cubicTo(w * 0.3, h * wv[1], w * 0.6, h * wv[2], w, h * wv[3])
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close(),
        Paint()..color = Color(wv[4].toInt()),
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// LATAR: langit, awan, bukit, laut, kapal, dedaunan (semua diam)
class _SceneryPainter extends CustomPainter {
  const _SceneryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final full = Rect.fromLTWH(0, 0, w, h);

    // Langit
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB9DDF5), Color(0xFFDCEEFA), Color(0xFFF4FAFE)],
          stops: [0.0, 0.45, 0.72],
        ).createShader(full),
    );

    // Awan
    _cloud(canvas, Offset(w * 0.22, h * 0.585), w * 0.14, 0.75);
    _cloud(canvas, Offset(w * 0.62, h * 0.605), w * 0.20, 0.65);
    _cloud(canvas, Offset(w * 0.15, h * 0.10), w * 0.12, 0.35);
    _cloud(canvas, Offset(w * 0.85, h * 0.20), w * 0.12, 0.30);

    // Bukit kiri & kanan
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.73)
        ..lineTo(0, h * 0.66)
        ..cubicTo(w * 0.10, h * 0.64, w * 0.30, h * 0.69, w * 0.42, h * 0.73)
        ..close(),
      Paint()..color = const Color(0xFF6FAE86),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.55, h * 0.73)
        ..cubicTo(w * 0.65, h * 0.69, w * 0.78, h * 0.60, w, h * 0.615)
        ..lineTo(w, h * 0.73)
        ..close(),
      Paint()..color = const Color(0xFF5BA37C),
    );

    // Laut
    final seaTop = h * 0.72;
    final sea = Rect.fromLTWH(0, seaTop, w, h - seaTop);
    canvas.drawRect(
      sea,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF39A5E6), Color(0xFF1E88E5), Color(0xFF1565C0)],
        ).createShader(sea),
    );

    // Garis ombak (statis)
    for (int i = 1; i <= 6; i++) {
      final y = seaTop + h * 0.032 * i;
      final p = Path()..moveTo(0, y);
      for (double x = 0; x <= w; x += 4) {
        p.lineTo(x, y + math.sin((x / w) * 4 * math.pi + i) * 4);
      }
      canvas.drawPath(
        p,
        Paint()
          ..color = Colors.white.withOpacity(i.isEven ? 0.28 : 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Kapal
    _ship(canvas, Offset(w * 0.46, h * 0.775), w * 0.20);

    // Dedaunan
    final rnd = math.Random(7);
    const greens = [
      Color(0xFF14573F),
      Color(0xFF1B6B4A),
      Color(0xFF247A55),
      Color(0xFF0E4A38),
    ];
    for (int i = 0; i < 26; i++) {
      final r = w * (0.035 + rnd.nextDouble() * 0.03);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset((i / 25) * w, h * (0.935 + rnd.nextDouble() * 0.045)),
          width: r * 1.6,
          height: r * 2.2,
        ),
        Paint()..color = greens[rnd.nextInt(greens.length)],
      );
    }
  }

  void _cloud(Canvas c, Offset o, double r, double opacity) {
    final p = Paint()..color = Colors.white.withOpacity(opacity);
    c.drawOval(Rect.fromCenter(center: o, width: r * 2.4, height: r * 0.7), p);
    c.drawCircle(o + Offset(-r * 0.4, -r * 0.2), r * 0.38, p);
    c.drawCircle(o + Offset(r * 0.15, -r * 0.3), r * 0.48, p);
    c.drawCircle(o + Offset(r * 0.6, -r * 0.12), r * 0.32, p);
  }

  void _ship(Canvas c, Offset o, double s) {
    void box(double dx, double dy, double bw, double bh, Color col) =>
        c.drawRect(Rect.fromLTWH(o.dx + dx * s, o.dy + dy * s, bw * s, bh * s),
            Paint()..color = col);

    // Badan kapal
    c.drawPath(
      Path()
        ..moveTo(o.dx - s * 0.5, o.dy)
        ..lineTo(o.dx + s * 0.55, o.dy)
        ..lineTo(o.dx + s * 0.40, o.dy + s * 0.16)
        ..lineTo(o.dx - s * 0.38, o.dy + s * 0.16)
        ..close(),
      Paint()..color = const Color(0xFF37474F),
    );
    box(-0.48, 0, 1.02, 0.035, const Color(0xFFD32F2F)); // garis merah
    box(-0.25, -0.14, 0.55, 0.14, Colors.white); // dek
    box(-0.05, -0.30, 0.24, 0.16, const Color(0xFFECEFF1)); // anjungan
    box(0, -0.26, 0.14, 0.05, const Color(0xFF455A64)); // jendela
    box(-0.18, -0.26, 0.07, 0.12, const Color(0xFFD32F2F)); // cerobong
    box(0.06, -0.40, 0.012, 0.10, const Color(0xFF455A64)); // tiang
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}