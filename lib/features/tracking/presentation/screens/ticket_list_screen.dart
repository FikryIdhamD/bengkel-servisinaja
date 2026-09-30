import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../auth/logic/auth_controller.dart';
import '../../logic/tracking_stream_provider.dart';

class TicketListScreen extends ConsumerWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentSessionProvider);
    final userId = session?.user.id;

    if (userId == null) {
      return const Center(child: Text('Anda belum login.'));
    }

    final bookingsAsyncValue = ref.watch(userBookingsStreamProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Tiket Pemesanan',
          style: AppTypography.headline1.copyWith(
            color: AppColors.charcoalDark,
          ),
        ),
      ),
      body: bookingsAsyncValue.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Text(
                'Belum ada tiket pemesanan.',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final bookingDateStr = booking['booking_date'] as String;
              final bookingDate =
                  DateTime.tryParse(bookingDateStr) ?? DateTime.now();
              final dateFormatted = DateFormat(
                'dd MMM yyyy',
              ).format(bookingDate);
              final timeSlot = booking['booking_time'];
              final status = booking['status'] ?? 'Menunggu Kedatangan';

              return GestureDetector(
                onTap: () {
                  context.push('/tracking/${booking['id']}');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 40,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['booking_code'] ?? 'PSA-UNKNOWN',
                              style: AppTypography.body1Medium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$dateFormatted • $timeSlot',
                              style: AppTypography.caption,
                            ),
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
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

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status,
                                        style: AppTypography.caption.copyWith(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) =>
              const ShimmerLoading(width: double.infinity, height: 100),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
