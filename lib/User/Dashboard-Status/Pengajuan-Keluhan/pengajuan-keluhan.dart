import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/User/Pengaduan-Masyarakat/pengaduan-masyarakat.dart';

class PengajuanKeluhanPage extends StatefulWidget {
  const PengajuanKeluhanPage({super.key});

  @override
  _PengajuanKeluhanPageState createState() => _PengajuanKeluhanPageState();
}

class _PengajuanKeluhanPageState extends State<PengajuanKeluhanPage> {
  List<Map<String, dynamic>> _pengajuanKeluhans = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadKeluhansFromFirebase();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadKeluhansFromFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('pengaduanMasyarakat')
            .where('email', isEqualTo: currentUser.email)
            .get();

        final data = snapshot.docs.map((doc) => doc.data()).toList();

        setState(() {
          _pengajuanKeluhans = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengguna tidak terautentikasi')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $error')),
      );
    }
  }

  List<Map<String, dynamic>> _getFilteredKeluhans() {
    if (_searchQuery.isEmpty) {
      return _pengajuanKeluhans;
    }
    return _pengajuanKeluhans.where((keluhan) {
      final subjekKeluhan = keluhan['subjekAduan']?.toLowerCase() ?? '';
      final deskripsiKeluhan = keluhan['deskripsi']?.toLowerCase() ?? '';
      return subjekKeluhan.contains(_searchQuery) ||
          deskripsiKeluhan.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredKeluhans = _getFilteredKeluhans();

    return Scaffold(
      backgroundColor: Color(0xFFECF5F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE2DED0),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'PENGAJUAN KELUHAN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  color: Colors.black,
                  fontFamily: 'Ubuntu',
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'STATUS KELUHAN ANDA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2F5061),
                  fontFamily: 'Ubuntu',
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF4297A0),
                hintText: 'Cari keluhan anda',
                hintStyle: const TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Ubuntu'),                
                prefixIcon: Icon(Icons.search, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredKeluhans.length,
              itemBuilder: (context, index) {
                final keluhan = filteredKeluhans[index];
                final subjekKeluhan = keluhan['subjekAduan'] ?? 'Tidak ada subjek';
                final deskripsiKeluhan = keluhan['deskripsi'] ?? 'Tidak ada deskripsi';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildStatusContainer(subjekKeluhan, deskripsiKeluhan),
                );
              },
            ),
            SizedBox(height: 20),
            _buildButtonContainer(
                'Ajukan Keluhan Lainnya', Icons.arrow_forward),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContainer(String subjekKeluhan, String deskripsiKeluhan) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFC4DFE2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subjekKeluhan,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                ),
              ),
              SizedBox(height: 4),
              Text(
                deskripsiKeluhan,
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonContainer(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PengaduanMasyarakat(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFE2DED0),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(icon, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
