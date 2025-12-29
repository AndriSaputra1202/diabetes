// Service untuk menangani autentikasi pengguna menggunakan Firebase Authentication
// dan menyimpan data pengguna ke Firestore

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _usersCollection = 'users';

  // Register user baru
  Future<UserModel> signUp(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email dan password tidak boleh kosong');
      }
      if (password.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String userId = userCredential.user!.uid;

      UserModel newUser = UserModel(
        id: userId,
        name: userData['name'] ?? '',
        email: email,
        age: userData['age'] ?? 0,
        gender: userData['gender'] ?? '',
        weight: userData['weight']?.toDouble() ?? 0.0,
        height: userData['height']?.toDouble() ?? 0.0,
        bloodSugar: userData['bloodSugar']?.toDouble() ?? 0.0,
        targetCarbs: userData['targetCarbs']?.toDouble() ?? 0.0,
        role: userData['role'] ?? 'patient',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .set(newUser.toJson());

      return newUser;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email sudah terdaftar');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'weak-password':
          throw Exception('Password terlalu lemah');
        case 'operation-not-allowed':
          throw Exception('Operasi tidak diizinkan');
        default:
          throw Exception('Gagal mendaftar: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Login user (PERBAIKAN UTAMA DISINI)
  Future<UserModel> signIn(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email dan password tidak boleh kosong');
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      DocumentSnapshot userDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception('Data pengguna tidak ditemukan');
      }

      // ✅ PERBAIKAN: Ambil data dan suntikkan ID manual
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      data['id'] = userDoc.id; // Masukkan ID dokumen ke dalam map data

      // Handle Typo di Database (createAt vs createdAt)
      if (data.containsKey('createAt') && !data.containsKey('createdAt')) {
        data['createdAt'] = data['createAt'];
      }

      return UserModel.fromJson(data);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar');
        case 'wrong-password':
          throw Exception('Password salah');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'user-disabled':
          throw Exception('Akun telah dinonaktifkan');
        case 'too-many-requests':
          throw Exception('Terlalu banyak percobaan.');
        default:
          throw Exception('Gagal login: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  /// Logout user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Gagal logout: $e');
    }
  }

  /// Dapatkan data user login (PERBAIKAN JUGA DISINI)
  Future<UserModel?> getCurrentUser() async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      DocumentSnapshot userDoc = await _firestore
          .collection(_usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) return null;

      // ✅ PERBAIKAN: Ambil data dan suntikkan ID manual
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      data['id'] = userDoc.id;

      // Handle Typo di Database
      if (data.containsKey('createAt') && !data.containsKey('createdAt')) {
        data['createdAt'] = data['createAt'];
      }

      return UserModel.fromJson(data);
    } catch (e) {
      // Jangan throw exception di sini agar tidak crash saat splash screen
      // Cukup return null agar user diarahkan ke login
      print('Error get current user: $e');
      return null;
    }
  }

  // ... (Sisa method lain di bawah tetap sama, tidak perlu diubah)
  String? getCurrentUserId() => _auth.currentUser?.uid;

  Future<void> resetPassword(String email) async {
    try {
      if (email.isEmpty) throw Exception('Email tidak boleh kosong');
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Gagal kirim email: ${e.message}');
    }
  }

  bool isLoggedIn() => _auth.currentUser != null;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> updateUserData(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    await _firestore.collection(_usersCollection).doc(userId).update(userData);
  }

  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception('No user login');
      await _firestore.collection(_usersCollection).doc(user.uid).delete();
      await user.delete();
    } catch (e) {
      throw Exception('Gagal hapus akun: $e');
    }
  }
}
