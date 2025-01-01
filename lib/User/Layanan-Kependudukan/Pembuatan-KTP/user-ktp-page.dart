import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserKtpPage extends StatefulWidget {
  const UserKtpPage({super.key});

  @override
  _UserKtpPageState createState() => _UserKtpPageState();
}

class _UserKtpPageState extends State<UserKtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _alamatLengkapController = TextEditingController();
  final _agamaController = TextEditingController();
  final _jenisPekerjaanController = TextEditingController();
  String? _alasanPembuatan;
  String? _jenisKelamin;
  String? _statusPerkawinan;
  DateTime? _selectedDateLahir;

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
        'alasanPembuatan': _alasanPembuatan,
        'nik': int.tryParse(_nikController.text),
        'namaLengkap': _namaLengkapController.text,
        'tempatLahir': _tempatLahirController.text,
        'tanggalLahir': _selectedDateLahir ?? DateTime.now(),
        'jenisKelamin': _jenisKelamin,
        'alamatLengkap': _alamatLengkapController.text,
        'agama': _agamaController.text,
        'jenisPekerjaan': _jenisPekerjaanController.text,
        'statusPerkawinan': _statusPerkawinan,
      };
      
      try {
        await FirebaseFirestore.instance.collection('userKTP').add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data diri KTP berhasil didaftarkan')),
        );

        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data diri KTP gagal didaftarkan: $error')),
        );
      }          
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4297A0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Color(0xFF4297A0),
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 35.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE2DED0),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Colors.black, size: 18.0),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Text(
                  'FORMULIR PENGAJUAN KTP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              Divider(
                color: Colors.white,
                thickness: 1,
              ),
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFE2DED0),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdownField(
                      label: 'Alasan Pembuatan',
                      items: ['Telah berusia 17 tahun', 'KTP hilang/rusak'],
                      currentValue: _alasanPembuatan,
                      onChanged: (value) {
                        setState(() {
                          _alasanPembuatan = value;
                        });
                      },
                      onSaved: (value) => _alasanPembuatan = value,
                    ),                                         
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF3AB3B1),
                  borderRadius: BorderRadius.circular(7),
                ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: 'NIK',
                        hint: 'nomor induk kependudukan',
                        controller: _nikController,
                        onSaved: (value) => _nikController.text = value!,
                        validator: (value) => value!.isEmpty || int.tryParse(value) == null
                          ? 'Field ini tidak boleh kosong'
                          : null,
                        isNumber: true,
                      ),                      
                      _buildDateField(),
                      _buildTextField(
                        label: 'Nama Lengkap',
                        hint: 'nama lengkap huruf kapital',
                        controller: _namaLengkapController,
                        onSaved: (value) => _namaLengkapController.text = value!,
                        validator: (value) => value!.isEmpty ? 'Field tidak boleh kosong' : null,
                      ),
                      _buildTextField(
                        label: 'Tempat Lahir',
                        hint: 'tempat lahir',
                        controller: _tempatLahirController,
                        onSaved: (value) => _tempatLahirController.text = value!,
                        validator: (value) => value!.isEmpty ? 'Field tidak boleh kosong' : null,
                      ),                      
                      _buildDropdownField(
                        label: 'Jenis Kelamin',
                        items: ['Laki-Laki', 'Perempuan'],
                        currentValue: _jenisKelamin,
                        onChanged: (value) {
                          setState(() {
                            _jenisKelamin = value;
                          });
                        },
                        onSaved: (value) => _jenisKelamin = value,
                      ), 
                      _buildTextField(
                        label: 'Alamat Lengkap',
                        hint: 'alamat sesuai KTP',
                        controller: _alamatLengkapController,
                        onSaved: (value) => _alamatLengkapController.text = value!,
                        validator: (value) => value!.isEmpty ? 'Field tidak boleh kosong' : null,
                      ),                                            
                      _buildTextField(
                        label: 'Agama',
                        hint: 'agama',
                        controller: _agamaController,
                        onSaved: (value) => _agamaController.text = value!,
                        validator: (value) => value!.isEmpty ? 'Field tidak boleh kosong' : null,
                      ),                       
                      _buildTextField(
                        label: 'Jenis Pekerjaan',
                        hint: 'jenis pekerjaan',
                        controller: _jenisPekerjaanController,
                        onSaved: (value) => _jenisPekerjaanController.text = value!,
                        validator: (value) => value!.isEmpty ? 'Field tidak boleh kosong' : null,
                      ),
                      _buildDropdownField(
                        label: 'Status Perkawinan',
                        items: ['Belum menikah', 'Sudah menikah', 'Cerai hidup', 'Cerai mati'],
                        currentValue: _statusPerkawinan,
                        onChanged: (value) {
                          setState(() {
                            _statusPerkawinan = value;
                          });
                        },
                        onSaved: (value) => _statusPerkawinan = value,
                      ),                        
                    ],
                  ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: Form(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFCDC2AE),
                      padding: EdgeInsets.symmetric(horizontal: 40),
                    ),
                    child: Text(
                      'Ajukan',
                      style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Ubuntu',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCustomDropdownField({
    required BuildContext context,
    required String label,
    required List<String> items,
    required FormFieldSetter<String?> onSave,
    required FormFieldValidator<String?> validator,
    String? currentValue,
    ValueChanged<String?>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: InputBorder.none,
              ),
              value: items.contains(currentValue) ? currentValue : null,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _alasanPembuatan = value;
                });
                if (onChanged != null) {
                  onChanged(value);
                }
              },
              onSaved: onSave,
              validator: validator,
              dropdownColor: Colors.white,
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tanggal Lahir', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _tanggalLahirController,
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
                      _selectedDateLahir = picked;
                      _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
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
                    _selectedDateLahir = picked;
                    _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(picked);
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
    required controller,
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