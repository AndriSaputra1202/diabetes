import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diabetes/providers/auth_provider.dart';
import 'package:diabetes/providers/patient_provider.dart';
import 'package:diabetes/screens/patient/recommendations_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // Palet Warna (Sesuai Tema Dashboard)
  final Color _primaryGreen = const Color(0xFF66BB6A);
  final Color _bgGreen = const Color(0xFFF1F8E9);

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, _) {
        return Scaffold(
          backgroundColor: _bgGreen,
          appBar: AppBar(
            title: const Text(
              "Pesan & Notifikasi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0.5,
            automaticallyImplyLeading:
                false, // Hilangkan tombol back di tab utama
            centerTitle: true,
          ),
          body: RefreshIndicator(
            color: _primaryGreen,
            onRefresh: () async {
              final user = context.read<AuthProvider>().currentUser;
              if (user != null) {
                await patientProvider.refreshData(user.id);
              }
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

                // Kartu Rekomendasi Dokter
                _buildRecommendationCard(context, patientProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    PatientProvider patientProvider,
  ) {
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
          onTap: () {
            // Navigasi ke halaman detail rekomendasi
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecommendationsScreen()),
            );
          },
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
}
