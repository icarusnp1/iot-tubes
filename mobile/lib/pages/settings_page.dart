import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool autoSync = true;
  bool notifications = true;
  bool alertSound = true;
  String syncInterval = '5';
  
  final Map<String, dynamic> iotDevice = {
    'deviceName': 'Heart Monitor Pro',
    'deviceId': 'ESP32-HM-001',
    'wifiSSID': 'IoT_Network',
    'wifiPassword': '********',
    'bluetoothEnabled': true,
  };

  final TextEditingController deviceNameController = TextEditingController();
  final TextEditingController deviceIdController = TextEditingController();
  final TextEditingController wifiSSIDController = TextEditingController();
  final TextEditingController wifiPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    deviceNameController.text = iotDevice['deviceName'];
    deviceIdController.text = iotDevice['deviceId'];
    wifiSSIDController.text = iotDevice['wifiSSID'];
    wifiPasswordController.text = iotDevice['wifiPassword'];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Pengaturan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola preferensi dan konfigurasi sistem',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Settings
          _buildSettingCard(
            icon: widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            title: 'Tampilan',
            child: _buildSwitchTile(
              'Mode Gelap',
              'Gunakan tema gelap untuk aplikasi',
              widget.isDarkMode,
              widget.onThemeChanged,
            ),
          ),
          const SizedBox(height: 16),

          // IoT Device Settings
          _buildSettingCard(
            icon: Icons.wifi,
            title: 'Koneksi IoT Device',
            child: Column(
              children: [
                _buildTextField(
                  'Nama Device',
                  deviceNameController,
                  enabled: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Device ID',
                  deviceIdController,
                  enabled: false,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  'Bluetooth',
                  'Aktifkan koneksi Bluetooth',
                  iotDevice['bluetoothEnabled'],
                  (value) {
                    setState(() {
                      iotDevice['bluetoothEnabled'] = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'WiFi SSID',
                        wifiSSIDController,
                        enabled: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        'WiFi Password',
                        wifiPasswordController,
                        enabled: true,
                        isPassword: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleTestConnection,
                    icon: const Icon(Icons.radio, size: 18),
                    label: const Text('Test Koneksi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2ECC71),
                      side: const BorderSide(color: Color(0xFF2ECC71)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sync Settings
          _buildSettingCard(
            icon: Icons.storage,
            title: 'Sinkronisasi Data',
            child: Column(
              children: [
                _buildSwitchTile(
                  'Auto Sync',
                  'Sinkronkan data secara otomatis',
                  autoSync,
                  (value) {
                    setState(() {
                      autoSync = value;
                    });
                  },
                ),
                if (autoSync) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interval Sinkronisasi (menit)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: widget.isDarkMode
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.isDarkMode
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: syncInterval,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: '1',
                              child: Text('1 menit'),
                            ),
                            DropdownMenuItem(
                              value: '5',
                              child: Text('5 menit'),
                            ),
                            DropdownMenuItem(
                              value: '10',
                              child: Text('10 menit'),
                            ),
                            DropdownMenuItem(
                              value: '30',
                              child: Text('30 menit'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              syncInterval = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Notification Settings
          _buildSettingCard(
            icon: Icons.notifications,
            title: 'Notifikasi & Alert',
            child: Column(
              children: [
                _buildSwitchTile(
                  'Push Notifications',
                  'Terima notifikasi data abnormal',
                  notifications,
                  (value) {
                    setState(() {
                      notifications = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  'Alert Sound',
                  'Mainkan suara saat alert',
                  alertSound,
                  (value) {
                    setState(() {
                      alertSound = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Security Settings
          _buildSettingCard(
            icon: Icons.shield,
            title: 'Keamanan',
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showMessage('Fitur ubah password');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Ubah Password'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showMessage('Fitur setup sidik jari');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Setup Sidik Jari'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showResetDialog();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[600],
                      side: BorderSide(color: Colors.red[600]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.centerLeft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Reset Database Lokal'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showMessage('Perubahan dibatalkan');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2ECC71), Color(0xFF0077B6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _handleSaveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Simpan Pengaturan'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? const Color(0xFF2d3748) : Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: widget.isDarkMode ? Colors.white : Colors.grey[900],
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
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
                  fontWeight: FontWeight.w500,
                  color: widget.isDarkMode ? Colors.white : Colors.grey[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2ECC71),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    required bool enabled,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? (widget.isDarkMode ? Colors.grey[800] : Colors.grey[50])
                : (widget.isDarkMode ? Colors.grey[800] : Colors.grey[100]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2ECC71),
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSaveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan berhasil disimpan!'),
        backgroundColor: Color(0xFF2ECC71),
      ),
    );
  }

  void _handleTestConnection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menguji koneksi IoT...'),
        backgroundColor: Color(0xFF0077B6),
        duration: Duration(seconds: 1),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koneksi IoT berhasil!'),
            backgroundColor: Color(0xFF2ECC71),
          ),
        );
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF0077B6),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database?'),
        content: const Text(
          'Apakah Anda yakin ingin mereset database lokal? Semua data akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showMessage('Database berhasil direset');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    deviceNameController.dispose();
    deviceIdController.dispose();
    wifiSSIDController.dispose();
    wifiPasswordController.dispose();
    super.dispose();
  }
}