import 'package:flutter/material.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final _formKey = GlobalKey<FormState>();

  final judulController = TextEditingController();
  final deskripsiController = TextEditingController();
  final lokasiController = TextEditingController();

  String? kategori;
  bool fotoDipilih = false;

  static const biruLaut = Color(0xFF087BD1);
  static const kategoriList = [
    'Sampah Laut',
    'Pencemaran Air',
    'Kerusakan Terumbu Karang',
    'Aktivitas Penangkapan Ikan Ilegal',
    'Lainnya',
  ];

  @override
  void dispose() {
    judulController.dispose();
    deskripsiController.dispose();
    lokasiController.dispose();
    super.dispose();
  }

  InputDecoration dekorasi(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: biruLaut),
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDE5EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: biruLaut, width: 1.5),
      ),
    );
  }

  void kirimLaporan() {
    if (!_formKey.currentState!.validate()) return;

    if (kategori == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori laporan terlebih dahulu')),
      );
      return;
    }

    final laporan = <String, String>{
      'judul': judulController.text.trim(),
      'kategori': kategori!,
      'deskripsi': deskripsiController.text.trim(),
      'lokasi': lokasiController.text.trim(),
      'status': 'Menunggu Verifikasi',
    };

    // Mengembalikan data laporan ke halaman sebelumnya.
    // Data belum disimpan ke database.
    Navigator.pop(context, laporan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF202B36),
        elevation: 0,
        title: const Text(
          'Buat Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Laporkan Masalah Lingkungan Laut',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Isi informasi berikut agar laporan dapat ditindaklanjuti.',
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 24),

              const Text(
                'Judul Laporan',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: judulController,
                decoration: dekorasi(
                  'Contoh: Sampah menumpuk di pantai',
                  Icons.edit_outlined,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Judul laporan wajib diisi'
                    : null,
              ),
              const SizedBox(height: 20),

              const Text(
                'Kategori',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: kategori,
                isExpanded: true,
                decoration: dekorasi(
                  'Pilih kategori laporan',
                  Icons.category_outlined,
                ),
                items: kategoriList.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  setState(() => kategori = value);
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'Deskripsi ',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: deskripsiController,
                maxLines: 4,
                decoration: dekorasi(
                  'Jelaskan masalah yang ditemukan...',
                  Icons.description_outlined,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Deskripsi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 20),

              const Text(
                'Lokasi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: lokasiController,
                decoration: dekorasi(
                  'Contoh: Pantai Sulamadaha, Ternate',
                  Icons.location_on_outlined,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Lokasi wajib diisi'
                    : null,
              ),
              const SizedBox(height: 20),

              const Text(
                'Foto Bukti (opsional)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  setState(() => fotoDipilih = !fotoDipilih);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pemilih foto belum dihubungkan. '
                        'Perlu menambahkan fitur galeri/kamera.',
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDE5EE)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 34,
                        color: biruLaut,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fotoDipilih
                            ? 'Tombol foto sudah ditekan'
                            : 'Tambah Foto',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Lampirkan foto kondisi di lokasi',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: kirimLaporan,
                  icon: const Icon(Icons.send_outlined),
                  label: const Text(
                    'Kirim Laporan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: biruLaut,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
