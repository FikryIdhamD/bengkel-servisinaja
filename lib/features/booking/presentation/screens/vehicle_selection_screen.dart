import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/primary_button.dart';

import '../../../../core/widgets/vehicle_card.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../garage/logic/garage_provider.dart';
import '../../logic/multi_vehicle_selection_provider.dart';
import '../../logic/service_configuration_provider.dart';
import '../../logic/booking_schedule_provider.dart';

class VehicleSelectionScreen extends ConsumerWidget {
  const VehicleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garageState = ref.watch(garageProvider);
    final selectedVehicles = ref.watch(selectedVehiclesProvider);

    Future<void> onBack() async {
      final shouldCancel = await showDialog<bool>(
        context: context,
        builder: (ctx) => ConfirmationDialog(
          title: 'Batalkan Booking?',
          content:
              'Apakah Anda yakin ingin kembali? Semua data booking yang sudah dipilih akan dihapus.',
          cancelText: 'Tidak',
          confirmText: 'Ya, Batalkan',
          onCancel: () => Navigator.pop(ctx, false),
          onConfirm: () {
            ref.read(selectedVehiclesProvider.notifier).clear();
            ref.read(serviceConfigurationProvider.notifier).clear();
            ref.read(bookingScheduleProvider.notifier).reset();
            Navigator.pop(ctx, true);
          },
        ),
      );

      if (shouldCancel == true) {
        if (context.mounted) context.pop();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoalDark),
            onPressed: onBack,
          ),
          title: Text(
            'Pilih Kendaraan Servis',
            style: AppTypography.headline1.copyWith(
              color: AppColors.charcoalDark,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Text(
                  'Centang motor yang ingin diservis dalam sesi pemesanan ini',
                  style: AppTypography.body1Medium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: garageState.when(
                  data: (vehicles) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(20.0),
                      itemCount: vehicles.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final v = vehicles[index];
                        final isSelected = selectedVehicles.any(
                          (selected) => selected.id == v.id,
                        );

                        return VehicleSelectableCard(
                          plateNumber: v.plateNumber,
                          modelName: v.modelName,
                          year: v.year.toString(),
                          isSelected: isSelected,
                          onTap: () {
                            ref
                                .read(selectedVehiclesProvider.notifier)
                                .toggleVehicle(v);
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  error: (err, stack) => Center(
                    child: Text(
                      'Terjadi kesalahan: $err',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.statusError,
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom Bar
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
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${selectedVehicles.length} Kendaraan Terpilih',
                          style: AppTypography.headline2,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: PrimaryButton(
                          text: 'Lanjut ke Layanan',
                          onPressed: selectedVehicles.isEmpty
                              ? null
                              : () {
                                  context.push('/service-configuration');
                                },
                          backgroundColor: selectedVehicles.isEmpty
                              ? AppColors.disabled
                              : AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
