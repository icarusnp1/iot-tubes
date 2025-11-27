import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Sistem Monitoring"),
      ),
      body: const Center(
        child: Text(
          "Selamat datang di dashboard!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
