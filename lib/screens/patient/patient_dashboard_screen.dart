import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diabetes/providers/auth_provider.dart';
import 'package:diabetes/providers/patient_provider.dart';
import 'package:diabetes/utils/nutrition_calculator.dart';

import 'package:diabetes/models/meal_model.dart';
import 'package:diabetes/screens/patient/report_screen.dart';
import 'package:diabetes/screens/patient/add_food_screen.dart';
import 'package:diabetes/screens/patient/profile_screen.dart';
import 'package:diabetes/screens/patient/recommendations_screen.dart';
//import 'package:diabetes/auth/login_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedIndex = 0;

  // ==================== TEMA WARNA ====================
  final Color _primaryGreen = const Color(0xFF66BB6A); // Hijau Cerah
  final Color _darkGreen = const Color(0xFF2E7D32); // Hijau Tua
  final Color _bgGreen = const Color(0xFFF5F7FA); // Background Putih Abu

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final patientProvider = context.read<PatientProvider>();

    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      final user = authProvider.currentUser!;
      patientProvider.setTargets(
        carbs: user.targetCarbs,
        calories: user.targetCarbs * 4 * 2.5,
      );
      await patientProvider.refreshData(user.id);
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
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
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _navigateToAddFood(String mealTimeId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddFoodScreen(mealTimeId: mealTimeId)),
    );
    if (mounted) await _loadData();
  }

  void _navigateToRecommendations() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RecommendationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeContent(), // Index 0: Home
      const ReportScreen(), // Index 1: Laporan
      _buildNotificationTab(), // Index 2: Notifikasi
      const ProfileScreen(), // Index 3: Profil
    ];

    return Scaffold(
      backgroundColor: _bgGreen,
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ==================== 1. HOME CONTENT ====================

  Widget _buildHomeContent() {
    return Consumer2<AuthProvider, PatientProvider>(
      builder: (context, authProvider, patientProvider, _) {
        if (authProvider.isLoading) {
          return Center(child: CircularProgressIndicator(color: _primaryGreen));
        }

        final user = authProvider.currentUser;
        if (user == null) return _buildUserNotFoundWidget();

        final List<MealModel> meals = patientProvider.todayMeals
            .cast<MealModel>()
            .toList();
        final totalCarbs = patientProvider.totalCarbs;

        if (totalCarbs > user.targetCarbs && meals.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted)
              _showOverTargetWarning(context, totalCarbs, user.targetCarbs);
          });
        }

        return RefreshIndicator(
          color: _primaryGreen,
          onRefresh: () async {
            await patientProvider.refreshData(user.id);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(user.name, authProvider),
                const SizedBox(height: 20),

                // Kartu Nutrisi
                _buildNutritionCards(
                  totalCarbs,
                  patientProvider.totalCalories,
                  patientProvider.totalProtein,
                  patientProvider.totalFat,
                  user.targetCarbs,
                ),

                // Bagian Jadwal Makan
                _buildMealTimesSection(meals, user.id),

                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== 2. NOTIFICATION TAB ====================

  Widget _buildNotificationTab() {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, _) {
        return Scaffold(
          backgroundColor: _bgGreen,
          appBar: AppBar(
            title: const Text(
              "Notifikasi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0.5,
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          body: RefreshIndicator(
            color: _primaryGreen,
            onRefresh: () async {
              final user = context.read<AuthProvider>().currentUser;
              if (user != null) await patientProvider.refreshData(user.id);
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  "Pesan Masuk",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecommendationCard(patientProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== COMPONENTS ====================

  Widget _buildHeader(String userName, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryGreen, _darkGreen],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, Semangat Sehat! 👋',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Tombol Logout dihapus dari sini (sudah ada di profil)
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _getFormattedDate(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(PatientProvider patientProvider) {
    final recommendations = patientProvider.recommendations;
    final unreadCount = patientProvider.unreadRecommendationsCount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _navigateToRecommendations,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_outlined,
                    color: Colors.orange.shade700,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pesan Dokter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recommendations.isEmpty
                            ? 'Tidak ada pesan baru'
                            : '${recommendations.length} pesan tersedia',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionCards(
    double totalCarbs,
    double totalCalories,
    double totalProtein,
    double totalFat,
    double targetCarbs,
  ) {
    final targetCalories = targetCarbs * 4 * 2.5;
    final targetProtein = targetCalories * 0.20 / 4;
    final targetFat = targetCalories * 0.25 / 9;

    return Transform.translate(
      offset: const Offset(0, -35),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            _buildNutritionCard(
              'Karbohidrat',
              totalCarbs,
              targetCarbs,
              'g',
              Icons.grain_rounded,
              _primaryGreen,
            ),
            _buildNutritionCard(
              'Kalori',
              totalCalories,
              targetCalories,
              'kcal',
              Icons.local_fire_department_rounded,
              Colors.orange,
            ),
            _buildNutritionCard(
              'Protein',
              totalProtein,
              targetProtein,
              'g',
              Icons.fitness_center_rounded,
              Colors.teal,
            ),
            _buildNutritionCard(
              'Lemak',
              totalFat,
              targetFat,
              'g',
              Icons.water_drop_rounded,
              Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(
    String title,
    double current,
    double target,
    String unit,
    IconData icon,
    Color color,
  ) {
    final percentage = NutritionCalculator.calculatePercentage(current, target);
    final progressColor = NutritionCalculator.getProgressColor(percentage);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                if (percentage > 100)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 18,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: current.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        TextSpan(
                          text: ' / ${target.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[400],
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[100],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTimesSection(List<MealModel> allMeals, String userId) {
    final mealTimes = [
      {
        'id': 'morning',
        'label': 'Sarapan',
        'icon': Icons.wb_sunny_rounded,
        'color': Colors.orange,
      },
      {
        'id': 'lunch',
        'label': 'Makan Siang',
        'icon': Icons.wb_sunny_outlined,
        'color': Colors.amber,
      },
      {
        'id': 'dinner',
        'label': 'Malam',
        'icon': Icons.nights_stay_rounded,
        'color': Colors.indigo,
      },
      {
        'id': 'snack',
        'label': 'Camilan',
        'icon': Icons.cookie_outlined,
        'color': Colors.purple,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jadwal Makan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ...mealTimes.map((mt) {
            final meals = allMeals
                .where((m) => m.mealTime == mt['id'])
                .toList();
            return _buildMealTimeCard(
              mt['label'] as String,
              mt['icon'] as IconData,
              mt['color'] as Color,
              meals,
              mt['id'] as String,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMealTimeCard(
    String label,
    IconData icon,
    Color color,
    List<MealModel> meals,
    String mealTimeId,
  ) {
    final itemCount = meals.fold<int>(
      0,
      (sum, meal) => sum + meal.foods.length,
    );
    final totalCarbs = meals.fold<double>(
      0,
      (sum, meal) => sum + meal.totalCarbs,
    );
    final hasData = meals.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasData ? _primaryGreen.withOpacity(0.5) : Colors.transparent,
          width: hasData ? 1.5 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToAddFood(mealTimeId),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        itemCount > 0
                            ? '$itemCount makanan • ${totalCarbs.toStringAsFixed(0)}g karbo'
                            : 'Belum ada catatan',
                        style: TextStyle(
                          fontSize: 13,
                          color: itemCount > 0
                              ? Colors.grey[700]
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _bgGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.add_rounded, color: _darkGreen, size: 22),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserNotFoundWidget() {
    return const Center(child: Text("User not found"));
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _darkGreen,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _showOverTargetWarning(
    BuildContext context,
    double current,
    double target,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text("Peringatan"),
          ],
        ),
        content: Text(
          "Anda telah melebihi target karbohidrat harian (${current.toInt()}/${target.toInt()}g).",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Saya Mengerti"),
          ),
        ],
      ),
    );
  }
}
