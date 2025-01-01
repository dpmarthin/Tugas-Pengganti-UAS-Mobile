import 'package:flutter/material.dart';
import 'register.dart';
import 'User/user-home.dart';
import '/Service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool isPasswordHidden = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isLoading = true;
      });

      String? result = await _auth.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });   

      if (result == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const UserHome(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login gagal: $result'),
        ));
      } 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4297A0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 40.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FCFC),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 43),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEmailField(),
                          const SizedBox(height: 15),
                          _buildPasswordField(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              _buildSubmitButton(),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset('assets/icon.png', height: 100),
        const SizedBox(height: 10),
        const Text(
          'MASUK AKUN',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Ubuntu',
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Belum memiliki akun?',
              style: TextStyle(fontFamily: 'Ubuntu'),
            ),
            const SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                );
              },
              child: const Text(
                'daftar disini',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Ubuntu',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'Masukkan email anda',
        hintStyle: const TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w300,
          fontFamily: 'Ubuntu',
        ),
        filled: true,
        fillColor: const Color(0xFFE0E5E7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(color: Color(0xFFE0E5E7)),
        ),
      ),
      style: const TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Email tidak boleh kosong';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Format email tidak valid';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: isPasswordHidden,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Masukkan password',
        hintStyle: const TextStyle(
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w300,
          fontFamily: 'Ubuntu',
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordHidden ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              isPasswordHidden = !isPasswordHidden;
            });
          },
        ),
        filled: true,
        fillColor: const Color(0xFFE0E5E7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7.0),
          borderSide: const BorderSide(color: Color(0xFFE0E5E7)),
        ),
      ),
      style: const TextStyle(color: Colors.black, fontFamily: 'Ubuntu'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 45,
      width: 280,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2F5061),
          padding: const EdgeInsets.symmetric(vertical: 10.0),
        ),
        child: const Text(
          'MASUK',
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