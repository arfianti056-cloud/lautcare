import 'package:flutter/material.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laporan'),
        backgroundColor: const Color(0xFF0878D1),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 60, color: Color(0xFF0878D1)),
            SizedBox(height: 12),
            Text('Belum ada riwayat laporan.', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
