import 'package:flutter/material.dart';
import 'dart:math';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  
  final Map<String, String> profile = {
    'name': 'Ragis Rahmatulloh',
    'email': 'Ragis.Rahmatulloh@example.com',
    'phone': '+62 812-3456-7890',
    'birthDate': '2005-05-15',
    'address': 'Bandung, Indonesia',
    'bloodType': 'O+',
    'height': '175',
    'weight': '70',
  };

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController birthDateController;
  late TextEditingController addressController;
  late TextEditingController bloodTypeController;
  late TextEditingController heightController;
  late TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: profile['name']);
    emailController = TextEditingController(text: profile['email']);
    phoneController = TextEditingController(text: profile['phone']);
    birthDateController = TextEditingController(text: profile['birthDate']);
    addressController = TextEditingController(text: profile['address']);
    bloodTypeController = TextEditingController(text: profile['bloodType']);
    heightController = TextEditingController(text: profile['height']);
    weightController = TextEditingController(text: profile['weight']);
  }

  double calculateBMI() {
    try {
      final weight = double.parse(profile['weight'] ?? '0');
      final height = double.parse(profile['height'] ?? '0') / 100;
      return weight / pow(height, 2);
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profil Pengguna',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ECC71), Color(0xFF0077B6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (isEditing) {
                        // Save changes
                        profile['name'] = nameController.text;
                        profile['email'] = emailController.text;
                        profile['phone'] = phoneController.text;
                        profile['birthDate'] = birthDateController.text;
                        profile['address'] = addressController.text;
                        profile['bloodType'] = bloodTypeController.text;
                        profile['height'] = heightController.text;
                        profile['weight'] = weightController.text;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profil berhasil diperbarui!'),
                            backgroundColor: Color(0xFF2ECC71),
                          ),
                        );
                      }
                      isEditing = !isEditing;
                    });
                  },
                  icon: Icon(
                    isEditing ? Icons.save : Icons.edit,
                    size: 18,
                  ),
                  label: Text(isEditing ? 'Simpan' : 'Edit Profil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
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
                // Avatar
                Container(
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2ECC71),
                      width: 4,
                    ),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2ECC71), Color(0xFF0077B6)],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name and Email
                Text(
                  profile['name']!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  profile['email']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Status Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Administrator',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2ECC71),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0077B6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Aktif',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0077B6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Personal Information Card
          Container(
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Pribadi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Nama Lengkap',
                  nameController,
                  Icons.person_outline,
                  isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Email',
                  emailController,
                  Icons.mail_outline,
                  isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Nomor Telepon',
                  phoneController,
                  Icons.phone_outlined,
                  isDarkMode,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Tanggal Lahir',
                  birthDateController,
                  Icons.calendar_today_outlined,
                  isDarkMode,
                  isDate: true,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Alamat',
                  addressController,
                  Icons.location_on_outlined,
                  isDarkMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Health Information Card
          Container(
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Kesehatan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        'Golongan Darah',
                        bloodTypeController,
                        null,
                        isDarkMode,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        'Tinggi Badan (cm)',
                        heightController,
                        null,
                        isDarkMode,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInputField(
                        'Berat Badan (kg)',
                        weightController,
                        null,
                        isDarkMode,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // BMI Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0077B6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Body Mass Index (BMI)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        calculateBMI().toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0077B6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Normal (18.5 - 24.9)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData? icon,
    bool isDarkMode, {
    bool isDate = false,
    bool isNumber = false,
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
          enabled: isEditing,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          readOnly: isDate && isEditing,
          onTap: isDate && isEditing
              ? () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    controller.text = picked.toString().split(' ')[0];
                  }
                }
              : null,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: Colors.grey[400])
                : null,
            filled: true,
            fillColor: isEditing
                ? (isDarkMode ? Colors.grey[800] : Colors.grey[50])
                : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
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
                color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: icon != null ? 12 : 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    addressController.dispose();
    bloodTypeController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}