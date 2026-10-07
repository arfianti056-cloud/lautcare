import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ============================================================
/// SPLASH SCREEN - LautCare
/// "Jaga Laut, Jaga Masa Depan"
/// Letakkan di: lib/screens/splash_screen.dart
/// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introCtrl;
  late final AnimationController _waveCtrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _textSlide;
  Timer? _timer;

  static const Color kBlue = Color(0xFF1565C0);

  @override
  void initState() {
    super.initState();

    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _fade = CurvedAnimation(parent: _introCtrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutBack),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _introCtrl,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    // Pindah ke halaman Login setelah 3 detik
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _introCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Latar belakang pemandangan laut
          AnimatedBuilder(
            animation: _waveCtrl,
            builder: (_, __) => CustomPaint(
              painter: _SceneryPainter(_waveCtrl.value),
            ),
          ),

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
                    SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: const [
                          Text(
                            'LautCare',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: kBlue,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
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

/// ============================================================
/// LOGO: lingkaran biru dengan gelombang putih
/// ============================================================
class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final circle = Rect.fromLTWH(0, 0, w, h);

    canvas.save();
    canvas.clipPath(Path()..addOval(circle));

    // Dasar lingkaran (biru tua -> biru terang)
    canvas.drawRect(
      circle,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        ).createShader(circle),
    );

    // Swoosh putih besar (lengkung atas)
    final white = Path()
      ..moveTo(w * 0.05, h * 0.45)
      ..cubicTo(w * 0.30, h * 0.18, w * 0.78, h * 0.10, w * 1.0, h * 0.42)
      ..cubicTo(w * 0.80, h * 0.36, w * 0.50, h * 0.40, w * 0.38, h * 0.58)
      ..cubicTo(w * 0.28, h * 0.72, w * 0.50, h * 0.80, w * 0.70, h * 0.70)
      ..cubicTo(w * 0.45, h * 0.92, w * 0.10, h * 0.78, w * 0.05, h * 0.45)
      ..close();
    canvas.drawPath(white, Paint()..color = Colors.white);

    // Gelombang biru muda di bawah
    final wave1 = Path()
      ..moveTo(0, h * 0.72)
      ..cubicTo(w * 0.25, h * 0.60, w * 0.50, h * 0.88, w, h * 0.66)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(wave1, Paint()..color = const Color(0xFF42A5F5));

    final wave2 = Path()
      ..moveTo(0, h * 0.82)
      ..cubicTo(w * 0.30, h * 0.72, w * 0.60, h * 0.96, w, h * 0.78)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(wave2, Paint()..color = const Color(0xFF1E88E5));

    // Garis putih tipis gelombang
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.08, h * 0.78)
        ..cubicTo(w * 0.30, h * 0.68, w * 0.55, h * 0.90, w * 0.95, h * 0.72),
      Paint()
        ..color = Colors.white.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ============================================================
/// LATAR: langit, awan, bukit, laut, kapal, dedaunan
/// ============================================================
class _SceneryPainter extends CustomPainter {
  final double t; // 0..1 untuk animasi gelombang
  _SceneryPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final full = Rect.fromLTWH(0, 0, w, h);

    // ---------- LANGIT ----------
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB9DDF5),
            Color(0xFFDCEEFA),
            Color(0xFFF4FAFE),
          ],
          stops: [0.0, 0.45, 0.72],
        ).createShader(full),
    );

    // ---------- AWAN ----------
    _cloud(canvas, Offset(w * 0.22, h * 0.585), w * 0.14, 0.75);
    _cloud(canvas, Offset(w * 0.62, h * 0.605), w * 0.20, 0.65);
    _cloud(canvas, Offset(w * 0.80, h * 0.545), w * 0.10, 0.55);
    _cloud(canvas, Offset(w * 0.15, h * 0.10), w * 0.12, 0.35);
    _cloud(canvas, Offset(w * 0.85, h * 0.20), w * 0.12, 0.30);

    // ---------- BUKIT KIRI ----------
    final hillL = Path()
      ..moveTo(0, h * 0.73)
      ..lineTo(0, h * 0.66)
      ..cubicTo(w * 0.05, h * 0.645, w * 0.12, h * 0.655, w * 0.17, h * 0.665)
      ..cubicTo(w * 0.24, h * 0.675, w * 0.36, h * 0.70, w * 0.42, h * 0.73)
      ..close();
    canvas.drawPath(hillL, Paint()..color = const Color(0xFF6FAE86));
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.73)
        ..cubicTo(w * 0.05, h * 0.69, w * 0.12, h * 0.69, w * 0.20, h * 0.73)
        ..close(),
      Paint()..color = const Color(0xFF4F9770),
    );

    // ---------- BUKIT KANAN (lebih tinggi) ----------
    final hillR = Path()
      ..moveTo(w * 0.55, h * 0.73)
      ..cubicTo(w * 0.62, h * 0.70, w * 0.70, h * 0.64, w * 0.78, h * 0.625)
      ..cubicTo(w * 0.86, h * 0.605, w * 0.94, h * 0.60, w, h * 0.615)
      ..lineTo(w, h * 0.73)
      ..close();
    canvas.drawPath(hillR, Paint()..color = const Color(0xFF5BA37C));
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.70, h * 0.73)
        ..cubicTo(w * 0.78, h * 0.67, w * 0.90, h * 0.66, w, h * 0.69)
        ..lineTo(w, h * 0.73)
        ..close(),
      Paint()..color = const Color(0xFF3F8C63),
    );

    // ---------- LAUT ----------
    final seaTop = h * 0.72;
    final seaRect = Rect.fromLTWH(0, seaTop, w, h - seaTop);
    canvas.drawRect(
      seaRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF39A5E6), Color(0xFF1E88E5), Color(0xFF1565C0)],
        ).createShader(seaRect),
    );

    // Garis-garis ombak bergerak
    for (int i = 0; i < 7; i++) {
      final y = seaTop + (h * 0.028) * (i + 1) + i * h * 0.006;
      final amp = 4.0 + i * 1.2;
      final phase = (t * 2 * math.pi) + i * 0.9;
      final p = Path()..moveTo(0, y);
      for (double x = 0; x <= w; x += 4) {
        p.lineTo(x, y + math.sin((x / w) * 4 * math.pi + phase) * amp);
      }
      canvas.drawPath(
        p,
        Paint()
          ..color = Colors.white.withOpacity(i.isEven ? 0.28 : 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6 + (i % 2),
      );
    }

    // ---------- KAPAL ----------
    final bob = math.sin(t * 2 * math.pi) * 2.5;
    _ship(canvas, Offset(w * 0.46, h * 0.775 + bob), w * 0.20);

    // ---------- DEDAUNAN BAWAH ----------
    _foliage(canvas, size);
  }

  void _cloud(Canvas c, Offset o, double r, double opacity) {
    final p = Paint()..color = Colors.white.withOpacity(opacity);
    c.drawOval(Rect.fromCenter(center: o, width: r * 2.4, height: r * 0.7), p);
    c.drawCircle(o + Offset(-r * 0.4, -r * 0.20), r * 0.38, p);
    c.drawCircle(o + Offset(r * 0.15, -r * 0.30), r * 0.48, p);
    c.drawCircle(o + Offset(r * 0.60, -r * 0.12), r * 0.32, p);
  }

  void _ship(Canvas c, Offset o, double s) {
    // Badan kapal
    final hull = Path()
      ..moveTo(o.dx - s * 0.5, o.dy)
      ..lineTo(o.dx + s * 0.55, o.dy)
      ..lineTo(o.dx + s * 0.40, o.dy + s * 0.16)
      ..lineTo(o.dx - s * 0.38, o.dy + s * 0.16)
      ..close();
    c.drawPath(hull, Paint()..color = const Color(0xFF37474F));

    // Garis merah
    c.drawRect(
      Rect.fromLTWH(o.dx - s * 0.48, o.dy, s * 1.02, s * 0.035),
      Paint()..color = const Color(0xFFD32F2F),
    );

    // Dek putih
    c.drawRect(
      Rect.fromLTWH(o.dx - s * 0.25, o.dy - s * 0.14, s * 0.55, s * 0.14),
      Paint()..color = Colors.white,
    );
    // Anjungan
    c.drawRect(
      Rect.fromLTWH(o.dx - s * 0.05, o.dy - s * 0.30, s * 0.24, s * 0.16),
      Paint()..color = const Color(0xFFECEFF1),
    );
    // Jendela
    c.drawRect(
      Rect.fromLTWH(o.dx, o.dy - s * 0.26, s * 0.14, s * 0.05),
      Paint()..color = const Color(0xFF455A64),
    );
    // Cerobong merah
    c.drawRect(
      Rect.fromLTWH(o.dx - s * 0.18, o.dy - s * 0.26, s * 0.07, s * 0.12),
      Paint()..color = const Color(0xFFD32F2F),
    );
    // Tiang
    c.drawRect(
      Rect.fromLTWH(o.dx + s * 0.06, o.dy - s * 0.40, s * 0.012, s * 0.10),
      Paint()..color = const Color(0xFF455A64),
    );
    // Riak di bawah kapal
    c.drawOval(
      Rect.fromCenter(
        center: Offset(o.dx + s * 0.05, o.dy + s * 0.19),
        width: s * 1.1,
        height: s * 0.07,
      ),
      Paint()..color = Colors.white.withOpacity(0.45),
    );
  }

  void _foliage(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Lapisan belakang (hijau tua kebiruan)
    final back = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.90)
      ..cubicTo(w * 0.08, h * 0.87, w * 0.14, h * 0.93, w * 0.22, h * 0.90)
      ..cubicTo(w * 0.30, h * 0.88, w * 0.36, h * 0.95, w * 0.46, h * 0.94)
      ..cubicTo(w * 0.60, h * 0.92, w * 0.70, h * 0.96, w * 0.80, h * 0.93)
      ..cubicTo(w * 0.90, h * 0.90, w * 0.95, h * 0.92, w, h * 0.89)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFF1F6B4F));

    // Pohon-pohon bulat
    final rnd = math.Random(7);
    final colors = [
      const Color(0xFF14573F),
      const Color(0xFF1B6B4A),
      const Color(0xFF247A55),
      const Color(0xFF0E4A38),
    ];
    for (int i = 0; i < 26; i++) {
      final x = (i / 25) * w;
      final baseY = h * (0.935 + rnd.nextDouble() * 0.045);
      final r = w * (0.035 + rnd.nextDouble() * 0.03);
      final paint = Paint()..color = colors[rnd.nextInt(colors.length)];
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(x, baseY), width: r * 1.6, height: r * 2.2),
        paint,
      );
    }

    // Pohon tinggi di sisi kiri & kanan
    void tree(double x, double top, double width, Color col) {
      final p = Path()
        ..moveTo(x, top)
        ..quadraticBezierTo(x + width, top + (h - top) * 0.35, x + width * 1.1, h)
        ..lineTo(x - width * 1.1, h)
        ..quadraticBezierTo(x - width, top + (h - top) * 0.35, x, top)
        ..close();
      canvas.drawPath(p, Paint()..color = col);
    }

    tree(w * 0.04, h * 0.865, w * 0.05, const Color(0xFF1B6B4A));
    tree(w * 0.13, h * 0.895, w * 0.045, const Color(0xFF14573F));
    tree(w * 0.20, h * 0.915, w * 0.04, const Color(0xFF247A55));
    tree(w * 0.93, h * 0.88, w * 0.05, const Color(0xFF1B6B4A));
    tree(w * 0.84, h * 0.905, w * 0.045, const Color(0xFF14573F));
    tree(w * 0.76, h * 0.925, w * 0.04, const Color(0xFF247A55));

    // Bagian paling bawah
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.975, w, h * 0.025),
      Paint()..color = const Color(0xFF0E4A38),
    );
  }

  @override
  bool shouldRepaint(covariant _SceneryPainter old) => old.t != t;
}