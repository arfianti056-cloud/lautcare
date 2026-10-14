import 'package:flutter/material.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  int _selectedIndex = 2; // Indeks ke-2 untuk Riwayat Laporan
  String _selectedCategory = 'Semua';

  // State awal: Kosong (belum ada laporan yang dibuat)
  // Nanti jika ada data dari database/API, data tersebut tinggal di-push ke list ini
  final List<Map<String, String>> _reports = [
    /*
    // CONTOH STRUKTUR DATA JIKA NANTI ADA LAPORAN MASUK:
    {
      'title': 'Sampah di Pantai Falajawa',
      'location': '12 Mei | Pesisir',
      'date': '12 Mei 2025',
      'status': 'Diverifikasi',
      'image': 'https://picsum.photos/200/200?random=1',
    },
    {
      'title': 'Pencemaran di Teluk Ternate',
      'location': '10 Mei | Jalan Laut',
      'date': '10 Mei 2025',
      'status': 'Diverifikasi',
      'image': 'https://picsum.photos/200/200?random=2',
    },
    {
      'title': 'Kerusakan Terumbu Karang',
      'location': '3 Mei | Mangkubumi',
      'date': '3 Mei 2025',
      'status': 'Diproses',
      'image': 'https://picsum.photos/200/200?random=3',
    },
    */
  ];

  // Getter Logika Filtering (Tetap dipertahankan untuk menyaring data ketika laporan masuk)
  List<Map<String, String>> get _filteredReports {
    if (_selectedCategory == 'Semua') {
      return _reports;
    } else if (_selectedCategory == 'Terverifikasi') {
      return _reports
          .where(
            (item) =>
                item['status'] == 'Diverifikasi' ||
                item['status'] == 'Terverifikasi',
          )
          .toList();
    } else if (_selectedCategory == 'Diproses') {
      return _reports.where((item) => item['status'] == 'Diproses').toList();
    }
    return _reports;
  }

  // Navigasi Bottom Bar
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/beranda');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/laporan');
        break;
      case 2:
        // Sudah berada di halaman riwayat
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profil');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayReports = _filteredReports;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0878D1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Riwayat Laporan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header Search Bar & Filter Chips (Selalu Tampil)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari judul, kategori, lokasi...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Semua'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Terverifikasi'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Diproses'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tampilan Konten Dinamis
          Expanded(
            child: displayReports.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.history, size: 64, color: Color(0xFF0878D1)),
                        SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat laporan.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: displayReports.length,
                    itemBuilder: (context, index) {
                      final item = displayReports[index];
                      return _buildReportCard(item);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0878D1),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
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

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedCategory == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF0878D1),
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (bool selected) {
        setState(() {
          _selectedCategory = label;
        });
      },
    );
  }

  Widget _buildReportCard(Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image']!,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['location']!,
                    style: const TextStyle(
                      color: Color(0xFF0878D1),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        item['date']!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EA),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['status']!,
                          style: const TextStyle(
                            color: Color(0xFF137333),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
