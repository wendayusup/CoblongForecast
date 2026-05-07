import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CuacaScreen extends StatefulWidget {
  const CuacaScreen({super.key});

  @override
  State<CuacaScreen> createState() => _CuacaScreenState();
}

class _CuacaScreenState extends State<CuacaScreen> {
  final List<Map<String, String>> daftarWilayah = [
    {"id": "32.73.02.1001", "nama": "Cipaganti"},
    {"id": "32.73.02.1002", "nama": "Dago"},
    {"id": "32.73.02.1003", "nama": "Lebakgede"},
    {"id": "32.73.02.1004", "nama": "Lebaksiliwangi"},
    {"id": "32.73.02.1005", "nama": "Sadangserang"},
    {"id": "32.73.02.1006", "nama": "Sekeloa"},
  ];

  String _selectedAdm4 = "32.73.02.1001";
  List _cuacaData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApiCuaca(_selectedAdm4);
  }

  // ==========================================
  // 1. FUNGSI COLLECT DATA API (BMKG)
  // ==========================================
  Future<void> _fetchApiCuaca(String adm4Code) async {

    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse("https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=$adm4Code"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List tempCuacaList = [];

        // Menggabungkan array cuaca harian menjadi 1 list memanjang
        for (var hari in data['data'][0]['cuaca']) {
          tempCuacaList.addAll(hari);
        }

        setState(() {
          _cuacaData = tempCuacaList;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // Fungsi merapikan format local_datetime dari BMKG (2026-05-05 22:00:00)
  String _formatWaktu(String datetimeStr) {
    try {
      DateTime dt = DateTime.parse(datetimeStr);
      List<String> bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      return "${dt.day} ${bulan[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:00";
    } catch (e) {
      return datetimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Dropdown Minimalis
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),

              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedAdm4,
                  isExpanded: true,
                  // ==========================================
                  // 2. FUNGSI FILTER/SEARCH WILAYAH (API)
                  // ==========================================
                  onChanged: (val) {

                    if (val != null) {
                      setState(() => _selectedAdm4 = val);
                      _fetchApiCuaca(val);
                    }
                  },
                  items: daftarWilayah.map((w) => DropdownMenuItem(value: w['id'], child: Text(w['nama']!))).toList(),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _cuacaData.length,
                  itemBuilder: (context, index) {
                    final item = _cuacaData[index];

                    // Ambil string waktu lokal, jika null pakai datetime utc
                    String rawTime = item['local_datetime'] ?? item['datetime'] ?? '';
                    String waktuBersih = _formatWaktu(rawTime);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],

                      ),
                      child: Column(
                        children: [
                          // Bagian Atas: Info Utama Cuaca
                          Row(
                            children: [
                              _getModernIcon(item['weather_desc'] ?? ''),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['weather_desc'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Text(waktuBersih, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              Text("${item['t']}°C", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.blueAccent)),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                          ),

                          // Bagian Bawah: Detail Tambahan (Kelembapan, Angin, Visibilitas)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildExtraInfo(Icons.water_drop_outlined, "${item['hu'] ?? '-'}%", "Kelembapan"),
                              _buildExtraInfo(Icons.air_outlined, "${item['ws'] ?? '-'} km/j", "Angin ${item['wd'] ?? ''}"),
                              _buildExtraInfo(Icons.visibility_outlined, "${item['vs_text'] ?? '-'}", "Visibilitas"),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  // Widget kecil untuk menampilkan info tambahan di bawah kartu
  Widget _buildExtraInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333))),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  // Fungsi penentuan Icon yang di-upgrade sedikit
  Widget _getModernIcon(String desc) {
    IconData icon = Icons.wb_cloudy_outlined;
    Color color = Colors.blueGrey;
    String descLower = desc.toLowerCase();

    if (descLower.contains('cerah berawan')) {
      icon = Icons.cloud_queue; color = Colors.lightBlue;
    } else if (descLower.contains('cerah')) {
      icon = Icons.wb_sunny_outlined; color = Colors.orange;
    } else if (descLower.contains('hujan ringan')) {
      icon = Icons.grain; color = Colors.blue;
    } else if (descLower.contains('hujan')) {
      icon = Icons.umbrella_outlined; color = Colors.indigo;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),

      child: Icon(icon, color: color, size: 32),
    );
  }
}