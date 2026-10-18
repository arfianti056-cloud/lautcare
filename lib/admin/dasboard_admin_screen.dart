
import 'package:flutter/material.dart';
import '../services/admin_dashboard_service.dart';

class DashboardAdmin extends StatefulWidget {
  final String token;

  const DashboardAdmin({
    super.key,
    required this.token,
  });

  static const blue = Color(0xFF0878E8);
  static const navy = Color(0xFF123F70);
  static const pale = Color(0xFFF2FAFF);

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

  void _reload() {
    setState(() {
      dashboardFuture =
          AdminDashboardService.fetchDashboard(widget.token);
    });
  }

  Future<void> _refresh() async {
    final future =
        AdminDashboardService.fetchDashboard(widget.token);

    setState(() {
      dashboardFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // Error akan ditampilkan oleh FutureBuilder.
    }
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
                        Icons.cloud_off,
                        size: 48,
                        color: DashboardAdmin.blue,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Data dashboard gagal dimuat',
                        textAlign: TextAlign.center,
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
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final response = snapshot.data;

            if (response == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Respons dashboard kosong.'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final rawStats = response['stats'];
            final stats = rawStats is Map
                ? Map<String, dynamic>.from(rawStats)
                : <String, dynamic>{};

            final rawReports = response['laporan'];
            final reports = rawReports is List
                ? rawReports
                    .whereType<Map>()
                    .map(
                      (item) => Map<String, dynamic>.from(item),
                    )
                    .toList()
                : <Map<String, dynamic>>[];

            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        const _Header(),
                        const SizedBox(height: 24),
                        _StatsGrid(stats: stats),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Laporan Terbaru',
                                style: TextStyle(
                                  color: DashboardAdmin.blue,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _reload,
                              tooltip: 'Muat ulang',
                              icon: const Icon(Icons.refresh),
                              color: DashboardAdmin.blue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (reports.isEmpty)
                          const _EmptyReports()
                        else
                          ...reports.map(
                            (report) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 14),
                              child: _ReportTile(report: report),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const _BottomNavigation(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          Icons.waves_rounded,
          color: DashboardAdmin.blue,
          size: 32,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Dashboard Admin',
            style: TextStyle(
              color: DashboardAdmin.navy,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Total Laporan',
        stats['total'] ?? 0,
        Icons.notifications_active,
        const Color(0xFF0878E8),
        const Color(0xFFE1F1FF),
      ),
      (
        'Diproses',
        stats['diproses'] ?? 0,
        Icons.pending_actions,
        const Color(0xFF13A86B),
        const Color(0xFFE2F8EF),
      ),
      (
        'Selesai',
        stats['selesai'] ?? 0,
        Icons.verified_user,
        const Color(0xFF13A86B),
        const Color(0xFFE2F8EF),
      ),
      (
        'Terverifikasi',
        stats['diverifikasi'] ?? 0,
        Icons.sync_alt,
        const Color(0xFFF07816),
        const Color(0xFFFFF0DC),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D1875B9),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.$1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: DashboardAdmin.navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: item.$5,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.$3,
                      color: item.$4,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      '${item.$2}',
                      style: const TextStyle(
                        color: DashboardAdmin.navy,
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReportTile extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final title = (
      report['title'] ??
      report['judul'] ??
      'Tanpa judul'
    ).toString();

    final status =
        (report['status'] ?? 'Belum ada status').toString();

    final date = (report['created_at'] ?? '-').toString();

    final normalizedStatus = status.toUpperCase();

    final Color color;
    final Color background;

    if (normalizedStatus == 'SELESAI') {
      color = const Color(0xFF13A86B);
      background = const Color(0xFFE2F8EF);
    } else if (normalizedStatus == 'DIPROSES') {
      color = const Color(0xFFF07816);
      background = const Color(0xFFFFF0DC);
    } else {
      color = DashboardAdmin.blue;
      background = const Color(0xFFEAF5FF);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1875B9),
            blurRadius: 13,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFFD8F0FC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.waves,
              color: DashboardAdmin.blue,
              size: 35,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardAdmin.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  date.length >= 10
                      ? date.substring(0, 10)
                      : date,
                  style: const TextStyle(
                    color: Color(0xFF6686A5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: DashboardAdmin.blue,
          ),
          SizedBox(height: 10),
          Text('Belum ada laporan terbaru.'),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_filled, 'Beranda'),
      (Icons.description_outlined, 'Laporan'),
      (Icons.location_on_outlined, 'Pencarian'),
      (Icons.notifications_none, 'Notifikasi'),
      (Icons.person_outline, 'Profil'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(5, 12, 5, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFDCEFFA)),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: () {},
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].$1,
                      size: 25,
                      color: i == 0
                          ? DashboardAdmin.blue
                          : const Color(0xFF6385A4),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      items[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: i == 0
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: i == 0
                            ? DashboardAdmin.blue
                            : const Color(0xFF6385A4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
