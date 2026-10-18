import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final ImagePicker _picker = ImagePicker();

  // Sesuaikan dengan IP laptop yang menjalankan Laravel.
  static const String baseUrl = 'http://10.186.187.67:8000/api';

  static const Color biruLaut = Color(0xFF087BD1);

  List<Map<String, dynamic>> kategoriList = [];

  int? kategoriId;
  XFile? fotoLaporan;
  Uint8List? fotoBytes;

  bool sedangMengirim = false;
  bool sedangMemuatKategori = true;

  @override
  void initState() {
    super.initState();
    ambilKategori();
  }

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

  void tampilkanPesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  // Mengambil kategori dari API Laravel.
  Future<void> ambilKategori() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal mengambil kategori. Kode: ${response.statusCode}',
        );
      }

      final hasil = jsonDecode(response.body);

      if (hasil is! Map || hasil['data'] is! List) {
        throw Exception('Format respons kategori tidak sesuai.');
      }

      final List<dynamic> data = hasil['data'];

      if (!mounted) return;

      setState(() {
        kategoriList = data.map<Map<String, dynamic>>((item) {
          return Map<String, dynamic>.from(item as Map);
        }).toList();

        sedangMemuatKategori = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        sedangMemuatKategori = false;
      });

      tampilkanPesan('Gagal mengambil kategori: $e');
    }
  }

  // Memilih foto dan membacanya agar kompatibel dengan Flutter Web.
  Future<void> pilihFoto(ImageSource sumber) async {
    try {
      final XFile? hasil = await _picker.pickImage(
        source: sumber,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (hasil == null) return;

      final Uint8List bytes = await hasil.readAsBytes();

      if (bytes.length > 2 * 1024 * 1024) {
        tampilkanPesan(
          'Ukuran foto melebihi 2 MB. Pilih foto yang lebih kecil.',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        fotoLaporan = hasil;
        fotoBytes = bytes;
      });
    } catch (e) {
      tampilkanPesan('Foto gagal dipilih: $e');
    }
  }

  Future<void> tampilkanPilihanFoto() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: biruLaut),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  pilihFoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: biruLaut,
                ),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  pilihFoto(ImageSource.gallery);
                },
              ),
              if (fotoBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Hapus Foto'),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    setState(() {
                      fotoLaporan = null;
                      fotoBytes = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Mengirim laporan ke API Laravel.
  Future<void> kirimLaporan() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (kategoriId == null) {
      tampilkanPesan('Pilih kategori laporan terlebih dahulu.');
      return;
    }

    if (sedangMengirim) return;

    setState(() {
      sedangMengirim = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('lautcare_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token login tidak ditemukan. Silakan login kembali.');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/reports'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields['kategori_id'] = kategoriId.toString();
      request.fields['judul'] = judulController.text.trim();
      request.fields['deskripsi'] = deskripsiController.text.trim();
      request.fields['lokasi'] = lokasiController.text.trim();

      if (fotoLaporan != null && fotoBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'foto',
            fotoBytes!,
            filename: fotoLaporan!.name,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      dynamic hasil;

      try {
        hasil = jsonDecode(response.body);
      } catch (_) {
        hasil = <String, dynamic>{};
      }

      if (response.statusCode == 201) {
        if (!mounted) return;

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
              title: const Text('Laporan Berhasil'),
              content: Text(
                hasil is Map
                    ? (hasil['message']?.toString() ??
                          'Laporan berhasil disimpan ke server.')
                    : 'Laporan berhasil disimpan ke server.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Tutup'),
                ),
              ],
            );
          },
        );

        if (!mounted) return;

        Navigator.pop(context, true);
      } else {
        String pesan =
            'Gagal mengirim laporan '
            '(HTTP ${response.statusCode}).';

        if (hasil is Map) {
          if (hasil['message'] != null) {
            pesan = hasil['message'].toString();
          }

          if (hasil['errors'] is Map) {
            final errors = hasil['errors'] as Map;
            final detail = errors.values
                .expand((item) => item is List ? item : [item])
                .join('\n');

            if (detail.isNotEmpty) {
              pesan = '$pesan\n$detail';
            }
          }
        }

        throw Exception(pesan);
      }
    } catch (e) {
      tampilkanPesan('Laporan gagal dikirim: $e');
    } finally {
      if (mounted) {
        setState(() {
          sedangMengirim = false;
        });
      }
    }
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

              if (sedangMemuatKategori)
                const LinearProgressIndicator()
              else if (kategoriList.isEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kategori belum tersedia dari server. '
                      'Pastikan tabel categories berisi data.',
                      style: TextStyle(color: Colors.red),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          sedangMemuatKategori = true;
                        });
                        ambilKategori();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Muat Ulang Kategori'),
                    ),
                  ],
                )
              else
                DropdownButtonFormField<int>(
                  value: kategoriId,
                  isExpanded: true,
                  decoration: dekorasi(
                    'Pilih kategori laporan',
                    Icons.category_outlined,
                  ),
                  items: kategoriList.map((item) {
                    final id = int.parse(item['id'].toString());

                    final nama =
                        (item['nama'] ??
                                item['name'] ??
                                item['nama_kategori'] ??
                                'Kategori')
                            .toString();

                    return DropdownMenuItem<int>(value: id, child: Text(nama));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      kategoriId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Pilih kategori laporan' : null,
                ),
              const SizedBox(height: 20),

              const Text(
                'Deskripsi',
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
                onTap: sedangMengirim ? null : tampilkanPilihanFoto,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDE5EE)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (fotoBytes != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            fotoBytes!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Foto berhasil dipilih',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.add_a_photo_outlined,
                          size: 38,
                          color: biruLaut,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tambah Foto',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Ambil foto atau pilih dari galeri',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: sedangMengirim ? null : kirimLaporan,
                  icon: sedangMengirim
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    sedangMengirim ? 'Mengirim...' : 'Kirim Laporan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: biruLaut,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
