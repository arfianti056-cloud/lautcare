
import 'package:flutter/material.dart';
import '../services/admin_dashboard_service.dart';
import 'notifikasi_admin.dart';

class NotifikasiAdmin extends StatefulWidget {
  final String token;

  const NotifikasiAdmin({
    super.key,
    required this.token,
  });

  @override
  State<NotifikasiAdmin> createState() => _NotifikasiAdminState();
}

class _NotifikasiAdminState extends State<NotifikasiAdmin> {
  late Future<List<Map<String, dynamic>>> futureLaporan;

  @override
  void initState() {
    super.initState();
    futureLaporan = ambilLaporan();
  }

  Future<List<Map<String, dynamic>>> ambilLaporan() async {
    final response =
        await AdminDashboardService.fetchDashboard(widget.token);

    final data = response['laporan'];

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<void> muatUlang() async {
    setState(() {
      futureLaporan = ambilLaporan();
    });

    await futureLaporan;
  }

  String teks(dynamic value, [String fallback = '-']) {
    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  String ambilKategori(Map<String, dynamic> laporan) {
    final kategori = laporan['kategori'];

    if (kategori is Map) {
      return teks(
        kategori['nama'] ??
            kategori['nama_kategori'] ??
            kategori['name'],
      );
    }

    return teks(kategori ?? laporan['kategori_id']);
  }

  String ambilNamaPelapor(Map<String, dynamic> laporan) {
    final pelapor = laporan['pelapor'];

    if (pelapor is Map) {
      return teks(
        pelapor['name'] ??
            pelapor['nama'] ??
            pelapor['nama_lengkap'],
        'Pelapor',
      );
    }

    return 'Pelapor';
  }

  String ambilWaktu(Map<String, dynamic> laporan) {
    return teks(
      laporan['created_at'] ?? laporan['createdAt'],
      'Waktu tidak tersedia',
    );
  }

  @override
  Widget build(BuildContext context) {
    const biru = Color(0xFF0878E8);
    const navy = Color(0xFF123F70);

    return Scaffold(
      backgroundColor: const Color(0xFFF2FAFF),
      appBar: AppBar(
        backgroundColor: biru,
        foregroundColor: Colors.white,
        title: const Text(
          'Notifikasi Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: muatUlang,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureLaporan,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 55,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Gagal memuat notifikasi laporan.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: muatUlang,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final laporan = snapshot.data ?? [];

          if (laporan.isEmpty) {
            return RefreshIndicator(
              onRefresh: muatUlang,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Icon(
                    Icons.notifications_none,
                    size: 75,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Belum ada laporan dari Pelapor.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Laporan baru akan muncul di sini.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          // Laporan terbaru ditampilkan lebih dahulu.
          final laporanTerurut = [...laporan];

          laporanTerurut.sort((a, b) {
            final waktuA = DateTime.tryParse(
              a['created_at']?.toString() ?? '',
            );
            final waktuB = DateTime.tryParse(
              b['created_at']?.toString() ?? '',
            );

            if (waktuA == null || waktuB == null) {
              return 0;
            }

            return waktuB.compareTo(waktuA);
          });

          return RefreshIndicator(
            onRefresh: muatUlang,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${laporanTerurut.length} laporan diterima',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 12),
                ...laporanTerurut.map((item) {
                  final judul = teks(
                    item['judul'],
                    'Laporan tanpa judul',
                  );

                  final status = teks(
                    item['status'],
                    'DILAPORKAN',
                  ).toUpperCase();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: biru.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.campaign_outlined,
                              color: biru,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  judul,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: navy,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${ambilNamaPelapor(item)} mengirim laporan baru.',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Kategori: ${ambilKategori(item)}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Waktu: ${ambilWaktu(item)}',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: biru.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      color: biru,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
