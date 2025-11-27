import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String currentPage;
  final Function(String) setCurrentPage;
  final VoidCallback onLogout;
  final bool isDarkMode;

  const Sidebar({
    super.key,
    required this.currentPage,
    required this.setCurrentPage,
    required this.onLogout,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'id': 'dashboard', 'label': 'Dashboard', 'icon': Icons.dashboard},
      {'id': 'data-user', 'label': 'Data User', 'icon': Icons.people},
      {'id': 'profile', 'label': 'Profil', 'icon': Icons.person},
      {'id': 'settings', 'label': 'Pengaturan', 'icon': Icons.settings},
    ];

    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF2d3748) : Colors.white,
      child: Column(
        children: [
          // Logo Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2ECC71), Color(0xFF0077B6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.show_chart,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sistem Monitoring',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.grey[900],
                          ),
                        ),
                        Text(
                          'Detak Jantung IoT',
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
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: menuItems.map((item) {
                final isActive = currentPage == item['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => setCurrentPage(item['id'] as String),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: isActive
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF2ECC71),
                                    Color(0xFF0077B6)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : null,
                          color: isActive
                              ? null
                              : (isDarkMode
                                  ? Colors.transparent
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF2ECC71)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 20,
                              color: isActive
                                  ? Colors.white
                                  : (isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[700]),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: isActive
                                    ? Colors.white
                                    : (isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[700]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Logout Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.red[900]!.withOpacity(0.1)
                        : Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        size: 20,
                        color: isDarkMode ? Colors.red[400] : Colors.red[600],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              isDarkMode ? Colors.red[400] : Colors.red[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}