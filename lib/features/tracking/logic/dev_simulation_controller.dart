import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../garage/data/vehicle_repository.dart';
import '../data/tracking_repository.dart';

class FallbackItemStatusNotifier extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  void setStatus(String bookingId, String status) {
    state = {...state, bookingId: status};
  }
}

final fallbackItemStatusProvider =
    NotifierProvider<FallbackItemStatusNotifier, Map<String, String>>(
      FallbackItemStatusNotifier.new,
    );

final devSimulationControllerProvider = Provider((ref) {
  return DevSimulationController(ref);
});

class DevSimulationController {
  final Ref _ref;

  DevSimulationController(this._ref);

  Future<void> updateItemStatus(
    String itemId,
    String status, {
    String? bookingId,
  }) async {
    if (bookingId != null) {
      _ref
          .read(vehicleRepositoryProvider)
          .updateDeletedBookingItemStatus(bookingId, itemId, status);
      _ref
          .read(fallbackItemStatusProvider.notifier)
          .setStatus(bookingId, status);
    }
    await _ref
        .read(trackingRepositoryProvider)
        .simulateUpdateItemStatus(itemId, status, fallbackBookingId: bookingId);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    if (status == 'Selesai') {
      _ref
          .read(fallbackItemStatusProvider.notifier)
          .setStatus(bookingId, 'Selesai');
    } else if (status == 'Menunggu Kedatangan') {
      _ref
          .read(fallbackItemStatusProvider.notifier)
          .setStatus(bookingId, 'Menunggu Antrean');
    } else if (status == 'Diproses') {
      final current = _ref.read(fallbackItemStatusProvider)[bookingId];
      if (current != 'Sedang Dikerjakan' && current != 'Pengecekan Akhir') {
        _ref
            .read(fallbackItemStatusProvider.notifier)
            .setStatus(bookingId, 'Sedang Dikerjakan');
      }
    }
    await _ref
        .read(trackingRepositoryProvider)
        .simulateUpdateBookingStatus(bookingId, status);
  }
}
