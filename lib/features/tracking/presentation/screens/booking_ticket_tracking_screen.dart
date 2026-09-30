import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../booking/logic/service_configuration_provider.dart';
import '../../../garage/data/models/vehicle_model.dart';
import '../../../garage/logic/garage_provider.dart';
import '../../logic/tracking_stream_provider.dart';
import 'widgets/dev_simulation_bottom_sheet.dart';

class BookingTicketTrackingScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingTicketTrackingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingTicketTrackingScreen> createState() =>
      _BookingTicketTrackingScreenState();
}

class _BookingTicketTrackingScreenState
    extends ConsumerState<BookingTicketTrackingScreen> {
  bool _isBillExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingStreamProvider(widget.bookingId));
    final itemsAsync = ref.watch(bookingItemsStreamProvider(widget.bookingId));
    final garageVehicles = ref.watch(garageProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalDark),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Tiket & Lacak Servis',
          style: AppTypography.headline1.copyWith(
            color: AppColors.charcoalDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report, color: AppColors.primaryOrange),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.8,
                  child: DevSimulationBottomSheet(bookingId: widget.bookingId),
                ),
              );
            },
          ),
        ],
      ),
      body: bookingAsync.when(
        data: (booking) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, booking, itemsAsync, garageVehicles),
                  const SizedBox(height: 24),
                  Text('Status Kendaraan', style: AppTypography.headline2),
                  const SizedBox(height: 16),
                  itemsAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const Center(child: Text('Tidak ada kendaraan'));
                      }
                      return Column(
                        children: items.asMap().entries.map((e) {
                          return _buildVehicleStatusCard(
                            e.value,
                            e.key,
                            garageVehicles,
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Map<String, dynamic> booking,
    AsyncValue<List<Map<String, dynamic>>> itemsAsync,
    List<Vehicle> garageVehicles,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_2, size: 100, color: AppColors.charcoalDark),
          const SizedBox(height: 16),
          Text(
            booking['booking_code'] ?? 'PSA-UNKNOWN',
            style: AppTypography.headline1.copyWith(
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 8),
          Text('Tunjukkan QR ini ke kasir bengkel', style: AppTypography.body2),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Status Pesanan', style: AppTypography.body1Medium),
              Builder(
                builder: (context) {
                  final status = booking['status'] ?? 'Menunggu Kedatangan';
                  Color statusColor = AppColors.textSecondary;
                  if (status == 'Diproses') {
                    statusColor = AppColors.primaryOrange;
                  }
                  if (status == 'Selesai') {
                    statusColor = AppColors.statusSuccess;
                  }
                  if (status == 'Dibatalkan') {
                    statusColor = AppColors.statusError;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: AppTypography.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: _isBillExpanded,
              onExpansionChanged: (expanded) {
                setState(() {
                  _isBillExpanded = expanded;
                });
              },
              tilePadding: EdgeInsets.zero,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Tagihan', style: AppTypography.body1Medium),
                  Row(
                    children: [
                      Text(
                        _isBillExpanded ? 'Tutup rincian' : 'Lihat rincian tagihan',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isBillExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.primaryOrange,
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    booking['total_amount'] != null
                        ? NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(booking['total_amount'])
                        : 'Menunggu Estimasi',
                    style: AppTypography.headline2.copyWith(
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isBillExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.primaryOrange,
                      size: 18,
                    ),
                  ),
                ],
              ),
              children: [
                const Divider(height: 24),
                itemsAsync.when(
                  data: (items) {
                    if (items.isEmpty) return const SizedBox();
                    final currencyFormat = NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    );

                    double grandTotalJasa = 0;
                    double grandTotalParts = 0;

                    for (var item in items) {
                      final pkgName = item['service_package_name'] as String?;
                      final pkg = defaultServicePackages
                          .where((p) =>
                              p.name.trim().toLowerCase() ==
                              (pkgName ?? '').trim().toLowerCase())
                          .firstOrNull;
                      final sPrice = pkg?.price ?? 0;
                      grandTotalJasa += sPrice;

                      final List<dynamic> parts =
                          item['spare_parts_names'] ?? [];
                      for (var pName in parts) {
                        final part = defaultSpareParts
                            .where((sp) =>
                                sp.name.trim().toLowerCase() ==
                                pName.toString().trim().toLowerCase())
                            .firstOrNull;
                        grandTotalParts += part?.price ?? 0;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final vehicleId = item['vehicle_id'];
                          final vehicle = garageVehicles
                              .where((v) => v.id == vehicleId)
                              .firstOrNull;

                          final pkgName =
                              item['service_package_name'] as String?;
                          final pkg = defaultServicePackages
                              .where((p) =>
                                  p.name.trim().toLowerCase() ==
                                  (pkgName ?? '').trim().toLowerCase())
                              .firstOrNull;
                          final servicePrice = pkg?.price;

                          final List<dynamic> parts =
                              item['spare_parts_names'] ?? [];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceGrey,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Vehicle header
                                Row(
                                  children: [
                                    if (vehicle != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        margin: const EdgeInsets.only(right: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.charcoalDark,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          vehicle.plateNumber,
                                          style: AppTypography.caption.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        vehicle != null
                                            ? 'Unit ${index + 1}: ${vehicle.modelName} (${vehicle.year})'
                                            : 'Unit ${index + 1}: Motor #${index + 1}',
                                        style:
                                            AppTypography.body1Medium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),
                                // Jasa Servis
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.build_circle_outlined,
                                              size: 16,
                                              color: AppColors.primaryOrange,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                pkgName ?? 'Paket Servis',
                                                style: AppTypography.body2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Text(
                                          servicePrice != null
                                              ? currencyFormat.format(servicePrice)
                                              : '-',
                                          style: AppTypography.body2.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Suku Cadang
                                const SizedBox(height: 10),
                                Text(
                                  'Suku Cadang & Pelumas:',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (parts.isNotEmpty)
                                  ...parts.asMap().entries.map((pEntry) {
                                    final pIndex = pEntry.key;
                                    final pName = pEntry.value;
                                    final part = defaultSpareParts
                                        .where((sp) =>
                                            sp.name.trim().toLowerCase() ==
                                            pName.toString().trim().toLowerCase())
                                        .firstOrNull;
                                    final partPrice = part?.price;
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            top: 4.0,
                                            bottom: 4.0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '• $pName',
                                                  style: AppTypography.caption,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: AppColors.border),
                                                ),
                                                child: Text(
                                                  partPrice != null
                                                      ? currencyFormat
                                                          .format(partPrice)
                                                      : '-',
                                                  style:
                                                      AppTypography.caption.copyWith(
                                                    color: AppColors.charcoalDark,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (pIndex < parts.length - 1)
                                          Divider(
                                            height: 6,
                                            thickness: 0.5,
                                            color: AppColors.border.withValues(alpha: 0.5),
                                          ),
                                      ],
                                    );
                                  })
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 4.0,
                                    ),
                                    child: Text(
                                      '• Tanpa suku cadang tambahan',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                const Divider(height: 16),
                                // Subtotal Unit
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Subtotal Unit ${index + 1}',
                                        style: AppTypography.caption.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primarySurface,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.primaryOrange
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        item['subtotal_price'] != null
                                            ? currencyFormat
                                                .format(item['subtotal_price'])
                                            : '-',
                                        style: AppTypography.body2.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryOrange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                        // Akumulasi Subtotal
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryOrange
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Subtotal Jasa Keseluruhan',
                                      style: AppTypography.caption,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    currencyFormat.format(grandTotalJasa),
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 12,
                                thickness: 0.5,
                                color: AppColors.border,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Subtotal Suku Cadang Keseluruhan',
                                      style: AppTypography.caption,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    currencyFormat.format(grandTotalParts),
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                  error: (e, s) => Text('Gagal memuat rincian: $e'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleStatusCard(
    Map<String, dynamic> item,
    int index,
    List<Vehicle> garageVehicles,
  ) {
    final status = item['status'] ?? 'Menunggu Antrean';
    final vehicleId = item['vehicle_id'];
    final vehicle = garageVehicles.where((v) => v.id == vehicleId).firstOrNull;

    int currentStep = 0;
    switch (status) {
      case 'Menunggu Antrean':
        currentStep = 0;
        break;
      case 'Sedang Dikerjakan':
        currentStep = 1;
        break;
      case 'Pengecekan Akhir':
        currentStep = 2;
        break;
      case 'Selesai':
        currentStep = 3;
        break;
    }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (vehicle != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
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
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            vehicle != null
                                ? vehicle.modelName
                                : 'Unit ${index + 1}',
                            style: AppTypography.headline2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle != null
                          ? 'Tahun Pembuatan: ${vehicle.year}'
                          : 'ID Kendaraan: ${item['vehicle_id']}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['service_package_name'] ?? 'Layanan',
                  textAlign: TextAlign.right,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (item['complaints'] != null &&
              (item['complaints'] as String).trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Keluhan: "${item['complaints']}"',
                style: AppTypography.caption.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _StepperIndicator(currentStep: currentStep),
        ],
      ),
    );
  }
}

class _StepperIndicator extends StatelessWidget {
  final int currentStep;

  const _StepperIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final steps = ['Antre', 'Dikerjakan', 'Cek Akhir', 'Selesai'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final isCompleted = index <= currentStep;
        final isActive = index == currentStep;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == 0
                          ? Colors.transparent
                          : isCompleted
                              ? AppColors.statusSuccess
                              : AppColors.border,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.statusSuccess
                          : AppColors.surfaceGrey,
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.statusSuccess
                            : AppColors.border,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index == steps.length - 1
                          ? Colors.transparent
                          : (index < currentStep)
                              ? AppColors.statusSuccess
                              : AppColors.border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                steps[index],
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: isActive
                      ? AppColors.charcoalDark
                      : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
