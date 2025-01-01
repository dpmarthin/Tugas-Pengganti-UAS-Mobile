import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PengaduanMasyarakat extends StatefulWidget {
  const PengaduanMasyarakat({super.key});

  @override
  _PengaduanMasyarakat createState() => _PengaduanMasyarakat();
}

class _PengaduanMasyarakat extends State<PengaduanMasyarakat> {
  final _formKey = GlobalKey<FormState>();
  final _subjekAduanController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _tanggalKejadianController = TextEditingController();
  final _lokasiLengkapController = TextEditingController();
  final _namaAnonimitasController = TextEditingController();
  final _noTeleponController = TextEditingController();
  DateTime? _selectedDateKejadian;
  String? _instansiTujuan;
  String? _anonimitas;

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengguna tidak terautentikasi')),
        );
        return;
      }      

      final data = {
        'email': currentUser.email,
        'subjekAduan': _subjekAduanController.text,
        'deskripsi': _deskripsiController.text,
        'tanggalKejadian': _selectedDateKejadian ?? DateTime.now(),
        'lokasiLengkap': _lokasiLengkapController.text,
        'instansiTujuan': _instansiTujuan,
        'anonimitas': _anonimitas,
        'namaAnonimitas': _anonimitas == 'Sertakan Nama' ? _namaAnonimitasController.text : null,
        'noTelepon': int.tryParse(_noTeleponController.text),
      };
      
      try {
        await FirebaseFirestore.instance.collection('pengaduanMasyarakat').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaduan berhasil diajukan')),
        );

        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengaduan gagal diajukan: $error')),
        );
      }      
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFECF5F6),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120.0),
          child: Container(
            padding: const EdgeInsets.only(top: 35),
            decoration: const BoxDecoration(
              color: Color(0xFF3AB3B1),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(7.0)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 10.0),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2DED0),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'AJUKAN KELUHAN',
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: 16),
                  _buildSection(
                    title: '',
                    fields: [
                      _buildTextField(
                        label: 'Subjek Aduan',
                        hint: 'tulis subjek aduan anda',
                        controller: _subjekAduanController,
                        onSaved: (value) => _subjekAduanController.text = value!,
                        validator: (value) => value!.isEmpty ? 'Field tidak boleh kosong' : null,
                      ),
                      _buildTextField(
                        label: 'Deskripsi',
                        hint: 'deskripsi lengkap',
                        controller: _deskripsiController,
                        onSaved: (value) => _deskripsiController.text = value!,
                        validator: (value) => value!.isEmpty ? 'Field tidak boleh kosong' : null,
                      ),
                      _buildDateField(),
                      _buildTextField(
                        label: 'Lokasi Lengkap',
                        hint: 'alamat subjek keluhan',
                        controller: _lokasiLengkapController,
                        onSaved: (value) => _lokasiLengkapController.text = value!,
                        validator: (value) => value!.isEmpty ? 'Field tidak boleh kosong' : null,
                      ),
                      _buildDropdownField(
                        label: 'Instansi Tujuan',
                        items: ['Disdukcapil', 'Kominfo', 'Dishub'],
                        currentValue: _instansiTujuan,
                        onChanged: (value) {
                          setState(() {
                            _instansiTujuan = value;
                          });
                        },
                        onSaved: (value) => _instansiTujuan = value,
                      ),
                      _buildDropdownField(
                        label: 'Anonimitas',
                        items: ['Anonim', 'Sertakan Nama'],
                        currentValue: _anonimitas,
                        onChanged: (value) {
                          setState(() {
                            _anonimitas = value;
                          });
                        },
                        onSaved: (value) => _anonimitas = value,
                      ),
                      if (_anonimitas == 'Sertakan Nama')
                        _buildTextField(
                          label: 'Nama Anonimitas',
                          hint: 'Nama Anda',
                          controller: _namaAnonimitasController,
                          onSaved: (value) => _namaAnonimitasController.text = value!,
                          validator: (value) => value!.isEmpty ? 'Field tidak boleh kosong' : null,
                        ),
                      _buildTextField(
                        label: 'Nomor Telepon',
                        hint: '+62 ...',
                        controller: _noTeleponController,
                        onSaved: (value) => _noTeleponController.text = value!,
                        validator: (value) => value!.isEmpty || int.tryParse(value) == null
                          ? 'Field ini tidak boleh kosong'
                          : null,
                        isNumber: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 34),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Form(
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2F5061),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding:
                                EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                          ),
                          child: const Text(
                            'AJUKAN',
                            style: TextStyle(
                              fontFamily: 'Ubuntu',
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> fields}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFC4DFE2),
        borderRadius: BorderRadius.circular(7),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF233C49),
                  ),
                ),
                SizedBox(height: 0),
              ],
            ),
          ),
          ...fields,
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tanggal Kejadian', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tanggalKejadianController,
                readOnly: true, 
                decoration: InputDecoration(
                  hintText: 'Pilih tanggal',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDateKejadian = picked;
                      _tanggalKejadianController.text = DateFormat('yyyy-MM-dd').format(picked);
                    });
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, size: 24.0), 
              padding: EdgeInsets.zero,
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDateKejadian = picked;
                    _tanggalKejadianController.text = DateFormat('yyyy-MM-dd').format(picked);
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FormFieldSetter<String?> onSaved,
    required FormFieldValidator<String?> validator,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
                fontFamily: 'Ubuntu',
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide.none,
              ),
            ),
            onSaved: onSaved,
            validator: validator,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldSetter<String?> onSaved,
    String? currentValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: currentValue,
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              filled: true,
              fillColor: Colors.white,
            ),
            onSaved: onSaved,
          ),
        ],
      ),
    );
  }
}
