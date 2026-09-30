import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_config.dart';
import 'models/vehicle_model.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

class VehicleRepository {
  final supabase = SupabaseConfig.client;
  final Set<String> _checkedSeedUsers = {};
  final Map<String, Vehicle> _deletedVehiclesCache = {};
  final Map<String, List<Map<String, dynamic>>> _deletedBookingItemsCache = {};

  Vehicle? getDeletedVehicleSnapshot(String? vehicleId) {
    if (vehicleId == null) return null;
    return _deletedVehiclesCache[vehicleId];
  }

  List<Map<String, dynamic>> getDeletedBookingItems(String bookingId) {
    return _deletedBookingItemsCache[bookingId] ?? const [];
  }

  void updateDeletedBookingItemStatus(
    String bookingId,
    String itemId,
    String status,
  ) {
    final items = _deletedBookingItemsCache[bookingId];
    if (items == null) return;
    for (final item in items) {
      if (item['id']?.toString() == itemId) {
        item['status'] = status;
      }
    }
  }

  Future<List<Vehicle>> getVehicles(
    String userId, {
    bool allowAutoSeed = true,
  }) async {
    final response = await supabase
        .from('vehicles')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    final vehicles = (response as List<dynamic>)
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();

    if (vehicles.isEmpty &&
        allowAutoSeed &&
        !_checkedSeedUsers.contains(userId)) {
      _checkedSeedUsers.add(userId);
      return await seedDefaultVehiclesIfEmpty(userId);
    }

    _checkedSeedUsers.add(userId);
    return vehicles;
  }

  Future<List<Vehicle>> seedDefaultVehiclesIfEmpty(String userId) async {
    try {
      final existing = await supabase
          .from('vehicles')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      if (existing.isNotEmpty) {
        return existing.map((e) => Vehicle.fromJson(e)).toList();
      }

      final inserted = await supabase
          .from('vehicles')
          .insert([
            {
              'user_id': userId,
              'plate_number': 'B 1234 PSA',
              'model_name': 'Honda Vario 160',
              'year': 2023,
            },
            {
              'user_id': userId,
              'plate_number': 'B 5678 PSA',
              'model_name': 'Honda BeAT FI',
              'year': 2022,
            },
          ])
          .select();

      return (inserted as List<dynamic>)
          .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Vehicle> addVehicle(
    String userId,
    String plateNumber,
    String modelName,
    int year,
  ) async {
    final response = await supabase
        .from('vehicles')
        .insert({
          'user_id': userId,
          'plate_number': plateNumber,
          'model_name': modelName,
          'year': year,
        })
        .select()
        .single();

    return Vehicle.fromJson(response);
  }

  Future<Vehicle> updateVehicle(
    String vehicleId,
    String plateNumber,
    String modelName,
    int year,
  ) async {
    final response = await supabase
        .from('vehicles')
        .update({
          'plate_number': plateNumber,
          'model_name': modelName,
          'year': year,
        })
        .eq('id', vehicleId)
        .select()
        .single();

    return Vehicle.fromJson(response);
  }

  Future<void> deleteVehicle(Vehicle vehicle) async {
    _deletedVehiclesCache[vehicle.id] = vehicle;
    try {
      final relatedItems = await supabase
          .from('booking_items')
          .select()
          .eq('vehicle_id', vehicle.id);
      for (final raw in relatedItems) {
        final copy = Map<String, dynamic>.from(raw);
        final bId = copy['booking_id']?.toString();
        if (bId != null) {
          final list = _deletedBookingItemsCache.putIfAbsent(bId, () => []);
          final existingIdx =
              list.indexWhere((e) => e['id']?.toString() == copy['id']?.toString());
          if (existingIdx >= 0) {
            list[existingIdx] = copy;
          } else {
            list.add(copy);
          }
        }
      }
    } catch (_) {}
    await supabase.from('vehicles').delete().eq('id', vehicle.id);
  }

  Future<Vehicle?> getVehicleById(String vehicleId) async {
    if (_deletedVehiclesCache.containsKey(vehicleId)) {
      return _deletedVehiclesCache[vehicleId];
    }
    try {
      final response = await supabase
          .from('vehicles')
          .select()
          .eq('id', vehicleId)
          .maybeSingle();

      if (response == null) return null;
      return Vehicle.fromJson(response);
    } catch (_) {
      return null;
    }
  }
}
