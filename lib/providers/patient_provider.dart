/// File: lib/providers/patient_provider.dart
import 'package:flutter/foundation.dart';
import '../models/meal_model.dart';
import '../models/recommendation_model.dart';
import '../services/database_service.dart';
import '../services/recommendation_service.dart';

class PatientProvider extends ChangeNotifier {
  // Services
  final DatabaseService _databaseService = DatabaseService();
  final RecommendationService _recommendationService = RecommendationService();

  // Data Makanan (Meals)
  List<MealModel> _todayMeals = [];
  double _totalCarbs = 0;
  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalFat = 0;

  // Target Harian (Default)
  double targetCarbs = 250;
  double targetCalories = 2000;
  double targetProtein = 75;
  double targetFat = 67;

  // Data Rekomendasi
  List<RecommendationModel> _recommendations = [];
  int _unreadRecommendationsCount = 0;

  // Status State
  bool _isLoading = false;
  String? _errorMessage;

  List<MealModel> get todayMeals => _todayMeals;

  double get totalCarbs => _totalCarbs;
  double get totalCalories => _totalCalories;
  double get totalProtein => _totalProtein;
  double get totalFat => _totalFat;

  List<RecommendationModel> get recommendations => _recommendations;
  int get unreadRecommendationsCount => _unreadRecommendationsCount;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Computed Properties
  double get carbsPercentage =>
      targetCarbs == 0 ? 0 : (_totalCarbs / targetCarbs) * 100;
  double get caloriesPercentage =>
      targetCalories == 0 ? 0 : (_totalCalories / targetCalories) * 100;
  double get remainingCarbs => targetCarbs - _totalCarbs;

  /// Set target nutrisi (dari user profile)
  void setTargets({
    double? carbs,
    double? calories,
    double? protein,
    double? fat,
  }) {
    if (carbs != null) targetCarbs = carbs;
    if (calories != null) targetCalories = calories;
    if (protein != null) targetProtein = protein;
    if (fat != null) targetFat = fat;
    notifyListeners();
  }

  /// Refresh semua data (Meals + Recommendations)
  Future<void> refreshData(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([loadTodayMeals(userId), loadRecommendations(userId)]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //MEAL LOGIC

  /// Load meals hari ini
  Future<void> loadTodayMeals(String userId) async {
    try {
      final meals = await _databaseService.getMealsByDate(
        userId,
        DateTime.now(),
      );
      _todayMeals = meals;
      _calculateDailyTotals();
    } catch (e) {
      print("Error loading meals: $e");
      throw e;
    }
  }

  /// Hitung total nutrisi
  void _calculateDailyTotals() {
    _totalCarbs = 0;
    _totalCalories = 0;
    _totalProtein = 0;
    _totalFat = 0;

    for (var meal in _todayMeals) {
      _totalCarbs += meal.totalCarbs;
      _totalCalories += meal.totalCalories;
      _totalProtein += meal.totalProtein;
      _totalFat += meal.totalFat;
    }
  }

  /// Tambah meal baru
  Future<bool> addMeal(MealModel meal) async {
    try {
      _isLoading = true;
      notifyListeners();

      String id = await _databaseService.addMeal(meal);

      // Update local list agar UI langsung berubah tanpa fetch ulang
      _todayMeals.add(meal.copyWith(id: id));
      _calculateDailyTotals();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Logika rekomenadsi

  /// Load rekomendasi dokter
  Future<void> loadRecommendations(String userId) async {
    try {
      // Menggunakan RecommendationService (yang sudah diperbaiki ID-nya)
      final recs = await _recommendationService.getPatientRecommendations(
        userId,
      );
      _recommendations = recs;
      _unreadRecommendationsCount = recs.where((r) => !r.read).length;
    } catch (e) {
      print("Error loading recommendations: $e");
      // Jangan throw error agar dashboard tetap jalan
    }
  }

  /// Tandai rekomendasi sudah dibaca
  Future<void> markRecommendationAsRead(String recId) async {
    try {
      //Update di Firebase
      await _recommendationService.markAsRead(recId);

      //Update di Local State (biar cepat & responsif)
      final index = _recommendations.indexWhere((r) => r.id == recId);
      if (index != -1) {
        _recommendations[index] = _recommendations[index].copyWith(read: true);
        _unreadRecommendationsCount = _recommendations
            .where((r) => !r.read)
            .length;
        notifyListeners();
      }
    } catch (e) {
      print("Gagal update status baca: $e");
    }
  }

  // ==================== HELPER ====================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _todayMeals = [];
    _recommendations = [];
    _totalCarbs = 0;
    _unreadRecommendationsCount = 0;
    notifyListeners();
  }
}
