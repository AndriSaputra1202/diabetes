import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendationModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String category; // 'Saran Makanan', 'Pola Makan', dll
  final String message;
  final List<String> foods; // List makanan yang direkomendasikan
  final String priority; // 'Rendah', 'Sedang', 'Tinggi'
  final DateTime date;
  final bool read; // Status sudah dibaca

  RecommendationModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.category,
    required this.message,
    required this.foods,
    required this.priority,
    required this.date,
    required this.read,
  });

  /// Konversi object RecommendationModel ke Map (untuk database/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'category': category,
      'message': message,
      'foods': foods,
      'priority': priority,
      // Simpan sebagai String ISO 8601 agar formatnya konsisten
      'date': date.toIso8601String(),
      'read': read,
    };
  }

  /// Konversi Map ke object RecommendationModel (dari database/API)
  /// ✅ SUDAH DIPERBAIKI: Aman terhadap perbedaan format tanggal
  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      doctorName: json['doctorName'] ?? 'Dokter',
      category: json['category'] ?? 'Umum',
      message: json['message'] ?? '',
      foods: List<String>.from(json['foods'] ?? []),
      priority: json['priority'] ?? 'Sedang',

      // Logika Cerdas: Cek apakah Timestamp (Firebase) atau String (JSON)
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.tryParse(json['date'].toString()) ?? DateTime.now(),

      read: json['read'] ?? false,
    );
  }

  /// Copy object dengan kemampuan mengubah field tertentu (Immutable pattern)
  RecommendationModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    String? doctorName,
    String? category,
    String? message,
    List<String>? foods,
    String? priority,
    DateTime? date,
    bool? read,
  }) {
    return RecommendationModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      category: category ?? this.category,
      message: message ?? this.message,
      foods: foods ?? this.foods,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      read: read ?? this.read,
    );
  }

  /// Cek apakah rekomendasi masih baru (dalam 7 hari terakhir)
  bool isNew() {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    return difference <= 7;
  }

  @override
  String toString() {
    return 'RecommendationModel(id: $id, doctor: $doctorName, category: $category, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
