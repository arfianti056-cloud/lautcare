import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilScreen extends StatefulWidget {
  final String nama;
  final String email;

  const ProfilScreen({
    super.key,
    this.nama = 'Pengguna LautCare',
    this.email = 'pengguna@email.com',
  });

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  static const Color biru = Color(0xFF4385E8);
  static const Color navy = Color(0xFF154B79);
  static const Color latar = Color(0xFFF7FAFD);

  static const String baseUrl = 'http://10.11.108.67:8000/api';

  final ImagePicker imagePicker = ImagePicker();

  late final TextEditingController namaController;
  late final TextEditingController emailController;

  String? token;
  String? fotoProfil;
  bool sedangMemuat = true;
  bool sedangMengunggah = false;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.nama);
    emailController = TextEditingController(text: widget.email);
    ambilProfil();
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Uri endpoint(String path) => Uri.parse('$baseUrl/$path');

  Map<String, String> headerJson(String authToken) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
  }

  void tampilkanPesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  String pesanError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map) {
        if (data['message'] != null) {
          return data['message'].toString();
        }

        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          if (errors.isNotEmpty) {
            final pertama = errors.values.first;
            if (pertama is List && pertama.isNotEmpty) {
              return pertama.first.toString();
            }
          }
        }
      }
    } catch (_) {}

    return 'Permintaan gagal (${response.statusCode}).';
  }

  Future<String?> ambilToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lautcare_token');
  }

  Future<void> ambilProfil() async {
    try {
      final authToken = await ambilToken();

      if (authToken == null || authToken.isEmpty) {
        if (!mounted) return;
        setState(() => sedangMemuat = false);
        tampilkanPesan('Token tidak ditemukan. Silakan login kembali.');
        return;
      }

      token = authToken;

      final response = await http.get(
        endpoint('profile'),
        headers: headerJson(authToken),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        if (!mounted) return;

        setState(() {
          namaController.text = user['name']?.toString() ?? widget.nama;
          emailController.text = user['email']?.toString() ?? widget.email;
          fotoProfil = user['foto_profil']?.toString();
          sedangMemuat = false;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lautcare_name', namaController.text);
      } else {
        if (!mounted) return;
        setState(() => sedangMemuat = false);
        tampilkanPesan(pesanError(response));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => sedangMemuat = false);
      tampilkanPesan('Tidak dapat terhubung ke server.');
    }
  }

  String? get urlFoto {
    if (fotoProfil == null || fotoProfil!.isEmpty) return null;

    if (fotoProfil!.startsWith('http://') ||
        fotoProfil!.startsWith('https://')) {
      return fotoProfil;
    }

    final host = Uri.parse(baseUrl).origin;
    final path = fotoProfil!.startsWith('/') ? fotoProfil! : '/${fotoProfil!}';

    return '$host/storage$path';
  }

  Future<void> editProfil() async {
    namaController.text = namaController.text.trim();
    emailController.text = emailController.text.trim();

    final namaAwal = namaController.text;
    final emailAwal = emailController.text;

    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (namaController.text.trim().isEmpty ||
                  emailController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama dan email wajib diisi.')),
                );
                return;
              }

              Navigator.pop(dialogContext, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (hasil != true) {
      namaController.text = namaAwal;
      emailController.text = emailAwal;
      return;
    }

    final authToken = token;
    if (authToken == null) {
      tampilkanPesan('Silakan login kembali.');
      return;
    }

    try {
      final response = await http.put(
        endpoint('profile'),
        headers: headerJson(authToken),
        body: jsonEncode({
          'name': namaController.text.trim(),
          'email': emailController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        if (!mounted) return;

        setState(() {
          namaController.text = user['name'].toString();
          emailController.text = user['email'].toString();
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lautcare_name', namaController.text);

        tampilkanPesan('Profil berhasil diperbarui.');
      } else {
        namaController.text = namaAwal;
        emailController.text = emailAwal;
        tampilkanPesan(pesanError(response));
      }
    } catch (_) {
      namaController.text = namaAwal;
      emailController.text = emailAwal;
      tampilkanPesan('Gagal menghubungi server.');
    }
  }

  Future<void> pilihFotoProfil() async {
    final authToken = token;

    if (authToken == null) {
      tampilkanPesan('Silakan login kembali.');
      return;
    }

    try {
      final XFile? foto = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (foto == null) return;

      final file = File(foto.path);
      final panjang = await file.length();

      if (panjang > 2 * 1024 * 1024) {
        tampilkanPesan('Ukuran foto maksimal 2 MB.');
        return;
      }

      if (!mounted) return;
      setState(() => sedangMengunggah = true);

      final request = http.MultipartRequest('POST', endpoint('profile/photo'));

      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $authToken';

      request.files.add(
        await http.MultipartFile.fromPath('foto_profil', foto.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];

        if (!mounted) return;

        setState(() {
          fotoProfil = user['foto_profil']?.toString();
        });

        tampilkanPesan('Foto profil berhasil diperbarui.');
      } else {
        tampilkanPesan(pesanError(response));
      }
    } catch (_) {
      tampilkanPesan('Gagal mengunggah foto. Periksa koneksi server.');
    } finally {
      if (mounted) {
        setState(() => sedangMengunggah = false);
      }
    }
  }

  Future<void> ubahPassword() async {
    final passwordLamaController = TextEditingController();
    final passwordBaruController = TextEditingController();
    final konfirmasiController = TextEditingController();

    try {
      final hasil = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Ubah Kata Sandi'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordLamaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi Lama',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordBaruController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi Baru',
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: konfirmasiController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi Baru',
                    prefixIcon: Icon(Icons.verified_user_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Kata sandi baru minimal 8 karakter.',
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (passwordLamaController.text.isEmpty ||
                    passwordBaruController.text.isEmpty ||
                    konfirmasiController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Semua kolom wajib diisi.')),
                  );
                  return;
                }

                if (passwordBaruController.text.length < 8) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kata sandi baru minimal 8 karakter.'),
                    ),
                  );
                  return;
                }

                if (passwordBaruController.text != konfirmasiController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Konfirmasi kata sandi tidak cocok.'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, true);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );

      if (hasil != true) return;

      final authToken = token;
      if (authToken == null) {
        tampilkanPesan('Silakan login kembali.');
        return;
      }

      final response = await http.put(
        endpoint('profile/password'),
        headers: headerJson(authToken),
        body: jsonEncode({
          'current_password': passwordLamaController.text,
          'password': passwordBaruController.text,
          'password_confirmation': konfirmasiController.text,
        }),
      );

      if (response.statusCode == 200) {
        tampilkanPesan('Kata sandi berhasil diubah.');
      } else {
        tampilkanPesan(pesanError(response));
      }
    } catch (_) {
      tampilkanPesan('Gagal menghubungi server.');
    } finally {
      passwordLamaController.dispose();
      passwordBaruController.dispose();
      konfirmasiController.dispose();
    }
  }

  void tampilkanInfo(String judul, String isi) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(judul),
        content: Text(isi),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget menuProfil({
    required IconData ikon,
    required String judul,
    required VoidCallback aksi,
    Color warna = navy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFEAF0F6)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
        leading: Icon(ikon, color: warna, size: 23),
        title: Text(
          judul,
          style: TextStyle(
            color: warna == Colors.red ? Colors.red : navy,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF8293A5)),
        onTap: aksi,
      ),
    );
  }

  void navigasiBawah(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/beranda');
        break;
      case 1:
        tampilkanInfo('Lapor', 'Hubungkan menu ini ke halaman laporan.');
        break;
      case 2:
        Navigator.pushNamed(context, '/riwayat');
        break;
      case 3:
        break;
    }
  }

  Future<void> konfirmasiKeluar() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    try {
      final authToken = token ?? await ambilToken();

      if (authToken != null && authToken.isNotEmpty) {
        await http.post(endpoint('logout'), headers: headerJson(authToken));
      }
    } catch (_) {
      // Token lokal tetap dihapus jika server tidak dapat dihubungi.
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lautcare_token');
    await prefs.remove('lautcare_name');

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: latar,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: navy,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: sedangMemuat
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: ambilProfil,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Foto profil
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          key: ValueKey(urlFoto),
                          radius: 43,
                          backgroundColor: biru,
                          backgroundImage: urlFoto != null
                              ? NetworkImage(urlFoto!)
                              : null,
                          child: urlFoto == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 55,
                                )
                              : null,
                        ),
                        Material(
                          color: biru,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: sedangMengunggah ? null : pilihFotoProfil,
                            child: Padding(
                              padding: const EdgeInsets.all(7),
                              child: sedangMengunggah
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 17,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Text(
                      namaController.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      emailController.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 28),

                    menuProfil(
                      ikon: Icons.edit_outlined,
                      judul: 'Edit Profil',
                      aksi: editProfil,
                    ),

                    menuProfil(
                      ikon: Icons.lock_outline,
                      judul: 'Ubah Password',
                      aksi: ubahPassword,
                    ),

                    const SizedBox(height: 8),

                    menuProfil(
                      ikon: Icons.info_outline,
                      judul: 'Tentang LautCare',
                      aksi: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'LautCare',
                          applicationVersion: '1.0.0',
                          children: const [Text('Jaga Laut, Jaga Masa Depan')],
                        );
                      },
                    ),

                    menuProfil(
                      ikon: Icons.logout,
                      judul: 'Keluar',
                      warna: Colors.red,
                      aksi: konfirmasiKeluar,
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: biru,
        unselectedItemColor: Colors.blueGrey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        onTap: navigasiBawah,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Lapor'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
