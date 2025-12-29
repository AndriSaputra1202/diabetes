/// File: lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  String? get currentUserId => _currentUser?.id;
  String? get currentUserRole => _currentUser?.role;
  bool get isPatient => _currentUser?.role == 'patient';
  bool get isDoctor => _currentUser?.role == 'doctor';

  Future<void> initialize() async {
    await checkAuthStatus();
  }

  //AUTHENTICATION METHODS
  // Register user baru

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required double weight,
    required double height,
    required double bloodSugar,
    required double targetCarbs,
    String role = 'patient',
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('Email, password, dan nama harus diisi');
      }

      Map<String, dynamic> userData = {
        'name': name,
        'age': age,
        'gender': gender,
        'weight': weight,
        'height': height,
        'bloodSugar': bloodSugar,
        'targetCarbs': targetCarbs,
        'role': role,
      };

      UserModel newUser = await _authService.signUp(email, password, userData);

      _currentUser = newUser;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email dan password harus diisi');
      }

      UserModel user = await _authService.signIn(email, password);

      _currentUser = user;
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout user
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cek status authentication (Persistensi Login)
  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      UserModel? user = await _authService.getCurrentUser();
      _currentUser = user;
      _errorMessage = null;
    } catch (e) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset password (KEMBALI ADA)
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (email.isEmpty) throw Exception('Email harus diisi');

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //PROFILE METHODS

  //Update Profile (PERBAIKAN UTAMA)
  //Menyimpan ke database DAN update tampilan lokal
  Future<bool> updateProfile({
    String? name,
    int? age,
    String? gender,
    double? weight,
    double? height,
    double? bloodSugar,
    double? targetCarbs,
  }) async {
    try {
      if (_currentUser == null) throw Exception('User tidak ditemukan');

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (age != null) updateData['age'] = age;
      if (gender != null) updateData['gender'] = gender;
      if (weight != null) updateData['weight'] = weight;
      if (height != null) updateData['height'] = height;
      if (bloodSugar != null) updateData['bloodSugar'] = bloodSugar;
      if (targetCarbs != null) updateData['targetCarbs'] = targetCarbs;

      if (updateData.isEmpty) return true;

      await _databaseService.updateUser(_currentUser!.id, updateData);

      //Update local state agar UI langsung berubah
      _currentUser = _currentUser!.copyWith(
        name: name,
        age: age,
        gender: gender,
        weight: weight,
        height: height,
        bloodSugar: bloodSugar,
        targetCarbs: targetCarbs,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Reload data user dari server
  Future<void> reloadUserData() async {
    if (_currentUser == null) return;
    try {
      _isLoading = true;
      notifyListeners();

      UserModel? user = await _databaseService.getUser(_currentUser!.id);
      if (user != null) {
        _currentUser = user;
      }
    } catch (e) {
      debugPrint("Gagal reload user data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    try {
      if (_currentUser == null) throw Exception('User tidak ditemukan');

      _isLoading = true;
      notifyListeners();

      await _databaseService.deleteUser(_currentUser!.id);
      await _authService.deleteAccount();

      _currentUser = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //HELPER METHODS

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  double getBMI() {
    if (_currentUser == null) return 0;
    return _currentUser!.calculateBMI();
  }

  String getBMIStatus() {
    if (_currentUser == null) return 'N/A';
    return _currentUser!.getBMIStatus();
  }

  void setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
