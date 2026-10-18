
import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminDashboardService {
  static const String baseUrl = 'http://10.186.187.67:8000';

  static Future<Map<String, dynamic>> fetchDashboard(
    String token,
  ) async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/api/admin/dashboard'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 401) {
      throw Exception(
        'Sesi login berakhir atau token tidak valid. Silakan login kembali.',
      );
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Akses ditolak. Pastikan akun memiliki role admin.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data dashboard. '
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Format respons API tidak sesuai.');
    }

    return decoded;
  }
}
