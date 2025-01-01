import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PengajuanDokumenPage extends StatefulWidget {
  const PengajuanDokumenPage({super.key});

  @override
  _PengajuanDokumenPageState createState() => _PengajuanDokumenPageState();
}

class _PengajuanDokumenPageState extends State<PengajuanDokumenPage> {
  List<Map<String, dynamic>> _pengajuanDokumens = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDokumensFromFirebase();
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

  Future<void> _loadDokumensFromFirebase() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('userKTP')
            .where('email', isEqualTo: currentUser.email)
            .get();

        final data = snapshot.docs.map((doc) => doc.data()).toList();

        setState(() {
          _pengajuanDokumens = data;
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

  List<Map<String, dynamic>> _getFilteredDokumens() {
    if (_searchQuery.isEmpty) {
      return _pengajuanDokumens;
    }
    return _pengajuanDokumens.where((dokumen) {
      final namaLengkap = dokumen['namaLengkap']?.toLowerCase() ?? '';
      final alasanPembuatan = dokumen['alasanPembuatan']?.toLowerCase() ?? '';
      return namaLengkap.contains(_searchQuery) ||
          alasanPembuatan.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDokumens = _getFilteredDokumens();

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
                'PENGAJUAN DOKUMEN',
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
                'STATUS PENGAJUAN ANDA',
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
                hintText: 'Cari dokumen anda',
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
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredDokumens.length,
              itemBuilder: (context, index) {
                final dokumen = filteredDokumens[index];
                final namaLengkap = dokumen['namaLengkap'] ?? 'Tidak ada nama lengkap';
                final alasanPembuatan =
                    dokumen['alasanPembuatan'] ?? 'Tidak ada alasan pembuatan';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildStatusContainer(namaLengkap, alasanPembuatan),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContainer(String namaLengkap, String alasanPembuatan) {
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
                namaLengkap, 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                ),
              ),
              SizedBox(height: 4),
              Text(
                alasanPembuatan,
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
}
