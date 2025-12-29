/// File: lib/providers/food_provider.dart
import 'package:flutter/foundation.dart';
import '../models/food_model.dart';
import '../services/food_service.dart';

class FoodProvider extends ChangeNotifier {
  final FoodService _foodService = FoodService();

  List<FoodModel> _allFoods = [];
  List<FoodModel> _filteredFoods = [];

  FoodModel? _selectedFood;
  double _selectedFoodWeight = 0;

  bool _isLoading = false;
  String? _errorMessage;

  List<FoodModel> get allFoods => _allFoods;
  List<FoodModel> get filteredFoods => _filteredFoods;
  FoodModel? get selectedFood => _selectedFood;
  double get selectedFoodWeight => _selectedFoodWeight;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasSelectedFood => _selectedFood != null;

  // Calculated Values (Nutrisi berdasarkan berat input)
  double get calculatedCarbs => _calc((f) => f.carbs);
  double get calculatedCalories => _calc((f) => f.calories);
  double get calculatedProtein => _calc((f) => f.protein);
  double get calculatedFat => _calc((f) => f.fat);

  // Helper internal untuk hitung nutrisi: (Nilai * Berat) / 100
  double _calc(double Function(FoodModel) selector) {
    if (_selectedFood == null || _selectedFoodWeight == 0) return 0;
    return (selector(_selectedFood!) * _selectedFoodWeight) / 100;
  }

  /// Load semua data makanan dari database
  Future<void> loadFoods() async {
    _setLoading(true);
    try {
      final foods = await _foodService.getAllFoods();
      _allFoods = foods;
      _filteredFoods = foods; // Awalnya tampilkan semua
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  /// Search lokal (Filter dari data yang sudah ada di memori)
  void searchFoods(String query) {
    if (query.isEmpty) {
      _filteredFoods = _allFoods;
    } else {
      _filteredFoods = _allFoods
          .where(
            (food) => food.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  /// Pilih Makanan untuk dihitung
  void selectFood(FoodModel food) {
    _selectedFood = food;
    _selectedFoodWeight = 0; // Reset berat saat ganti makanan
    notifyListeners();
  }

  /// Set Berat Makanan (gram)
  void setFoodWeight(double weight) {
    _selectedFoodWeight = weight < 0 ? 0 : weight;
    notifyListeners();
  }

  /// Reset Pilihan (Clear)
  void clearSelection() {
    _selectedFood = null;
    _selectedFoodWeight = 0;
    notifyListeners();
  }

  // ==================== FILTERS ====================

  /// Filter makanan ramah diabetes
  Future<void> filterDiabeticFriendly() async {
    _setLoading(true);
    try {
      _filteredFoods = await _foodService.getDiabeticFriendlyFoods();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Filter berdasarkan kategori (tinggi-protein, rendah-lemak, dll)
  Future<void> filterByCategory(String category) async {
    _setLoading(true);
    try {
      _filteredFoods = await _foodService.getFoodsByCategory(category);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Reset Filter kembali ke semua makanan
  void resetFilter() {
    _filteredFoods = _allFoods;
    notifyListeners();
  }

  /// Ambil Makanan Populer (Top 10)
  Future<List<FoodModel>> getPopularFoods() async {
    try {
      return await _foodService.getPopularFoods();
    } catch (e) {
      return []; // Return list kosong jika gagal agar tidak crash
    }
  }

  // ==================== ADMIN METHODS ====================

  /// Tambah makanan baru ke database
  Future<bool> addFood(FoodModel food) async {
    _setLoading(true);
    try {
      String id = await _foodService.addFood(food);
      // Tambahkan ke list lokal agar langsung muncul tanpa refresh
      _allFoods.add(food.copyWith(id: id));
      searchFoods(''); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== INITIALIZATION (UPLOAD DATA) ====================

  /// ✅ Upload data hardcoded ke Firebase (Hanya jalankan sekali!)
  /// Fungsi ini dipanggil oleh tombol merah di Dashboard
  Future<void> uploadInitialData() async {
    _setLoading(true);
    try {
      // Panggil fungsi di service
      await _foodService.initializeFoodsToFirestore();

      // Reload data agar UI langsung update dengan data dari server
      await loadFoods();
      print("✅ Data berhasil di-upload ke Firebase!");
    } catch (e) {
      _errorMessage = e.toString();
      print("❌ Gagal upload: $e");
    } finally {
      _setLoading(false);
    }
  }

  // Helper Loading
  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
