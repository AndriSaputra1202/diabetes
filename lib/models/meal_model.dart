// Model item makanan dalam satu meal
// Model untuk data makanan yang dikonsumsi pengguna
// Mencatat waktu makan dan total nutrisi

class MealModel {
  String id;
  String userId;
  DateTime date;
  String mealTime; // 'morning', 'lunch', 'dinner', 'snack'
  List<FoodItemModel> foods; // List makanan yang dimakan dengan berat
  double totalCarbs;
  double totalCalories;
  double totalProtein;
  double totalFat;

  MealModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.mealTime,
    required this.foods,
    required this.totalCarbs,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
  });

  /// Konversi object MealModel ke Map (untuk database/API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'mealTime': mealTime,
      'foods': foods.map((food) => food.toJson()).toList(),
      'totalCarbs': totalCarbs,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalFat': totalFat,
    };
  }

  /// Konversi Map ke object MealModel (dari database/API)
  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      mealTime: json['mealTime'] as String,
      foods: (json['foods'] as List)
          .map((food) => FoodItemModel.fromJson(food as Map<String, dynamic>))
          .toList(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
    );
  }

  // Hitung ulang total nutrisi dari semua makanan
  void calculateTotals() {
    totalCarbs = 0;
    totalCalories = 0;
    totalProtein = 0;
    totalFat = 0;

    for (var food in foods) {
      totalCarbs += food.carbs;
      totalCalories += food.calories;
      totalProtein += food.protein;
      totalFat += food.fat;
    }
  }

  // Copy object dengan kemampuan mengubah field tertentu
  MealModel copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? mealTime,
    List<FoodItemModel>? foods,
    double? totalCarbs,
    double? totalCalories,
    double? totalProtein,
    double? totalFat,
  }) {
    return MealModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mealTime: mealTime ?? this.mealTime,
      foods: foods ?? this.foods,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalFat: totalFat ?? this.totalFat,
    );
  }

  //label waktu makan dalam bahasa Indonesia
  String getMealTimeLabel() {
    switch (mealTime) {
      case 'morning':
        return 'Pagi';
      case 'lunch':
        return 'Siang';
      case 'dinner':
        return 'Malam';
      case 'snack':
        return 'Camilan';
      default:
        return 'Lainnya';
    }
  }

  @override
  String toString() {
    return 'MealModel(id: $id, mealTime: $mealTime, totalCarbs: ${totalCarbs}g)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MealModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Model untuk item makanan dalam meal dengan berat dan nutrisi
class FoodItemModel {
  String foodId;
  String foodName;
  double weight; // gram
  double carbs;
  double calories;
  double protein;
  double fat;

  FoodItemModel({
    required this.foodId,
    required this.foodName,
    required this.weight,
    required this.carbs,
    required this.calories,
    required this.protein,
    required this.fat,
  });

  /// Konversi object FoodItemModel ke Map
  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'weight': weight,
      'carbs': carbs,
      'calories': calories,
      'protein': protein,
      'fat': fat,
    };
  }

  /// Konversi Map ke object FoodItemModel
  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      foodId: json['foodId'] as String,
      foodName: json['foodName'] as String,
      weight: (json['weight'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  /// Copy object dengan kemampuan mengubah field tertentu
  FoodItemModel copyWith({
    String? foodId,
    String? foodName,
    double? weight,
    double? carbs,
    double? calories,
    double? protein,
    double? fat,
  }) {
    return FoodItemModel(
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      weight: weight ?? this.weight,
      carbs: carbs ?? this.carbs,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
    );
  }

  @override
  String toString() {
    return 'FoodItemModel(foodName: $foodName, weight: ${weight}g, carbs: ${carbs}g)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItemModel && other.foodId == foodId;
  }

  @override
  int get hashCode => foodId.hashCode;
}
