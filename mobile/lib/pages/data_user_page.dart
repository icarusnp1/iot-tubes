import 'package:flutter/material.dart';

class DataUserPage extends StatefulWidget {
  const DataUserPage({super.key});

  @override
  State<DataUserPage> createState() => _DataUserPageState();
}

class _DataUserPageState extends State<DataUserPage> {
  String dateFilter = 'today';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> healthRecords = [
    {
      'id': 1,
      'timestamp': '2024-10-31 14:30:25',
      'bpm': 75,
      'spo2': 98,
      'temperature': 36.5,
      'activity': 'Jalan',
      'status': 'normal'
    },
    {
      'id': 2,
      'timestamp': '2024-10-31 14:15:10',
      'bpm': 82,
      'spo2': 97,
      'temperature': 36.6,
      'activity': 'Joging',
      'status': 'normal'
    },
    {
      'id': 3,
      'timestamp': '2024-10-31 14:00:45',
      'bpm': 68,
      'spo2': 99,
      'temperature': 36.4,
      'activity': 'Diam',
      'status': 'normal'
    },
    {
      'id': 4,
      'timestamp': '2024-10-31 13:45:30',
      'bpm': 105,
      'spo2': 96,
      'temperature': 37.0,
      'activity': 'Lari',
      'status': 'warning'
    },
    {
      'id': 5,
      'timestamp': '2024-10-31 13:30:15',
      'bpm': 72,
      'spo2': 98,
      'temperature': 36.5,
      'activity': 'Jalan',
      'status': 'normal'
    },
  ];

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
                '1,247',
                Icons.favorite,
                const Color(0xFF0077B6),
                isDarkMode,
              ),
              _buildStatCard(
                'Rata-rata BPM',
                '75',
                Icons.favorite,
                const Color(0xFF2ECC71),
                isDarkMode,
                filled: true,
              ),
              _buildStatCard(
                'Rata-rata SpO₂',
                '98%',
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

          // Data Table
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
                rows: healthRecords.map((record) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          record['timestamp'],
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
                              '${record['bpm']}',
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
                              '${record['spo2']}%',
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
                              '${record['temperature']}°C',
                              style: TextStyle(
                                color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          record['activity'],
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[900],
                          ),
                        ),
                      ),
                      DataCell(_getStatusBadge(record['status'])),
                    ],
                  );
                }).toList(),
              ),
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

  void _handleExport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data akan diexport ke file CSV'),
        backgroundColor: Color(0xFF2ECC71),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}