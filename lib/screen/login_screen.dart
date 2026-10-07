import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email/Nomor HP dan password harus diisi',
          ),
        ),
      );
      return;
    }

    // TODO:
    // Hubungkan ke Firebase/API di sini.
  }

  void loginWithGoogle() {
    // TODO:
    // Hubungkan Google Sign-In di sini.
  }

  void register() {
    // TODO:
    // Navigasi ke halaman register.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FBFF),

      body: Stack(
        children: [

          // =====================================================
          // BACKGROUND
          // =====================================================

          const Positioned.fill(
            child: LoginBackground(),
          ),

          // =====================================================
          // CONTENT
          // =====================================================

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const SizedBox(height: 28),

                          // =================================================
                          // LOGO
                          // =================================================

                          Center(
                            child: Image.asset(
                              'assets/images/LautCare_Ocean_Wave_Logo-removebg-preview.png',
                                width: 225,
                                fit: BoxFit.contain,
                              
                            ),
                          ),

                          const SizedBox(height: 43),

                          // =================================================
                          // WELCOME
                          // =================================================

                          const Text(
                            'Selamat datang kembali!',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF154B79),
                              letterSpacing: -0.4,
                            ),
                          ),

                          const SizedBox(height: 7),

                          const Text(
                            'Masuk untuk melanjutkan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF557894),
                            ),
                          ),

                          const SizedBox(height: 43),

                          // =================================================
                          // EMAIL / NOMOR HP
                          // =================================================

                          const Text(
                            'Email atau Nomor HP',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF234C6D),
                            ),
                          ),

                          const SizedBox(height: 9),

                          _LoginTextField(
                            controller: emailController,
                            hintText: 'contoh@email.com',
                            keyboardType:
                                TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                          ),

                          const SizedBox(height: 28),

                          // =================================================
                          // PASSWORD
                          // =================================================

                          const Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF234C6D),
                            ),
                          ),

                          const SizedBox(height: 9),

                          _LoginTextField(
                            controller: passwordController,
                            hintText: 'Masukkan password',
                            obscureText: hidePassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 24,
                                color:
                                    const Color(0xFF527B99),
                              ),
                            ),
                          ),

                          const SizedBox(height: 31),

                          // =================================================
                          // LOGIN BUTTON
                          // =================================================

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF0878D1),
                                foregroundColor: Colors.white,
                                elevation: 1,
                                shadowColor:
                                    const Color(0x330878D1),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // =================================================
                          // REGISTER
                          // =================================================

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: register,
                              child: RichText(
                                text: const TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          'Belum punya akun? ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color(0xFF0878D1),
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Daftar di sini',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.w700,
                                        color:
                                            Color(0xFF006BC5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 55),

                          // =================================================
                          // OR
                          // =================================================

                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Color(0xFFBED8E8),
                                ),
                              ),

                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                                child: Text(
                                  'atau',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: const Color(
                                      0xFF527B99,
                                    ),
                                  ),
                                ),
                              ),

                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Color(0xFFBED8E8),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // =================================================
                          // GOOGLE LOGIN
                          // =================================================

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              onPressed: loginWithGoogle,
                              style: OutlinedButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withOpacity(
                                  0.72,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFBBD9E9),
                                  width: 1.3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [

                                  // Google G
                                  const Text(
                                    'G',
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4285F4),
                                    ),
                                  ),

                                  const SizedBox(width: 13),

                                  const Text(
                                    'Login dengan Google',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.w600,
                                      color:
                                          Color(0xFF234C6D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 175),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


// =============================================================
// TEXT FIELD
// =============================================================

class _LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData prefixIcon;
  final Widget? suffixIcon;

  const _LoginTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF294E6A),
        ),
        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: const TextStyle(
            fontSize: 15,
            color: Color(0xFF91B1C9),
          ),

          prefixIcon: Icon(
            prefixIcon,
            size: 25,
            color: const Color(0xFF527B99),
          ),

          suffixIcon: suffixIcon,

          filled: true,
          fillColor: Colors.white.withOpacity(0.48),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 15,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFBBD9E9),
              width: 1.4,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFBBD9E9),
              width: 1.4,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF0878D1),
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}


// =============================================================
// LOGIN BACKGROUND
// =============================================================

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LoginBackgroundPainter(),
      size: Size.infinite,
    );
  }
}


// =============================================================
// BACKGROUND PAINTER
// =============================================================

class LoginBackgroundPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {

    // =========================================================
    // SKY GRADIENT
    // =========================================================

    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFE9F9FF),
          Color(0xFFF8FDFF),
          Color(0xFFF4FBFF),
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      skyPaint,
    );


    // =========================================================
    // CLOUDS LEFT
    // =========================================================

    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.60);

    _drawCloud(
      canvas,
      cloudPaint,
      Offset(
        -15,
        size.height * 0.28,
      ),
      105,
    );


    // =========================================================
    // CLOUD RIGHT
    // =========================================================

    _drawCloud(
      canvas,
      cloudPaint,
      Offset(
        size.width - 35,
        size.height * 0.34,
      ),
      95,
    );


    // =========================================================
    // SEAGULLS
    // =========================================================

    final birdPaint = Paint()
      ..color = const Color(0xFF73C7F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    _drawBird(
      canvas,
      birdPaint,
      Offset(
        size.width * 0.80,
        size.height * 0.26,
      ),
      25,
    );

    _drawBird(
      canvas,
      birdPaint,
      Offset(
        size.width * 0.73,
        size.height * 0.31,
      ),
      18,
    );


    // =========================================================
    // OCEAN WAVES
    // =========================================================

    final oceanTop =
        size.height * 0.84;


    // Wave 1
    final wave1 = Paint()
      ..color = const Color(0xFFE0F6FF);

    final path1 = Path();

    path1.moveTo(
      0,
      oceanTop + 10,
    );

    path1.cubicTo(
      size.width * 0.20,
      oceanTop - 30,
      size.width * 0.35,
      oceanTop + 50,
      size.width * 0.52,
      oceanTop + 5,
    );

    path1.cubicTo(
      size.width * 0.72,
      oceanTop - 40,
      size.width * 0.85,
      oceanTop + 25,
      size.width,
      oceanTop - 10,
    );

    path1.lineTo(
      size.width,
      size.height,
    );

    path1.lineTo(
      0,
      size.height,
    );

    path1.close();

    canvas.drawPath(
      path1,
      wave1,
    );


    // Wave 2
    final wave2 = Paint()
      ..color = const Color(0xFFB7E9FA);

    final path2 = Path();

    path2.moveTo(
      0,
      oceanTop + 55,
    );

    path2.cubicTo(
      size.width * 0.22,
      oceanTop + 5,
      size.width * 0.38,
      oceanTop + 80,
      size.width * 0.58,
      oceanTop + 35,
    );

    path2.cubicTo(
      size.width * 0.77,
      oceanTop - 5,
      size.width * 0.88,
      oceanTop + 65,
      size.width,
      oceanTop + 25,
    );

    path2.lineTo(
      size.width,
      size.height,
    );

    path2.lineTo(
      0,
      size.height,
    );

    path2.close();

    canvas.drawPath(
      path2,
      wave2,
    );


    // Wave 3
    final wave3 = Paint()
      ..color = const Color(0xFF54C5F0);

    final path3 = Path();

    path3.moveTo(
      0,
      oceanTop + 100,
    );

    path3.cubicTo(
      size.width * 0.20,
      oceanTop + 45,
      size.width * 0.38,
      oceanTop + 125,
      size.width * 0.58,
      oceanTop + 75,
    );

    path3.cubicTo(
      size.width * 0.75,
      oceanTop + 35,
      size.width * 0.88,
      oceanTop + 115,
      size.width,
      oceanTop + 65,
    );

    path3.lineTo(
      size.width,
      size.height,
    );

    path3.lineTo(
      0,
      size.height,
    );

    path3.close();

    canvas.drawPath(
      path3,
      wave3,
    );


    // Wave 4
    final wave4 = Paint()
      ..color = const Color(0xFF087FD7);

    final path4 = Path();

    path4.moveTo(
      0,
      oceanTop + 145,
    );

    path4.cubicTo(
      size.width * 0.22,
      oceanTop + 85,
      size.width * 0.42,
      oceanTop + 170,
      size.width * 0.62,
      oceanTop + 115,
    );

    path4.cubicTo(
      size.width * 0.78,
      oceanTop + 75,
      size.width * 0.90,
      oceanTop + 155,
      size.width,
      oceanTop + 105,
    );

    path4.lineTo(
      size.width,
      size.height,
    );

    path4.lineTo(
      0,
      size.height,
    );

    path4.close();

    canvas.drawPath(
      path4,
      wave4,
    );


    // Wave 5 - dark bottom
    final wave5 = Paint()
      ..color = const Color(0xFF0562B8);

    final path5 = Path();

    path5.moveTo(
      0,
      oceanTop + 195,
    );

    path5.cubicTo(
      size.width * 0.25,
      oceanTop + 145,
      size.width * 0.40,
      oceanTop + 215,
      size.width * 0.62,
      oceanTop + 165,
    );

    path5.cubicTo(
      size.width * 0.80,
      oceanTop + 125,
      size.width * 0.90,
      oceanTop + 205,
      size.width,
      oceanTop + 150,
    );

    path5.lineTo(
      size.width,
      size.height,
    );

    path5.lineTo(
      0,
      size.height,
    );

    path5.close();

    canvas.drawPath(
      path5,
      wave5,
    );


    // =========================================================
    // SMALL WATER BUBBLES
    // =========================================================

    final bubblePaint = Paint()
      ..color = const Color(0xFF63C8F0).withOpacity(0.65);

    canvas.drawCircle(
      Offset(
        size.width * 0.09,
        size.height * 0.94,
      ),
      4,
      bubblePaint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.13,
        size.height * 0.96,
      ),
      6,
      bubblePaint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.17,
        size.height * 0.925,
      ),
      3,
      bubblePaint,
    );
  }


  // ===========================================================
  // CLOUD
  // ===========================================================

  void _drawCloud(
    Canvas canvas,
    Paint paint,
    Offset position,
    double width,
  ) {
    final path = Path();

    path.moveTo(
      position.dx,
      position.dy + 45,
    );

    path.quadraticBezierTo(
      position.dx + width * 0.12,
      position.dy + 5,
      position.dx + width * 0.32,
      position.dy + 30,
    );

    path.quadraticBezierTo(
      position.dx + width * 0.40,
      position.dy - 15,
      position.dx + width * 0.60,
      position.dy + 20,
    );

    path.quadraticBezierTo(
      position.dx + width * 0.75,
      position.dy - 5,
      position.dx + width * 0.86,
      position.dy + 30,
    );

    path.quadraticBezierTo(
      position.dx + width,
      position.dy + 30,
      position.dx + width,
      position.dy + 55,
    );

    path.lineTo(
      position.dx,
      position.dy + 55,
    );

    path.close();

    canvas.drawPath(
      path,
      paint,
    );
  }


  // ===========================================================
  // BIRD
  // ===========================================================

  void _drawBird(
    Canvas canvas,
    Paint paint,
    Offset position,
    double width,
  ) {
    final path = Path();

    path.moveTo(
      position.dx,
      position.dy,
    );

    path.quadraticBezierTo(
      position.dx + width * 0.25,
      position.dy - width * 0.20,
      position.dx + width * 0.50,
      position.dy,
    );

    path.quadraticBezierTo(
      position.dx + width * 0.75,
      position.dy - width * 0.20,
      position.dx + width,
      position.dy,
    );

    canvas.drawPath(
      path,
      paint,
    );
  }


  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}