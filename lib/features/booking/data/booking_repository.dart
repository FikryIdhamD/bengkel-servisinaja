import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final bookingRepositoryProvider = Provider((ref) {
  return BookingRepository(Supabase.instance.client);
});

class BookingRepository {
  final SupabaseClient _client;

  BookingRepository(this._client);

  Future<String> createBooking({
    required String userId,
    required String workshopName,
    required DateTime bookingDate,
    required String timeSlot,
    required double totalPrice,
    required int totalDuration,
    required List<Map<String, dynamic>> items,
  }) async {
    // We do sequential inserts since Supabase dart client doesn't support complex RPC inserts
    // out of the box unless we created a specific Postgres function.
    // Insert into bookings
    final bookingCode =
        'PSA-${bookingDate.year}${bookingDate.month.toString().padLeft(2, '0')}${bookingDate.day.toString().padLeft(2, '0')}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final bookingResponse = await _client
        .from('bookings')
        .insert({
          'user_id': userId,
          'booking_code': bookingCode,
          'workshop_name': workshopName,
          'booking_date': bookingDate.toIso8601String().split('T')[0],
          'booking_time': timeSlot, // CHANGED from time_slot
          'total_amount': totalPrice, // CHANGED from total_price
          'total_duration_minutes': totalDuration,
          'status': 'Menunggu Kedatangan',
        })
        .select()
        .single();

    final bookingId = bookingResponse['id'];

    // Insert items
    for (var item in items) {
      await _client.from('booking_items').insert({
        'booking_id': bookingId,
        'vehicle_id': item['vehicle_id'],
        'service_package_name': item['service_package_name'],
        'spare_parts_names': item['spare_parts_names'],
        'complaints': item['complaints'],
        'subtotal_price': item['subtotal_price'],
        'status': 'Menunggu Antrean',
      });
    }
    return bookingId;
  }
}
