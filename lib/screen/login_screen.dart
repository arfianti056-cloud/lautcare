import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

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
          content: Text('Email/Nomor HP dan password harus diisi'),
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, '/beranda');
  }

  void register() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: LoginBackgroundPainter()),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =================================================
                  // LOGO + NAMA LAUTCARE
                  // =================================================

                  Row(
                    children: [
                      Image.asset(
                        'assets/images/LautCare_Ocean_Wave_Logo-removebg-preview.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'LautCare',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0878D1),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =================================================
                  // WELCOME
                  // =================================================
                  const Text(
                    'Selamat datang kembali',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF154B79),
                    ),
                  ),

                  const SizedBox(height: 3),

                  const Text(
                    'Masuk untuk melanjutkan',
                    style: TextStyle(fontSize: 11, color: Color(0xFF557894)),
                  ),

                  const SizedBox(height: 25),

                  // =================================================
                  // EMAIL / NOMOR HP
                  // =================================================
                  const Text(
                    'Email atau Nomor HP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF234C6D),
                    ),
                  ),

                  const SizedBox(height: 6),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'contoh@email.com',
                      hintStyle: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFB0BEC5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: const BorderSide(color: Color(0xFFD9E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: const BorderSide(color: Color(0xFFD9E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: const BorderSide(color: Color(0xFF0878D1)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // =================================================
                  // PASSWORD
                  // =================================================
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF234C6D),
                    ),
                  ),

                  const SizedBox(height: 6),

                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      hintText: 'Masukkan password',
                      hintStyle: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFB0BEC5),
                      ),
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
                          size: 17,
                          color: const Color(0xFF527B99),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: const BorderSide(color: Color(0xFFD9E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: const BorderSide(color: Color(0xFFD9E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: const BorderSide(color: Color(0xFF0878D1)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 17),

                  // =================================================
                  // LOGIN BUTTON
                  // =================================================
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0878D1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // =================================================
                  // REGISTER
                  // =================================================
                  Center(
                    child: GestureDetector(
                      onTap: register,
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Belum punya akun? ',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF527B99),
                              ),
                            ),
                            TextSpan(
                              text: 'Daftar di sini',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0878D1),
                              ),
                            ),
                          ],
                        ),
                      ),
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

// =============================================================
// BACKGROUND LOGIN
// =============================================================

class LoginBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = Colors.white;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      backgroundPaint,
    );

    final wave1 = Paint()..color = const Color(0xFFE0F6FF);

    final path1 = Path();

    final waveTop = size.height * 0.87;

    path1.moveTo(0, waveTop);

    path1.cubicTo(
      size.width * 0.20,
      waveTop - 35,
      size.width * 0.38,
      waveTop + 30,
      size.width * 0.55,
      waveTop - 5,
    );

    path1.cubicTo(
      size.width * 0.72,
      waveTop - 40,
      size.width * 0.88,
      waveTop + 20,
      size.width,
      waveTop - 15,
    );

    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    canvas.drawPath(path1, wave1);

    final wave2 = Paint()..color = const Color(0xFFB7E9FA);

    final path2 = Path();

    path2.moveTo(0, waveTop + 35);

    path2.cubicTo(
      size.width * 0.22,
      waveTop - 5,
      size.width * 0.40,
      waveTop + 65,
      size.width * 0.58,
      waveTop + 20,
    );

    path2.cubicTo(
      size.width * 0.78,
      waveTop - 15,
      size.width * 0.90,
      waveTop + 50,
      size.width,
      waveTop + 10,
    );

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, wave2);

    final wave3 = Paint()..color = const Color(0xFF54C5F0);

    final path3 = Path();

    path3.moveTo(0, waveTop + 65);

    path3.cubicTo(
      size.width * 0.20,
      waveTop + 25,
      size.width * 0.42,
      waveTop + 95,
      size.width * 0.60,
      waveTop + 50,
    );

    path3.cubicTo(
      size.width * 0.78,
      waveTop + 20,
      size.width * 0.90,
      waveTop + 80,
      size.width,
      waveTop + 40,
    );

    path3.lineTo(size.width, size.height);
    path3.lineTo(0, size.height);
    path3.close();

    canvas.drawPath(path3, wave3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
