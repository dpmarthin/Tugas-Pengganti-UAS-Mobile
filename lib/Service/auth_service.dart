import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signup({
    required String email,
    required String password,
    required String namaLengkap,
    required String tempatLahir,
    required DateTime tanggalLahir,
    required String provinsi,
    required String kotaKabupaten,
    required String jenisKelamin,
    required int noTelepon,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email.trim(),
        'namaLengkap': namaLengkap.trim(),
        'tempatLahir': tempatLahir.trim(),
        'tanggalLahir': tanggalLahir,
        'provinsi': provinsi.trim(),
        'kotaKabupaten': kotaKabupaten.trim(),
        'jenisKelamin': jenisKelamin,
        'noTelepon': noTelepon,
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  signOut() async {
    _auth.signOut();
  }
}