import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tracking_repository.dart';

final bookingStreamProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, bookingId) {
      final repo = ref.watch(trackingRepositoryProvider);
      return repo.watchBooking(bookingId).map((list) => list.first);
    });

final bookingItemsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, bookingId) {
      final repo = ref.watch(trackingRepositoryProvider);
      return repo.watchBookingItems(bookingId);
    });

final userBookingsStreamProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
      final repo = ref.watch(trackingRepositoryProvider);
      return repo.watchUserBookings(userId);
    });

final bookingFutureProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, bookingId) async {
      final repo = ref.watch(trackingRepositoryProvider);
      return await repo.getBooking(bookingId);
    });
