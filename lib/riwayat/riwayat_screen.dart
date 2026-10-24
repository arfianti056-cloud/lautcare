import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  static const String baseUrl = 'http://10.11.108.67:8000/api';
  static const String storageUrl = 'http://10.11.108.67:8000/storage/';

  int _selectedIndex = 2;
  String _selectedCategory = 'Semua';
  String _token = '';

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _reports = [];

  bool _isLoading = true;
  String? _errorMessage;
  bool _alreadyCheckedArguments = false;

  final List<String> _filters = [
    'Semua',
    'Diverifikasi',
    'Diproses',
    'Selesai',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map && arguments['token'] is String) {
      final tokenBaru = arguments['token'] as String;

      if (tokenBaru.isNotEmpty && tokenBaru != _token) {
        _token = tokenBaru;
        _loadReports();
      }
    } else if (_token.isEmpty && !_alreadyCheckedArguments) {
      _alreadyCheckedArguments = true;
      _loadReports();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_token.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Token login tidak ditemukan. Silakan login kembali.';
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        if (result is Map && result['data'] is List) {
          final data = result['data'] as List;

          final reports = data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();

          reports.sort((a, b) {
            final dateA = DateTime.tryParse('${a['created_at'] ?? ''}');
            final dateB = DateTime.tryParse('${b['created_at'] ?? ''}');

            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;

            return dateB.compareTo(dateA);
          });

          setState(() {
            _reports = reports;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Format data laporan tidak sesuai.';
          });
        }
      } else if (response.statusCode == 401) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Sesi login berakhir. Silakan login kembali.';
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Gagal mengambil laporan. Kode: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Tidak dapat terhubung ke server Laravel.';
      });

      debugPrint('ERROR MEMUAT LAPORAN: $e');
    }
  }

  String _text(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return '-';
    }
    return value.toString();
  }

  String _status(Map<String, dynamic> report) {
    return _text(report['status']).toUpperCase().trim();
  }

  String _categoryName(Map<String, dynamic> report) {
    final category = report['kategori'];

    if (category is Map && category['nama'] != null) {
      return category['nama'].toString();
    }

    return 'Kategori tidak tersedia';
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }

  String _displayStatus(String status) {
    switch (status) {
      case 'DILAPORKAN':
        return 'Dilaporkan';
      case 'DIVERIFIKASI':
      case 'TERVERIFIKASI':
        return 'Diverifikasi';
      case 'DIPROSES':
        return 'Diproses';
      case 'SELESAI':
        return 'Selesai';
      default:
        return status.isEmpty ? 'Belum diketahui' : status;
    }
  }

  // Membuat URL foto berdasarkan nilai yang diterima dari Laravel.
  String? _photoUrl(Map<String, dynamic> report) {
    final rawPath = report['foto']?.toString().trim();

    if (rawPath == null || rawPath.isEmpty || rawPath == 'null') {
      return null;
    }

    // Jika Laravel mengirim URL lengkap, gunakan URL tersebut.
    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return rawPath;
    }

    // Jika path diawali /storage/, jangan menambahkan /storage/ dua kali.
    if (rawPath.startsWith('/storage/')) {
      return 'http://10.11.108.67:8000$rawPath';
    }

    if (rawPath.startsWith('storage/')) {
      return 'http://10.11.108.67:8000/$rawPath';
    }

    // Menghapus garis miring di awal agar URL tidak menjadi ganda.
    final cleanPath = rawPath.replaceFirst(RegExp(r'^/+'), '');

    return '$storageUrl$cleanPath';
  }

  List<Map<String, dynamic>> get _filteredReports {
    final keyword = _searchController.text.trim().toLowerCase();

    return _reports.where((report) {
      final title = _text(report['judul']).toLowerCase();
      final category = _categoryName(report).toLowerCase();
      final location = _text(report['lokasi']).toLowerCase();
      final status = _status(report);

      final matchesSearch =
          keyword.isEmpty ||
          title.contains(keyword) ||
          category.contains(keyword) ||
          location.contains(keyword);

      bool matchesStatus;

      switch (_selectedCategory) {
        case 'Diverifikasi':
          matchesStatus = status == 'DIVERIFIKASI' || status == 'TERVERIFIKASI';
          break;
        case 'Diproses':
          matchesStatus = status == 'DIPROSES';
          break;
        case 'Selesai':
          matchesStatus = status == 'SELESAI';
          break;
        default:
          matchesStatus = true;
      }

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(
          context,
          '/beranda',
          arguments: {'token': _token},
        );
        break;
      case 1:
        Navigator.pushReplacementNamed(
          context,
          '/laporan',
          arguments: {'token': _token},
        );
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacementNamed(
          context,
          '/profil',
          arguments: {'token': _token},
        );
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
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _loadReports,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari judul, kategori, lokasi...',
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
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
                    children: _filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(filter),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildMessage(
                    icon: Icons.cloud_off_outlined,
                    title: 'Laporan belum dapat dimuat',
                    description: _errorMessage!,
                    showRetry: true,
                  )
                : displayReports.isEmpty
                ? _buildMessage(
                    icon: Icons.history,
                    title: 'Belum ada laporan',
                    description: _reports.isEmpty
                        ? 'Belum ada laporan yang tersimpan.'
                        : 'Tidak ada laporan yang cocok dengan pencarian atau filter.',
                  )
                : RefreshIndicator(
                    onRefresh: _loadReports,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: displayReports.length,
                      itemBuilder: (context, index) {
                        return _buildReportCard(displayReports[index]);
                      },
                    ),
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
    final isSelected = _selectedCategory == label;

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
      onSelected: (_) {
        setState(() {
          _selectedCategory = label;
        });
      },
    );
  }

  Widget _buildReportCard(Map<String, dynamic> item) {
    final photoUrl = _photoUrl(item);
    final status = _status(item);

    debugPrint('PATH FOTO: ${item['foto']}');
    debugPrint('URL FOTO: $photoUrl');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showReportDetail(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: photoUrl == null
                      ? _photoPlaceholder()
                      : Image.network(
                          photoUrl,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          headers: const {'Accept': 'image/*'},
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;

                            return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('GAGAL MEMUAT FOTO: $photoUrl');
                            debugPrint('ERROR FOTO: $error');
                            return _photoPlaceholder();
                          },
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(item['judul']),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _categoryName(item),
                      style: const TextStyle(
                        color: Color(0xFF0878D1),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _text(item['lokasi']),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _formatDate(item['created_at']),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        _statusBadge(status),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
    );
  }

  Widget _statusBadge(String status) {
    Color background;
    Color foreground;

    switch (status) {
      case 'SELESAI':
        background = const Color(0xFFE6F4EA);
        foreground = const Color(0xFF137333);
        break;
      case 'DIPROSES':
        background = const Color(0xFFFFF4E5);
        foreground = const Color(0xFF9A6700);
        break;
      case 'DIVERIFIKASI':
      case 'TERVERIFIKASI':
        background = const Color(0xFFE3F2FD);
        foreground = const Color(0xFF0878D1);
        break;
      default:
        background = const Color(0xFFF1F5F9);
        foreground = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        _displayStatus(status),
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String description,
    bool showRetry = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: const Color(0xFF0878D1)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            if (showRetry) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _loadReports,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReportDetail(Map<String, dynamic> report) {
    final photoUrl = _photoUrl(report);
    final currentStatus = _status(report);

    final steps = ['DILAPORKAN', 'DIVERIFIKASI', 'DIPROSES', 'SELESAI'];

    final normalizedStatus = currentStatus == 'TERVERIFIKASI'
        ? 'DIVERIFIKASI'
        : currentStatus;

    final currentStep = steps.indexOf(normalizedStatus);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Detail Laporan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (photoUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photoUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          headers: const {'Accept': 'image/*'},
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;

                            return const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('GAGAL MEMUAT FOTO DETAIL: $photoUrl');
                            debugPrint('ERROR FOTO DETAIL: $error');

                            return Container(
                              height: 140,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 42,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _text(report['judul']),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _detailRow('Kategori', _categoryName(report)),
                    _detailRow('Lokasi', _text(report['lokasi'])),
                    _detailRow(
                      'Tanggal laporan',
                      _formatDate(report['created_at']),
                    ),
                    _detailRow(
                      'Status sekarang',
                      _displayStatus(currentStatus),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Deskripsi Laporan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _text(report['deskripsi']),
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Perkembangan Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(steps.length, (index) {
                      final step = steps[index];
                      final isReached =
                          currentStep >= 0 && index <= currentStep;
                      final isCurrent = index == currentStep;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 30,
                            child: Column(
                              children: [
                                Icon(
                                  isReached
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isReached
                                      ? const Color(0xFF0878D1)
                                      : Colors.grey[400],
                                  size: 22,
                                ),
                                if (index < steps.length - 1)
                                  Container(
                                    width: 2,
                                    height: 38,
                                    color: isReached
                                        ? const Color(0xFF0878D1)
                                        : Colors.grey[300],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 2,
                                bottom: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _displayStatus(step),
                                    style: TextStyle(
                                      fontWeight: isCurrent
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isReached
                                          ? const Color(0xFF0878D1)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                  if (isCurrent)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Status laporan saat ini',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (currentStep < 0)
                      const Text(
                        'Status belum cocok dengan tahapan yang tersedia.',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
