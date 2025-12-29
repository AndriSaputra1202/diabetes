// Service khusus untuk menangani operasi rekomendasi dari dokter ke pasien
// Menyediakan fitur notifikasi dan tracking rekomendasi

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recommendation_model.dart';

class RecommendationService {
  // Instance Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nama collection
  final String _recommendationsCollection = 'recommendations';
  final String _usersCollection = 'users';

  // ==================== MAIN METHODS ====================

  /// Dokter mengirim rekomendasi ke pasien
  Future<String> sendRecommendation(
    String patientId,
    RecommendationModel data,
  ) async {
    try {
      if (patientId.isEmpty) {
        throw Exception('Patient ID tidak boleh kosong');
      }

      if (data.message.isEmpty) {
        throw Exception('Pesan rekomendasi tidak boleh kosong');
      }

      // Pastikan patientId sesuai
      data = data.copyWith(patientId: patientId);

      // Simpan rekomendasi ke Firestore
      DocumentReference docRef = await _firestore
          .collection(_recommendationsCollection)
          .add(data.toJson());

      // Update jumlah notifikasi pasien (optional)
      await _incrementNotificationCount(patientId);

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal mengirim rekomendasi: $e');
    }
  }

  /// Ambil semua rekomendasi untuk pasien tertentu
  Future<List<RecommendationModel>> getPatientRecommendations(
    String patientId, {
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(_recommendationsCollection)
          .where('patientId', isEqualTo: patientId)
          .orderBy('date', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ✅ FIX: Inject ID Dokumen Asli
        return RecommendationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error get patient recommendations: $e");
      return [];
    }
  }

  /// Ambil semua rekomendasi yang dibuat oleh dokter tertentu
  Future<List<RecommendationModel>> getDoctorRecommendations(
    String doctorId, {
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(_recommendationsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('date', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ✅ FIX: Inject ID Dokumen Asli
        return RecommendationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error get doctor recommendations: $e");
      return [];
    }
  }

  /// Ambil rekomendasi yang belum dibaca oleh pasien
  Future<List<RecommendationModel>> getUnreadRecommendations(
    String patientId,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recommendationsCollection)
          .where('patientId', isEqualTo: patientId)
          .where('read', isEqualTo: false)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ✅ FIX: Inject ID Dokumen Asli
        return RecommendationModel.fromJson(data);
      }).toList();
    } catch (e) {
      print("Error get unread recommendations: $e");
      return [];
    }
  }

  /// Tandai semua rekomendasi pasien sebagai sudah dibaca
  Future<int> markAllAsRead(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recommendationsCollection)
          .where('patientId', isEqualTo: patientId)
          .where('read', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0;
      }

      WriteBatch batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
      await _resetNotificationCount(patientId);

      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Gagal menandai semua sebagai dibaca: $e');
    }
  }

  /// Ambil statistik rekomendasi pasien
  Future<Map<String, dynamic>> getRecommendationStats(String patientId) async {
    try {
      List<RecommendationModel> allRecommendations =
          await getPatientRecommendations(patientId);

      int total = allRecommendations.length;
      int unread = allRecommendations.where((rec) => !rec.read).length;
      int read = allRecommendations.where((rec) => rec.read).length;

      int highPriority = allRecommendations
          .where((rec) => rec.priority == 'Tinggi')
          .length;
      int mediumPriority = allRecommendations
          .where((rec) => rec.priority == 'Sedang')
          .length;
      int lowPriority = allRecommendations
          .where((rec) => rec.priority == 'Rendah')
          .length;

      Map<String, int> byCategory = {};
      for (var rec in allRecommendations) {
        byCategory[rec.category] = (byCategory[rec.category] ?? 0) + 1;
      }

      RecommendationModel? latest = allRecommendations.isNotEmpty
          ? allRecommendations.first
          : null;

      int newRecommendations = allRecommendations
          .where((rec) => rec.isNew())
          .length;

      return {
        'total': total,
        'unread': unread,
        'read': read,
        'highPriority': highPriority,
        'mediumPriority': mediumPriority,
        'lowPriority': lowPriority,
        'byCategory': byCategory,
        'latest': latest?.toJson(),
        'newRecommendations': newRecommendations,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik rekomendasi: $e');
    }
  }

  // ==================== ADDITIONAL METHODS ====================

  /// Ambil rekomendasi berdasarkan kategori
  Future<List<RecommendationModel>> getRecommendationsByCategory(
    String patientId,
    String category,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recommendationsCollection)
          .where('patientId', isEqualTo: patientId)
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ✅ FIX
        return RecommendationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal filter kategori: $e');
    }
  }

  /// Ambil rekomendasi berdasarkan prioritas
  Future<List<RecommendationModel>> getRecommendationsByPriority(
    String patientId,
    String priority,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recommendationsCollection)
          .where('patientId', isEqualTo: patientId)
          .where('priority', isEqualTo: priority)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ✅ FIX
        return RecommendationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal filter prioritas: $e');
    }
  }

  /// Ambil rekomendasi dalam range tanggal tertentu
  Future<List<RecommendationModel>> getRecommendationsByDateRange(
    String patientId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recommendationsCollection)
          .where('patientId', isEqualTo: patientId)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // ✅ FIX
        return RecommendationModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal filter range tanggal: $e');
    }
  }

  /// Update rekomendasi
  Future<void> updateRecommendation(
    String recommendationId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(_recommendationsCollection)
          .doc(recommendationId)
          .update(data);
    } catch (e) {
      throw Exception('Gagal update rekomendasi: $e');
    }
  }

  /// Tandai rekomendasi sebagai sudah dibaca
  Future<void> markAsRead(String recommendationId) async {
    try {
      await _firestore
          .collection(_recommendationsCollection)
          .doc(recommendationId)
          .update({'read': true});
    } catch (e) {
      throw Exception('Gagal menandai dibaca: $e');
    }
  }

  /// Hapus rekomendasi
  Future<void> deleteRecommendation(String recommendationId) async {
    try {
      await _firestore
          .collection(_recommendationsCollection)
          .doc(recommendationId)
          .delete();
    } catch (e) {
      throw Exception('Gagal menghapus rekomendasi: $e');
    }
  }

  /// Hapus semua rekomendasi pasien
  Future<int> deleteAllPatientRecommendations(String patientId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recommendationsCollection)
          .where('patientId', isEqualTo: patientId)
          .get();

      if (snapshot.docs.isEmpty) return 0;

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Gagal hapus semua rekomendasi: $e');
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
      return 0;
    }
  }

  // ==================== REAL-TIME STREAMS ====================

  /// Stream rekomendasi pasien (Real-time)
  Stream<List<RecommendationModel>> streamPatientRecommendations(
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
            data['id'] = doc.id; // ✅ FIX
            return RecommendationModel.fromJson(data);
          }).toList();
        });
  }

  /// Stream unread count (Real-time)
  Stream<int> streamUnreadCount(String patientId) {
    return _firestore
        .collection(_recommendationsCollection)
        .where('patientId', isEqualTo: patientId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Stream rekomendasi dokter (Real-time)
  Stream<List<RecommendationModel>> streamDoctorRecommendations(
    String doctorId,
  ) {
    return _firestore
        .collection(_recommendationsCollection)
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id; // ✅ FIX
            return RecommendationModel.fromJson(data);
          }).toList();
        });
  }

  // ==================== HELPER METHODS ====================

  Future<void> _incrementNotificationCount(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'notificationCount': FieldValue.increment(1),
      });
    } catch (e) {
      print('Failed to increment notification count: $e');
    }
  }

  Future<void> _resetNotificationCount(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'notificationCount': 0,
      });
    } catch (e) {
      print('Failed to reset notification count: $e');
    }
  }

  /// Ambil daftar pasien yang pernah menerima rekomendasi dari dokter
  Future<List<String>> getDoctorPatients(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_recommendationsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .get();

      Set<String> patientIds = {};
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data['patientId'] != null) {
          patientIds.add(data['patientId'] as String);
        }
      }

      return patientIds.toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar pasien dokter: $e');
    }
  }

  /// Batch send recommendations
  Future<int> batchSendRecommendations(
    List<String> patientIds,
    RecommendationModel recommendation,
  ) async {
    try {
      WriteBatch batch = _firestore.batch();
      int count = 0;

      for (String patientId in patientIds) {
        RecommendationModel newRec = recommendation.copyWith(
          id: '', // ID akan di-generate otomatis
          patientId: patientId,
        );

        DocumentReference docRef = _firestore
            .collection(_recommendationsCollection)
            .doc();

        batch.set(docRef, newRec.toJson());
        count++;
      }

      await batch.commit();
      return count;
    } catch (e) {
      throw Exception('Gagal batch send rekomendasi: $e');
    }
  }
}
