import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final int age;
  final String gender;
  final double weight;
  final double height;
  final double bloodSugar;
  final double targetCarbs;
  final String role; // 'patient', 'doctor', 'admin'
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.bloodSugar,
    required this.targetCarbs,
    required this.role,
    required this.createdAt,
  });

  // Konversi dari JSON/Firestore ke Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      age: (json['age'] ?? 0).toInt(),
      gender: json['gender'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
      bloodSugar: (json['bloodSugar'] ?? 0).toDouble(),
      targetCarbs: (json['targetCarbs'] ?? 0).toDouble(),
      role: json['role'] ?? 'patient',

      // ✅ PERBAIKAN UTAMA DI SINI:
      // Cek apakah datanya Timestamp (dari Firebase) atau String
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp)
                .toDate() // Jika Timestamp, convert ke DateTime
          : DateTime.tryParse(json['createdAt'].toString()) ??
                DateTime.now(), // Jika String, parse
    );
  }

  // Konversi dari Object ke JSON (untuk simpan ke database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'bloodSugar': bloodSugar,
      'targetCarbs': targetCarbs,
      'role': role,
      'createdAt': createdAt
          .toIso8601String(), // Simpan sebagai String agar konsisten
    };
  }

  // Helper untuk copy object dengan update field tertentu
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? gender,
    double? weight,
    double? height,
    double? bloodSugar,
    double? targetCarbs,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      bloodSugar: bloodSugar ?? this.bloodSugar,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Hitung BMI (Body Mass Index)
  double calculateBMI() {
    if (height <= 0 || weight <= 0) return 0;
    double heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Status BMI
  String getBMIStatus() {
    double bmi = calculateBMI();
    if (bmi == 0) return 'Belum ada data';
    if (bmi < 18.5) return 'Kurus';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Gemuk';
    return 'Obesitas';
  }
}
