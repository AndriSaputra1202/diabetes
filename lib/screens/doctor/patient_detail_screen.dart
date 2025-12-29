import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diabetes/providers/doctor_provider.dart';
import 'package:diabetes/models/user_model.dart';
import 'package:diabetes/screens/doctor/doctor_recommendation_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailScreen({super.key, required this.patientId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ OPTIMASI: Memastikan data dimuat saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().selectPatient(widget.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari Provider
    final doctorProvider = context.watch<DoctorProvider>();

    // ✅ Type Safety: Memastikan tipe data jelas
    final UserModel? patient = doctorProvider.selectedPatient;
    final meals = doctorProvider.selectedPatientMeals;
    final stats = doctorProvider.patientStats;

    // Loading state
    if (doctorProvider.isLoading || patient == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ==================== HEADER ====================
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF009688), Color(0xFF00796B)], // Teal Gradient
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // App Bar Custom
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${patient.age} Tahun • ${patient.gender}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Row (Header)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHeaderStat(
                      'Gula Darah',
                      '${patient.bloodSugar.toInt()} mg/dL',
                    ),
                    _buildHeaderStat(
                      'Target Karbo',
                      '${patient.targetCarbs.toInt()} g',
                    ),
                    _buildHeaderStat(
                      'Berat Badan',
                      '${patient.weight.toInt()} kg',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==================== BODY CONTENT ====================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOMBOL REKOMENDASI
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DoctorRecommendationScreen(patient: patient),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.edit_note, size: 24),
                      label: const Text(
                        "BERI REKOMENDASI",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. CARD STATISTIK HARIAN
                  Text(
                    "Statistik Hari Ini",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDailyStatsCard(stats),

                  const SizedBox(height: 24),

                  // 3. LOG MAKANAN (HISTORY)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Riwayat Makan",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        "${meals.length} entri",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (meals.isEmpty)
                    _buildEmptyState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        return _buildMealCard(meals[index]);
                      },
                    ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper: Statistik di Header (Atas)
  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }

  // Helper: Card Statistik Harian (Tengah)
  Widget _buildDailyStatsCard(Map<String, dynamic>? stats) {
    final double karbo = stats?['totalCarbs']?.toDouble() ?? 0.0;
    final double kalori = stats?['totalCalories']?.toDouble() ?? 0.0;
    final double protein = stats?['totalProtein']?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            Icons.grain,
            'Karbo',
            '${karbo.toInt()}g',
            Colors.blue,
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          _buildStatItem(
            Icons.local_fire_department,
            'Kalori',
            '${kalori.toInt()}',
            Colors.orange,
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          _buildStatItem(
            Icons.fitness_center,
            'Protein',
            '${protein.toInt()}g',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  // Helper: Card List Makanan
  Widget _buildMealCard(var meal) {
    IconData icon;
    Color color;
    String timeLabel;

    switch (meal.mealTime) {
      case 'morning':
        icon = Icons.wb_sunny;
        color = Colors.orange;
        timeLabel = 'Pagi';
        break;
      case 'lunch':
        icon = Icons.wb_cloudy;
        color = Colors.amber;
        timeLabel = 'Siang';
        break;
      case 'dinner':
        icon = Icons.nights_stay;
        color = Colors.indigo;
        timeLabel = 'Malam';
        break;
      default:
        icon = Icons.cookie;
        color = Colors.purple;
        timeLabel = 'Camilan';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          timeLabel,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              "${meal.totalCalories.toInt()} kkal • ${meal.totalCarbs.toInt()}g Karbo",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (meal.foods.isNotEmpty)
              Text(
                meal.foods.map((f) => f.foodName).join(", "),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "${meal.foods.length} item",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.no_meals, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            "Belum ada catatan makan hari ini",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
