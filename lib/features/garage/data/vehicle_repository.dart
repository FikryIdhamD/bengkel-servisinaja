import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_config.dart';
import 'models/vehicle_model.dart';

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

class VehicleRepository {
  final supabase = SupabaseConfig.client;

  Future<List<Vehicle>> getVehicles(String userId) async {
    final response = await supabase
        .from('vehicles')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return (response as List<dynamic>)
        .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
        .toList();
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
}
