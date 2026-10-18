import 'dart:convert';
import 'package:http/http.dart' as http;

class AutService {
  // Sesuaikan URL base API Laravel kamu (contoh menggunakan IP lokal/localhost)
  // Catatan: Jika menggunakan emulator Android, localhost biasanya '10.0.2.2'
  // Jika menggunakan Flutter Web / Chrome, bisa menggunakan 'http://127.0.0.1:8000/api'
  static const String baseUrl = 'http://10.186.187.67:8000/api';

  // Fungsi Login (mendukung Admin maupun Pelapor)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Login berhasil',
          'token': data['token'], // Token Sanctum dari Laravel
          'user': data['user'],   // Informasi data user/admin
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Email atau password salah',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi ke server: $e',
      };
    }
  }

  // Fungsi Register (jika dibutuhkan untuk pendaftaran akun pelapor)
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registrasi berhasil',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal melakukan registrasi',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi ke server: $e',
      };
    }
  }
}