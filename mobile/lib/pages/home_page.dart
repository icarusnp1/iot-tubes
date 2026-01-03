import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';

// Main Dashboard Page
class HomePage extends StatefulWidget {
  final bool isDarkMode;

  const HomePage({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double bpm = 0;
  double spo2 = 0;
  double speed = 0;
  int steps = 0;
  Timer? refreshTimer;

  List<double> bpmHistory = [];
  List<double> spo2History = [];

  bool get isAbnormal => bpm > 100 || bpm < 60 || spo2 < 95;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchDashboard();
    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => fetchDashboard(),
    );
  }

  Future<void> fetchDashboard() async {
    try {
      // Ambil user_id dari SharedPreferences
      final userId = await ApiService().getCurrentUserId();

      if (userId == null) {
        setState(() {
          error = 'User ID tidak ditemukan. Silakan login kembali.';
          isLoading = false;
        });
        return;
      }

      final res = await ApiService().getDashboard(userId);

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'];

        setState(() {
          // Ambil data dari response 'latest'
          if (data['latest'] != null) {
            bpm = (data['latest']['bpm'] ?? 0).toDouble();
            spo2 = (data['latest']['spo2'] ?? 0).toDouble();
            speed =
                (data['latest']['speed_mps'] ?? 0).toDouble() *
                3.6; // m/s → km/jam
            steps = data['latest']['steps'] ?? 0;
          }

          // Ambil data grafik
          if (data['graph'] != null) {
            final bpmList =
                (data['graph']['bpm'] as List?)
                    ?.where((e) => e != null)
                    .map<double>((e) => (e as num).toDouble())
                    .toList() ??
                [];

            final spo2List =
                (data['graph']['spo2'] as List?)
                    ?.where((e) => e != null)
                    .map<double>((e) => (e as num).toDouble())
                    .toList() ??
                [];

            // Ambil 7 data terakhir
            bpmHistory = bpmList.length > 30
                ? bpmList.sublist(bpmList.length - 30)
                : bpmList;

            spo2History = spo2List.length > 30
                ? spo2List.sublist(spo2List.length - 30)
                : spo2List;
          }

          isLoading = false;
          error = null;
        });
      } else {
        setState(() {
          error = res['message'] ?? 'Gagal mengambil data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: ${e.toString()}';
        isLoading = false;
      });
      print('Error fetching dashboard: $e');
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    // Tampilkan loading indicator
    if (isLoading) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1a202c) : Colors.grey[50],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Tampilkan error message jika ada
    if (error != null) {
      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF1a202c) : Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    error = null;
                  });
                  fetchDashboard();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1a202c) : Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: fetchDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Abnormal Alert
              if (isAbnormal)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: const Border(
                      left: BorderSide(color: Color(0xFFE53935), width: 4),
                    ),
                  ),
                  child: const Text(
                    '⚠️ Peringatan: Data kesehatan menunjukkan nilai abnormal. Segera konsultasi dengan dokter.',
                    style: TextStyle(fontSize: 14, color: Color(0xFFE53935)),
                  ),
                ),

              // KELOMPOK 1: Monitor Detak Jantung
              _buildSectionHeader(
                icon: Icons.favorite,
                iconColor: const Color(0xFFE53935),
                title: 'Monitor Detak Jantung',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),
              HealthStatusCard(
                title: 'Detak Jantung',
                value: bpm.round(),
                unit: 'BPM',
                isDarkMode: isDarkMode,
                type: HealthType.bpm,
                mainIcon: Icons.favorite,
                mainColor: const Color(0xFFE53935),
              ),
              const SizedBox(height: 16),
              HealthStatusCard(
                title: 'Saturasi Oksigen (SpO₂)',
                value: spo2.round(),
                unit: '%',
                isDarkMode: isDarkMode,
                type: HealthType.spo2,
                mainIcon: Icons.water_drop,
                mainColor: const Color(0xFF0077B6),
              ),
              const SizedBox(height: 32),

              // KELOMPOK 2: Monitoring Aktivitas
              _buildSectionHeader(
                icon: Icons.directions_run,
                iconColor: const Color(0xFF2ECC71),
                title: 'Monitoring Aktivitas',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),
              MetricCard(
                title: 'Kecepatan',
                value: speed.toStringAsFixed(1),
                unit: 'km/jam',
                icon: Icons.speed,
                color: const Color(0xFF2ECC71),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),
              MetricCard(
                title: 'Langkah',
                value: steps.toString(),
                unit: 'steps',
                icon: Icons.directions_walk,
                color: const Color(0xFF9C27B0),
                isDarkMode: isDarkMode,
              ),

              const SizedBox(height: 32),

              // Charts Section
              _buildSectionHeader(
                icon: Icons.show_chart,
                iconColor: const Color(0xFF0077B6),
                title: 'Grafik & Tren Data',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth / 2 - 16)
                            : constraints.maxWidth,
                        child: ChartCard(
                          title: 'Grafik Detak Jantung',
                          data: bpmHistory,
                          currentValue: bpm,
                          isDarkMode: isDarkMode,
                          type: 'bpm',
                        ),
                      ),
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth / 2 - 16)
                            : constraints.maxWidth,
                        child: ChartCard(
                          title: 'Grafik SpO₂',
                          data: spo2History,
                          currentValue: spo2,
                          isDarkMode: isDarkMode,
                          type: 'spo2',
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Sync Panel
              SyncPanel(isDarkMode: isDarkMode, onRefresh: fetchDashboard),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [iconColor, iconColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
      ],
    );
  }
}

// --------------------------- ChartCard Widget ---------------------------
class ChartCard extends StatelessWidget {
  final String title;
  final List<double> data;
  final double currentValue;
  final bool isDarkMode;
  final String type; // 'bpm' or 'spo2' (for color choices)

  const ChartCard({
    Key? key,
    required this.title,
    required this.data,
    required this.currentValue,
    required this.isDarkMode,
    required this.type,
  }) : super(key: key);

  Color _primaryColor() {
    if (type == 'bpm') return const Color(0xFFE53935);
    if (type == 'spo2') return const Color(0xFF0077B6);
    return const Color(0xFF2ECC71);
  }

  @override
  Widget build(BuildContext context) {
    final primary = _primaryColor();
    final bg = isDarkMode ? const Color(0xFF2d3748) : Colors.white;

    // convert to FlSpot
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    // y bounds
    double minY = data.isNotEmpty ? data.reduce(min) : 0;
    double maxY = data.isNotEmpty ? data.reduce(max) : 1;

    // Add padding
    final padding = type == 'bpm' ? 10.0 : 5.0;
    minY -= padding;
    maxY += padding;

    // Prevent flat line
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }

    double roundDown(double v, double step) => (v / step).floor() * step;

    double roundUp(double v, double step) => (v / step).ceil() * step;

    final step = type == 'bpm' ? 10.0 : 5.0;
    minY = roundDown(minY, step);
    maxY = roundUp(maxY, step);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentValue.toStringAsFixed(type == 'bpm' ? 0 : 0),
                    style: TextStyle(
                      fontSize: 18,
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    type == 'bpm' ? 'BPM' : '%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // chart area
          SizedBox(
            height: 220,
            child: data.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(right: 6.0, top: 8),
                    child: LineChart(
                      LineChartData(
                        minY: minY,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          horizontalInterval: 10,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.12),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.10),
                              strokeWidth: 1,
                              dashArray: [4, 4],
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 10,
                              getTitlesWidget: (v, meta) {
                                return leftTitleWidgets(v, meta);
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (v, meta) {
                                return bottomTitleWidgets(v, meta, data.length);
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(
                              color: Colors.grey.withOpacity(0.20),
                            ),
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.20),
                            ),
                            top: BorderSide(color: Colors.transparent),
                            right: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: primary,
                            barWidth: 2.2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3.6,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: primary,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  primary.withOpacity(0.20),
                                  primary.withOpacity(0.02),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 10),

          // small legend / info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terakhir ${data.length} sampel',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
              ),
              Text(
                'Range: ${minY.toStringAsFixed(0)} - ${maxY.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // left axis widgets (Y axis)
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontSize: 11);
    if (value % 10 == 0) {
      return Text(
        '${value.toInt()}',
        style: style,
        textAlign: TextAlign.center,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  // bottom axis widgets (X axis) -> hari (Sen..Min)
  Widget bottomTitleWidgets(double value, TitleMeta meta, int dataLength) {
    const style = TextStyle(color: Colors.grey, fontSize: 11);

    // prefer to show weekdays for last 7 points; otherwise show numeric index
    final labels = List.generate(30, (index) {
      if (index % 10 == 0) {
        return index.toString(); // 0, 10, 20, 30, 40, 50
      }
      return ''; // hide other labels
    });

    // if dataLength >=7, show last 7 labels anchored to last 7 indices
    if (dataLength >= 30) {
      final startIndex = dataLength - 30;
      final idx = value.toInt();
      if (idx >= startIndex && idx < startIndex + 30) {
        final label = labels[idx - startIndex];
        return SideTitleWidget(
          space: 6,
          meta: meta,
          child: Text(label, style: style),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      // if less than 7 datapoints, map available points to first labels
      final idx = value.toInt();
      if (idx >= 0 && idx < dataLength && idx < labels.length) {
        return SideTitleWidget(
          space: 6,
          meta: meta,
          child: Text(labels[idx], style: style),
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }
}

// --------------------------- SyncPanel (placeholder) ---------------------------
class SyncPanel extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback? onRefresh;

  const SyncPanel({Key? key, required this.isDarkMode, this.onRefresh})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sinkronisasi Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Terakhir sinkron: beberapa menit yang lalu',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final api = ApiService();

              // Example topic (adjust to your MQTT structure)
              const String topic = 'esp32_1/session';

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menyinkronkan data...')),
              );

              final result = await api.publishCurrentUser(topic: topic);

              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data berhasil disinkronkan')),
                );

                // Optional: refresh UI
                if (onRefresh != null) {
                  onRefresh!();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message'] ?? 'Gagal menyinkronkan data',
                    ),
                  ),
                );
              }
            },
            child: const Text('Sinkronkan'),
          ),
        ],
      ),
    );
  }
}

// --------------------------- HealthStatusCard, MetricCard ---------------------------
// (Salin ulang implementasi widget Anda yang sudah ada di file aslinya)
enum HealthType { bpm, spo2, temperature, humidity }

class HealthStatusCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final String unit;
  final bool isDarkMode;
  final HealthType type;
  final IconData mainIcon;
  final Color mainColor;

  const HealthStatusCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.isDarkMode,
    required this.type,
    required this.mainIcon,
    required this.mainColor,
  }) : super(key: key);

  Map<String, dynamic> _getStatus() {
    final numValue = value is String ? double.parse(value) : value.toDouble();

    switch (type) {
      case HealthType.bpm:
        if (numValue < 60) {
          return {
            'label': 'Bradikardi',
            'color': const Color(0xFFFF9800),
            'icon': Icons.warning_amber,
            'description': 'Detak jantung lebih lambat dari normal',
            'range': 'Normal: 60-100 BPM',
          };
        }
        if (numValue > 100) {
          return {
            'label': 'Takikardi',
            'color': const Color(0xFFE53935),
            'icon': Icons.error_outline,
            'description': 'Detak jantung lebih cepat dari normal',
            'range': 'Normal: 60-100 BPM',
          };
        }
        return {
          'label': 'Normal',
          'color': const Color(0xFF2ECC71),
          'icon': Icons.check_circle_outline,
          'description': 'Detak jantung dalam kondisi baik',
          'range': 'Normal: 60-100 BPM',
        };

      case HealthType.spo2:
        if (numValue < 90) {
          return {
            'label': 'Hipoksemia Berat',
            'color': const Color(0xFFE53935),
            'icon': Icons.error_outline,
            'description':
                'Kadar oksigen sangat rendah - segera hubungi dokter',
            'range': 'Normal: 95-100%',
          };
        }
        if (numValue < 95) {
          return {
            'label': 'Hipoksemia Ringan',
            'color': const Color(0xFFFF9800),
            'icon': Icons.warning_amber,
            'description': 'Kadar oksigen sedikit rendah',
            'range': 'Normal: 95-100%',
          };
        }
        return {
          'label': 'Normal',
          'color': const Color(0xFF2ECC71),
          'icon': Icons.check_circle_outline,
          'description': 'Kadar oksigen optimal',
          'range': 'Normal: 95-100%',
        };

      case HealthType.temperature:
        if (numValue < 22) {
          return {
            'label': 'Dingin',
            'color': const Color(0xFF2196F3),
            'icon': Icons.warning_amber,
            'description': 'Suhu ruangan terlalu dingin',
            'range': 'Normal: 22-26°C',
          };
        }
        if (numValue > 26) {
          return {
            'label': 'Panas',
            'color': const Color(0xFFE53935),
            'icon': Icons.error_outline,
            'description': 'Suhu ruangan terlalu panas',
            'range': 'Normal: 22-26°C',
          };
        }
        return {
          'label': 'Normal',
          'color': const Color(0xFF2ECC71),
          'icon': Icons.check_circle_outline,
          'description': 'Suhu ruangan nyaman',
          'range': 'Normal: 22-26°C',
        };

      case HealthType.humidity:
        if (numValue < 40) {
          return {
            'label': 'Kering',
            'color': const Color(0xFFFF9800),
            'icon': Icons.warning_amber,
            'description': 'Kelembapan terlalu rendah',
            'range': 'Normal: 40-60%',
          };
        }
        if (numValue > 60) {
          return {
            'label': 'Lembap',
            'color': const Color(0xFF2196F3),
            'icon': Icons.error_outline,
            'description': 'Kelembapan terlalu tinggi',
            'range': 'Normal: 40-60%',
          };
        }
        return {
          'label': 'Normal',
          'color': const Color(0xFF2ECC71),
          'icon': Icons.check_circle_outline,
          'description': 'Kelembapan ideal',
          'range': 'Normal: 40-60%',
        };
    }
  }

  double _getScalePosition() {
    final numValue = value is String ? double.parse(value) : value.toDouble();

    switch (type) {
      case HealthType.bpm:
        return min(100, max(0, ((numValue - 40) / (120 - 40)) * 100));
      case HealthType.spo2:
        return min(100, max(0, ((numValue - 85) / (100 - 85)) * 100));
      case HealthType.temperature:
        return min(100, max(0, ((numValue - 18) / (32 - 18)) * 100));
      case HealthType.humidity:
        return min(100, max(0, ((numValue - 20) / (80 - 20)) * 100));
    }
  }

  List<String> _getScaleLabels() {
    switch (type) {
      case HealthType.bpm:
        return ['40', '60', '100', '120'];
      case HealthType.spo2:
        return ['85%', '90%', '95%', '100%'];
      case HealthType.temperature:
        return ['18°C', '22°C', '26°C', '32°C'];
      case HealthType.humidity:
        return ['20%', '40%', '60%', '80%'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getStatus();
    final position = _getScalePosition();
    final scaleLabels = _getScaleLabels();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: status['color'],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          unit,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: mainColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(mainIcon, color: mainColor, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (status['color'] as Color).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: (status['color'] as Color).withOpacity(0.4),
              ),
            ),
            child: Text(
              status['label'],
              style: TextStyle(fontSize: 12, color: status['color']),
            ),
          ),
          const SizedBox(height: 16),

          // Visual Scale
          Stack(
            children: [
              Container(
                height: 32,
                decoration: BoxDecoration(
                  gradient: _getGradient(),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              Positioned(
                left: position / 100 * MediaQuery.of(context).size.width * 0.85,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Scale Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: scaleLabels
                .map(
                  (label) => Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),

          // Status Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]?.withOpacity(0.5)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(status['icon'], size: 16, color: status['color']),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status['description'],
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Text(
                    status['range'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (type) {
      case HealthType.bpm:
        return const LinearGradient(
          colors: [
            Color(0xFFFF9800),
            Color(0xFF2ECC71),
            Color(0xFF2ECC71),
            Color(0xFFE53935),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        );
      case HealthType.spo2:
        return const LinearGradient(
          colors: [
            Color(0xFFE53935),
            Color(0xFFFF9800),
            Color(0xFF2ECC71),
            Color(0xFF2ECC71),
          ],
          stops: [0.0, 0.4, 0.7, 1.0],
        );
      case HealthType.temperature:
        return const LinearGradient(
          colors: [
            Color(0xFF2196F3),
            Color(0xFF2ECC71),
            Color(0xFF2ECC71),
            Color(0xFFE53935),
          ],
          stops: [0.0, 0.3, 0.6, 1.0],
        );
      case HealthType.humidity:
        return const LinearGradient(
          colors: [
            Color(0xFFFF9800),
            Color(0xFF2ECC71),
            Color(0xFF2ECC71),
            Color(0xFF2196F3),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        );
    }
  }
}

// MetricCard Widget
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isDarkMode;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          unit,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
