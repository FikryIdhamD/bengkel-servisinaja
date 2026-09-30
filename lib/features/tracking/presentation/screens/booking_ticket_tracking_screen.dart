import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../booking/logic/service_configuration_provider.dart';
import '../../../garage/data/models/vehicle_model.dart';
import '../../../garage/data/vehicle_repository.dart';
import '../../../garage/logic/garage_provider.dart';
import '../../data/tracking_repository.dart';
import '../../logic/dev_simulation_controller.dart';
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

  List<Map<String, dynamic>> _resolveEffectiveItems(
    Map<String, dynamic> booking,
    List<Map<String, dynamic>> dbItems,
    String? fallbackSimulatedStatus,
  ) {
    final deletedCached = ref
        .read(vehicleRepositoryProvider)
        .getDeletedBookingItems(widget.bookingId);
    final merged = <Map<String, dynamic>>[...dbItems];
    for (final cached in deletedCached) {
      final cachedId = cached['id']?.toString();
      if (cachedId != null &&
          !merged.any((m) => m['id']?.toString() == cachedId)) {
        merged.add(cached);
      }
    }

    if (merged.isNotEmpty) {
      return merged;
    }

    final bookingStatus =
        booking['status']?.toString() ?? 'Menunggu Kedatangan';
    String defaultStatus;
    if (fallbackSimulatedStatus != null) {
      defaultStatus = fallbackSimulatedStatus;
    } else if (bookingStatus == 'Selesai') {
      defaultStatus = 'Selesai';
    } else if (bookingStatus == 'Diproses') {
      defaultStatus = 'Sedang Dikerjakan';
    } else {
      defaultStatus = 'Menunggu Antrean';
    }

    return [
      <String, dynamic>{
        'id': 'deleted-${widget.bookingId}',
        'booking_id': widget.bookingId,
        'vehicle_id': null,
        'service_package_name': 'Layanan Servis',
        'spare_parts_names': const <dynamic>[],
        'complaints': null,
        'subtotal_price': booking['total_amount'],
        'status': defaultStatus,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingStreamProvider(widget.bookingId));
    final itemsAsync = ref.watch(bookingItemsStreamProvider(widget.bookingId));
    final garageVehicles = ref.watch(garageProvider).value ?? [];
    final fallbackSimulatedStatus =
        ref.watch(fallbackItemStatusProvider)[widget.bookingId];

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
          final isOrderCompleted = booking['status'] == 'Selesai';
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(
                    context,
                    booking,
                    itemsAsync,
                    garageVehicles,
                    fallbackSimulatedStatus,
                  ),
                  const SizedBox(height: 24),
                  Text('Status Kendaraan', style: AppTypography.headline2),
                  const SizedBox(height: 16),
                  itemsAsync.when(
                    data: (items) {
                      final effectiveItems = _resolveEffectiveItems(
                        booking,
                        items,
                        fallbackSimulatedStatus,
                      );
                      return Column(
                        children: effectiveItems.asMap().entries.map((e) {
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
                  if (isOrderCompleted) ...[
                    const SizedBox(height: 12),
                    _WorkshopRatingSection(
                      bookingId: widget.bookingId,
                      booking: booking,
                    ),
                  ],
                  const SizedBox(height: 24),
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
    String? fallbackSimulatedStatus,
  ) {
    final workshopName =
        booking['workshop_name']?.toString() ?? 'Bengkel Resmi PitStop';
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
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.storefront,
                size: 16,
                color: AppColors.primaryOrange,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  workshopName,
                  style: AppTypography.body1Medium.copyWith(
                    color: AppColors.charcoalDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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
                  data: (rawItems) {
                    final items = _resolveEffectiveItems(
                      booking,
                      rawItems,
                      fallbackSimulatedStatus,
                    );
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

                    if (grandTotalJasa == 0 &&
                        grandTotalParts == 0 &&
                        booking['total_amount'] != null) {
                      grandTotalJasa =
                          (booking['total_amount'] as num).toDouble();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final vehicleId = item['vehicle_id']?.toString();
                          final activeVehicle = garageVehicles
                              .where((v) => v.id == vehicleId)
                              .firstOrNull;

                          final pkgName =
                              item['service_package_name'] as String?;
                          final pkg = defaultServicePackages
                              .where((p) =>
                                  p.name.trim().toLowerCase() ==
                                  (pkgName ?? '').trim().toLowerCase())
                              .firstOrNull;
                          final servicePrice = pkg?.price ??
                              (item['subtotal_price'] as num?)?.toDouble();

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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      margin: const EdgeInsets.only(right: 6),
                                      decoration: BoxDecoration(
                                        color: activeVehicle != null
                                            ? AppColors.charcoalDark
                                            : AppColors.statusError,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        activeVehicle != null
                                            ? activeVehicle.plateNumber
                                            : 'Plat Dihapus',
                                        style: AppTypography.caption.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        activeVehicle != null
                                            ? 'Unit ${index + 1}: ${activeVehicle.modelName} (${activeVehicle.year})'
                                            : 'Unit ${index + 1}: Kendaraan Dihapus (-)',
                                        style:
                                            AppTypography.body1Medium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: activeVehicle != null
                                              ? AppColors.charcoalDark
                                              : AppColors.statusError,
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
    final vehicleId = item['vehicle_id']?.toString();
    final activeVehicle =
        garageVehicles.where((v) => v.id == vehicleId).firstOrNull;
    final isDeleted = activeVehicle == null;

    final plateText =
        !isDeleted ? activeVehicle.plateNumber : 'Plat Dihapus';
    final modelText =
        !isDeleted ? activeVehicle.modelName : 'Kendaraan Dihapus';
    final yearText =
        !isDeleted ? '${activeVehicle.year}' : '-';

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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDeleted
                            ? AppColors.statusError
                            : AppColors.charcoalDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        plateText,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      modelText,
                      style: AppTypography.headline2.copyWith(
                        color: isDeleted
                            ? AppColors.statusError
                            : AppColors.charcoalDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      yearText,
                      style: AppTypography.caption.copyWith(
                        color: isDeleted
                            ? AppColors.statusError
                            : AppColors.textSecondary,
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

class _WorkshopRatingSection extends ConsumerStatefulWidget {
  final String bookingId;
  final Map<String, dynamic> booking;

  const _WorkshopRatingSection({
    required this.bookingId,
    required this.booking,
  });

  @override
  ConsumerState<_WorkshopRatingSection> createState() =>
      _WorkshopRatingSectionState();
}

class _WorkshopRatingSectionState
    extends ConsumerState<_WorkshopRatingSection> {
  int _selectedRating = 0;
  bool _isSubmitting = false;
  bool _isEditing = false;
  late final TextEditingController _reviewController;

  static const List<String> _quickTags = [
    'Pelayanan Cepat',
    'Mekanik Ramah',
    'Hasil Servis Rapi',
    'Harga Transparan',
    'Ruang Tunggu Nyaman',
  ];

  @override
  void initState() {
    super.initState();
    final existingRating = (widget.booking['rating'] as num?)?.toInt() ?? 0;
    final existingReview = widget.booking['review_text']?.toString() ?? '';
    _selectedRating = existingRating;
    _reviewController = TextEditingController(text: existingReview);
  }

  @override
  void didUpdateWidget(covariant _WorkshopRatingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newRating = (widget.booking['rating'] as num?)?.toInt();
    if (!_isEditing && newRating != null && newRating != _selectedRating) {
      _selectedRating = newRating;
      _reviewController.text = widget.booking['review_text']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Sangat Kurang';
      case 2:
        return 'Kurang Memuaskan';
      case 3:
        return 'Cukup Baik';
      case 4:
        return 'Memuaskan';
      case 5:
        return 'Sangat Memuaskan!';
      default:
        return 'Ketuk bintang untuk memberi nilai';
    }
  }

  void _toggleQuickTag(String tag) {
    final current = _reviewController.text.trim();
    if (current.contains(tag)) return;
    setState(() {
      if (current.isEmpty) {
        _reviewController.text = tag;
      } else {
        _reviewController.text = '$current, $tag';
      }
      _reviewController.selection = TextSelection.fromPosition(
        TextPosition(offset: _reviewController.text.length),
      );
    });
  }

  Future<void> _submitRating() async {
    if (_selectedRating < 1 || _selectedRating > 5) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(trackingRepositoryProvider).submitBookingRating(
            bookingId: widget.bookingId,
            rating: _selectedRating,
            reviewText: _reviewController.text,
          );
      ref.invalidate(workshopRatingsProvider);
      if (mounted) {
        setState(() {
          _isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terima kasih! Penilaian bengkel berhasil disimpan.'),
            backgroundColor: AppColors.statusSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim penilaian: $e'),
            backgroundColor: AppColors.statusError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final workshopName =
        widget.booking['workshop_name']?.toString() ?? 'Bengkel Resmi PitStop';
    final savedRating = (widget.booking['rating'] as num?)?.toInt();
    final savedReview = widget.booking['review_text']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Penilaian Bengkel', style: AppTypography.headline2),
        const SizedBox(height: 12),
        if (savedRating != null && !_isEditing)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.statusSuccess.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.statusSuccess.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppColors.statusSuccess,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Penilaian Terkirim',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.statusSuccess,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedRating = savedRating;
                          _reviewController.text = savedReview;
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.primaryOrange,
                      ),
                      label: Text(
                        'Ubah',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workshopName,
                            style: AppTypography.headline2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                index < savedRating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: AppColors.primaryOrange,
                                size: 20,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$savedRating.0 / 5.0 • ${_ratingLabel(savedRating)}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.charcoalDark,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (savedReview.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '"$savedReview"',
                      style: AppTypography.body2.copyWith(
                        color: AppColors.charcoalDark,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryOrange.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.primaryOrange,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bagaimana Layanan di $workshopName?',
                  textAlign: TextAlign.center,
                  style: AppTypography.headline2.copyWith(
                    color: AppColors.charcoalDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Berikan rating untuk membantu peningkatan kualitas mekanik & cabang bengkel kami.',
                  textAlign: TextAlign.center,
                  style: AppTypography.body2,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    final isSelected = starValue <= _selectedRating;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = starValue;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Icon(
                          isSelected
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 40,
                          color: isSelected
                              ? AppColors.primaryOrange
                              : AppColors.border,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedRating > 0
                        ? AppColors.primarySurface
                        : AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _ratingLabel(_selectedRating),
                    style: AppTypography.caption.copyWith(
                      color: _selectedRating > 0
                          ? AppColors.primaryOrange
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickTags.map((tag) {
                      final isTagIncluded = _reviewController.text.contains(tag);
                      return InkWell(
                        onTap: () => _toggleQuickTag(tag),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isTagIncluded
                                ? AppColors.primarySurface
                                : AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isTagIncluded
                                  ? AppColors.primaryOrange
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            '+ $tag',
                            style: AppTypography.caption.copyWith(
                              color: isTagIncluded
                                  ? AppColors.primaryOrange
                                  : AppColors.textSecondary,
                              fontWeight: isTagIncluded
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reviewController,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  style: AppTypography.body1Regular,
                  decoration: InputDecoration(
                    hintText:
                        'Ceritakan pengalaman servis motor Anda di bengkel ini (opsional)...',
                    hintStyle: AppTypography.body2,
                    filled: true,
                    fillColor: AppColors.surfaceGrey,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primaryOrange,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (_isEditing) ...[
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _isEditing = false;
                                  });
                                },
                          child: Text(
                            'Batal',
                            style: AppTypography.buttonText.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        text: _isEditing
                            ? 'Simpan Perubahan'
                            : 'Kirim Penilaian',
                        isLoading: _isSubmitting,
                        onPressed:
                            _selectedRating > 0 ? _submitRating : null,
                        backgroundColor: _selectedRating > 0
                            ? AppColors.primaryOrange
                            : AppColors.disabled,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

