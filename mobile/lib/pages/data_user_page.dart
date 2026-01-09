import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DataUserPage extends StatefulWidget {
  const DataUserPage({super.key});

  @override
  State<DataUserPage> createState() => _DataUserPageState();
}

class _DataUserPageState extends State<DataUserPage> {
  final ApiService apiService = ApiService();

  int? userId;
  int page = 1;
  int limit = 20;
  int total = 0;

  bool loading = false;
  String errorMsg = '';

  List<Map<String, dynamic>> records = [];
  double avgBpm = 0;
  double avgSpo2 = 0;
  int totalRecords = 0;

  String dateFilter = 'today';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSessionAndHistory();
  }

  Future<void> _loadSessionAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('user_id');
    setState(() {
      userId = uid;
    });
    if (userId == null) {
      setState(() {
        errorMsg = 'User belum login (user_id tidak ditemukan).';
      });
      return;
    }
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (userId == null) return;

    setState(() {
      loading = true;
      errorMsg = '';
    });

    final endpoint = '/api/history/$userId?page=$page&limit=$limit';
    final res = await apiService.get(endpoint, auth: true);

    final statsEndpoint = "/api/history/$userId/stats";
    final statsRes = await apiService.get(statsEndpoint, auth: true);

    if (!mounted) return;
    setState(() {
      loading = false;
    });

    if (res['success'] == true && res['data'] != null) {
      try {
        final data = res['data'] as Map<String, dynamic>;
        final List<dynamic> items = data['data'] ?? [];
        records = items.map<Map<String, dynamic>>((e) {
          return Map<String, dynamic>.from(e as Map);
        }).toList();

        page = data['page'] != null ? (data['page'] as num).toInt() : page;
        limit = data['limit'] != null ? (data['limit'] as num).toInt() : limit;
        total = data['total'] != null ? (data['total'] as num).toInt() : total;
        errorMsg = '';
      } catch (e) {
        setState(() {
          errorMsg = 'Format response tidak sesuai: $e';
        });
      }
    } else {
      String m = res['message'] ?? 'Gagal memuat riwayat';
      setState(() {
        errorMsg = m;
      });
    }

    if (statsRes['success'] == true && statsRes['data'] != null) {
      try {
        final data = statsRes['data'] as Map<String, dynamic>;
        print(data);
        avgBpm = (data['avg_bpm'] as num).toDouble();
        avgSpo2 = (data['avg_spo2'] as num).toDouble();
        totalRecords = data['total_records'] as int;
      } catch (e) {
        setState(() {
          errorMsg = 'Format response tidak sesuai: $e';
        });
      }
    } else {
      String m = statsRes['message'] ?? 'Gagal memuat riwayat';
      setState(() {
        errorMsg = m;
      });
    }

  }

  void _prevPage() {
    if (page > 1) {
      setState(() => page--);
      _loadHistory();
    }
  }

  void _nextPage() {
    final maxPage = (total / limit).ceil();
    if (page < maxPage) {
      setState(() => page++);
      _loadHistory();
    }
  }

  void _changeLimit(int newLimit) {
    setState(() {
      limit = newLimit;
      page = 1;
    });
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Data Riwayat Pengguna',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat monitoring kesehatan dan aktivitas',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3.5,
            children: [
              _buildStatCard(
                'Total Records',
                totalRecords.toString(),
                Icons.favorite,
                const Color(0xFF0077B6),
                isDarkMode,
              ),
              _buildStatCard(
                'Rata-rata BPM',
                avgBpm.toStringAsFixed(2),
                Icons.favorite,
                const Color(0xFF2ECC71),
                isDarkMode,
                filled: true,
              ),
              _buildStatCard(
                'Rata-rata SpO₂',
                avgSpo2.toStringAsFixed(2),
                Icons.water_drop,
                const Color(0xFFFF9800),
                isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters and Search Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari data...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter and Export Row
                Row(
                  children: [
                    // Date Filter Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: dateFilter,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: 'today',
                              child: Text('Hari Ini'),
                            ),
                            DropdownMenuItem(
                              value: 'week',
                              child: Text('7 Hari'),
                            ),
                            DropdownMenuItem(
                              value: 'month',
                              child: Text('30 Hari'),
                            ),
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('Semua'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              dateFilter = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Export Button
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2ECC71), Color(0xFF0077B6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _handleExport,
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Export CSV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Error or Loading
          if (errorMsg.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(errorMsg, style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 12),
          ],

          if (loading) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 12),
          ],

          // Data Table
          if (!loading && records.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    isDarkMode
                        ? Colors.grey[800]!.withOpacity(0.5)
                        : Colors.grey[50],
                  ),
                  columns: [
                    DataColumn(
                      label: Text(
                        'Waktu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'BPM',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'SpO₂',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Suhu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Aktivitas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                        ),
                      ),
                    ),
                  ],
                  rows: records
                      .where((record) {
                        if (searchQuery.isEmpty) return true;
                        final activity = (record['activity'] ?? '').toString().toLowerCase();
                        final status = (record['status'] ?? '').toString().toLowerCase();
                        final query = searchQuery.toLowerCase();
                        return activity.contains(query) || status.contains(query);
                      })
                      .map((record) {
                        final time = _formatTime(record['time'] ?? record['timestamp']);
                        final bpm = record['bpm']?.toString() ?? '-';
                        final spo2 = record['spo2']?.toString() ?? '-';
                        final temp = record['temp_c'] != null ? '${record['temp_c']}' : '-';
                        final activity = record['activity'] ?? '-';
                        final status = record['status'] ?? '-';

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                time,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    size: 16,
                                    color: Color(0xFFE53935),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    bpm,
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  const Icon(
                                    Icons.water_drop,
                                    size: 16,
                                    color: Color(0xFF0077B6),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$spo2%',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  const Icon(
                                    Icons.thermostat,
                                    size: 16,
                                    color: Color(0xFFFF9800),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${temp}°C',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                activity,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                                ),
                              ),
                            ),
                            DataCell(_getStatusBadge(status)),
                          ],
                        );
                      })
                      .toList(),
                ),
              ),
            ),

          if (!loading && records.isEmpty && errorMsg.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Belum ada data riwayat'),
            ),

          const SizedBox(height: 24),

          // Pagination Controls
          if (!loading && records.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total: $total'),
                      DropdownButton<int>(
                        value: limit,
                        items: const [
                          DropdownMenuItem(value: 10, child: Text('10')),
                          DropdownMenuItem(value: 20, child: Text('20')),
                          DropdownMenuItem(value: 50, child: Text('50')),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          _changeLimit(v);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: page > 1 ? _prevPage : null,
                        child: const Text('← Prev'),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Page $page of ${(total == 0 ? 1 : (total + limit - 1) ~/ limit)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: (page * limit) < total ? _nextPage : null,
                        child: const Text('Next →'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode, {
    bool filled = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 24,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStatusBadge(String status) {
    Color backgroundColor;
    String label;

    switch (status) {
      case 'normal':
        backgroundColor = const Color(0xFF2ECC71);
        label = 'Normal';
        break;
      case 'warning':
        backgroundColor = const Color(0xFFFFEB3B);
        label = 'Peringatan';
        break;
      case 'danger':
        backgroundColor = const Color(0xFFE53935);
        label = 'Bahaya';
        break;
      default:
        backgroundColor = Colors.grey;
        label = '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _handleExport() async {
  if (records.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tidak ada data untuk diexport'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  try {
    // Request storage permission
    final status = await Permission.storage.request();

    if (status.isDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin penyimpanan ditolak'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (status.isDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin penyimpanan ditolak secara permanen. Aktifkan di Pengaturan.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Build CSV content
    final csv = _generateCSV();
    
    // Get download directory
    final directory = await getExternalStorageDirectory();
    if (directory == null) throw Exception('Tidak dapat mengakses folder penyimpanan aplikasi');

    // optional: create a "Downloads" subfolder inside the app dir
    final appDownloadsDir = Directory('${directory.path}/IoT-Tubes-Exports');
    if (!await appDownloadsDir.exists()) await appDownloadsDir.create(recursive: true);

    // Create filename with timestamp
    final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '').substring(0, 14);
    final filename = 'health_records_$timestamp.csv';
    final filepath = '${directory.path}/$filename';

    // Write file
    final file = File(filepath);
    await file.writeAsString(csv);
    
    print("Exporting CSV: Written to $filepath");

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File disimpan ke: $filename'),
        backgroundColor: const Color(0xFF2ECC71),
        duration: const Duration(seconds: 3),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    print("Error Exporting CSV: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal export: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  String _generateCSV() {
    // Header row
    final headers = ['Waktu', 'BPM', 'SpO₂', 'Suhu (°C)', 'Aktivitas', 'Status', 'Kelembaban'];
    
    // Data rows
    final rows = records.map((record) {
      final time = _formatTime(record['time'] ?? record['timestamp']) ?? '-';
      final bpm = record['bpm']?.toString() ?? '-';
      final spo2 = record['spo2']?.toString() ?? '-';
      final temp = record['temp_c']?.toString() ?? '-';
      final activity = record['activity']?.toString() ?? '-';
      final status = record['status']?.toString() ?? '-';
      final humidity = record['humidity']?.toString() ?? '-';

      // Escape quotes and wrap in quotes if contains comma
      final escape = (String s) => '"${s.replaceAll('"', '""')}"';
      
      return [time, bpm, spo2, temp, activity, status, humidity]
          .map((v) => v.contains(',') || v.contains('"') ? escape(v) : v)
          .join(',');
    }).toList();

    // Combine header and rows
    return [headers.join(','), ...rows].join('\n');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

    String _formatTime(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return '-';
    try {
      final dateTime = DateTime.parse(rawTime);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return rawTime;
    }
  }
}