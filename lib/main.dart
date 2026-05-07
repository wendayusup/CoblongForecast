import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'splashscreen.dart';
import 'cuaca.dart';
import 'itinerary.dart';
import 'profil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coblong Forecast',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
        brightness: Brightness.light,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  String _nama = "Wenda Maulana Yusup";
  String _nim = "211344031";
  String _institusi = "Polman Bandung";

  final List<String> _titles = ["Menu Utama", "Cuaca", "Planner", "Profil"];

  void setPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const CuacaScreen(),
    const ItineraryScreen(),
    const ProfilScreen(),
  ];

  void updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('nama') ?? _nama;
      _nim = prefs.getString('nim') ?? _nim;
      // Institusi bisa diambil dari prefs jika ada, default Polman Bandung
      _institusi = prefs.getString('institusi') ?? "Polman Bandung";
    });
  }

  Widget _buildGlobalHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 15, 20, 25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Color(0xFF00B4DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
                    const Text("Selamat Datang,", 
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(_nama, 
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
              ),
              Row(
                children: [
                  if (_currentIndex != 0) // Hanya muncul jika tidak sedang di Home
                    GestureDetector(
                      onTap: () => setPage(0),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.home_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(_titles[_currentIndex], 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(_nim, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(width: 15),
                const Text("|", style: TextStyle(color: Colors.white24)),
                const SizedBox(width: 15),
                const Icon(Icons.school_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(_institusi, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Data dimuat di initState, tidak perlu di build agar tidak looping
    // _loadUserInfo();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: Column(
        children: [
          _buildGlobalHeader(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
            _loadUserInfo();
          },
          backgroundColor: Colors.white,
          indicatorColor: Colors.blueAccent.withValues(alpha: 0.1),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: Colors.blueAccent),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.cloud_queue),
              selectedIcon: Icon(Icons.cloud, color: Colors.blueAccent),
              label: 'Cuaca',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today_outlined),
              selectedIcon: Icon(Icons.calendar_today, color: Colors.blueAccent),
              label: 'Planner',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: Colors.blueAccent),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparan agar terlihat warna background parent
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        children: [
          const Text("Informasi Menu",
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
          const Text("Mau cek apa hari ini?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 25),

          // Fungsi Interaktif: Mengarahkan ke halaman yang tepat
          _buildModernMenu(context, "Informasi Cuaca", "Cek prakiraan di area Coblong",
            Icons.cloud_queue, const Color(0xFF42A5F5), const CuacaScreen()),
          _buildModernMenu(context, "Planner Kegiatan", "Atur jadwal dan itinerary kamu",
            Icons.calendar_today_outlined, const Color(0xFFFFA726), const ItineraryScreen()),
          _buildModernMenu(context, "Profil Pengembang", "Lihat detail identitas",
            Icons.person_outline, const Color(0xFF66BB6A), const ProfilScreen()),
          
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildModernMenu(BuildContext context, String title, String subtitle, IconData icon, Color color, Widget page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,

            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),

          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Navigasi internal diubah: jika diklik di menu, pindah tab
          final navigationState = context.findAncestorStateOfType<_MainNavigationState>();
          if (navigationState != null) {
            int targetIndex = 0;
            if (title.contains("Cuaca")) {
              targetIndex = 1;
            } else if (title.contains("Planner")) {
              targetIndex = 2;
            } else if (title.contains("Profil")) {
              targetIndex = 3;
            }
            
            navigationState.setPage(targetIndex);
          } else {
            // Fallback jika tidak dalam MainNavigation
            Navigator.push(context, MaterialPageRoute(builder: (context) => page));
          }
        },
      ),
    );
  }
}