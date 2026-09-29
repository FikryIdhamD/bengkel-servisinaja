import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';

import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../auth/logic/auth_controller.dart';
import '../../../garage/logic/garage_provider.dart';
import '../../../booking/logic/booking_schedule_provider.dart';

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
        title: Row(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, $fullName', style: AppTypography.headline2),
                Row(
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 14,
                      color: AppColors.statusSuccess,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Akun Terverifikasi',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.statusSuccess,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.charcoalDark,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.charcoalDark),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return ConfirmationDialog(
                    title: 'Konfirmasi Keluar',
                    content:
                        'Apakah Anda yakin ingin keluar dari sesi aplikasi saat ini?',
                    cancelText: 'Batal',
                    confirmText: 'Keluar',
                    onCancel: () => Navigator.pop(dialogContext),
                    onConfirm: () {
                      Navigator.pop(dialogContext); // Tutup dialog
                      final authRepo = ref.read(authRepositoryProvider);
                      context.go('/login'); // Pindah halaman
                      Future.microtask(() async {
                        await authRepo.signOut(); // Proses logout background
                      });
                    },
                  );
                },
              );
            },
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
                          'Jakarta Barat, DKI Jakarta',
                          style: AppTypography.body1Medium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Banner Promosi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryOrange, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Servis Banyak Motor Sekaligus Lebih Praktis',
                            style: AppTypography.headline2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'di PitStop by Servisin Aja',
                            style: AppTypography.body2.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.handyman, size: 48, color: Colors.white),
                  ],
                ),
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
                        return Container(
                          width: 240,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                  v.plateNumber,
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${v.modelName} • ${v.year}',
                                style: AppTypography.headline2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryOrange,
                  ),
                ),
                error: (err, stack) => Text(
                  'Terjadi kesalahan: $err',
                  style: AppTypography.body2.copyWith(color: Colors.red),
                ),
              ),
              const SizedBox(height: 32),

              // Bengkel Terdekat
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bengkel Terdekat', style: AppTypography.headline2),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Lihat Peta',
                      style: AppTypography.body1Medium.copyWith(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  final refNotifier = ref.read(
                    bookingScheduleProvider.notifier,
                  );
                  refNotifier.setWorkshop(defaultWorkshops[0]);
                  context.push('/vehicle-selection');
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BSD Autoparts',
                              style: AppTypography.headline2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jl. Letnan Sutopo, Tangerang Selatan',
                              style: AppTypography.body2,
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
                                  '1.2 km',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primaryOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '4.8',
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.bold,
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

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
