// Digunakan untuk role 'doctor' dalam aplikasi monitoring gizi diabetes

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/meal_model.dart';
import '../models/recommendation_model.dart';
import '../services/database_service.dart';
import '../services/recommendation_service.dart';

class DoctorProvider extends ChangeNotifier {
  // Services
  final DatabaseService _databaseService = DatabaseService();
  final RecommendationService _recommendationService = RecommendationService();

  // List semua pasien
  List<UserModel> _patientsList = [];
  // List pasien yang sudah difilter (untuk search)
  List<UserModel> _filteredPatients = [];
  // Pasien yang sedang dipilih/dimonitor
  UserModel? _selectedPatient;
  // Meals dari pasien yang dipilih
  List<MealModel> _selectedPatientMeals = [];
  // Statistik pasien yang dipilih
  Map<String, dynamic>? _patientStats;
  // List rekomendasi yang sudah dikirim oleh dokter
  List<RecommendationModel> _sentRecommendations = [];
  // Loading state
  bool _isLoading = false; // Error message
  String? _errorMessage;

  // Get list semua pasien
  List<UserModel> get patientsList => _patientsList;
  // Get list pasien yang sudah difilter
  List<UserModel> get filteredPatients => _filteredPatients;
  // Get pasien yang sedang dipilih
  UserModel? get selectedPatient => _selectedPatient;
  // Get meals dari pasien yang dipilih
  List<MealModel> get selectedPatientMeals => _selectedPatientMeals;
  // Get statistik pasien
  Map<String, dynamic>? get patientStats => _patientStats;
  // Get rekomendasi yang sudah dikirim
  List<RecommendationModel> get sentRecommendations => _sentRecommendations;
  // Get loading state
  bool get isLoading => _isLoading;
  // Get error message
  String? get errorMessage => _errorMessage;
  // Get jumlah total pasien
  int get totalPatients => _patientsList.length;
  // Get jumlah rekomendasi yang sudah dikirim
  int get totalRecommendationsSent => _sentRecommendations.length;
  // Check apakah ada pasien yang dipilih
  bool get hasSelectedPatient => _selectedPatient != null;

  Future<void> loadAllPatients() async {
    try {
      // Set loading state
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load semua users dengan role 'patient'
      List<UserModel> patients = await _databaseService.getUsersByRole(
        'patient',
      );

      // Sort by name
      patients.sort((a, b) => a.name.compareTo(b.name));

      _patientsList = patients;
      _filteredPatients = patients;

      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchPatients(String query) {
    if (query.isEmpty) {
      // Show all patients
      _filteredPatients = _patientsList;
    } else {
      // Filter by name (case insensitive)
      String lowerQuery = query.toLowerCase();
      _filteredPatients = _patientsList
          .where((patient) => patient.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    notifyListeners();
  }

  Future<void> selectPatient(String patientId) async {
    try {
      // Set loading state
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Find patient dari list
      UserModel? patient = _patientsList.firstWhere(
        (p) => p.id == patientId,
        orElse: () => throw Exception('Pasien tidak ditemukan'),
      );

      // Set selected patient
      _selectedPatient = patient;

      // Load patient meals untuk hari ini
      await loadPatientMeals(patientId);

      // Calculate patient stats
      await _calculatePatientStats(patientId);

      // Clear error
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      // Set error message
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      // Set loading ke false
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load meals dari pasien berdasarkan date range
  // Parameters:
  // - patientId: ID pasien
  // - startDate: Tanggal mulai (optional, default: hari ini)
  // - endDate: Tanggal akhir (optional, default: hari ini)
  Future<void> loadPatientMeals(
    String patientId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Set loading state
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Set default dates jika tidak ada
      DateTime start = startDate ?? DateTime.now();
      DateTime end = endDate ?? DateTime.now();

      // Load meals dari database
      List<MealModel> meals;

      if (startDate == null && endDate == null) {
        // Load hari ini saja
        meals = await _databaseService.getMealsByDate(
          patientId,
          DateTime.now(),
        );
      } else {
        // Load by range
        meals = await _databaseService.getMealsByDateRange(
          patientId,
          start,
          end,
        );
      }

      // Set selected patient meals
      _selectedPatientMeals = meals;

      // Clear error
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      // Set error message
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      // Set loading ke false
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate statistik pasien (7 hari terakhir)
  // Private method
  //
  /// Parameters:
  // - patientId: ID pasien
  Future<void> _calculatePatientStats(String patientId) async {
    try {
      // Get data 7 hari terakhir
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: 6));

      List<Map<String, dynamic>> stats = await _databaseService
          .getNutritionStats(patientId, days: 7);

      if (stats.isEmpty) {
        _patientStats = {
          'avgCarbs': 0.0,
          'avgCalories': 0.0,
          'avgProtein': 0.0,
          'avgFat': 0.0,
          'daysTracked': 0,
        };
        return;
      }

      // Calculate averages
      double totalCarbs = 0;
      double totalCalories = 0;
      double totalProtein = 0;
      double totalFat = 0;

      for (var dayStat in stats) {
        totalCarbs += dayStat['carbs'] ?? 0;
        totalCalories += dayStat['calories'] ?? 0;
        totalProtein += dayStat['protein'] ?? 0;
        totalFat += dayStat['fat'] ?? 0;
      }

      int daysTracked = stats.length;

      _patientStats = {
        'avgCarbs': totalCarbs / daysTracked,
        'avgCalories': totalCalories / daysTracked,
        'avgProtein': totalProtein / daysTracked,
        'avgFat': totalFat / daysTracked,
        'daysTracked': daysTracked,
        'totalCarbs': totalCarbs,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalFat': totalFat,
      };
    } catch (e) {
      _patientStats = null;
    }
  }

  void clearSelectedPatient() {
    _selectedPatient = null;
    _selectedPatientMeals = [];
    _patientStats = null;

    notifyListeners();
  }

  // Refresh data pasien yang dipilih
  //
  // Returns: void
  Future<void> refreshSelectedPatient() async {
    if (_selectedPatient != null) {
      await selectPatient(_selectedPatient!.id);
    }
  }

  Future<bool> sendRecommendation({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String category,
    required String message,
    required List<String> foods,
    required String priority,
  }) async {
    try {
      // Set loading state
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Validasi input
      if (message.isEmpty) {
        throw Exception('Pesan rekomendasi tidak boleh kosong');
      }

      // Create recommendation model
      RecommendationModel recommendation = RecommendationModel(
        id: '', // Will be auto-generated
        patientId: patientId,
        doctorId: doctorId,
        doctorName: doctorName,
        category: category,
        message: message,
        foods: foods,
        priority: priority,
        date: DateTime.now(),
        read: false,
      );

      // Save to database
      String recId = await _recommendationService.sendRecommendation(
        patientId,
        recommendation,
      );

      // Update recommendation dengan ID
      recommendation = recommendation.copyWith(id: recId);

      // Add ke sent recommendations
      _sentRecommendations.insert(0, recommendation);

      // Clear error
      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      // Set error message
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    } finally {
      // Set loading ke false
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load rekomendasi yang sudah dikirim oleh dokter
  ///
  /// Parameters:
  /// - doctorId: ID dokter
  Future<void> loadSentRecommendations(String doctorId) async {
    try {
      // Set loading state
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load recommendations dari service
      List<RecommendationModel> recommendations = await _recommendationService
          .getDoctorRecommendations(doctorId);

      // Set sent recommendations
      _sentRecommendations = recommendations;

      // Clear error
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      // Set error message
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      // Set loading ke false
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update recommendation
  ///
  /// Parameters:
  /// - recId: ID recommendation
  /// - data: Data yang akan diupdate
  ///
  /// Returns: true jika berhasil, false jika gagal
  Future<bool> updateRecommendation(
    String recId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Set loading state
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Update di database
      await _recommendationService.updateRecommendation(recId, data);

      // Update di local list
      int index = _sentRecommendations.indexWhere((rec) => rec.id == recId);
      if (index != -1) {
        RecommendationModel oldRec = _sentRecommendations[index];
        _sentRecommendations[index] = oldRec.copyWith(
          category: data['category'] ?? oldRec.category,
          message: data['message'] ?? oldRec.message,
          foods: data['foods'] ?? oldRec.foods,
          priority: data['priority'] ?? oldRec.priority,
        );
      }

      // Clear error
      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      // Set error message
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    } finally {
      // Set loading ke false
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete recommendation
  ///
  /// Parameters:
  /// - recId: ID recommendation
  ///
  /// Returns: true jika berhasil, false jika gagal
  Future<bool> deleteRecommendation(String recId) async {
    try {
      // Set loading state
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Delete dari database
      await _recommendationService.deleteRecommendation(recId);

      // Remove dari local list
      _sentRecommendations.removeWhere((rec) => rec.id == recId);

      // Clear error
      _errorMessage = null;

      notifyListeners();

      return true;
    } catch (e) {
      // Set error message
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      return false;
    } finally {
      // Set loading ke false
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get rekomendasi untuk pasien tertentu
  ///
  /// Parameters:
  /// - patientId: ID pasien
  ///
  /// Returns: List<RecommendationModel>
  List<RecommendationModel> getRecommendationsForPatient(String patientId) {
    return _sentRecommendations
        .where((rec) => rec.patientId == patientId)
        .toList();
  }

  /// Get patient dengan konsumsi karbohidrat tertinggi
  ///
  /// Returns: List<Map> dengan patient data dan avg carbs
  Future<List<Map<String, dynamic>>> getHighCarbsPatients() async {
    try {
      List<Map<String, dynamic>> highCarbsPatients = [];

      for (var patient in _patientsList) {
        // Get nutrition stats untuk patient ini
        List<Map<String, dynamic>> stats = await _databaseService
            .getNutritionStats(patient.id, days: 7);

        if (stats.isNotEmpty) {
          double totalCarbs = 0;
          for (var stat in stats) {
            totalCarbs += stat['carbs'] ?? 0;
          }
          double avgCarbs = totalCarbs / stats.length;

          // Check jika melebihi target
          if (avgCarbs > patient.targetCarbs) {
            highCarbsPatients.add({
              'patient': patient,
              'avgCarbs': avgCarbs,
              'targetCarbs': patient.targetCarbs,
              'difference': avgCarbs - patient.targetCarbs,
            });
          }
        }
      }

      // Sort by difference (descending)
      highCarbsPatients.sort(
        (a, b) =>
            (b['difference'] as double).compareTo(a['difference'] as double),
      );

      return highCarbsPatients;
    } catch (e) {
      return [];
    }
  }

  // Get statistik umum dokter
  //
  // Returns: Map dengan statistik
  Map<String, dynamic> getDoctorStats() {
    int totalRecommendations = _sentRecommendations.length;
    int highPriority = _sentRecommendations
        .where((rec) => rec.priority == 'Tinggi')
        .length;
    int mediumPriority = _sentRecommendations
        .where((rec) => rec.priority == 'Sedang')
        .length;
    int lowPriority = _sentRecommendations
        .where((rec) => rec.priority == 'Rendah')
        .length;

    // Group by category
    Map<String, int> byCategory = {};
    for (var rec in _sentRecommendations) {
      byCategory[rec.category] = (byCategory[rec.category] ?? 0) + 1;
    }

    return {
      'totalPatients': _patientsList.length,
      'totalRecommendations': totalRecommendations,
      'highPriority': highPriority,
      'mediumPriority': mediumPriority,
      'lowPriority': lowPriority,
      'byCategory': byCategory,
    };
  }

  // Get patient yang belum tracking hari ini
  //
  // Returns: List<UserModel>
  Future<List<UserModel>> getPatientsWithoutTodayTracking() async {
    try {
      List<UserModel> inactivePatients = [];
      DateTime today = DateTime.now();

      for (var patient in _patientsList) {
        List<MealModel> todayMeals = await _databaseService.getMealsByDate(
          patient.id,
          today,
        );

        if (todayMeals.isEmpty) {
          inactivePatients.add(patient);
        }
      }

      return inactivePatients;
    } catch (e) {
      return [];
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Clear error message
  ///
  /// Returns: void
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset semua data (untuk logout atau switch user)
  //
  // Returns: void
  void reset() {
    _patientsList = [];
    _filteredPatients = [];
    _selectedPatient = null;
    _selectedPatientMeals = [];
    _patientStats = null;
    _sentRecommendations = [];
    _errorMessage = null;
    _isLoading = false;

    notifyListeners();
  }

  // Refresh semua data
  //
  // Parameters:
  // - doctorId: ID dokter
  //
  // Returns: void
  Future<void> refreshAllData(String doctorId) async {
    try {
      // Set loading state
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load patients
      await loadAllPatients();

      // Load sent recommendations
      await loadSentRecommendations(doctorId);

      // Refresh selected patient if any
      if (_selectedPatient != null) {
        await refreshSelectedPatient();
      }

      // Clear error
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      // Set error message
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      // Set loading ke false
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sort patients by name
  //
  /// Parameters:
  // - ascending: true untuk A-Z, false untuk Z-A
  //
  // Returns: void
  void sortPatientsByName({bool ascending = true}) {
    if (ascending) {
      _filteredPatients.sort((a, b) => a.name.compareTo(b.name));
    } else {
      _filteredPatients.sort((a, b) => b.name.compareTo(a.name));
    }

    notifyListeners();
  }

  // Sort patients by blood sugar
  //
  // Parameters:
  // - ascending: true untuk rendah ke tinggi, false untuk tinggi ke rendah
  //
  // Returns: void
  void sortPatientsByBloodSugar({bool ascending = true}) {
    if (ascending) {
      _filteredPatients.sort((a, b) => a.bloodSugar.compareTo(b.bloodSugar));
    } else {
      _filteredPatients.sort((a, b) => b.bloodSugar.compareTo(a.bloodSugar));
    }

    notifyListeners();
  }

  /// Get average stats dari selected patient meals
  ///
  /// Returns: Map dengan average values
  Map<String, double> getSelectedPatientMealsAverage() {
    if (_selectedPatientMeals.isEmpty) {
      return {'avgCarbs': 0, 'avgCalories': 0, 'avgProtein': 0, 'avgFat': 0};
    }

    double totalCarbs = 0;
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;

    for (var meal in _selectedPatientMeals) {
      totalCarbs += meal.totalCarbs;
      totalCalories += meal.totalCalories;
      totalProtein += meal.totalProtein;
      totalFat += meal.totalFat;
    }

    int count = _selectedPatientMeals.length;

    return {
      'avgCarbs': totalCarbs / count,
      'avgCalories': totalCalories / count,
      'avgProtein': totalProtein / count,
      'avgFat': totalFat / count,
    };
  }
}
