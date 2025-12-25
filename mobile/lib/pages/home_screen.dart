import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../services/api_service.dart';
import 'home_page.dart';
import 'data_user_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentPage = 'dashboard';
  bool isDarkMode = false;
  bool isDbConnected = false;
  bool isCheckingDb = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Check database connection on startup
    _checkDatabaseConnection();
  }

  Future<void> _checkDatabaseConnection() async {
    setState(() {
      isCheckingDb = true;
    });

    final result = await apiService.checkDatabaseConnection();

    setState(() {
      isCheckingDb = false;
      isDbConnected = result['success'] ?? false;
    });

    // Show notification only if connection failed
    if (!result['success'] && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(result['message'] ?? 'Database tidak terhubung'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFE53935),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Coba Lagi',
            textColor: Colors.white,
            onPressed: _checkDatabaseConnection,
          ),
        ),
      );
    }
  }

  Widget _getCurrentPage() {
    switch (currentPage) {
      case 'dashboard':
        return HomePage(isDarkMode: isDarkMode);
      case 'data-user':
        return const DataUserPage();
      case 'profile':
        return const ProfilePage();
      case 'settings':
        return SettingsPage(
          isDarkMode: isDarkMode,
          onThemeChanged: (value) {
            setState(() {
              isDarkMode = value;
            });
          },
        );
      default:
        return HomePage(isDarkMode: isDarkMode);
    }
  }

  void _setCurrentPage(String page) {
    setState(() {
      currentPage = page;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logout logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout berhasil')),
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Row(
            children: [
              Text(_getPageTitle()),
              const SizedBox(width: 12),
              // Database connection indicator
              if (isCheckingDb)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                )
              else
                GestureDetector(
                  onTap: _checkDatabaseConnection,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDbConnected
                          ? const Color(0xFF2ECC71).withOpacity(0.2)
                          : const Color(0xFFE53935).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDbConnected ? Icons.cloud_done : Icons.cloud_off,
                          size: 16,
                          color: isDbConnected
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFE53935),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isDbConnected ? 'DB' : 'DB',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDbConnected
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            // Refresh database connection button
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: isCheckingDb ? null : _checkDatabaseConnection,
              tooltip: 'Refresh Database Connection',
            ),
            // Theme toggle
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
          ],
        ),
        drawer: Sidebar(
          currentPage: currentPage,
          setCurrentPage: _setCurrentPage,
          onLogout: _handleLogout,
          isDarkMode: isDarkMode,
          isDbConnected: isDbConnected,
        ),
        body: _getCurrentPage(),
      ),
    );
  }

  String _getPageTitle() {
    switch (currentPage) {
      case 'dashboard':
        return 'Dashboard';
      case 'data-user':
        return 'Data User';
      case 'profile':
        return 'Profil';
      case 'settings':
        return 'Pengaturan';
      default:
        return 'Sistem Monitoring';
    }
  }
}