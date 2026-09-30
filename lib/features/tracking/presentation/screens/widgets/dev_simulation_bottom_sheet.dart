import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/typography.dart';
import '../../../../garage/data/vehicle_repository.dart';
import '../../../../garage/logic/garage_provider.dart';
import '../../../logic/dev_simulation_controller.dart';
import '../../../logic/tracking_stream_provider.dart';

class DevSimulationBottomSheet extends ConsumerWidget {
  final String bookingId;

  const DevSimulationBottomSheet({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsyncValue = ref.watch(bookingItemsStreamProvider(bookingId));
    final bookingAsyncValue = ref.watch(bookingStreamProvider(bookingId));
    final fallbackSimulatedStatus =
        ref.watch(fallbackItemStatusProvider)[bookingId];

    return Container(
      padding: const EdgeInsets.all(20),
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
              Text('Dev Simulation Mode', style: AppTypography.headline2),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Simulasi update real-time status Induk & Kendaraan dari bengkel.',
            style: AppTypography.body2,
          ),
          const SizedBox(height: 20),
          _SimulationBookingCard(bookingId: bookingId),
          const SizedBox(height: 20),
          Text('Status per Kendaraan', style: AppTypography.headline2),
          const SizedBox(height: 12),
          Expanded(
            child: itemsAsyncValue.when(
              data: (items) {
                final deletedCached = ref
                    .read(vehicleRepositoryProvider)
                    .getDeletedBookingItems(bookingId);
                final effectiveItems = <Map<String, dynamic>>[...items];
                for (final cached in deletedCached) {
                  final cachedId = cached['id']?.toString();
                  if (cachedId != null &&
                      !effectiveItems.any((m) => m['id']?.toString() == cachedId)) {
                    effectiveItems.add(cached);
                  }
                }

                if (effectiveItems.isEmpty) {
                  final bookingStatus =
                      bookingAsyncValue.value?['status']?.toString() ??
                          'Menunggu Kedatangan';
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
                  effectiveItems.add({
                    'id': 'deleted-$bookingId',
                    'booking_id': bookingId,
                    'vehicle_id': null,
                    'status': defaultStatus,
                  });
                }

                return ListView.builder(
                  itemCount: effectiveItems.length,
                  itemBuilder: (context, index) {
                    final item = effectiveItems[index];
                    return _SimulationItemCard(
                      bookingId: bookingId,
                      item: item,
                      index: index,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimulationItemCard extends ConsumerWidget {
  final String bookingId;
  final Map<String, dynamic> item;
  final int index;

  const _SimulationItemCard({
    required this.bookingId,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = item['status'] ?? 'PENDING';
    final itemId = item['id'].toString();
    final vehicleId = item['vehicle_id']?.toString();
    final vehicles = ref.watch(garageProvider).value ?? [];
    final activeVehicle =
        vehicles.where((v) => v.id == vehicleId).firstOrNull;

    final isDeleted = activeVehicle == null;
    final vehicleTitle = !isDeleted
        ? '${activeVehicle.modelName} (${activeVehicle.plateNumber})'
        : 'Kendaraan Dihapus (Plat Dihapus)';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surfaceGrey,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vehicleTitle,
              style: AppTypography.body1Medium.copyWith(
                color: isDeleted
                    ? AppColors.statusError
                    : AppColors.charcoalDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusButton(
                  title: 'Antre',
                  isActive: status == 'Menunggu Antrean',
                  onTap: () {
                    ref.read(devSimulationControllerProvider).updateItemStatus(
                          itemId,
                          'Menunggu Antrean',
                          bookingId: bookingId,
                        );
                  },
                ),
                _StatusButton(
                  title: 'Dikerjakan',
                  isActive: status == 'Sedang Dikerjakan',
                  onTap: () {
                    ref.read(devSimulationControllerProvider).updateItemStatus(
                          itemId,
                          'Sedang Dikerjakan',
                          bookingId: bookingId,
                        );
                  },
                ),
                _StatusButton(
                  title: 'Pengecekan',
                  isActive: status == 'Pengecekan Akhir',
                  onTap: () {
                    ref.read(devSimulationControllerProvider).updateItemStatus(
                          itemId,
                          'Pengecekan Akhir',
                          bookingId: bookingId,
                        );
                  },
                ),
                _StatusButton(
                  title: 'Selesai',
                  isActive: status == 'Selesai',
                  onTap: () {
                    ref.read(devSimulationControllerProvider).updateItemStatus(
                          itemId,
                          'Selesai',
                          bookingId: bookingId,
                        );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusButton({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryOrange : AppColors.background,
          border: Border.all(
            color: isActive ? AppColors.primaryOrange : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: AppTypography.caption.copyWith(
            color: isActive ? AppColors.background : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _SimulationBookingCard extends ConsumerWidget {
  final String bookingId;

  const _SimulationBookingCard({required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsyncValue = ref.watch(bookingStreamProvider(bookingId));

    return bookingAsyncValue.when(
      data: (booking) {
        final status = booking['status'] ?? 'Menunggu Kedatangan';
        return Card(
          margin: EdgeInsets.zero,
          color: AppColors.surfaceGrey,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Pesanan (Induk)',
                  style: AppTypography.body1Medium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusButton(
                      title: 'Menunggu',
                      isActive: status == 'Menunggu Kedatangan',
                      onTap: () {
                        ref
                            .read(devSimulationControllerProvider)
                            .updateBookingStatus(
                              bookingId,
                              'Menunggu Kedatangan',
                            );
                      },
                    ),
                    _StatusButton(
                      title: 'Diproses',
                      isActive: status == 'Diproses',
                      onTap: () {
                        ref
                            .read(devSimulationControllerProvider)
                            .updateBookingStatus(bookingId, 'Diproses');
                      },
                    ),
                    _StatusButton(
                      title: 'Selesai',
                      isActive: status == 'Selesai',
                      onTap: () {
                        ref
                            .read(devSimulationControllerProvider)
                            .updateBookingStatus(bookingId, 'Selesai');
                      },
                    ),
                    _StatusButton(
                      title: 'Batal',
                      isActive: status == 'Dibatalkan',
                      onTap: () {
                        ref
                            .read(devSimulationControllerProvider)
                            .updateBookingStatus(bookingId, 'Dibatalkan');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
