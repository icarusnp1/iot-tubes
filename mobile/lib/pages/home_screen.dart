import 'package:flutter/material.dart';
import 'package:mobile_iot/pages/home_page.dart';
import '../widgets/sidebar.dart';
// import 'dashboard_page.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Widget _getCurrentPage() {
  //   switch (currentPage) {
  //     case 'dashboard':
  //       return const DashboardPage();
  //     case 'data-user':
  //       return const DataUserPage();
  //     case 'profile':
  //       return const ProfilePage();
  //     case 'settings':
  //       return SettingsPage(
  //         isDarkMode: isDarkMode,
  //         onThemeChanged: (value) {
  //           setState(() {
  //             isDarkMode = value;
  //           });
  //         },
  //       );
  //     default:
  //       return const DashboardPage();
  //   }
  // }

  Widget _getCurrentPage() {
    switch (currentPage) {
      case 'dashboard':
        return const HomePage();
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
        return const HomePage();
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
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logout berhasil')));
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
          title: Text(_getPageTitle()),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
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
