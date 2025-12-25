import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService api = ApiService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  bool isEditing = false;
  bool isLoading = true;

  double? bmi;

  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);

    final profileRes = await api.get('/api/user/profile', auth: true);
    final healthRes = await api.get('/api/user/health', auth: true);

    if (profileRes['success'] && healthRes['success']) {
      final p = profileRes['data'];
      final h = healthRes['data'];

      setState(() {
        nameController.text = p['name'] ?? '';
        emailController.text = p['email'] ?? '';
        birthDateController.text = p['date_of_birth'] ?? '';

        bloodTypeController.text = h['blood_type'] ?? '';
        heightController.text = h['height_cm']?.toString() ?? '';
        weightController.text = h['weight_kg']?.toString() ?? '';
        bmi = h['bmi']?.toDouble();

        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      _showSnack('Gagal memuat data profil');
    }
  }

  Future<void> _saveProfileAndHealth() async {
    setState(() => isLoading = true);

    // 1️⃣ Update USER PROFILE
    final profileRes = await api.putAuth('/api/user/profile', {
      'name': nameController.text,
      'date_of_birth': birthDateController.text,
    });

    // 2️⃣ Update HEALTH
    final healthRes = await api.putAuth('/api/user/health', {
      'blood_type': bloodTypeController.text,
      'height_cm': double.tryParse(heightController.text),
      'weight_kg': double.tryParse(weightController.text),
    });

    setState(() => isLoading = false);

    if (profileRes['success'] && healthRes['success']) {
      await _loadAllData();
      setState(() => isEditing = false);
      _showSnack('Profil berhasil diperbarui', success: true);
    } else {
      _showSnack('Gagal menyimpan profil');
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profil Kesehatan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (isEditing) {
                    _saveProfileAndHealth();
                  } else {
                    setState(() => isEditing = true);
                  }
                },
                icon: Icon(isEditing ? Icons.save : Icons.edit),
                label: Text(isEditing ? 'Simpan' : 'Edit'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// USER INFO CARD
          /// USER INFO CARD
          _card(
            isDark,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Pengguna',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),

                _input('Nama Lengkap', nameController, isEditing),
                const SizedBox(height: 16),

                _input(
                  'Email',
                  emailController,
                  isEditing, //
                ),
                const SizedBox(height: 16),

                _input(
                  'Tanggal Lahir (YYYY-MM-DD)',
                  birthDateController,
                  isEditing,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// HEALTH FORM
          _card(
            isDark,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Kesehatan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                _input('Golongan Darah', bloodTypeController, isEditing),
                const SizedBox(height: 16),
                _input(
                  'Tinggi Badan (cm)',
                  heightController,
                  isEditing,
                  isNumber: true,
                ),
                const SizedBox(height: 16),
                _input(
                  'Berat Badan (kg)',
                  weightController,
                  isEditing,
                  isNumber: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// BMI CARD
          _card(
            isDark,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Body Mass Index (BMI)',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  bmi != null ? bmi!.toStringAsFixed(1) : '-',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _bmiStatus(bmi),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller,
    bool enabled, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _card(bool isDark, Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2d3748) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  String _bmiStatus(double? bmi) {
    if (bmi == null) return '-';
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obesitas';
  }

  @override
  void dispose() {
    bloodTypeController.dispose();
    heightController.dispose();
    weightController.dispose();
    nameController.dispose();
    emailController.dispose();
    birthDateController.dispose();

    super.dispose();
  }
}
