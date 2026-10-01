import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_notification.dart';
import '../../../auth/logic/auth_controller.dart';
import '../../data/booking_repository.dart';
import '../../logic/multi_vehicle_selection_provider.dart';
import '../../logic/booking_schedule_provider.dart';
import '../../logic/booking_summary_computed_provider.dart';
import '../../logic/service_configuration_provider.dart';

class SummaryCheckoutScreen extends ConsumerStatefulWidget {
  const SummaryCheckoutScreen({super.key});

  @override
  ConsumerState<SummaryCheckoutScreen> createState() =>
      _SummaryCheckoutScreenState();
}

class _SummaryCheckoutScreenState extends ConsumerState<SummaryCheckoutScreen> {
  bool _isLoading = false;

  Future<void> _confirmBooking() async {
    final schedule = ref.read(bookingScheduleProvider);
    final vehicles = ref.read(selectedVehiclesProvider);
    final configs = ref.read(serviceConfigurationProvider);
    final summary = ref.read(bookingSummaryComputedProvider);
    final user = ref.read(currentSessionProvider)?.user;

    if (user == null || !schedule.isValid) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(bookingRepositoryProvider);

      final List<Map<String, dynamic>> items = [];
      for (var v in vehicles) {
        final config = configs[v.id];
        if (config != null) {
          double subtotal = (config.selectedPackage?.price ?? 0);
          final partsNames = <String>[];
          for (var p in config.selectedParts) {
            subtotal += p.price;
            partsNames.add(p.name);
          }

          items.add({
            'vehicle_id': v.id,
            'service_package_name': config.selectedPackage?.name ?? '',
            'spare_parts_names': partsNames,
            'complaints': config.complaints,
            'subtotal_price': subtotal,
          });
        }
      }

      final bookingId = await repo.createBooking(
        userId: user.id,
        workshopName: schedule.selectedWorkshop!.name,
        bookingDate: schedule.selectedDate!,
        timeSlot: schedule.selectedTimeSlot!,
        totalPrice: summary.grandTotal,
        totalDuration: summary.totalDurationMinutes,
        items: items,
      );

      // Clear states
      ref.read(selectedVehiclesProvider.notifier).clear();
      ref.read(serviceConfigurationProvider.notifier).clear();
      ref.read(bookingScheduleProvider.notifier).reset();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.background,
            title: const Icon(
              Icons.check_circle,
              color: AppColors.statusSuccess,
              size: 64,
            ),
            content: Text(
              'Booking Servis Berhasil!\nSilakan datang ke bengkel pada waktu yang ditentukan.',
              textAlign: TextAlign.center,
              style: AppTypography.body1Medium,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/tickets');
                    context.push('/tracking/$bookingId');
                  },
                  child: Text(
                    'Lihat Tiket',
                    style: AppTypography.buttonText.copyWith(
                      color: AppColors.background,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppNotification.showError(
          context,
          'Gagal membuat pesanan: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = ref.watch(bookingScheduleProvider);
    final vehicles = ref.watch(selectedVehiclesProvider);
    final configs = ref.watch(serviceConfigurationProvider);
    final summary = ref.watch(bookingSummaryComputedProvider);

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
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
          'Ringkasan Pesanan',
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
                  // Lokasi & Jadwal
                  Text(
                    'Lokasi & Jadwal Servis',
                    style: AppTypography.headline2,
                  ),
                  const SizedBox(height: 12),
                    Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.storefront,
                              color: AppColors.primaryOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                schedule.selectedWorkshop?.name ?? '',
                                style: AppTypography.body1Medium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: AppColors.primaryOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                schedule.selectedDate != null
                                    ? DateFormat(
                                        'EEEE, dd MMM yyyy',
                                      ).format(schedule.selectedDate!)
                                    : '',
                                style: AppTypography.body2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: AppColors.primaryOrange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${schedule.selectedTimeSlot} WIB',
                                style: AppTypography.body2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('Rincian Kendaraan', style: AppTypography.headline2),
                  const SizedBox(height: 12),
                  ...vehicles.asMap().entries.map((e) {
                    final unitNum = e.key + 1;
                    final vehicle = e.value;
                    final config = configs[vehicle.id];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Unit $unitNum - ${vehicle.plateNumber}',
                                  style: AppTypography.body1Medium.copyWith(
                                    color: AppColors.primaryOrange,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${vehicle.modelName} (${vehicle.year})',
                                style: AppTypography.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          if (config?.selectedPackage != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    config!.selectedPackage!.name,
                                    style: AppTypography.body2,
                                  ),
                                ),
                                Text(
                                  currencyFormat.format(
                                    config.selectedPackage!.price,
                                  ),
                                  style: AppTypography.body2,
                                ),
                              ],
                            ),
                          if (config != null &&
                              config.selectedParts.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Suku Cadang:', style: AppTypography.caption),
                            ...config.selectedParts.map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p.name,
                                        style: AppTypography.body2,
                                      ),
                                    ),
                                    Text(
                                      currencyFormat.format(p.price),
                                      style: AppTypography.body2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  Text('Metode Pembayaran', style: AppTypography.headline2),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      // Opsi 1: Bayar di Bengkel (Selected)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryOrange),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.payments,
                              color: AppColors.primaryOrange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bayar di Bengkel',
                                    style: AppTypography.body1Medium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pembayaran dilakukan setelah servis selesai',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryOrange,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Opsi 2: Transfer Bank (Unselected)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Transfer Bank (Virtual Account)',
                                    style: AppTypography.body1Medium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.circle_outlined,
                              color: AppColors.border,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Opsi 3: E-Wallet (Unselected)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGrey,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'E-Wallet (GoPay, OVO, Dana)',
                                    style: AppTypography.body1Medium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.circle_outlined,
                              color: AppColors.border,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),

                  // Total Harga
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('Subtotal Jasa', style: AppTypography.body2),
                      ),
                      Text(
                        currencyFormat.format(summary.totalServicePrice),
                        style: AppTypography.body1Medium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Subtotal Suku Cadang',
                          style: AppTypography.body2,
                        ),
                      ),
                      Text(
                        currencyFormat.format(summary.totalPartsPrice),
                        style: AppTypography.body1Medium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Grand Total',
                          style: AppTypography.headline2,
                        ),
                      ),
                      Text(
                        currencyFormat.format(summary.grandTotal),
                        style: AppTypography.headline1.copyWith(
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                ],
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
              child: PrimaryButton(
                text: 'Konfirmasi & Pesan',
                isLoading: _isLoading,
                onPressed: _confirmBooking,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
