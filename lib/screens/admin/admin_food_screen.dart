import 'package:flutter/material.dart';
import 'package:diabetes/services/food_service.dart';
import 'package:diabetes/models/food_model.dart';

class AdminFoodScreen extends StatefulWidget {
  const AdminFoodScreen({super.key});

  @override
  State<AdminFoodScreen> createState() => _AdminFoodScreenState();
}

class _AdminFoodScreenState extends State<AdminFoodScreen> {
  final FoodService _foodService = FoodService();
  late Future<List<FoodModel>> _foodsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _foodsFuture = _foodService.getAllFoods();
    });
  }

  // ==================== 1. FITUR TAMBAH MAKANAN ====================
  void _showAddFoodSheet() {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final carbsController = TextEditingController();
    final proteinController = TextEditingController();
    final fatController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tambah Data Makanan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7), // Admin Purple
                ),
              ),
              const SizedBox(height: 16),

              // Nama Makanan
              TextField(
                controller: nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "Nama Makanan",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fastfood, color: Colors.purple),
                ),
              ),
              const SizedBox(height: 16),

              // Baris 1: Kalori & Karbo
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: caloriesController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Kalori",
                        border: OutlineInputBorder(),
                        suffixText: "kkal",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: carbsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Karbo",
                        border: OutlineInputBorder(),
                        suffixText: "g",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Baris 2: Protein & Lemak
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: proteinController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: "Protein",
                        border: OutlineInputBorder(),
                        suffixText: "g",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: fatController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: "Lemak",
                        border: OutlineInputBorder(),
                        suffixText: "g",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Nama makanan wajib diisi"),
                        ),
                      );
                      return;
                    }

                    // Parse angka (default 0.0 jika kosong/error)
                    final double calories =
                        double.tryParse(caloriesController.text) ?? 0.0;
                    final double carbs =
                        double.tryParse(carbsController.text) ?? 0.0;
                    final double protein =
                        double.tryParse(proteinController.text) ?? 0.0;
                    final double fat =
                        double.tryParse(fatController.text) ?? 0.0;

                    try {
                      // AKTIFKAN UNTUK KE FIREBASE
                      await _foodService.addFood(
                        FoodModel(
                          id: '', // ID kosong, nanti digenerate Firestore
                          name: nameController.text,
                          calories: calories,
                          carbs: carbs,
                          protein: protein,
                          fat: fat,
                        ),
                      );

                      if (mounted) {
                        Navigator.pop(context); // Tutup form
                        _loadData(); // Refresh tampilan list
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Data makanan berhasil disimpan ke Database",
                            ),
                            backgroundColor: Colors.purple,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Gagal menyimpan: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "SIMPAN DATA",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 2. FITUR DETAIL MAKANAN ====================
  void _showFoodDetail(FoodModel food) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 40,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              food.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4527A0),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Informasi Nilai Gizi (Per 100g/Porsi)",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Grid Nutrisi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientInfo(
                  "Kalori",
                  "${food.calories.toInt()}",
                  "kkal",
                  Colors.orange,
                ),
                _buildNutrientInfo("Karbo", "${food.carbs}", "g", Colors.blue),
                _buildNutrientInfo(
                  "Protein",
                  "${food.protein}",
                  "g",
                  Colors.green,
                ),
                _buildNutrientInfo(
                  "Lemak",
                  "${food.fat}",
                  "g",
                  Colors.redAccent,
                ),
              ],
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.purple),
                  foregroundColor: Colors.purple,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Tutup"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tema Admin Purple
    const primaryColor = Color(0xFF673AB7);
    const bgColor = Color(0xFFF3E5F5);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Manajemen Makanan"),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFoodSheet,
        backgroundColor: const Color(0xFFD1C4E9),
        foregroundColor: primaryColor,
        icon: const Icon(Icons.add),
        label: const Text("Tambah Makanan"),
      ),

      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: primaryColor,
        child: FutureBuilder<List<FoodModel>>(
          future: _foodsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_food, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      "Belum ada data makanan",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            }

            final foods = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: foods.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final food = foods[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showFoodDetail(food),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.fastfood_rounded,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department,
                                      size: 14,
                                      color: Colors.orange[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${food.calories.toInt()} kkal",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "•",
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "K: ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      "${food.carbs}g",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
