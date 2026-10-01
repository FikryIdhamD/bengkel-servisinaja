import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/app_notification.dart';
import '../../../booking/logic/multi_vehicle_selection_provider.dart';
import '../../data/models/vehicle_model.dart';
import '../../logic/garage_provider.dart';
import 'widgets/add_vehicle_modal_sheet.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  Future<void> _confirmDeleteVehicle(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Hapus Kendaraan?',
        content:
            'Apakah Anda yakin ingin menghapus ${vehicle.modelName} (${vehicle.plateNumber}) dari garasi? Riwayat tiket servis lama akan tetap tersimpan.',
        cancelText: 'Batal',
        confirmText: 'Ya, Hapus',
        confirmColor: AppColors.statusError,
        onCancel: () => Navigator.pop(ctx, false),
        onConfirm: () => Navigator.pop(ctx, true),
      ),
    );

    if (confirmed == true) {
      try {
        final selected = ref.read(selectedVehiclesProvider);
        if (selected.any((s) => s.id == vehicle.id)) {
          ref.read(selectedVehiclesProvider.notifier).toggleVehicle(vehicle);
        }
        await ref.read(garageProvider.notifier).deleteVehicle(vehicle);
        if (context.mounted) {
          AppNotification.showSuccess(
            context,
            '${vehicle.modelName} berhasil dihapus dari garasi',
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppNotification.showError(
            context,
            'Gagal menghapus kendaraan: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garageState = ref.watch(garageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        title: Text('Garasi Saya', style: AppTypography.headline1),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddVehicleModalSheet(ref: ref),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Tambah Kendaraan',
                    style: AppTypography.buttonText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: garageState.when(
                data: (vehicles) {
                  if (vehicles.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.garage_outlined,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada kendaraan di garasi.',
                              style: AppTypography.body1Regular,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: vehicles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final v = vehicles[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/vehicle/${v.id}');
                        },
                        child: Container(
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
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySurface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.two_wheeler,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                              const SizedBox(width: 16),
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
                                        v.plateNumber,
                                        style: AppTypography.caption.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${v.modelName} (${v.year})',
                                      style: AppTypography.headline2,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Row(
                              //   mainAxisSize: MainAxisSize.min,
                              //   children: [
                              //     IconButton(
                              //       tooltip: 'Edit Kendaraan',
                              //       icon: const Icon(
                              //         Icons.edit_outlined,
                              //         color: AppColors.primaryOrange,
                              //         size: 20,
                              //       ),
                              //       onPressed: () {
                              //         showDialog(
                              //           context: context,
                              //           builder: (context) =>
                              //               AddVehicleModalSheet(
                              //             ref: ref,
                              //             vehicleToEdit: v,
                              //           ),
                              //         );
                              //       },
                              //     ),
                              //     IconButton(
                              //       tooltip: 'Hapus Kendaraan',
                              //       icon: const Icon(
                              //         Icons.delete_outline,
                              //         color: AppColors.statusError,
                              //         size: 20,
                              //       ),
                              //       onPressed: () =>
                              //           _confirmDeleteVehicle(context, ref, v),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                        ),
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
                    style: AppTypography.body1Regular.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
