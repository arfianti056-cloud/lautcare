import 'package:flutter/material.dart';

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

  late final TextEditingController namaController;
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.nama);
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void editProfil() {
    final namaAwal = namaController.text;
    final emailAwal = emailController.text;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
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
        actions: [
          TextButton(
            onPressed: () {
              namaController.text = namaAwal;
              emailController.text = emailAwal;
              Navigator.pop(dialogContext);
            },
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

              setState(() {
                namaController.text = namaController.text.trim();
                emailController.text = emailController.text.trim();
              });

              Navigator.pop(dialogContext);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
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

  void ubahPassword() {
    final passwordController = TextEditingController();
    final konfirmasiController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: konfirmasiController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password',
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.isEmpty ||
                  passwordController.text != konfirmasiController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password kosong atau tidak cocok.'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext);
              tampilkanInfo(
                'Ubah Password',
                'Form sudah diisi. Hubungkan fitur ini ke sistem akun '
                    'agar password benar-benar berubah.',
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    ).then((_) {
      passwordController.dispose();
      konfirmasiController.dispose();
    });
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
        tampilkanInfo('Panduan', 'Panduan LautCare.');
        break;
      case 3:
        Navigator.pushNamed(context, '/riwayat');
        break;
      case 4:
        break;
    }
  }

  void konfirmasiKeluar() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // Foto profil
            const CircleAvatar(
              radius: 43,
              backgroundColor: biru,
              child: Icon(Icons.person, color: Colors.white, size: 55),
            ),

            const SizedBox(height: 15),

            // Nama pengguna
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
              style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
            ),

            const SizedBox(height: 28),

            // Menu profil
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Panduan',
          ),
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
