import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
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
                      itemCount:
                          vehicles.length + 1, // +1 for the add new button
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        if (index == vehicles.length) {
                          // Add New Vehicle Button
                          return GestureDetector(
                            onTap: () => _showAddVehicleModal(context, ref),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primaryOrange,
                                  width: 1,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add,
                                    color: AppColors.primaryOrange,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Tambah Motor Baru',
                                    style: AppTypography.headline2.copyWith(
                                      color: AppColors.primaryOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

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
                      style: AppTypography.body2.copyWith(color: Colors.red),
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

  void _showAddVehicleModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddVehicleModalSheet(ref: ref),
    );
  }
}

class _AddVehicleModalSheet extends StatefulWidget {
  final WidgetRef ref;

  const _AddVehicleModalSheet({required this.ref});

  @override
  State<_AddVehicleModalSheet> createState() => _AddVehicleModalSheetState();
}

class _AddVehicleModalSheetState extends State<_AddVehicleModalSheet> {
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  bool _isLoading = false;

  void _submit() async {
    final plate = _plateController.text.trim();
    final model = _modelController.text.trim();
    final year = int.tryParse(_yearController.text.trim()) ?? 0;

    if (plate.isEmpty || model.isEmpty || year == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data dengan benar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newVehicle = await widget.ref
          .read(garageProvider.notifier)
          .addVehicle(plate, model, year);
      if (newVehicle != null) {
        widget.ref
            .read(selectedVehiclesProvider.notifier)
            .selectVehicle(newVehicle);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan motor: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tambah Motor Baru', style: AppTypography.headline1),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Nomor Polisi', style: AppTypography.body1Medium),
          const SizedBox(height: 8),
          CustomTextField(
            placeholder: 'Misal: B 1234 ABC',
            controller: _plateController,
          ),
          const SizedBox(height: 16),
          Text('Merk & Model Motor', style: AppTypography.body1Medium),
          const SizedBox(height: 8),
          CustomTextField(
            placeholder: 'Misal: Honda Vario 160',
            controller: _modelController,
          ),
          const SizedBox(height: 16),
          Text('Tahun Pembuatan', style: AppTypography.body1Medium),
          const SizedBox(height: 8),
          CustomTextField(
            placeholder: 'Misal: 2023',
            keyboardType: TextInputType.number,
            controller: _yearController,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Simpan ke Garasi & Pilih',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
