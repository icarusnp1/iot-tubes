import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  void login() {
    String user = userC.text;
    String pass = passC.text;

    if (user == "admin" && pass == "12345") {
      // berpindah halaman
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      // tampilkan pesan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username atau password salah!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD9F4E7),
              Color(0xFFDAEEFA),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 330,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF38D39F),
                          Color(0xFF35A5DA),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.monitor_heart_outlined,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Sistem Monitoring",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Detak Jantung Berbasis IoT",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 25),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Username",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: userC,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline),
                      hintText: "Masukkan username",
                      filled: true,
                      fillColor: const Color(0xFFF2F3F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    controller: passC,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      hintText: "Masukkan password",
                      filled: true,
                      fillColor: const Color(0xFFF2F3F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3DDB85),
                          Color(0xFF0073E6),
                        ],
                      ),
                    ),
                    child: TextButton(
                      onPressed: login,
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "© 2024 IoT Heart Monitoring System",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
