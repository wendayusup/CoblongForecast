import 'package:flutter/material.dart';
import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ==========================================
    // 1. FUNGSI DURASI & NAVIGASI SPLASH (3 Detik)
    // ==========================================
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // Fix: Check mounted before using context
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Color(0xFF00B4DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // Menggunakan MainAxisAlignment.center agar tidak overflow
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi Logo & Teks
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutBack,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    // KUNCI PERBAIKANNYA DI SINI: clamp() mengunci nilai dari 0.0 sampai 1.0
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Column(
                children: [
                  // Logo Glassmorphism
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),

                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 25,
                          right: 30,
                          child: Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 60),
                        ),
                        Positioned(
                          bottom: 30,
                          left: 25,
                          child: Icon(Icons.cloud_rounded, color: Colors.white, size: 75),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  const Text(
                    "Coblong Forecast",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: const Text(
                      "Weather & Planner App",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Jarak antara elemen animasi dan loading
            const SizedBox(height: 80),

            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            const SizedBox(height: 30),

            // Nama Tunggal Pengembang
            const Text(
              "WendaYusup",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}