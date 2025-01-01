import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditUserProfilePage extends StatefulWidget {
  const EditUserProfilePage({super.key});

  @override
  _EditUserProfilePageState createState() => _EditUserProfilePageState();
}

class _EditUserProfilePageState extends State<EditUserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isPasswordHidden = true;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _namaLengkapController;
  late TextEditingController _tempatLahirController;
  late TextEditingController _provinsiController;
  late TextEditingController _kotaKabupatenController;
  late TextEditingController _tanggalLahirController;
  late TextEditingController _jenisKelaminController;
  late TextEditingController _noTeleponController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _namaLengkapController = TextEditingController();
    _tempatLahirController = TextEditingController();
    _provinsiController = TextEditingController();
    _kotaKabupatenController = TextEditingController();
    _tanggalLahirController = TextEditingController();
    _jenisKelaminController = TextEditingController();
    _noTeleponController = TextEditingController();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          setState(() {
            _emailController.text = userData['email'] ?? '';
            _namaLengkapController.text = userData['namaLengkap'] ?? '';
            _provinsiController.text = userData['provinsi'] ?? '';
            _kotaKabupatenController.text = userData['kotaKabupaten'] ?? '';
            _tempatLahirController.text = userData['tempatLahir'] ?? '';
            _selectedDate = (userData['tanggalLahir'] as Timestamp?)?.toDate();
            _tanggalLahirController.text = _selectedDate != null
                ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                : '';
            _selectedGender = userData['jenisKelamin'] ?? '';
            _noTeleponController.text = userData['noTelepon']?.toString() ?? '';
          });
        }
      }
    } catch (e) {
      print('Error memuat data user: $e');
    }
  }

  Future<void> _updateUserInfo() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

          await userDoc.update({
            'email': _emailController.text,
            'namaLengkap': _namaLengkapController.text,
            'tempatLahir': _tempatLahirController.text,
            'provinsi': _provinsiController.text,
            'kotaKabupaten': _kotaKabupatenController.text,
            'tanggalLahir': _selectedDate,
            'jenisKelamin': _selectedGender,
            'noTelepon': int.tryParse(_noTeleponController.text),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diubah')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error memperbarui data user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui data')),
        );
      }
    }
  }

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _tempatLahirController.dispose();
    _provinsiController.dispose();
    _kotaKabupatenController.dispose();
    _tanggalLahirController.dispose();
    _jenisKelaminController.dispose();
    _noTeleponController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4297A0), 
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE2DED0),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 60),
                const Center(
                  child: Text(
                    'UBAH PROFIL',
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FCFC),
                              borderRadius: BorderRadius.circular(7.0),
                              border: Border.all(color: const Color(0xFF4297A0)),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildProfilePictureFeature(),
                                  _buildTextField(
                                    label: 'Nama Lengkap',
                                    hint: 'BUDI WIJAYA',
                                    controller: _namaLengkapController,
                                  ),
                                  _buildTextField(
                                    label: 'Tempat Lahir',
                                    hint: 'Sukabumi',
                                    controller: _tempatLahirController,
                                  ),
                                  _buildTextField(
                                    label: 'Provinsi Domisili',
                                    hint: 'Jawa Barat',
                                    controller: _provinsiController,
                                  ),
                                  _buildTextField(
                                    label: 'Kota/Kabupaten Domisili',
                                    hint: 'Bandung',
                                    controller: _kotaKabupatenController,
                                  ),                                  
                                  _buildDateField(
                                    hint: _tanggalLahirController.text,
                                    selectedDate: _selectedDate,
                                    onSelect: (date) => setState(() {
                                      _selectedDate = date;
                                      _tanggalLahirController.text = DateFormat('yyyy-MM-dd').format(date);
                                    }),
                                  ),
                                  _buildGenderField(),
                                  _buildTextField(
                                    label: 'Nomor Telepon',
                                    hint: '081236484878',
                                    controller: _noTeleponController,
                                    keyboardType: TextInputType.phone,
                                  ),
                                  _buildTextField(
                                    label: 'Username',
                                    hint: 'budywjy_',
                                    controller: _emailController,
                                  ),
                                  _buildTextField(
                                    label: 'Password',
                                    hint: '********',
                                    controller: _passwordController,
                                    obscureText: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 41),
                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: _updateUserInfo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFCDC2AE),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                      horizontal: 45.0,
                                    ),
                                  ),
                                  child: const Text(
                                    'SIMPAN',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      fontFamily: 'Ubuntu',
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                    height: 23),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfilePictureFeature() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Profil',
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: const AssetImage('assets/user-home/profile-logo.png'),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFE0E5E7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: BorderSide.none,
              ),
              hintText: hint,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildDateField({
    required String hint,
    required DateTime? selectedDate,
    required void Function(DateTime) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Lahir',
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFE0E5E7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                        borderSide: BorderSide.none,
                      ),
                      hintText: hint,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != selectedDate) {
                        onSelect(picked);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != selectedDate) {
                    onSelect(picked);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2F5061),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
                child: const Icon(Icons.calendar_today, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kelamin',
          style: TextStyle(
            fontFamily: 'Ubuntu',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: [
            Row(
              children: [
                Radio(
                  value: 'Laki-Laki',
                  groupValue: _selectedGender,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const Text('Laki-Laki'),
              ],
            ),
            Row(
              children: [
                Radio(
                  value: 'Perempuan',
                  groupValue: _selectedGender,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const Text('Perempuan'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
