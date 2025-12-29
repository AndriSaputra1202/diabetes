/// File: lib/services/database_service.dart
/// Service untuk menangani operasi database Firestore
/// Mengelola data user, meals, dan recommendations

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/meal_model.dart';
import '../models/recommendation_model.dart';

class DatabaseService {
  // Instance Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nama collection
  final String _usersCollection = 'users';
  final String _mealsCollection = 'meals';
  final String _recommendationsCollection = 'recommendations';

  // ==================== USER OPERATIONS ====================

  /// Buat user baru di Firestore
  Future<void> createUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).set(userData);
    } catch (e) {
      throw Exception('Gagal membuat user: $e');
    }
  }

  /// Ambil data user berdasarkan ID
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      // ✅ PERBAIKAN: Pastikan ID diambil dari dokumen
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;

      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Gagal mengambil data user: $e');
    }
  }

  /// Update data user (General)
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(data);
    } catch (e) {
      throw Exception('Gagal update user: $e');
    }
  }

  /// Update data profile user (Khusus Edit Profile)
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update(data);
    } catch (e) {
      throw Exception('Gagal update profile: $e');
    }
  }

  /// Hapus data user
  Future<void> deleteUser(String userId) async {
    try {
      // Hapus semua meals user
      QuerySnapshot meals = await _firestore
          .collection(_mealsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in meals.docs) {
        await doc.reference.delete();
      }

      // Hapus semua recommendations terkait user
      QuerySnapshot recommendations = await _firestore
          .collection(_recommendationsCollection)
          .where('patientId', isEqualTo: userId)
          .get();

      for (var doc in recommendations.docs) {
        await doc.reference.delete();
      }

      // Hapus user
      await _firestore.collection(_usersCollection).doc(userId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus user: $e');
    }
  }

  /// Ambil semua users berdasarkan role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_usersCollection)
          .where('role', isEqualTo: role)
          .get();

      return snapshot.docs.map((doc) {
        // ✅ PERBAIKAN: Pastikan ID diambil dari dokumen
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return UserModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil users: $e');
    }
  }

  // ==================== MEAL OPERATIONS ====================

  /// Tambah data konsumsi makanan
  Future<String> addMeal(MealModel meal) async {
    try {
      meal.calculateTotals();
      DocumentReference docRef = await _firestore
          .collection(_mealsCollection)
          .add(meal.toJson());

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah meal: $e');
    }
  }

  /// Ambil meals berdasarkan tanggal tertentu
  Future<List<MealModel>> getMealsByDate(String userId, DateTime date) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection(_mealsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ✅ ID dari dokumen
        return MealModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil meals: $e');
    }
  }

  /// Ambil meals berdasarkan range tanggal
  Future<List<MealModel>> getMealsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      DateTime startDate = DateTime(
        start.year,
        start.month,
        start.day,
        0,
        0,
        0,
      );
      DateTime endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection(_mealsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('date', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ✅ ID dari dokumen
        return MealModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil meals: $e');
    }
  }

  /// Update data meal
  Future<void> updateMeal(String mealId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_mealsCollection).doc(mealId).update(data);
    } catch (e) {
      throw Exception('Gagal update meal: $e');
    }
  }

  /// Hapus meal
  Future<void> deleteMeal(String mealId) async {
    try {
      await _firestore.collection(_mealsCollection).doc(mealId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus meal: $e');
    }
  }

  /// Ambil total nutrisi hari ini
  Future<Map<String, double>> getTodayNutrition(String userId) async {
    try {
      DateTime today = DateTime.now();
      List<MealModel> todayMeals = await getMealsByDate(userId, today);

      double totalCarbs = 0;
      double totalCalories = 0;
      double totalProtein = 0;
      double totalFat = 0;

      for (var meal in todayMeals) {
        totalCarbs += meal.totalCarbs;
        totalCalories += meal.totalCalories;
        totalProtein += meal.totalProtein;
        totalFat += meal.totalFat;
      }

      return {
        'carbs': totalCarbs,
        'calories': totalCalories,
        'protein': totalProtein,
        'fat': totalFat,
      };
    } catch (e) {
      throw Exception('Gagal mengambil nutrisi hari ini: $e');
    }
  }

  /// Ambil statistik nutrisi dalam periode tertentu
  Future<List<Map<String, dynamic>>> getNutritionStats(
    String userId, {
    int days = 7,
  }) async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: days - 1));

      List<MealModel> meals = await getMealsByDateRange(
        userId,
        startDate,
        endDate,
      );

      Map<String, Map<String, double>> dailyStats = {};

      for (var meal in meals) {
        String dateKey =
            '${meal.date.year}-${meal.date.month.toString().padLeft(2, '0')}-${meal.date.day.toString().padLeft(2, '0')}';

        if (!dailyStats.containsKey(dateKey)) {
          dailyStats[dateKey] = {
            'carbs': 0,
            'calories': 0,
            'protein': 0,
            'fat': 0,
          };
        }

        dailyStats[dateKey]!['carbs'] =
            dailyStats[dateKey]!['carbs']! + meal.totalCarbs;
        dailyStats[dateKey]!['calories'] =
            dailyStats[dateKey]!['calories']! + meal.totalCalories;
        dailyStats[dateKey]!['protein'] =
            dailyStats[dateKey]!['protein']! + meal.totalProtein;
        dailyStats[dateKey]!['fat'] =
            dailyStats[dateKey]!['fat']! + meal.totalFat;
      }

      List<Map<String, dynamic>> result = [];
      dailyStats.forEach((date, stats) {
        result.add({
          'date': date,
          'carbs': stats['carbs'],
          'calories': stats['calories'],
          'protein': stats['protein'],
          'fat': stats['fat'],
        });
      });

      result.sort((a, b) => a['date'].compareTo(b['date']));
      return result;
    } catch (e) {
      throw Exception('Gagal mengambil statistik nutrisi: $e');
    }
  }

  // ==================== RECOMMENDATION OPERATIONS ====================

  /// Tambah rekomendasi baru
  Future<String> addRecommendation(RecommendationModel recommendation) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_recommendationsCollection)
          .add(recommendation.toJson());

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah rekomendasi: $e');
    }
  }

  /// Ambil rekomendasi berdasarkan patient ID
  Future<List<RecommendationModel>> getRecommendationsByPatient(
    String patientId,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recommendationsCollection)
          .where('patientId', isEqualTo: patientId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ✅ Fix: ID diambil dari dokumen
        return RecommendationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil rekomendasi: $e');
    }
  }

  /// Ambil rekomendasi berdasarkan doctor ID
  Future<List<RecommendationModel>> getRecommendationsByDoctor(
    String doctorId,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recommendationsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ✅ Fix: ID diambil dari dokumen
        return RecommendationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal mengambil rekomendasi: $e');
    }
  }

  /// Update data rekomendasi
  Future<void> updateRecommendation(
    String recId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(_recommendationsCollection)
          .doc(recId)
          .update(data);
    } catch (e) {
      throw Exception('Gagal update rekomendasi: $e');
    }
  }

  /// Tandai rekomendasi sebagai sudah dibaca
  Future<void> markAsRead(String recId) async {
    try {
      await _firestore.collection(_recommendationsCollection).doc(recId).update(
        {'read': true},
      );
    } catch (e) {
      throw Exception('Gagal nandai baca: $e');
    }
  }

  /// Hapus rekomendasi
  Future<void> deleteRecommendation(String recId) async {
    try {
      await _firestore
          .collection(_recommendationsCollection)
          .doc(recId)
          .delete();
    } catch (e) {
      throw Exception('Gagal menghapus rekomendasi: $e');
    }
  }

  /// Ambil jumlah rekomendasi yang belum dibaca
  Future<int> getUnreadCount(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recommendationsCollection)
          .where('patientId', isEqualTo: patientId)
          .where('read', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Gagal hitung unread: $e');
    }
  }

  /// Stream rekomendasi pasien
  Stream<List<RecommendationModel>> streamRecommendationsByPatient(
    String patientId,
  ) {
    return _firestore
        .collection(_recommendationsCollection)
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id; // ✅ Fix ID
            return RecommendationModel.fromJson(data);
          }).toList();
        });
  }

  /// Stream meals hari ini
  Stream<List<MealModel>> streamTodayMeals(String userId) {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day, 0, 0, 0);
    DateTime endOfDay = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    );

    return _firestore
        .collection(_mealsCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id; // ✅ Fix ID
            return MealModel.fromJson(data);
          }).toList();
        });
  }

  /// Batch delete meals
  Future<void> deleteMealsBatch(List<String> mealIds) async {
    try {
      WriteBatch batch = _firestore.batch();
      for (String mealId in mealIds) {
        DocumentReference docRef = _firestore
            .collection(_mealsCollection)
            .doc(mealId);
        batch.delete(docRef);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Gagal menghapus meals: $e');
    }
  }
}
