import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isAdmin = false;
  bool hidePassword = true;
  bool isLoading = false;

  static const blue = Color(0xFF0878D1);
  static const navy = Color(0xFF154B79);
  static const lightBlue = Color(0xFFD9E8F5);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (isLoading) return;

    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email/username dan password harus diisi'),
        ),
      );
      return;
    }

    // Login Admin tetap menggunakan alur lama.
    if (isAdmin) {
      Navigator.pushReplacementNamed(context, '/admin');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('http://192.168.43.67:8000/api/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': emailController.text.trim(),
              'password': passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 20));

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      final data = decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{};

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Ambil nama pengguna dari respons API Laravel.
        final user = data['user'];

        String nama = '';

        if (user is Map) {
          nama = user['name']?.toString() ?? '';
        }

        // Cadangan jika nama dikirim langsung di dalam respons.
        if (nama.trim().isEmpty) {
          nama = data['name']?.toString() ?? '';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil. Selamat datang di LAUTCARE!'),
          ),
        );

        // Kirim nama pengguna ke halaman beranda.
        Navigator.pushReplacementNamed(
          context,
          '/beranda',
          arguments: {'name': nama},
        );
      } else {
        String pesan =
            data['message']?.toString() ??
            'Login gagal. Periksa kembali email dan password kamu.';

        final errors = data['errors'];

        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;

          if (firstError is List && firstError.isNotEmpty) {
            pesan = firstError.first.toString();
          }
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(pesan)));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak dapat menghubungi server. '
            'Periksa jaringan dan server Laravel.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
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
          Positioned.fill(child: CustomPaint(painter: LoginWavePainter())),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 190),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 650),
                      child: _loginForm(),
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

  Widget _loginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F7FB),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: lightBlue),
          ),
          child: Row(
            children: [
              _roleButton(
                'Pelapor',
                Icons.person_outline,
                !isAdmin,
                () => setState(() => isAdmin = false),
              ),
              _roleButton(
                'Admin',
                Icons.shield_outlined,
                isAdmin,
                () => setState(() => isAdmin = true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          isAdmin ? 'Login Admin' : 'Selamat datang kembali',
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isAdmin
              ? 'Masuk untuk mengakses panel admin LautCare'
              : 'Masuk untuk melanjutkan',
          style: const TextStyle(fontSize: 15, color: Color(0xFF557894)),
        ),
        const SizedBox(height: 30),
        _label(isAdmin ? 'Username atau Email' : 'Email atau Nomor HP'),
        const SizedBox(height: 9),
        _input(
          controller: emailController,
          hint: isAdmin ? 'Masukkan username atau email' : 'contoh@email.com',
          icon: isAdmin ? Icons.person_outline : Icons.mail_outline,
        ),
        const SizedBox(height: 22),
        _label('Password'),
        const SizedBox(height: 9),
        _input(
          controller: passwordController,
          hint: 'Masukkan password',
          icon: Icons.lock_outline,
          password: true,
        ),
        const SizedBox(height: 26),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : login,
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 23,
                    height: 23,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        if (!isAdmin) ...[
          const SizedBox(height: 20),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                const Text(
                  'Belum punya akun? ',
                  style: TextStyle(color: Color(0xFF557894)),
                ),
                GestureDetector(
                  onTap: register,
                  child: const Text(
                    'Daftar di sini',
                    style: TextStyle(color: blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider(color: lightBlue)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text('atau', style: TextStyle(color: Color(0xFF557894))),
              ),
              Expanded(child: Divider(color: lightBlue)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Login Google belum diintegrasikan.'),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: navy,
                side: const BorderSide(color: lightBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('G  Login dengan Google'),
            ),
          ),
        ] else ...[
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Khusus untuk admin LautCare',
              style: TextStyle(fontSize: 12, color: Color(0xFF557894)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _roleButton(
    String title,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: selected ? blue : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: selected ? Colors.white : const Color(0xFF6A88AD),
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : const Color(0xFF6A88AD),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: navy,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool password = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: password && hidePassword,
      keyboardType: password ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
        prefixIcon: Icon(icon, color: const Color(0xFF6A88AD)),
        suffixIcon: password
            ? IconButton(
                onPressed: () {
                  setState(() => hidePassword = !hidePassword);
                },
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF527B99),
                ),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 19,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: blue, width: 1.5),
        ),
      ),
    );
  }
}

class LoginWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void drawWave(double start, double amplitude, Color color) {
      final path = Path()..moveTo(0, start);

      path.cubicTo(
        size.width * 0.20,
        start - amplitude,
        size.width * 0.36,
        start + amplitude,
        size.width * 0.55,
        start,
      );

      path.cubicTo(
        size.width * 0.75,
        start - amplitude,
        size.width * 0.88,
        start + amplitude,
        size.width,
        start - amplitude * 0.3,
      );

      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(path, Paint()..color = color);
    }

    drawWave(size.height * 0.76, 35, const Color(0xFFE0F6FF));
    drawWave(size.height * 0.83, 35, const Color(0xFFB7E9FA));
    drawWave(size.height * 0.91, 30, const Color(0xFF54C5F0));
  }

  @override
  bool shouldRepaint(covariant LoginWavePainter oldDelegate) => false;
}
