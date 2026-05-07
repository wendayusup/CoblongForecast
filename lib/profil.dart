import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  String _nama = "Wenda Maulana Yusup";
  String _nim = "Belum diisi";
  String _jurusan = "Teknik Otomasi Manufaktur & Mekatronika";
  String _prodi = "Belum diisi";
  String _email = "wenda@example.com";
  String? _imagePath; // Menyimpan path foto profil

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // ==========================================
  // 1. FUNGSI LOAD & SAVE DATA LOKAL (Shared Prefs)
  // ==========================================
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nama = prefs.getString('nama') ?? _nama;
      _nim = prefs.getString('nim') ?? _nim;
      _jurusan = prefs.getString('jurusan') ?? _jurusan;
      _prodi = prefs.getString('prodi') ?? _prodi;
      _email = prefs.getString('email') ?? _email;
      _imagePath = prefs.getString('imagePath');
    });
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('imagePath', pickedFile.path);
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _saveProfileData(
    String n,
    String ni,
    String j,
    String p,
    String e,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama', n);
    await prefs.setString('nim', ni);
    await prefs.setString('jurusan', j);
    await prefs.setString('prodi', p);
    await prefs.setString('email', e);
    _loadProfileData();
  }

  void _showEditForm() {
    final formKey = GlobalKey<FormState>();
    TextEditingController n = TextEditingController(text: _nama);
    TextEditingController ni = TextEditingController(text: _nim);
    TextEditingController j = TextEditingController(text: _jurusan);
    TextEditingController p = TextEditingController(text: _prodi);
    TextEditingController e = TextEditingController(text: _email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Update Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                _buildEditField(n, "Nama"),
                _buildEditField(ni, "NIM"),
                _buildEditField(j, "Jurusan"),
                _buildEditField(p, "Prodi"),
                _buildEditField(e, "Email"),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _saveProfileData(n.text, ni.text, j.text, p.text, e.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  Widget _buildEditField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (val) => val!.isEmpty ? "$label tidak boleh kosong" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Bagian Foto Profil
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          backgroundImage: _imagePath != null
                              ? FileImage(File(_imagePath!))
                              : null,
                          child: _imagePath == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.green,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Tombol Edit Profil
                  ElevatedButton.icon(
                    onPressed: _showEditForm,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text("Edit Profil"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      foregroundColor: Colors.green,
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Identitas Lengkap"),
                          content: Text(
                            "Nama: $_nama\nNIM: $_nim\nJurusan: $_jurusan\nProdi: $_prodi\nEmail: $_email",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Tutup"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          _nama,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Ketuk untuk detail lengkap (Message Box)",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 30),
                        _buildInfoTile(Icons.badge_outlined, "NIM", _nim),
                        _buildInfoTile(
                          Icons.school_outlined,
                          "Institusi",
                          "Polman Bandung",
                        ),
                        _buildInfoTile(
                          Icons.account_tree_outlined,
                          "Jurusan",
                          _jurusan,
                        ),
                        _buildInfoTile(Icons.email_outlined, "Email", _email),
                        _buildInfoTile(
                          Icons.location_on_outlined,
                          "Alamat",
                          "Bandung, Jawa Barat",
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
