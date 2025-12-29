/// File: lib/utils/nutrition_calculator.dart
/// Utility class untuk kalkulasi nutrisi dan kesehatan
/// Menyediakan berbagai perhitungan terkait gizi, BMI, dan kebutuhan kalori harian

import 'package:flutter/material.dart';
import 'dart:math' as math;

class NutritionCalculator {
  // ==================== BASIC CALCULATIONS ====================

  /// Hitung nilai nutrisi berdasarkan berat makanan
  /// Formula: (nutrientPer100g * weight) / 100
  ///
  /// Parameters:
  /// - nutrientPer100g: Nilai nutrisi per 100 gram
  /// - weight: Berat makanan dalam gram
  ///
  /// Returns: double nilai nutrisi untuk berat tersebut
  ///
  /// Example:
  /// ```dart
  /// // Nasi putih: 28.7g carbs per 100g
  /// // Berat: 150g
  /// double carbs = calculateNutrient(28.7, 150);
  /// // Result: 43.05g
  /// ```
  static double calculateNutrient(double nutrientPer100g, double weight) {
    if (weight <= 0) return 0;
    return (nutrientPer100g * weight) / 100;
  }

  /// Hitung total nutrisi dari list makanan
  ///
  /// Parameters:
  /// - foods: List of Map dengan keys: carbs, calories, protein, fat
  ///
  /// Returns: Map dengan total semua nutrisi
  ///
  /// Example:
  /// ```dart
  /// List<Map<String, dynamic>> foods = [
  ///   {'carbs': 43.05, 'calories': 195, 'protein': 4.05, 'fat': 0.45},
  ///   {'carbs': 15.0, 'calories': 120, 'protein': 8.0, 'fat': 5.0},
  /// ];
  /// Map<String, double> total = calculateTotalNutrition(foods);
  /// // Result: {'carbs': 58.05, 'calories': 315, 'protein': 12.05, 'fat': 5.45}
  /// ```
  static Map<String, double> calculateTotalNutrition(
    List<Map<String, dynamic>> foods,
  ) {
    double totalCarbs = 0;
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;

    for (var food in foods) {
      totalCarbs += (food['carbs'] ?? 0).toDouble();
      totalCalories += (food['calories'] ?? 0).toDouble();
      totalProtein += (food['protein'] ?? 0).toDouble();
      totalFat += (food['fat'] ?? 0).toDouble();
    }

    return {
      'carbs': totalCarbs,
      'calories': totalCalories,
      'protein': totalProtein,
      'fat': totalFat,
    };
  }

  /// Hitung persentase dari nilai terhadap target
  /// Formula: (value / target) * 100
  ///
  /// Parameters:
  /// - value: Nilai saat ini
  /// - target: Target yang ingin dicapai
  ///
  /// Returns: double persentase (0-100+)
  ///
  /// Example:
  /// ```dart
  /// double percentage = calculatePercentage(150, 200);
  /// // Result: 75.0
  /// ```
  static double calculatePercentage(double value, double target) {
    if (target <= 0) return 0;
    return (value / target) * 100;
  }

  /// Format nilai nutrisi dengan decimal tertentu
  ///
  /// Parameters:
  /// - value: Nilai yang akan diformat
  /// - decimals: Jumlah angka di belakang koma (default: 1)
  ///
  /// Returns: String formatted value
  ///
  /// Example:
  /// ```dart
  /// String formatted = formatNutritionValue(45.6789);
  /// // Result: "45.7"
  /// ```
  static String formatNutritionValue(double value, [int decimals = 1]) {
    return value.toStringAsFixed(decimals);
  }

  /// Hitung sisa nutrisi yang bisa dikonsumsi
  ///
  /// Parameters:
  /// - current: Konsumsi saat ini
  /// - target: Target harian
  ///
  /// Returns: double sisa (bisa negatif jika over)
  static double calculateRemaining(double current, double target) {
    return target - current;
  }

  // ==================== BMI CALCULATIONS ====================

  /// Hitung Body Mass Index (BMI)
  /// Formula: weight(kg) / (height(m) ^ 2)
  ///
  /// Parameters:
  /// - weight: Berat badan dalam kilogram
  /// - height: Tinggi badan dalam centimeter
  ///
  /// Returns: double nilai BMI
  ///
  /// Example:
  /// ```dart
  /// double bmi = calculateBMI(70, 170);
  /// // Result: 24.2 (Normal)
  /// ```
  static double calculateBMI(double weight, double height) {
    if (weight <= 0 || height <= 0) return 0;

    // Convert height from cm to meter
    double heightInMeters = height / 100;

    // Calculate BMI
    return weight / math.pow(heightInMeters, 2);
  }

  /// Get kategori BMI berdasarkan nilai BMI
  ///
  /// Parameters:
  /// - bmi: Nilai BMI
  ///
  /// Returns: String kategori BMI
  ///
  /// Categories:
  /// - < 18.5: Kurus (Underweight)
  /// - 18.5-24.9: Normal
  /// - 25-29.9: Kelebihan Berat Badan (Overweight)
  /// - >= 30: Obesitas (Obese)
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Kurus';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Kelebihan Berat Badan';
    } else {
      return 'Obesitas';
    }
  }

  /// Get deskripsi lengkap kategori BMI
  ///
  /// Parameters:
  /// - bmi: Nilai BMI
  ///
  /// Returns: Map dengan category dan description
  static Map<String, String> getBMIDetails(double bmi) {
    if (bmi < 18.5) {
      return {
        'category': 'Kurus',
        'description':
            'Berat badan Anda kurang dari ideal. Pertimbangkan untuk menambah asupan kalori dan konsultasi dengan ahli gizi.',
      };
    } else if (bmi < 25) {
      return {
        'category': 'Normal',
        'description':
            'Berat badan Anda ideal. Pertahankan pola makan sehat dan olahraga teratur.',
      };
    } else if (bmi < 30) {
      return {
        'category': 'Kelebihan Berat Badan',
        'description':
            'Berat badan Anda berlebih. Pertimbangkan untuk mengurangi asupan kalori dan meningkatkan aktivitas fisik.',
      };
    } else {
      return {
        'category': 'Obesitas',
        'description':
            'Anda mengalami obesitas. Sangat disarankan untuk konsultasi dengan dokter atau ahli gizi untuk program penurunan berat badan yang aman.',
      };
    }
  }

  // ==================== DAILY NEEDS CALCULATIONS ====================

  /// Hitung kebutuhan kalori harian menggunakan Harris-Benedict Formula
  ///
  /// Parameters:
  /// - age: Umur dalam tahun
  /// - gender: "Laki-laki" atau "Perempuan"
  /// - weight: Berat badan dalam kg
  /// - height: Tinggi badan dalam cm
  /// - activityLevel: Tingkat aktivitas
  ///   * "sedentary": Tidak aktif / jarang olahraga
  ///   * "light": Olahraga ringan 1-3 hari/minggu
  ///   * "moderate": Olahraga sedang 3-5 hari/minggu
  ///   * "active": Olahraga berat 6-7 hari/minggu
  ///   * "very_active": Olahraga sangat berat / atlet
  ///
  /// Returns: double kebutuhan kalori per hari
  ///
  /// Formula:
  /// - Laki-laki: BMR = 88.362 + (13.397 × weight) + (4.799 × height) - (5.677 × age)
  /// - Perempuan: BMR = 447.593 + (9.247 × weight) + (3.098 × height) - (4.330 × age)
  /// - TDEE = BMR × Activity Factor
  static double calculateDailyCalorieNeeds(
    int age,
    String gender,
    double weight,
    double height,
    String activityLevel,
  ) {
    if (age <= 0 || weight <= 0 || height <= 0) return 0;

    // Calculate BMR (Basal Metabolic Rate) using Harris-Benedict Formula
    double bmr;

    if (gender.toLowerCase() == 'laki-laki' || gender.toLowerCase() == 'male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    // Activity multipliers
    double activityFactor;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        activityFactor = 1.2; // Little or no exercise
        break;
      case 'light':
        activityFactor = 1.375; // Light exercise 1-3 days/week
        break;
      case 'moderate':
        activityFactor = 1.55; // Moderate exercise 3-5 days/week
        break;
      case 'active':
        activityFactor = 1.725; // Heavy exercise 6-7 days/week
        break;
      case 'very_active':
        activityFactor = 1.9; // Very heavy exercise / physical job
        break;
      default:
        activityFactor = 1.2; // Default to sedentary
    }

    // Calculate TDEE (Total Daily Energy Expenditure)
    return bmr * activityFactor;
  }

  /// Get rekomendasi karbohidrat berdasarkan kalori harian
  /// Karbohidrat sebaiknya 45-65% dari total kalori
  /// 1 gram karbohidrat = 4 kalori
  ///
  /// Parameters:
  /// - dailyCalories: Kebutuhan kalori harian
  ///
  /// Returns: Map dengan 'min' dan 'max' karbohidrat dalam gram
  ///
  /// Example:
  /// ```dart
  /// Map<String, double> carbsRange = getCarbsRecommendation(2000);
  /// // Result: {'min': 225, 'max': 325}
  /// // 45% = 900 kcal = 225g, 65% = 1300 kcal = 325g
  /// ```
  static Map<String, double> getCarbsRecommendation(double dailyCalories) {
    if (dailyCalories <= 0) {
      return {'min': 0, 'max': 0};
    }

    // 45-65% dari total kalori untuk karbohidrat
    double minCarbsCalories = dailyCalories * 0.45;
    double maxCarbsCalories = dailyCalories * 0.65;

    // 1 gram karbohidrat = 4 kalori
    double minCarbsGrams = minCarbsCalories / 4;
    double maxCarbsGrams = maxCarbsCalories / 4;

    return {'min': minCarbsGrams, 'max': maxCarbsGrams};
  }

  /// Get rekomendasi protein berdasarkan kalori harian
  /// Protein sebaiknya 10-35% dari total kalori
  /// 1 gram protein = 4 kalori
  ///
  /// Parameters:
  /// - dailyCalories: Kebutuhan kalori harian
  ///
  /// Returns: Map dengan 'min' dan 'max' protein dalam gram
  static Map<String, double> getProteinRecommendation(double dailyCalories) {
    if (dailyCalories <= 0) {
      return {'min': 0, 'max': 0};
    }

    // 10-35% dari total kalori untuk protein
    double minProteinCalories = dailyCalories * 0.10;
    double maxProteinCalories = dailyCalories * 0.35;

    // 1 gram protein = 4 kalori
    double minProteinGrams = minProteinCalories / 4;
    double maxProteinGrams = maxProteinCalories / 4;

    return {'min': minProteinGrams, 'max': maxProteinGrams};
  }

  /// Get rekomendasi lemak berdasarkan kalori harian
  /// Lemak sebaiknya 20-35% dari total kalori
  /// 1 gram lemak = 9 kalori
  ///
  /// Parameters:
  /// - dailyCalories: Kebutuhan kalori harian
  ///
  /// Returns: Map dengan 'min' dan 'max' lemak dalam gram
  static Map<String, double> getFatRecommendation(double dailyCalories) {
    if (dailyCalories <= 0) {
      return {'min': 0, 'max': 0};
    }

    // 20-35% dari total kalori untuk lemak
    double minFatCalories = dailyCalories * 0.20;
    double maxFatCalories = dailyCalories * 0.35;

    // 1 gram lemak = 9 kalori
    double minFatGrams = minFatCalories / 9;
    double maxFatGrams = maxFatCalories / 9;

    return {'min': minFatGrams, 'max': maxFatGrams};
  }

  /// Get rekomendasi karbohidrat untuk penderita diabetes
  /// Biasanya lebih rendah: 130-180 gram per hari
  ///
  /// Parameters:
  /// - dailyCalories: Kebutuhan kalori harian
  ///
  /// Returns: double rekomendasi karbohidrat untuk diabetes dalam gram
  static double getDiabeticCarbsRecommendation(double dailyCalories) {
    // Untuk diabetes, biasanya 130-180g carbs per day
    // atau sekitar 40-50% dari kalori
    double carbsCalories = dailyCalories * 0.45;
    return carbsCalories / 4;
  }

  // ==================== PROGRESS & STATUS ====================

  /// Get warna progress berdasarkan persentase
  ///
  /// Parameters:
  /// - percentage: Persentase pencapaian (0-100+)
  ///
  /// Returns: Color yang sesuai dengan status
  ///   * < 80%: Colors.green (aman)
  ///   * 80-100%: Colors.orange (mendekati batas)
  ///   * > 100%: Colors.red (melebihi target)
  static Color getProgressColor(double percentage) {
    if (percentage < 80) {
      return Colors.green;
    } else if (percentage < 100) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Get warna berdasarkan kategori BMI
  ///
  /// Parameters:
  /// - bmi: Nilai BMI
  ///
  /// Returns: Color yang sesuai dengan kategori
  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue; // Underweight
    } else if (bmi < 25) {
      return Colors.green; // Normal
    } else if (bmi < 30) {
      return Colors.orange; // Overweight
    } else {
      return Colors.red; // Obese
    }
  }

  /// Check apakah nilai melebihi target
  ///
  /// Parameters:
  /// - value: Nilai saat ini
  /// - target: Target yang ditetapkan
  ///
  /// Returns: bool true jika melebihi target
  static bool isOverTarget(double value, double target) {
    return value > target;
  }

  /// Check apakah mendekati target (80-100%)
  ///
  /// Parameters:
  /// - value: Nilai saat ini
  /// - target: Target yang ditetapkan
  ///
  /// Returns: bool true jika mendekati target
  static bool isApproachingTarget(double value, double target) {
    if (target <= 0) return false;
    double percentage = calculatePercentage(value, target);
    return percentage >= 80 && percentage < 100;
  }

  /// Get status text berdasarkan percentage
  ///
  /// Parameters:
  /// - percentage: Persentase pencapaian
  ///
  /// Returns: String status message
  static String getProgressStatus(double percentage) {
    if (percentage < 50) {
      return 'Masih aman';
    } else if (percentage < 80) {
      return 'Berjalan baik';
    } else if (percentage < 100) {
      return 'Mendekati batas';
    } else if (percentage < 120) {
      return 'Melebihi target';
    } else {
      return 'Jauh melebihi target';
    }
  }

  // ==================== STATISTICAL CALCULATIONS ====================

  /// Calculate rata-rata karbohidrat dari list meals
  ///
  /// Parameters:
  /// - meals: List of Map dengan key 'carbs'
  ///
  /// Returns: double rata-rata karbohidrat
  ///
  /// Example:
  /// ```dart
  /// List<Map<String, dynamic>> meals = [
  ///   {'carbs': 50.0},
  ///   {'carbs': 40.0},
  ///   {'carbs': 60.0},
  /// ];
  /// double avg = calculateAverageCarbs(meals);
  /// // Result: 50.0
  /// ```
  static double calculateAverageCarbs(List<Map<String, dynamic>> meals) {
    if (meals.isEmpty) return 0;

    double total = 0;
    for (var meal in meals) {
      total += (meal['carbs'] ?? 0).toDouble();
    }

    return total / meals.length;
  }

  /// Calculate rata-rata kalori dari list meals
  ///
  /// Parameters:
  /// - meals: List of Map dengan key 'calories'
  ///
  /// Returns: double rata-rata kalori
  static double calculateAverageCalories(List<Map<String, dynamic>> meals) {
    if (meals.isEmpty) return 0;

    double total = 0;
    for (var meal in meals) {
      total += (meal['calories'] ?? 0).toDouble();
    }

    return total / meals.length;
  }

  /// Calculate standard deviation (untuk analisis variasi konsumsi)
  ///
  /// Parameters:
  /// - values: List of double values
  ///
  /// Returns: double standard deviation
  static double calculateStandardDeviation(List<double> values) {
    if (values.isEmpty) return 0;

    // Calculate mean
    double mean = values.reduce((a, b) => a + b) / values.length;

    // Calculate variance
    double variance = 0;
    for (var value in values) {
      variance += math.pow(value - mean, 2);
    }
    variance /= values.length;

    // Return standard deviation
    return math.sqrt(variance);
  }

  // ==================== UTILITY METHODS ====================

  /// Convert calories to grams of carbs
  /// 1 gram carbs = 4 calories
  static double caloriesToCarbs(double calories) {
    return calories / 4;
  }

  /// Convert carbs grams to calories
  /// 1 gram carbs = 4 calories
  static double carbsToCalories(double carbs) {
    return carbs * 4;
  }

  /// Convert calories to grams of protein
  /// 1 gram protein = 4 calories
  static double caloriesToProtein(double calories) {
    return calories / 4;
  }

  /// Convert protein grams to calories
  /// 1 gram protein = 4 calories
  static double proteinToCalories(double protein) {
    return protein * 4;
  }

  /// Convert calories to grams of fat
  /// 1 gram fat = 9 calories
  static double caloriesToFat(double calories) {
    return calories / 9;
  }

  /// Convert fat grams to calories
  /// 1 gram fat = 9 calories
  static double fatToCalories(double fat) {
    return fat * 9;
  }

  /// Get glycemic load category
  /// GL < 10: Low, 10-20: Medium, > 20: High
  static String getGlycemicLoadCategory(double glycemicLoad) {
    if (glycemicLoad < 10) {
      return 'Rendah';
    } else if (glycemicLoad <= 20) {
      return 'Sedang';
    } else {
      return 'Tinggi';
    }
  }

  /// Calculate ideal weight range using BMI
  /// BMI 18.5-24.9 is considered healthy
  ///
  /// Parameters:
  /// - height: Tinggi badan dalam cm
  ///
  /// Returns: Map dengan 'min' dan 'max' berat ideal dalam kg
  static Map<String, double> calculateIdealWeightRange(double height) {
    if (height <= 0) return {'min': 0, 'max': 0};

    double heightInMeters = height / 100;
    double minWeight = 18.5 * math.pow(heightInMeters, 2);
    double maxWeight = 24.9 * math.pow(heightInMeters, 2);

    return {'min': minWeight, 'max': maxWeight};
  }
}

