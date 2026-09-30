import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';

import '../../../auth/logic/auth_controller.dart';
import '../../../garage/logic/garage_provider.dart';
import '../../../../core/data/dummy_workshops.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/promo_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final user = session?.user;
    final fullName = user?.userMetadata?['full_name'] ?? 'Pengguna';

    final garageState = ref.watch(garageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: InkWell(
          onTap: () => context.go('/profile'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                    style: AppTypography.headline2.copyWith(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $fullName',
                        style: AppTypography.headline2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.statusSuccess,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Akun Terverifikasi',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.statusSuccess,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.charcoalDark,
            ),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lokasi Saat Ini
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lokasi Saat Ini', style: AppTypography.caption),
                        Text(
                          'Jakarta, Indonesia',
                          style: AppTypography.body1Medium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Banner Promosi (Carousel)
              PromoCarousel(
                banners: [
                  PromoBanner(
                    title: 'Servis Banyak Motor Lebih Praktis',
                    subtitle: 'Dapatkan diskon khusus untuk servis borongan.',
                    backgroundColor: AppColors.primaryDark,
                  ),
                  PromoBanner(
                    title: 'Gratis Cuci Motor!',
                    subtitle:
                        'Setiap servis lengkap mendapatkan gratis cuci motor.',
                    backgroundColor: AppColors.statusProgress,
                  ),
                  PromoBanner(
                    title: 'Ganti Oli 3x Gratis 1x',
                    subtitle: 'Promo pelanggan setia, kumpulkan cap sekarang.',
                    backgroundColor: AppColors.statusSuccess,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Garasi Saya
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Garasi Saya', style: AppTypography.headline2),
                  TextButton(
                    onPressed: () {
                      context.go('/garage');
                    },
                    child: Text(
                      'Lihat Semua',
                      style: AppTypography.body1Medium.copyWith(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Daftar Motor
              garageState.when(
                data: (vehicles) {
                  if (vehicles.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGrey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          'Belum ada kendaraan di garasi.',
                          style: AppTypography.body2,
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: vehicles.length > 3 ? 3 : vehicles.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final v = vehicles[index];
                        return GestureDetector(
                          onTap: () {
                            context.push('/vehicle/${v.id}');
                          },
                          child: Container(
                            width: 280,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.two_wheeler,
                                    color: AppColors.primaryOrange,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.charcoalDark,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          v.plateNumber,
                                          style: AppTypography.caption.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${v.modelName} (${v.year})',
                                        style: AppTypography.headline2,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 16),
                    itemBuilder: (context, index) =>
                        const ShimmerLoading(width: 280, height: 120),
                  ),
                ),
                error: (err, stack) => Text(
                  'Terjadi kesalahan: $err',
                  style: AppTypography.body2.copyWith(
                    color: AppColors.statusError,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Bengkel Terdekat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bengkel Terdekat', style: AppTypography.headline2),
                  TextButton(
                    onPressed: () {
                      context.push('/workshop-list');
                    },
                    child: Text(
                      'Lihat Semua',
                      style: AppTypography.body1Medium.copyWith(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: defaultWorkshops
                    .where((w) => w.city.toLowerCase().contains('jakarta'))
                    .take(3)
                    .map((workshop) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            context.push('/workshop/${workshop.id}');
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: AppColors.primaryOrange,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        workshop.name,
                                        style: AppTypography.headline2,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${workshop.address}, ${workshop.city}',
                                        style: AppTypography.body2,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: AppColors.primaryOrange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${workshop.distanceKm} km',
                                            style: AppTypography.caption,
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.star,
                                            size: 14,
                                            color: AppColors.primaryOrange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '4.8 (120 Ulasan)',
                                            style: AppTypography.caption,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
