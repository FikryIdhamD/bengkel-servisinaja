import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tracking_repository.dart';

final devSimulationControllerProvider = Provider((ref) {
  return DevSimulationController(ref.watch(trackingRepositoryProvider));
});

class DevSimulationController {
  final TrackingRepository _repo;

  DevSimulationController(this._repo);

  Future<void> updateItemStatus(String itemId, String status) async {
    await _repo.simulateUpdateItemStatus(itemId, status);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _repo.simulateUpdateBookingStatus(bookingId, status);
  }
}
