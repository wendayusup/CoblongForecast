import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  // ==========================================
  // 1. CONFIGURASI & DATA DATABASE (MySQL)
  // ==========================================
  String _baseUrl = "192.168.0.100"; // IP Default
  String get apiUrl => "http://$_baseUrl/api_project/api_itinerary.php";

  List _data = []; // Penampung data dari database
  bool _isLoading = true; // State untuk loading indicator

  TextEditingController searchController = TextEditingController();
  TextEditingController ipController = TextEditingController();

  // Daftar wilayah yang sama dengan fitur Cuaca
  final List<String> daftarWilayah = [
    "Cipaganti",
    "Dago",
    "Lebakgede",
    "Lebaksiliwangi",
    "Sadangserang",
    "Sekeloa",
  ];

  @override
  void initState() {
    super.initState();
    _loadIpAndData();
  }

  Future<void> _loadIpAndData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _baseUrl = prefs.getString('ip_laptop') ?? _baseUrl;
      ipController.text = _baseUrl;
    });
    _fetchData();
  }

  void _showIpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfigurasi IP Laptop"),
        content: TextField(
          controller: ipController,
          decoration: const InputDecoration(hintText: "Contoh: 192.168.1.10"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('ip_laptop', ipController.text);
              setState(() {
                _baseUrl = ipController.text;
              });
              if (!context.mounted) return;
              Navigator.pop(context);
              _fetchData();
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. FUNGSI READ (AMBIL DATA DARI DB)
  // ==========================================
  Future<void> _fetchData([String query = '']) async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse("$apiUrl?search=$query"));
      if (response.statusCode == 200) {
        setState(() {
          _data = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pilihTanggal(
    BuildContext context,
    TextEditingController controller,
  ) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String tanggalFormat =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        controller.text = tanggalFormat;
      });
    }
  }

  // ==========================================
  // 3. FUNGSI CREATE & UPDATE (SIMPAN KE DB)
  // ==========================================
  void _showFormDialog([Map? item]) {
    final formKey = GlobalKey<FormState>();
    TextEditingController kegiatanCtrl = TextEditingController(
      text: item?['kegiatan'] ?? '',
    );
    TextEditingController tanggalCtrl = TextEditingController(
      text: item?['tanggal'] ?? '',
    );

    String selectedLokasi = item?['lokasi'] ?? daftarWilayah[0];
    if (!daftarWilayah.contains(selectedLokasi)) {
      selectedLokasi = daftarWilayah[0];
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            item == null ? "Tambah Rencana" : "Edit Rencana",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(
                    kegiatanCtrl,
                    "Nama Kegiatan",
                    Icons.assignment_outlined,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLokasi,
                    decoration: InputDecoration(
                      labelText: "Lokasi Wilayah",
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: Colors.blueAccent,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: daftarWilayah
                        .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                        .toList(),
                    onChanged: (val) =>
                        setDialogState(() => selectedLokasi = val!),
                    validator: (val) =>
                        val == null ? "Pilih lokasi wilayah" : null,
                  ),
                  const SizedBox(height: 15),
                  _buildDateField(
                    tanggalCtrl,
                    "Tanggal Kegiatan",
                    Icons.calendar_today_outlined,
                    context,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Map<String, dynamic> body = {
                    "kegiatan": kegiatanCtrl.text,
                    "lokasi": selectedLokasi,
                    "tanggal": tanggalCtrl.text,
                  };
                  if (item != null) body["id"] = item["id"];

                  final request = item == null ? http.post : http.put;
                  await request(Uri.parse(apiUrl), body: json.encode(body));

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _fetchData();
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val!.isEmpty ? "Field tidak boleh kosong" : null,
    );
  }

  Widget _buildDateField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    BuildContext context,
  ) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      onTap: () => _pilihTanggal(context, ctrl),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) => val!.isEmpty ? "Tanggal tidak boleh kosong" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Cari rencana...",
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.blueAccent,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      onChanged: (val) => _fetchData(val),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showIpDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      final item = _data[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.event_note_rounded,
                              color: Colors.blueAccent,
                            ),
                          ),
                          title: Text(
                            item['kegiatan'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item['lokasi'],
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  item['tanggal'],
                                  style: const TextStyle(color: Colors.grey, fontSize: 13)
                                ),
                              ],
                            ),
                          ),
                          trailing: PopupMenuButton(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.grey,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                onTap: () => Future.delayed(
                                  Duration.zero,
                                  () => _showFormDialog(item),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 10),
                                    Text("Edit"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () async {
                                  await http.delete(
                                    Uri.parse("$apiUrl?id=${item['id']}"),
                                  );
                                  _fetchData();
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 10),
                                    Text("Hapus"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        label: const Text(
          "Tambah Rencana",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
