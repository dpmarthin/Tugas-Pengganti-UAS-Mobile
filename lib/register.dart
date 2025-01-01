import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/Service/auth_service.dart';
import 'login.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaLengkapController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _provinsiController = TextEditingController();
  final _kotaKabupatenController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _noTeleponController = TextEditingController();

  String _selectedGender = 'Laki-Laki';
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool isPasswordHidden = true;

  void _signup() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    String? result = await _auth.signup(
      email: _emailController.text,
      password: _passwordController.text,
      namaLengkap: _namaLengkapController.text,
      tempatLahir: _tempatLahirController.text,
      tanggalLahir: _selectedDate ?? DateTime.now(),
      provinsi: _provinsiController.text,
      kotaKabupaten: _kotaKabupatenController.text,
      jenisKelamin: _selectedGender,
      noTelepon: int.tryParse(_noTeleponController.text) ?? 0,
    );

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register berhasil')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register gagal: $result')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF5F6),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4297A0),
                    borderRadius: BorderRadius.circular(7.0),
                  ),
                  child: Column(
                    children: [
                      _buildTextField(
                        label: 'Email',
                        hint: 'Masukkan email anda',
                        controller: _emailController,
                      ),
                      _buildPasswordField(),
                      const SizedBox(height: 15),
                      _buildTextField(
                        label: 'Nama Lengkap',
                        hint: 'Tulis nama lengkap anda',
                        controller: _namaLengkapController,
                      ),
                      _buildTextField(
                        label: 'Tempat Lahir',
                        hint: 'Tulis tempat lahir anda',
                        controller: _tempatLahirController,
                      ),
                      _buildDateField(),
                      _buildTextField(
                        label: 'Provinsi',
                        hint: 'Tulis domisili provinsi anda',
                        controller: _provinsiController,
                      ),
                      _buildTextField(
                        label: 'Kota/Kabupaten',
                        hint: 'Tulis domisili kota/kabupaten anda',
                        controller: _kotaKabupatenController,
                      ),                      
                      _buildTextField(
                        label: 'No. Telepon',
                        hint: '+62...',
                        controller: _noTeleponController,
                        keyboardType: TextInputType.phone,
                      ),      
                      _buildDropdownField(
                        label: 'Jenis Kelamin',
                        items: ['Laki-Laki', 'Perempuan'],
                        selectedValue: _selectedGender,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue!;
                          });
                        },
                        onSaved: (String? newValue) {
                          _selectedGender = newValue!;
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Silakan pilih jenis kelamin';
                          }
                          return null;
                        },
                      ),                         
                      const SizedBox(height: 20),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Image.asset('assets/icon.png', height: 100),
              const SizedBox(height: 10),
              const Text(
                'REGISTRASI AKUN',
                style: TextStyle(
                  fontFamily: 'Ubuntu',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Klik disini untuk login',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextFormField(
          controller: _passwordController,
          obscureText: isPasswordHidden,
          decoration: InputDecoration(
            hintText: 'Masukkan password',
            fillColor: Colors.white,
            filled: true,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordHidden ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  isPasswordHidden = !isPasswordHidden;
                });
              },
            ),
          ),
        ),
      ],
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
                      _selectedDate = picked;
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
                    _selectedDate = picked;
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

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedValue!.isEmpty ? 'Laki-Laki' : selectedValue,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7.0),
            ),
          ),
          onChanged: onChanged,
          onSaved: onSaved,
          validator: validator,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F5061),
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Masuk',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Ubuntu',
                ),
              ),
            ),
          );
  }
}
