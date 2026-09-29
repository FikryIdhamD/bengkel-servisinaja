import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../logic/tracking_stream_provider.dart';
import 'widgets/dev_simulation_bottom_sheet.dart';

class BookingTicketTrackingScreen extends ConsumerWidget {
  final String bookingId;

  const BookingTicketTrackingScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingStreamProvider(bookingId));
    final itemsAsync = ref.watch(bookingItemsStreamProvider(bookingId));

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
                  child: DevSimulationBottomSheet(bookingId: bookingId),
                ),
              );
            },
          ),
        ],
      ),
      body: bookingAsync.when(
        data: (booking) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(booking),
                  const SizedBox(height: 24),
                  Text('Status Kendaraan', style: AppTypography.headline2),
                  const SizedBox(height: 16),
                  itemsAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return const Center(child: Text('Tidak ada kendaraan'));
                      }
                      return Column(
                        children: items
                            .map((item) => _buildVehicleStatusCard(item))
                            .toList(),
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

  Widget _buildHeader(Map<String, dynamic> booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
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
                  if (status == 'Diproses')
                    statusColor = AppColors.primaryOrange;
                  if (status == 'Selesai')
                    statusColor = AppColors.statusSuccess;
                  if (status == 'Dibatalkan')
                    statusColor = AppColors.statusError;

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
        ],
      ),
    );
  }

  Widget _buildVehicleStatusCard(Map<String, dynamic> item) {
    final status = item['status'] ?? 'Menunggu Antrean';
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
                child: Text(
                  'Motor ID: ${item['vehicle_id']}',
                  style: AppTypography.headline2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['service_package_name'] ?? '',
                  textAlign: TextAlign.right,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primaryOrange,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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
