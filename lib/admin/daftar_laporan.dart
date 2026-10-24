import 'package:flutter/material.dart';

class DaftarLaporan extends StatefulWidget {
  final List<Map<String, dynamic>> laporan;
  final String? statusFilter;

  const DaftarLaporan({
    super.key,
    required this.laporan,
    this.statusFilter,
  });

  @override
  State<DaftarLaporan> createState() => _DaftarLaporanState();
}

class _DaftarLaporanState extends State<DaftarLaporan> {
  final TextEditingController _searchController =
      TextEditingController();

  String _statusAktif = 'SEMUA';
  String _kataKunci = '';

  static const Color blue = Color(0xFF0878E8);
  static const Color navy = Color(0xFF123F70);
  static const Color background = Color(0xFFF2FAFF);

  final List<String> _daftarStatus = [
    'SEMUA',
    'DILAPORKAN',
    'DIVERIFIKASI',
    'DIPROSES',
    'SELESAI',
  ];

  @override
  void initState() {
    super.initState();
    _statusAktif =
        _normalisasiStatus(widget.statusFilter ?? 'SEMUA');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _normalisasiStatus(String status) {
    final value = status.trim().toUpperCase();

    if (value == 'TERVERIFIKASI') {
      return 'DIVERIFIKASI';
    }

    if (value == 'SEMUA' || value.isEmpty) {
      return 'SEMUA';
    }

    return value;
  }

  String _ambilTeks(dynamic value) {
    if (value == null) return '-';

    if (value is Map) {
      return (value['nama'] ??
              value['name'] ??
              value['judul'] ??
              value['title'] ??
              '-')
          .toString();
    }

    return value.toString();
  }

  String _ambilJudul(Map<String, dynamic> laporan) {
    return _ambilTeks(laporan['judul'] ?? laporan['title']);
  }

  String _ambilKategori(Map<String, dynamic> laporan) {
    return _ambilTeks(
      laporan['kategori'] ?? laporan['category'],
    );
  }

  String _ambilLokasi(Map<String, dynamic> laporan) {
    return _ambilTeks(
      laporan['lokasi'] ?? laporan['location'],
    );
  }

  String _ambilStatus(Map<String, dynamic> laporan) {
    return _normalisasiStatus(
      _ambilTeks(laporan['status']),
    );
  }

  String _ambilTanggal(Map<String, dynamic> laporan) {
    final tanggal =
        laporan['created_at'] ?? laporan['tanggal'];

    if (tanggal == null || tanggal.toString().isEmpty) {
      return '-';
    }

    return tanggal.toString();
  }

  String? _ambilFoto(Map<String, dynamic> laporan) {
    final foto = laporan['foto'] ??
        laporan['foto_url'] ??
        laporan['image'];

    if (foto == null || foto.toString().isEmpty) {
      return null;
    }

    return foto.toString();
  }

  List<Map<String, dynamic>> get _laporanTerfilter {
    return widget.laporan.where((laporan) {
      final judul = _ambilJudul(laporan).toLowerCase();
      final kategori = _ambilKategori(laporan).toLowerCase();
      final lokasi = _ambilLokasi(laporan).toLowerCase();

      final cocokPencarian =
          judul.contains(_kataKunci) ||
          kategori.contains(_kataKunci) ||
          lokasi.contains(_kataKunci);

      final status = _ambilStatus(laporan);

      final cocokStatus =
          _statusAktif == 'SEMUA' ||
          status == _statusAktif;

      return cocokPencarian && cocokStatus;
    }).toList();
  }

  Color _warnaStatus(String status) {
    switch (status) {
      case 'DIVERIFIKASI':
        return Colors.blue;
      case 'DIPROSES':
        return Colors.orange;
      case 'SELESAI':
        return Colors.green;
      case 'DILAPORKAN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _labelStatus(String status) {
    switch (status) {
      case 'DIVERIFIKASI':
        return 'Terverifikasi';
      case 'DILAPORKAN':
        return 'Dilaporkan';
      case 'DIPROSES':
        return 'Diproses';
      case 'SELESAI':
        return 'Selesai';
      default:
        return status;
    }
  }

  // =========================
  // HALAMAN DAFTAR LAPORAN
  // =========================

  @override
  Widget build(BuildContext context) {
    final laporan = _laporanTerfilter;

    return Scaffold(
      backgroundColor: background,

      // HEADER
      appBar: AppBar(
        backgroundColor: blue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daftar Laporan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ISI HALAMAN
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _bagianPencarian(),

            _bagianFilter(),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16, 8, 16, 12,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Laporan Masyarakat',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                  ),
                  Text(
                    '${laporan.length} laporan',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: laporan.isEmpty
                  ? _tampilanKosong()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 20,
                      ),
                      itemCount: laporan.length,
                      itemBuilder: (context, index) {
                        return _kartuLaporan(
                          laporan[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // =========================
      // NAVIGASI BAWAH
      // =========================

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFF8FF),
        selectedItemColor: blue,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        elevation: 8,

        onTap: (index) {
          if (index == 0) {
            // Kembali ke Dashboard Admin sebelumnya.
            Navigator.pop(context);
          } else if (index == 1) {
            // Pengguna sudah berada di Daftar Laporan.
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Halaman Profil belum tersedia.',
                ),
              ),
            );
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
            activeIcon: Icon(Icons.description),
            label: 'DaftarLaporan',
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

  // =========================
  // PENCARIAN LAPORAN
  // =========================

  Widget _bagianPencarian() {
    return Container(
      color: blue,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _kataKunci = value.toLowerCase().trim();
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari judul, kategori, atau lokasi...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _kataKunci.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _kataKunci = '';
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // =========================
  // FILTER STATUS
  // =========================

  Widget _bagianFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 12,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _daftarStatus.map((status) {
            final terpilih = _statusAktif == status;

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              child: ChoiceChip(
                label: Text(
                  status == 'SEMUA'
                      ? 'Semua'
                      : _labelStatus(status),
                ),
                selected: terpilih,
                onSelected: (_) {
                  setState(() {
                    _statusAktif = status;
                  });
                },
                selectedColor: blue,
                backgroundColor: background,
                labelStyle: TextStyle(
                  color: terpilih ? Colors.white : navy,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: terpilih ? blue : Colors.black12,
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // =========================
  // KARTU LAPORAN
  // =========================

  Widget _kartuLaporan(
    Map<String, dynamic> laporan,
  ) {
    final judul = _ambilJudul(laporan);
    final kategori = _ambilKategori(laporan);
    final lokasi = _ambilLokasi(laporan);
    final status = _ambilStatus(laporan);
    final tanggal = _ambilTanggal(laporan);
    final foto = _ambilFoto(laporan);
    final warna = _warnaStatus(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: foto != null
                  ? Image.network(
                      foto,
                      width: 95,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return _placeholderFoto();
                      },
                    )
                  : _placeholderFoto(),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 15,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          kategori,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          lokasi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          tanggal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 9),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: warna.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _labelStatus(status),
                      style: TextStyle(
                        color: warna,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
  }

  // =========================
  // FOTO KOSONG
  // =========================

  Widget _placeholderFoto() {
    return Container(
      width: 95,
      height: 110,
      color: const Color(0xFFE4F2FC),
      child: const Icon(
        Icons.image_outlined,
        color: blue,
        size: 35,
      ),
    );
  }

  // =========================
  // TAMPILAN JIKA KOSONG
  // =========================

  Widget _tampilanKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 65,
              color: Colors.black26,
            ),

            const SizedBox(height: 12),

            const Text(
              'Laporan tidak ditemukan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _kataKunci.isNotEmpty
                  ? 'Coba gunakan kata kunci yang berbeda.'
                  : 'Belum ada laporan dengan status ini.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}