// Model untuk data makanan/nutrisi
// Nilai nutrisi per 100 gram

class FoodModel {
  String id;
  String name;
  double carbs; // per 100g
  double calories; // per 100g
  double protein; // per 100g
  double fat; // per 100g

  FoodModel({
    required this.id,
    required this.name,
    required this.carbs,
    required this.calories,
    required this.protein,
    required this.fat,
  });

  /// Konversi object FoodModel ke Map (untuk database)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'carbs': carbs,
      'calories': calories,
      'protein': protein,
      'fat': fat,
    };
  }

  /// Konversi Map ke object FoodModel (dari database)
  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      carbs: (json['carbs'] as num).toDouble(),
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  /// Hitung nutrisi berdasarkan berat (gram)
  Map<String, double> calculateNutrition(double weight) {
    double factor = weight / 100;
    return {
      'carbs': carbs * factor,
      'calories': calories * factor,
      'protein': protein * factor,
      'fat': fat * factor,
    };
  }

  /// Copy object dengan kemampuan mengubah field tertentu
  FoodModel copyWith({
    String? id,
    String? name,
    double? carbs,
    double? calories,
    double? protein,
    double? fat,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      carbs: carbs ?? this.carbs,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
    );
  }

  @override
  String toString() {
    return 'FoodModel(id: $id, name: $name, carbs: ${carbs}g, calories: ${calories}kcal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
