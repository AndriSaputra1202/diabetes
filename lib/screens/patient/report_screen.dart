/// File: lib/screens/patient/report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diabetes/providers/auth_provider.dart';
import 'package:diabetes/services/database_service.dart';
import 'package:diabetes/models/meal_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DatabaseService _databaseService = DatabaseService();

  // Tema Warna (Fresh Green) - Konsisten dengan Dashboard
  final Color _primaryGreen = const Color(0xFF66BB6A);
  final Color _darkGreen = const Color(0xFF2E7D32);
  final Color _bgGreen = const Color(0xFFF1F8E9);

  // State variables
  DateTime _selectedDate = DateTime.now();
  List<MealModel> _selectedDateMeals = [];
  List<Map<String, dynamic>> _weeklyData = [];

  bool _isLoadingMeals = false;
  bool _isLoadingWeekly = false;
  String? _errorMessage; // ✅ Variabel ini sekarang akan digunakan

  // Nutrition totals
  double _totalCarbs = 0;
  double _totalCalories = 0;
  double _totalProtein = 0;
  double _totalFat = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      await Future.wait([_loadMealsData(_selectedDate), _loadWeeklyTrend()]);
    }
  }

  Future<void> _loadMealsData(DateTime date) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    setState(() {
      _isLoadingMeals = true;
      _errorMessage = null; // Reset error sebelum load
    });

    try {
      final meals = await _databaseService.getMealsByDate(
        authProvider.currentUser!.id,
        date,
      );

      _calculateTotalNutrition(meals);

      if (mounted) {
        setState(() {
          _selectedDateMeals = meals;
          _isLoadingMeals = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: $e'; // Set pesan error
          _isLoadingMeals = false;
        });
      }
    }
  }

  void _calculateTotalNutrition(List<MealModel> meals) {
    double carbs = 0;
    double calories = 0;
    double protein = 0;
    double fat = 0;

    for (var meal in meals) {
      carbs += meal.totalCarbs;
      calories += meal.totalCalories;
      protein += meal.totalProtein;
      fat += meal.totalFat;
    }

    if (mounted) {
      setState(() {
        _totalCarbs = carbs;
        _totalCalories = calories;
        _totalProtein = protein;
        _totalFat = fat;
      });
    }
  }

  Future<void> _loadWeeklyTrend() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) return;

    setState(() => _isLoadingWeekly = true);

    try {
      final stats = await _databaseService.getNutritionStats(
        authProvider.currentUser!.id,
        days: 7,
      );

      if (mounted) {
        setState(() {
          _weeklyData = stats;
          _isLoadingWeekly = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingWeekly = false);
      debugPrint('Error loading weekly trend: $e');
    }
  }

  Future<void> _refreshData() async {
    await _initializeData();
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryGreen,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      await _loadMealsData(picked);
    }
  }

  String _getFormattedDate(DateTime date) {
    final List<String> days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final List<String> months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showMealDetail(String mealTime) {
    final mealsForTime = _selectedDateMeals
        .where((meal) => meal.mealTime == mealTime)
        .toList();

    if (mealsForTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada data untuk waktu makan ini'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMealDetailModal(mealsForTime),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgGreen,
      appBar: AppBar(
        title: const Text(
          'Laporan Konsumsi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        color: _primaryGreen,
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildDateSelector(),

              // ✅ Menampilkan Error jika ada
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              if (_isLoadingMeals)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_selectedDateMeals.isEmpty &&
                  _errorMessage == null) // Cek error null
                _buildEmptyState()
              else ...[
                _buildSectionTitle('Tren Mingguan'),
                _buildWeeklyTrendChart(),

                _buildSectionTitle('Ringkasan Nutrisi'),
                _buildNutritionSummary(),

                _buildSectionTitle('Detail Waktu Makan'),
                _buildMealTimesList(),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryGreen, _darkGreen],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 40, color: Colors.white),
          SizedBox(height: 10),
          Text(
            'Statistik Harian',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text('', style: TextStyle(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }

  // ==================== DATE SELECTOR ====================

  Widget _buildDateSelector() {
    return Transform.translate(
      offset: const Offset(0, -25),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_month, color: _primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tanggal',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getFormattedDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: _showDatePicker,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Ubah',
                  style: TextStyle(
                    color: _primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_meals_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Belum ada data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada catatan pada tanggal ini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ==================== NUTRITION SUMMARY ====================

  Widget _buildNutritionSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _buildNutritionCard(
            'Karbohidrat',
            _totalCarbs,
            'g',
            Icons.grain_rounded,
            Colors.blue,
          ),
          _buildNutritionCard(
            'Kalori',
            _totalCalories,
            'kcal',
            Icons.local_fire_department_rounded,
            Colors.orange,
          ),
          _buildNutritionCard(
            'Protein',
            _totalProtein,
            'g',
            Icons.fitness_center_rounded,
            Colors.green,
          ),
          _buildNutritionCard(
            'Lemak',
            _totalFat,
            'g',
            Icons.water_drop_rounded,
            Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(
    String title,
    double value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== WEEKLY CHART ====================

  Widget _buildWeeklyTrendChart() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart_rounded, color: _primaryGreen, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tren Karbo 7 Hari',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingWeekly)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_weeklyData.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Belum ada data tren',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            )
          else
            _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (_weeklyData.isEmpty) return const SizedBox();

    double maxCarbs = 0;
    for (var data in _weeklyData) {
      if (data['carbs'] > maxCarbs)
        maxCarbs = (data['carbs'] as num).toDouble();
    }
    if (maxCarbs == 0) maxCarbs = 100;

    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _weeklyData.map((data) {
          final carbs = (data['carbs'] as num).toDouble();
          final date = data['date'] as String;
          final heightPercentage = (carbs / maxCarbs).clamp(0.0, 1.0);

          DateTime? dateTime;
          try {
            dateTime = DateTime.parse(date);
          } catch (e) {
            dateTime = DateTime.now();
          }

          final dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
          final dayLabel = dayNames[dateTime.weekday - 1];

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    carbs.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 120 * heightPercentage,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [_primaryGreen, _primaryGreen.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayLabel,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== MEAL LIST ====================

  Widget _buildMealTimesList() {
    final mealTimes = [
      {'id': 'morning', 'label': 'Pagi', 'icon': Icons.wb_sunny_rounded},
      {'id': 'lunch', 'label': 'Siang', 'icon': Icons.wb_sunny_outlined},
      {'id': 'dinner', 'label': 'Malam', 'icon': Icons.nights_stay_rounded},
      {'id': 'snack', 'label': 'Camilan', 'icon': Icons.cookie_outlined},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: mealTimes.map((mealTime) {
          final mealsForTime = _selectedDateMeals
              .where((meal) => meal.mealTime == mealTime['id'])
              .toList();
          return _buildMealTimeCard(
            mealTime['id'] as String,
            mealTime['label'] as String,
            mealTime['icon'] as IconData,
            mealsForTime,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMealTimeCard(
    String mealTimeId,
    String label,
    IconData icon,
    List<MealModel> meals,
  ) {
    final itemCount = meals.fold<int>(
      0,
      (sum, meal) => sum + meal.foods.length,
    );
    final totalCarbs = meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalCarbs,
    );
    final totalCalories = meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalCalories,
    );
    final hasData = meals.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasData ? _primaryGreen.withOpacity(0.5) : Colors.transparent,
          width: hasData ? 1.5 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: hasData ? () => _showMealDetail(mealTimeId) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (hasData ? _primaryGreen : Colors.grey[400]!)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: hasData ? _primaryGreen : Colors.grey[400],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (hasData)
                        Text(
                          '$itemCount item • ${totalCarbs.toStringAsFixed(0)}g karbo • ${totalCalories.toStringAsFixed(0)} kcal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        )
                      else
                        Text(
                          'Belum ada data',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                if (hasData)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: _primaryGreen,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== MEAL DETAIL MODAL ====================

  Widget _buildMealDetailModal(List<MealModel> meals) {
    double totalCarbs = 0;
    double totalCalories = 0;
    double totalProtein = 0;
    double totalFat = 0;

    for (var meal in meals) {
      totalCarbs += meal.totalCarbs;
      totalCalories += meal.totalCalories;
      totalProtein += meal.totalProtein;
      totalFat += meal.totalFat;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detail Makanan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                      children: [
                        _buildSummaryCard(
                          'Karbo',
                          totalCarbs,
                          'g',
                          Colors.blue,
                        ),
                        _buildSummaryCard(
                          'Kalori',
                          totalCalories,
                          'kcal',
                          Colors.orange,
                        ),
                        _buildSummaryCard(
                          'Protein',
                          totalProtein,
                          'g',
                          Colors.green,
                        ),
                        _buildSummaryCard('Lemak', totalFat, 'g', Colors.red),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Daftar Item',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...meals
                        .expand(
                          (meal) => meal.foods.map(
                            (food) => _buildFoodItemCard(food),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    String label,
    double value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
          const SizedBox(height: 2),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItemCard(FoodItemModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.foodName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${food.weight} gram',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${food.carbs}g Karbo',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                '${food.calories} kkal',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
