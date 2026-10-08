import 'package:flutter/material.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  static const Color biruLaut = Color(0xFF0077B6);
  static const Color background = Color(0xFFF7FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/LautCare_Ocean_Wave_Logo-removebg-preview.png',
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LautCare',
                  style: TextStyle(
                    color: biruLaut,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Jaga Laut, Jaga Masa Depan',
                  style: TextStyle(color: biruLaut, fontSize: 9),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: biruLaut),
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // BANNER BERANDA DARI GAMBAR PROPOSAL
            // ======================================================
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/images/benner_beranda.jpeg',
                width: double.infinity,
                height: 145,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 22),

            // ======================================================
            // RINGKASAN LAPORAN
            // ======================================================
            const Text(
              'Ringkasan Laporan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _buildStatCard(
                  icon: Icons.description_outlined,
                  title: 'Total Laporan',
                  value: '0',
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  icon: Icons.autorenew,
                  title: 'Diproses',
                  value: '0',
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  icon: Icons.check_circle_outline,
                  title: 'Selesai',
                  value: '0',
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ======================================================
            // KATEGORI LAPORAN
            // ======================================================
            const Text(
              'Kategori Laporan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 125,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryCard(
                    icon: Icons.delete_outline,
                    title: 'Sampah Laut',
                  ),
                  const SizedBox(width: 12),

                  _buildCategoryCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Pencemaran Air',
                  ),
                  const SizedBox(width: 12),

                  _buildCategoryCard(
                    icon: Icons.waves_outlined,
                    title: 'Kerusakan Terumbu Karang',
                  ),
                  const SizedBox(width: 12),

                  _buildCategoryCard(
                    icon: Icons.phishing_outlined,
                    title: 'Aktivitas Penangkapan Ikan Illegal',
                  ),
                  const SizedBox(width: 12),

                  _buildCategoryCard(icon: Icons.more_horiz, title: 'Lainnya'),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ======================================================
            // LAPORAN TERBARU
            // ======================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Laporan Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),

                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(color: biruLaut),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ======================================================
            // BELUM ADA LAPORAN
            // ======================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 50, color: Colors.grey),

                  SizedBox(height: 12),

                  Text(
                    'Belum ada laporan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'Anda belum membuat laporan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ======================================================
            // BUTTON BUAT LAPORAN
            // ======================================================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text(
                  'Buat Laporan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: biruLaut,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION
      // ============================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: biruLaut,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.report_outlined),
            activeIcon: Icon(Icons.report),
            label: 'Lapor',
          ),

          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),

          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifikasi',
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

  // ==============================================================
  // CARD RINGKASAN
  // ==============================================================

  static Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: biruLaut, size: 28),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: biruLaut,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // CARD KATEGORI
  // ==============================================================

  static Widget _buildCategoryCard({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: biruLaut, size: 30),

          const SizedBox(height: 8),

          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
