import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../garage/data/models/vehicle_model.dart';

final selectedVehiclesProvider =
    NotifierProvider<MultiVehicleSelectionNotifier, List<Vehicle>>(
      MultiVehicleSelectionNotifier.new,
    );

class MultiVehicleSelectionNotifier extends Notifier<List<Vehicle>> {
  @override
  List<Vehicle> build() {
    return [];
  }

  void toggleVehicle(Vehicle vehicle) {
    if (state.any((v) => v.id == vehicle.id)) {
      state = state.where((v) => v.id != vehicle.id).toList();
    } else {
      state = [...state, vehicle];
    }
  }

  void selectVehicle(Vehicle vehicle) {
    if (!state.any((v) => v.id == vehicle.id)) {
      state = [...state, vehicle];
    }
  }

  void clear() {
    state = [];
  }
}
