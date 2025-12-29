import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_model.dart';

class FoodService {
  // Instance Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nama collection
  final String _foodsCollection = 'foods';

  // Flag untuk menggunakan data lokal atau Firestore
  // Set ke true untuk menggunakan data lokal (offline mode / testing)
  final bool _useLocalData = false;

  // ==================== SAMPLE DATA MAKANAN (LENGKAP) ====================
  /// Data makanan lokal (hardcoded) untuk keperluan development dan offline mode
  /// Semua nilai nutrisi per 100 gram
  final List<FoodModel> _localFoods = [
    // Karbohidrat / Makanan Pokok
    FoodModel(
      id: 'food_001',
      name: 'Nasi Putih',
      carbs: 28.7,
      calories: 130,
      protein: 2.7,
      fat: 0.3,
    ),
    FoodModel(
      id: 'food_002',
      name: 'Nasi Merah',
      carbs: 23.0,
      calories: 111,
      protein: 2.6,
      fat: 0.9,
    ),
    FoodModel(
      id: 'food_003',
      name: 'Roti Gandum',
      carbs: 49.0,
      calories: 247,
      protein: 13.0,
      fat: 3.4,
    ),
    FoodModel(
      id: 'food_004',
      name: 'Kentang Rebus',
      carbs: 20.1,
      calories: 87,
      protein: 1.9,
      fat: 0.1,
    ),
    FoodModel(
      id: 'food_005',
      name: 'Ubi Jalar',
      carbs: 20.1,
      calories: 86,
      protein: 1.6,
      fat: 0.1,
    ),

    // Protein Hewani
    FoodModel(
      id: 'food_006',
      name: 'Dada Ayam Tanpa Kulit',
      carbs: 0,
      calories: 165,
      protein: 31.0,
      fat: 3.6,
    ),
    FoodModel(
      id: 'food_007',
      name: 'Telur Ayam Rebus',
      carbs: 1.1,
      calories: 155,
      protein: 12.6,
      fat: 10.6,
    ),
    FoodModel(
      id: 'food_008',
      name: 'Ikan Salmon',
      carbs: 0,
      calories: 208,
      protein: 20.0,
      fat: 13.0,
    ),
    FoodModel(
      id: 'food_009',
      name: 'Tuna Kalengan',
      carbs: 0,
      calories: 116,
      protein: 25.5,
      fat: 0.8,
    ),
    FoodModel(
      id: 'food_010',
      name: 'Daging Sapi Tanpa Lemak',
      carbs: 0,
      calories: 250,
      protein: 26.0,
      fat: 15.0,
    ),

    // Protein Nabati
    FoodModel(
      id: 'food_011',
      name: 'Tempe',
      carbs: 9.0,
      calories: 193,
      protein: 20.8,
      fat: 8.8,
    ),
    FoodModel(
      id: 'food_012',
      name: 'Tahu',
      carbs: 0.8,
      calories: 76,
      protein: 8.0,
      fat: 4.8,
    ),
    FoodModel(
      id: 'food_013',
      name: 'Kacang Merah',
      carbs: 22.8,
      calories: 127,
      protein: 8.7,
      fat: 0.5,
    ),
    FoodModel(
      id: 'food_014',
      name: 'Kacang Hijau',
      carbs: 19.3,
      calories: 105,
      protein: 7.0,
      fat: 0.4,
    ),

    // Sayuran
    FoodModel(
      id: 'food_015',
      name: 'Bayam',
      carbs: 3.6,
      calories: 23,
      protein: 2.9,
      fat: 0.4,
    ),
    FoodModel(
      id: 'food_016',
      name: 'Brokoli',
      carbs: 6.6,
      calories: 34,
      protein: 2.8,
      fat: 0.4,
    ),
    FoodModel(
      id: 'food_017',
      name: 'Wortel',
      carbs: 9.6,
      calories: 41,
      protein: 0.9,
      fat: 0.2,
    ),
    FoodModel(
      id: 'food_018',
      name: 'Kacang Panjang',
      carbs: 7.9,
      calories: 47,
      protein: 2.7,
      fat: 0.2,
    ),
    FoodModel(
      id: 'food_019',
      name: 'Kangkung',
      carbs: 3.1,
      calories: 19,
      protein: 2.6,
      fat: 0.3,
    ),
    FoodModel(
      id: 'food_020',
      name: 'Tomat',
      carbs: 3.9,
      calories: 18,
      protein: 0.9,
      fat: 0.2,
    ),

    // Buah-buahan
    FoodModel(
      id: 'food_021',
      name: 'Apel',
      carbs: 13.8,
      calories: 52,
      protein: 0.3,
      fat: 0.2,
    ),
    FoodModel(
      id: 'food_022',
      name: 'Pisang',
      carbs: 22.8,
      calories: 89,
      protein: 1.1,
      fat: 0.3,
    ),
    FoodModel(
      id: 'food_023',
      name: 'Pepaya',
      carbs: 11.0,
      calories: 43,
      protein: 0.5,
      fat: 0.3,
    ),
    FoodModel(
      id: 'food_024',
      name: 'Jeruk',
      carbs: 11.8,
      calories: 47,
      protein: 0.9,
      fat: 0.1,
    ),
    FoodModel(
      id: 'food_025',
      name: 'Semangka',
      carbs: 7.6,
      calories: 30,
      protein: 0.6,
      fat: 0.2,
    ),

    // Susu dan Produk Olahan
    FoodModel(
      id: 'food_026',
      name: 'Susu Rendah Lemak',
      carbs: 4.8,
      calories: 42,
      protein: 3.4,
      fat: 1.0,
    ),
    FoodModel(
      id: 'food_027',
      name: 'Yogurt Plain',
      carbs: 4.7,
      calories: 59,
      protein: 3.5,
      fat: 3.3,
    ),
    FoodModel(
      id: 'food_028',
      name: 'Keju Cottage',
      carbs: 3.4,
      calories: 98,
      protein: 11.1,
      fat: 4.3,
    ),

    // Camilan Sehat
    FoodModel(
      id: 'food_029',
      name: 'Kacang Almond',
      carbs: 21.6,
      calories: 579,
      protein: 21.2,
      fat: 49.9,
    ),
    FoodModel(
      id: 'food_030',
      name: 'Oatmeal',
      carbs: 66.3,
      calories: 389,
      protein: 16.9,
      fat: 6.9,
    ),
  ];

  // ==================== MAIN METHODS ====================

  /// Ambil semua makanan dari database atau data lokal
  Future<List<FoodModel>> getAllFoods() async {
    try {
      if (_useLocalData) return _localFoods;

      QuerySnapshot snapshot = await _firestore
          .collection(_foodsCollection)
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FoodModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data makanan: $e');
    }
  }

  /// Ambil makanan berdasarkan ID
  Future<FoodModel?> getFoodById(String foodId) async {
    try {
      if (_useLocalData) {
        try {
          return _localFoods.firstWhere((food) => food.id == foodId);
        } catch (e) {
          return null;
        }
      } else {
        DocumentSnapshot doc = await _firestore
            .collection(_foodsCollection)
            .doc(foodId)
            .get();

        if (!doc.exists) return null;

        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FoodModel.fromJson(data);
      }
    } catch (e) {
      throw Exception('Gagal mengambil makanan: $e');
    }
  }

  /// Search makanan berdasarkan nama (FIXED SYNTAX)
  Future<List<FoodModel>> searchFoods(String query) async {
    try {
      if (query.isEmpty) return await getAllFoods();

      if (_useLocalData) {
        String lowerQuery = query.toLowerCase();
        return _localFoods
            .where((food) => food.name.toLowerCase().contains(lowerQuery))
            .toList();
      } else {
        // Trik agar search prefix (Start With) case-insensitive
        String formattedQuery = query;
        if (query.isNotEmpty) {
          formattedQuery = query[0].toUpperCase() + query.substring(1);
        }

        QuerySnapshot snapshot = await _firestore
            .collection(_foodsCollection)
            .where('name', isGreaterThanOrEqualTo: formattedQuery)
            .where('name', isLessThanOrEqualTo: '$formattedQuery\uf8ff')
            .get();

        // ✅ FIXED: Syntax map dan toList diperbaiki
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return FoodModel.fromJson(data);
        }).toList();
      }
    } catch (e) {
      throw Exception('Gagal mencari makanan: $e');
    }
  }

  /// ✅ METHOD BARU: Ambil makanan populer (Top 10)
  /// Diperlukan oleh FoodProvider
  Future<List<FoodModel>> getPopularFoods() async {
    try {
      if (_useLocalData) return _localFoods.take(10).toList();

      QuerySnapshot snapshot = await _firestore
          .collection(_foodsCollection)
          .limit(10) // Ambil 10 saja
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FoodModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil makanan populer: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Filter makanan berdasarkan kategori nutrisi (OPTIMIZED)
  Future<List<FoodModel>> getFoodsByCategory(String category) async {
    try {
      if (_useLocalData) {
        switch (category) {
          case 'tinggi-protein':
            return _localFoods.where((food) => food.protein > 15).toList();
          case 'rendah-karbo':
            return _localFoods.where((food) => food.carbs < 10).toList();
          case 'rendah-lemak':
            return _localFoods.where((food) => food.fat < 5).toList();
          case 'rendah-kalori':
            return _localFoods.where((food) => food.calories < 100).toList();
          default:
            return _localFoods;
        }
      }

      // Query langsung ke Firestore
      Query query = _firestore.collection(_foodsCollection);

      switch (category) {
        case 'tinggi-protein':
          query = query.where('protein', isGreaterThan: 15);
          break;
        case 'rendah-karbo':
          query = query.where('carbs', isLessThan: 10);
          break;
        case 'rendah-lemak':
          query = query.where('fat', isLessThan: 5);
          break;
        case 'rendah-kalori':
          query = query.where('calories', isLessThan: 100);
          break;
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FoodModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal filter makanan: $e');
    }
  }

  /// Rekomendasi makanan untuk penderita diabetes (Rendah Karbo)
  Future<List<FoodModel>> getDiabeticFriendlyFoods() async {
    try {
      if (_useLocalData) {
        return _localFoods.where((food) => food.carbs < 15).toList();
      }

      // Query optimized
      QuerySnapshot snapshot = await _firestore
          .collection(_foodsCollection)
          .where('carbs', isLessThan: 15)
          .orderBy('carbs', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return FoodModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil makanan untuk diabetes: $e');
    }
  }

  /// Hitung estimasi porsi untuk mencapai target nutrisi
  double calculatePortionForCarbs(FoodModel food, double targetCarbs) {
    if (food.carbs == 0) return 0;
    return (targetCarbs / food.carbs) * 100;
  }

  // ==================== ADMIN METHODS ====================

  /// Tambah makanan baru (untuk admin)
  Future<String> addFood(FoodModel food) async {
    if (_useLocalData) throw Exception('Mode lokal: Tidak bisa tambah data.');
    try {
      DocumentReference docRef = await _firestore
          .collection(_foodsCollection)
          .add(food.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah makanan: $e');
    }
  }

  /// Update data makanan
  Future<void> updateFood(String foodId, Map<String, dynamic> data) async {
    if (_useLocalData) throw Exception('Mode lokal: Tidak bisa update data.');
    try {
      await _firestore.collection(_foodsCollection).doc(foodId).update(data);
    } catch (e) {
      throw Exception('Gagal update makanan: $e');
    }
  }

  /// Hapus makanan
  Future<void> deleteFood(String foodId) async {
    if (_useLocalData) throw Exception('Mode lokal: Tidak bisa hapus data.');
    try {
      await _firestore.collection(_foodsCollection).doc(foodId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus makanan: $e');
    }
  }

  /// Upload data lokal ke Firestore (One-time setup)
  Future<void> initializeFoodsToFirestore() async {
    if (_useLocalData) return;
    try {
      WriteBatch batch = _firestore.batch();
      for (var food in _localFoods) {
        DocumentReference docRef = _firestore
            .collection(_foodsCollection)
            .doc(food.id);
        batch.set(docRef, food.toJson());
      }
      await batch.commit();
      print(
        'Successfully initialized ${_localFoods.length} foods to Firestore',
      );
    } catch (e) {
      throw Exception('Gagal initialize makanan ke Firestore: $e');
    }
  }

  /// Batch add multiple foods (untuk admin)
  Future<void> addFoodsBatch(List<FoodModel> foods) async {
    if (_useLocalData) throw Exception('Mode lokal aktif');
    try {
      WriteBatch batch = _firestore.batch();
      for (var food in foods) {
        DocumentReference docRef = _firestore
            .collection(_foodsCollection)
            .doc();
        batch.set(docRef, food.toJson());
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menambah makanan batch: $e');
    }
  }
}
