import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../logic/garage_provider.dart';

class VehicleDetailScreen extends ConsumerWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garageState = ref.watch(garageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detail & Riwayat Motor',
          style: AppTypography.headline1.copyWith(
            color: AppColors.charcoalDark,
          ),
        ),
      ),
      body: garageState.when(
        data: (vehicles) {
          final vehicle = vehicles.firstWhere(
            (v) => v.id == vehicleId,
            orElse: () => vehicles.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.charcoalDark,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    vehicle.plateNumber,
                                    style: AppTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  vehicle.modelName,
                                  style: AppTypography.headline1.copyWith(
                                    color: AppColors.charcoalDark,
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vehicle.year.toString(),
                                  style: AppTypography.headline2.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.two_wheeler,
                              color: AppColors.primaryOrange,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Riwayat Perbaikan (Dummy)',
                  style: AppTypography.headline2,
                ),
                const SizedBox(height: 16),
                _buildHistoryCard(
                  date: '12 Sep 2026',
                  workshop: 'PitStop BSD Autoparts',
                  services: 'Ganti Oli MPX 2, Servis CVT',
                  cost: 'Rp 120.000',
                ),
                _buildHistoryCard(
                  date: '05 Jan 2026',
                  workshop: 'PitStop Cipete Raya',
                  services: 'Ganti Kampas Rem Depan, Tune Up',
                  cost: 'Rp 185.000',
                ),
                _buildHistoryCard(
                  date: '10 Ags 2025',
                  workshop: 'PitStop BSD Autoparts',
                  services: 'Servis Rutin, Ganti Busi',
                  cost: 'Rp 95.000',
                ),
              ],
            ),
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) =>
              const ShimmerLoading(width: double.infinity, height: 120),
        ),
        error: (e, _) => Center(child: Text('Gagal memuat: $e')),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String workshop,
    required String services,
    required String cost,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                cost,
                style: AppTypography.body1Medium.copyWith(
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(workshop, style: AppTypography.headline2),
          const SizedBox(height: 4),
          Text(services, style: AppTypography.body2),
        ],
      ),
    );
  }
}
