import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  static const String baseUrl = 'http://10.186.187.67:8000/api';

  String namaPengguna = 'Pengguna';
  String token = '';

  bool sedangMemuat = true;
  String? pesanError;
  List<Map<String, dynamic>> daftarLaporan = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      final nama = arguments['name'];
      final tokenDariLogin = arguments['token'];

      if (nama is String && nama.trim().isNotEmpty) {
        namaPengguna = nama.trim();
      }

      if (tokenDariLogin is String && tokenDariLogin.isNotEmpty) {
        token = tokenDariLogin;
      }
    } else if (arguments is String && arguments.trim().isNotEmpty) {
      namaPengguna = arguments.trim();
    }

    // Ambil data laporan setelah mendapatkan token.
    if (token.isNotEmpty && !sudahMemuatToken) {
      sudahMemuatToken = true;
      ambilLaporan();
    } else if (token.isEmpty && !sudahMemuatToken) {
      sudahMemuatToken = true;
      setState(() {
        sedangMemuat = false;
        pesanError = 'Token login tidak ditemukan. Silakan login kembali.';
      });
    }
  }

  bool sudahMemuatToken = false;

  Future<void> ambilLaporan() async {
    if (!mounted) return;

    setState(() {
      sedangMemuat = true;
      pesanError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final hasil = jsonDecode(response.body);

        if (hasil is Map && hasil['data'] is List) {
          final data = hasil['data'] as List;

          setState(() {
            daftarLaporan = data
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .toList();

            sedangMemuat = false;
          });
        } else {
          setState(() {
            sedangMemuat = false;
            pesanError = 'Format data laporan dari server tidak sesuai.';
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          sedangMemuat = false;
          pesanError = 'Sesi login berakhir. Silakan login kembali.';
        });
      } else {
        setState(() {
          sedangMemuat = false;
          pesanError =
              'Laporan gagal dimuat. Kode server: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        sedangMemuat = false;
        pesanError =
            'Tidak dapat terhubung ke server. Periksa koneksi dan alamat API.';
      });
    }
  }

  String statusLaporan(Map<String, dynamic> laporan) {
    return (laporan['status'] ?? '').toString().trim().toUpperCase();
  }

  int get totalLaporan => daftarLaporan.length;

  int get jumlahDiproses => daftarLaporan.where((laporan) {
    return statusLaporan(laporan) == 'DIPROSES';
  }).length;

  int get jumlahSelesai => daftarLaporan.where((laporan) {
    return statusLaporan(laporan) == 'SELESAI';
  }).length;

  String teks(dynamic nilai) {
    if (nilai == null || nilai.toString().trim().isEmpty) {
      return '-';
    }
    return nilai.toString();
  }

  String namaKategori(Map<String, dynamic> laporan) {
    final kategori = laporan['kategori'];

    if (kategori is Map && kategori['nama'] != null) {
      return kategori['nama'].toString();
    }

    return 'Kategori laporan';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
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
        actions: [
          IconButton(
            onPressed: ambilLaporan,
            tooltip: 'Muat ulang laporan',
            icon: const Icon(Icons.refresh, color: Color(0xFF0878D1)),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ambilLaporan,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BANNER BERANDA
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/benner_beranda.jpg',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 15,
                        top: 15,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, $namaPengguna 👋',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 4),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Peduli Laut, Mulai dari Kita',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                shadows: [
                                  Shadow(color: Colors.black45, blurRadius: 3),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // RINGKASAN LAPORAN
              const Text(
                'Ringkasan Laporan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Laporan',
                      value: sedangMemuat ? '...' : '$totalLaporan',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Diproses',
                      value: sedangMemuat ? '...' : '$jumlahDiproses',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Selesai',
                      value: sedangMemuat ? '...' : '$jumlahSelesai',
                    ),
                  ),
                ],
              ),

              if (pesanError != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4E5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    pesanError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A5200),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: ambilLaporan,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba lagi'),
                ),
              ],

              const SizedBox(height: 22),

              // KATEGORI
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 112,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCategoryCard(
                      icon: Icons.delete_outline,
                      title: 'Sampah Laut',
                    ),
                    _buildCategoryCard(
                      icon: Icons.water_drop_outlined,
                      title: 'Pencemaran Air',
                    ),
                    _buildCategoryCard(
                      icon: Icons.phishing_outlined,
                      title: 'Aktivitas Penangkapan Ikan Ilegal',
                    ),
                    _buildCategoryCard(
                      icon: Icons.more_horiz,
                      title: 'Lainnya',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // LAPORAN TERBARU
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Laporan Terbaru',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/riwayat',
                        arguments: {'token': token},
                      );
                    },
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (sedangMemuat)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (pesanError != null)
                _buildPesanKosong(
                  'Laporan belum dapat ditampilkan',
                  'Periksa koneksi server, lalu tekan tombol muat ulang.',
                  Icons.cloud_off_outlined,
                )
              else if (daftarLaporan.isEmpty)
                _buildPesanKosong(
                  'Belum ada laporan',
                  'Belum ada laporan yang dibuat.',
                  Icons.description_outlined,
                )
              else
                ...daftarLaporan
                    .take(3)
                    .map((laporan) => _buildLaporanCard(laporan)),

              const SizedBox(height: 22),
            ],
          ),
        ),
      ),

      // NAVIGASI BAWAH
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: const Color(0xFF0878D1),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              break;

            case 1:
              if (token.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Token login tidak ditemukan. Silakan login kembali.',
                    ),
                  ),
                );
                return;
              }

              Navigator.pushNamed(
                context,
                '/laporan',
                arguments: {'token': token},
              );
              break;

            case 2:
              Navigator.pushNamed(
                context,
                '/riwayat',
                arguments: {'token': token},
              );
              break;

            case 3:
              Navigator.pushNamed(
                context,
                '/profil',
                arguments: {'token': token},
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Buat Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Riwayat Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // KARTU RINGKASAN
  Widget _buildStatCard({required String title, required String value}) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // KARTU KATEGORI
  Widget _buildCategoryCard({required IconData icon, required String title}) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EAF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: const Color(0xFF0878D1)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // KARTU LAPORAN TERBARU
  Widget _buildLaporanCard(Map<String, dynamic> laporan) {
    final judul = teks(laporan['judul']);
    final lokasi = teks(laporan['lokasi']);
    final status = teks(laporan['status']);
    final kategori = namaKategori(laporan);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            judul,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            kategori,
            style: const TextStyle(fontSize: 12, color: Color(0xFF0878D1)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  lokasi,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0878D1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PESAN KETIKA DATA KOSONG ATAU GAGAL DIMUAT
  Widget _buildPesanKosong(String judul, String deskripsi, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            judul,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            deskripsi,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
