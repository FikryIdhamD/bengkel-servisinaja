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

  Future<void> simulateUpdateItemStatus(String itemId, String status) async {
    await _client
        .from('booking_items')
        .update({'status': status})
        .eq('id', itemId);
  }

  Future<void> simulateUpdateBookingStatus(String bookingId, String status) async {
    await _client
        .from('bookings')
        .update({'status': status})
        .eq('id', bookingId);
  }
}
