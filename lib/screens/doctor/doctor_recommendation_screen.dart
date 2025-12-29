import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diabetes/models/user_model.dart';
import 'package:diabetes/models/food_model.dart';
import 'package:diabetes/providers/doctor_provider.dart';
import 'package:diabetes/providers/auth_provider.dart';
import 'package:diabetes/providers/food_provider.dart';

class DoctorRecommendationScreen extends StatefulWidget {
  final UserModel patient;

  const DoctorRecommendationScreen({super.key, required this.patient});

  @override
  State<DoctorRecommendationScreen> createState() =>
      _DoctorRecommendationScreenState();
}

class _DoctorRecommendationScreenState
    extends State<DoctorRecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  // State Variables
  String? selectedCategory;
  String selectedPriority = 'Sedang'; // Default
  List<FoodModel> _selectedFoods = [];
  bool _isSending = false;

  final List<String> categories = [
    'Saran Makanan',
    'Pantangan Makanan',
    'Pola Makan',
    'Aktivitas Fisik',
    'Lainnya',
  ];

  final List<String> priorities = ['Rendah', 'Sedang', 'Tinggi'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().loadFoods();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // ==================== LOGIC METHODS (DIPERBAIKI) ====================

  Future<void> _handleSendRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih kategori rekomendasi')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final doctorProvider = context.read<DoctorProvider>();

      // ✅ PERBAIKAN: Cek session, jika null coba load ulang (Fix Hot Restart Issue)
      if (authProvider.currentUser == null) {
        await authProvider.checkAuthStatus();
      }

      final currentUser = authProvider.currentUser;

      // Jika masih null setelah reload, berarti memang logout
      if (currentUser == null) {
        throw Exception("Sesi dokter berakhir. Silakan login ulang.");
      }

      // Kirim ke Firebase
      final success = await doctorProvider.sendRecommendation(
        patientId: widget.patient.id,
        doctorId: currentUser.id,
        doctorName: currentUser.name,
        category: selectedCategory!,
        message: _messageController.text.trim(),
        foods: _selectedFoods.map((f) => f.name).toList(),
        priority: selectedPriority,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Rekomendasi berhasil dikirim!'),
            backgroundColor: Colors.teal,
          ),
        );
        Navigator.pop(context); // Kembali ke detail pasien
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // Modal Selector (Sama seperti sebelumnya)
  void _showFoodSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (_, controller) {
            return Consumer<FoodProvider>(
              builder: (context, foodProvider, _) {
                final foods = foodProvider.allFoods;

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: const Text(
                        "Pilih Makanan (Opsional)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: controller,
                        itemCount: foods.length,
                        itemBuilder: (context, index) {
                          final food = foods[index];
                          final isSelected = _selectedFoods.contains(food);

                          return ListTile(
                            title: Text(food.name),
                            subtitle: Text(
                              "${food.calories.toInt()} kkal • Karbo: ${food.carbs}g",
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.teal,
                                  )
                                : const Icon(
                                    Icons.circle_outlined,
                                    color: Colors.grey,
                                  ),
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFoods.remove(food);
                                } else {
                                  _selectedFoods.add(food);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                          child: const Text(
                            "Selesai Memilih",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Tinggi':
        return Colors.red;
      case 'Sedang':
        return Colors.orange;
      case 'Rendah':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Rekomendasi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.teal, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.patient.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.patient.age} tahun • Target: ${widget.patient.targetCarbs}g karbo/hari',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Selection
              const Text(
                'Kategori Rekomendasi *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  hintText: 'Pilih kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
              ),
              const SizedBox(height: 24),

              // Recommended Foods
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rekomendasi Makanan (Opsional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _showFoodSelector,
                    icon: const Icon(Icons.add, size: 18, color: Colors.teal),
                    label: const Text(
                      "Pilih",
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_selectedFoods.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedFoods.map((food) {
                    return Chip(
                      label: Text(food.name),
                      backgroundColor: Colors.teal.shade50,
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedFoods.remove(food);
                        });
                      },
                      labelStyle: const TextStyle(color: Colors.teal),
                    );
                  }).toList(),
                )
              else
                const Text(
                  "Belum ada makanan dipilih.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),

              const SizedBox(height: 24),

              // Message Input
              const Text(
                'Pesan / Saran Medis *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Tulis saran lengkap untuk pasien...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Masukkan pesan rekomendasi' : null,
              ),
              const SizedBox(height: 24),

              // Priority Selection
              const Text(
                'Tingkat Urgensi *',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: priorities.map((priority) {
                  bool isSelected = selectedPriority == priority;
                  Color color = _getPriorityColor(priority);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () =>
                            setState(() => selectedPriority = priority),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? color : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            priority,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _handleSendRecommendation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'KIRIM REKOMENDASI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
