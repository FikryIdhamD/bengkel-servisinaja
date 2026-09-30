import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final trackingRepositoryProvider = Provider((ref) {
  return TrackingRepository(Supabase.instance.client);
});

class TrackingRepository {
  final SupabaseClient _client;

  TrackingRepository(this._client);

  Stream<List<Map<String, dynamic>>> watchBookingItems(String bookingId) {
    return _client
        .from('booking_items')
        .stream(primaryKey: ['id'])
        .eq('booking_id', bookingId);
  }

  Stream<List<Map<String, dynamic>>> watchUserBookings(String userId) {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> watchBooking(String bookingId) {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('id', bookingId);
  }

  Future<Map<String, dynamic>> getBooking(String bookingId) async {
    return _client.from('bookings').select().eq('id', bookingId).single();
  }

  Future<void> simulateUpdateItemStatus(
    String itemId,
    String status, {
    String? fallbackBookingId,
  }) async {
    Map<String, dynamic>? updated;
    if (!itemId.startsWith('deleted-')) {
      try {
        updated = await _client
            .from('booking_items')
            .update({'status': status})
            .eq('id', itemId)
            .select('booking_id')
            .maybeSingle();
      } catch (_) {}
    }

    final bookingId =
        updated?['booking_id']?.toString() ?? fallbackBookingId;
    if (bookingId != null) {
      final allItems = await _client
          .from('booking_items')
          .select('status')
          .eq('booking_id', bookingId);

      if (allItems.isNotEmpty) {
        final allFinished = allItems.every((i) => i['status'] == 'Selesai');
        final anyInProgress = allItems.any(
          (i) =>
              i['status'] == 'Sedang Dikerjakan' ||
              i['status'] == 'Pengecekan Akhir' ||
              i['status'] == 'Selesai',
        );

        if (allFinished) {
          await simulateUpdateBookingStatus(bookingId, 'Selesai');
        } else if (anyInProgress) {
          await simulateUpdateBookingStatus(bookingId, 'Diproses');
        } else {
          await simulateUpdateBookingStatus(bookingId, 'Menunggu Kedatangan');
        }
      } else {
        if (status == 'Selesai') {
          await simulateUpdateBookingStatus(bookingId, 'Selesai');
        } else if (status == 'Sedang Dikerjakan' ||
            status == 'Pengecekan Akhir') {
          await simulateUpdateBookingStatus(bookingId, 'Diproses');
        } else {
          await simulateUpdateBookingStatus(bookingId, 'Menunggu Kedatangan');
        }
      }
    }
  }

  Future<void> simulateUpdateBookingStatus(
    String bookingId,
    String status,
  ) async {
    await _client
        .from('bookings')
        .update({'status': status})
        .eq('id', bookingId);
  }

  Future<void> submitBookingRating({
    required String bookingId,
    required int rating,
    String? reviewText,
  }) async {
    await _client
        .from('bookings')
        .update({
          'rating': rating,
          'review_text':
              (reviewText != null && reviewText.trim().isNotEmpty)
                  ? reviewText.trim()
                  : null,
          'rated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', bookingId);
  }

  Future<Map<String, Map<String, dynamic>>> getWorkshopRatingsMap() async {
    final Map<String, Map<String, dynamic>> result = {};
    try {
      final workshopsData = await _client.from('workshops').select();
      for (final row in workshopsData) {
        final name = row['name']?.toString();
        if (name != null &&
            row['rating_avg'] != null &&
            row['rating_count'] != null) {
          result[name] = {
            'rating': (row['rating_avg'] as num).toDouble(),
            'count': (row['rating_count'] as num).toInt(),
          };
        }
      }
    } catch (_) {
      // Fallback if rating_avg / rating_count columns are not yet added to workshops
    }

    try {
      final ratedBookings = await _client
          .from('bookings')
          .select('workshop_name, rating')
          .not('rating', 'is', null);

      final Map<String, List<int>> grouped = {};
      for (final row in ratedBookings) {
        final wName = row['workshop_name']?.toString();
        final r = (row['rating'] as num?)?.toInt();
        if (wName != null && r != null) {
          grouped.putIfAbsent(wName, () => []).add(r);
        }
      }

      grouped.forEach((wName, ratings) {
        if (!result.containsKey(wName)) {
          const baseRating = 4.8;
          const baseCount = 120;
          final sumNew = ratings.fold<int>(0, (a, b) => a + b);
          final totalCount = baseCount + ratings.length;
          final avg = ((baseRating * baseCount) + sumNew) / totalCount;
          result[wName] = {
            'rating': double.parse(avg.toStringAsFixed(1)),
            'count': totalCount,
          };
        }
      });
    } catch (_) {}

    return result;
  }
}
