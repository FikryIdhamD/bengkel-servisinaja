import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/vehicle_model.dart';
import '../data/vehicle_repository.dart';
import '../../auth/logic/auth_controller.dart';

final garageProvider = AsyncNotifierProvider<GarageNotifier, List<Vehicle>>(
  GarageNotifier.new,
);

class GarageNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    final session = ref.watch(currentSessionProvider);
    final userId = session?.user.id;
    if (userId == null) return [];

    final repo = ref.read(vehicleRepositoryProvider);
    return await repo.getVehicles(userId);
  }

  Future<Vehicle?> addVehicle(
    String plateNumber,
    String modelName,
    int year,
  ) async {
    final session = ref.read(currentSessionProvider);
    final userId = session?.user.id;
    if (userId == null) return null;

    final repo = ref.read(vehicleRepositoryProvider);
    Vehicle? newVehicle;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      newVehicle = await repo.addVehicle(userId, plateNumber, modelName, year);
      return repo.getVehicles(userId);
    });

    return newVehicle;
  }
}
