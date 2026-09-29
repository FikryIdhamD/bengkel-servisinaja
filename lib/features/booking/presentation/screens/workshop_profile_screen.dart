import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/data/dummy_workshops.dart';

class WorkshopProfileScreen extends ConsumerWidget {
  final String workshopId;

  const WorkshopProfileScreen({super.key, required this.workshopId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find workshop from default list for now (replace with Supabase fetch later)
    final workshop = defaultWorkshops.firstWhere(
      (w) => w.id == workshopId,
      orElse: () => defaultWorkshops.first,
    );

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
          'Profil Bengkel',
          style: AppTypography.headline1.copyWith(
            color: AppColors.charcoalDark,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.store, size: 80, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(workshop.name, style: AppTypography.headline1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.primaryOrange,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '4.8 (120 Ulasan)',
                        style: AppTypography.body1Medium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Informasi Bengkel', style: AppTypography.headline2),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alamat Lengkap',
                              style: AppTypography.body1Medium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${workshop.address}, ${workshop.city}',
                              style: AppTypography.body2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jam Operasional',
                              style: AppTypography.body1Medium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workshop.openingHours,
                              style: AppTypography.body2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.phone, color: AppColors.primaryOrange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Telepon', style: AppTypography.body1Medium),
                            const SizedBox(height: 4),
                            Text(
                              workshop.phoneNumber,
                              style: AppTypography.body2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: PrimaryButton(
                text: 'Buka di Google Maps',
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
