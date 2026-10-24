
import 'package:flutter/material.dart';

import '../services/admin_dashboard_service.dart';
import 'daftar_laporan.dart';
import 'notifikasi_admin.dart';

class DashboardAdmin extends StatefulWidget {
  final String token;

  const DashboardAdmin({
    super.key,
    required this.token,
  });

  static const Color blue = Color(0xFF0878E8);
  static const Color navy = Color(0xFF123F70);
  static const Color pale = Color(0xFFF2FAFF);

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  late Future<Map<String, dynamic>> dashboardFuture;

  @override
  void initState() {
    super.initState();
    dashboardFuture =
        AdminDashboardService.fetchDashboard(widget.token);
  }

  Future<void> _refreshDashboard() async {
    final future = AdminDashboardService.fetchDashboard(widget.token);

    setState(() {
      dashboardFuture = future;
    });

    await future;
  }

  // Membuka halaman daftar laporan dengan filter status.
  void bukaDaftarLaporan(
    List<Map<String, dynamic>> laporan,
    String? status,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DaftarLaporan(
          laporan: laporan,
          statusFilter: status,
        ),
      ),
    );
  }

  int _ambilAngka(
    Map<String, dynamic> stats,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = stats[key];

      if (value is num) {
        return value.toInt();
      }

      if (value != null) {
        return int.tryParse(value.toString()) ?? 0;
      }
    }

    return 0;
  }

  List<Map<String, dynamic>> _ambilDaftarLaporan(dynamic data) {
    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DashboardAdmin.pale,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: DashboardAdmin.blue,
                ),
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
                        Icons.cloud_off_outlined,
                        size: 55,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Gagal memuat dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DashboardAdmin.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            dashboardFuture =
                                AdminDashboardService.fetchDashboard(
                              widget.token,
                            );
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final response = snapshot.data ?? {};

            final statsData = response['stats'];
            final stats = statsData is Map
                ? Map<String, dynamic>.from(statsData)
                : <String, dynamic>{};

            final laporan = _ambilDaftarLaporan(
              response['laporan'],
            );

            final total = _ambilAngka(
              stats,
              ['total', 'total_laporan'],
            );

            final terverifikasi = _ambilAngka(
              stats,
              ['diverifikasi', 'terverifikasi'],
            );

            final diproses = _ambilAngka(
              stats,
              ['diproses'],
            );

            final selesai = _ambilAngka(
              stats,
              ['selesai'],
            );

            return RefreshIndicator(
              color: DashboardAdmin.blue,
              onRefresh: _refreshDashboard,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _header(),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Laporan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: DashboardAdmin.navy,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Pantau laporan kebersihan laut di LautCare.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Empat kartu statistik yang dapat ditekan.
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.35,
                          children: [
                            _StatCard(
                              title: 'Total Laporan',
                              value: total,
                              icon: Icons.description_outlined,
                              color: DashboardAdmin.blue,
                              onTap: () {
                                bukaDaftarLaporan(laporan, null);
                              },
                            ),
                            _StatCard(
                              title: 'Terverifikasi',
                              value: terverifikasi,
                              icon: Icons.verified_outlined,
                              color: Colors.blue,
                              onTap: () {
                                bukaDaftarLaporan(
                                  laporan,
                                  'DIVERIFIKASI',
                                );
                              },
                            ),
                            _StatCard(
                              title: 'Diproses',
                              value: diproses,
                              icon: Icons.sync_outlined,
                              color: Colors.orange,
                              onTap: () {
                                bukaDaftarLaporan(
                                  laporan,
                                  'DIPROSES',
                                );
                              },
                            ),
                            _StatCard(
                              title: 'Selesai',
                              value: selesai,
                              icon: Icons.check_circle_outline,
                              color: Colors.green,
                              onTap: () {
                                bukaDaftarLaporan(
                                  laporan,
                                  'SELESAI',
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Laporan Terbaru',
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: DashboardAdmin.navy,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                bukaDaftarLaporan(laporan, null);
                              },
                              child: const Text('Lihat Semua'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        if (laporan.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 45,
                                  color: Colors.black26,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Belum ada laporan.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...laporan.take(5).map(
                                (item) => _ReportTile(
                                  laporan: item,
                                  onTap: () {
                                    bukaDaftarLaporan(
                                      laporan,
                                      null,
                                    );
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // Navigasi bawah.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: DashboardAdmin.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            dashboardFuture.then((data) {
              if (!mounted) return;

              final daftarLaporan = _ambilDaftarLaporan(
                data['laporan'],
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DaftarLaporan(
                    laporan: daftarLaporan,
                    statusFilter: null,
                  ),
                ),
              );
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Daftar Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

 

Widget _header() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // Logo LautCare di sebelah kiri
        Image.asset(
          'assets/images/logo.png',
          width: 28,
          height: 28,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.waves,
              color: DashboardAdmin.blue,
              size: 28,
            );
          },
        ),

        const SizedBox(width: 12),

        // Judul header
        const Expanded(
          child: Text(
            'Dashboard Admin',
            style: TextStyle(
              color: DashboardAdmin.navy,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Tombol notifikasi menggantikan pencarian
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: () {
    Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NotifikasiAdmin(
      token: widget.token,
    ),
  ),
);
  },
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: DashboardAdmin.navy,
            size: 25,
          ),
        ),
      ],
    ),
  );
}
}


class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                color: color,
                size: 27,
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: DashboardAdmin.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final Map<String, dynamic> laporan;
  final VoidCallback onTap;

  const _ReportTile({
    required this.laporan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final judul =
        laporan['judul'] ?? laporan['title'] ?? 'Tanpa Judul';

    final status = (laporan['status'] ?? 'DILAPORKAN')
        .toString()
        .toUpperCase();

    final kategori =
        laporan['kategori'] ?? laporan['category'] ?? '-';

    final warna = status == 'SELESAI'
        ? Colors.green
        : status == 'DIPROSES'
            ? Colors.orange
            : status == 'DIVERIFIKASI' ||
                    status == 'TERVERIFIKASI'
                ? Colors.blue
                : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: DashboardAdmin.pale,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: DashboardAdmin.blue,
          ),
        ),
        title: Text(
          judul.toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: DashboardAdmin.navy,
          ),
        ),
        subtitle:null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: warna.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status == 'DIVERIFIKASI' ||
                    status == 'TERVERIFIKASI'
                ? 'Terverifikasi'
                : status == 'DILAPORKAN'
                    ? 'Dilaporkan'
                    : status,
            style: TextStyle(
              color: warna,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
