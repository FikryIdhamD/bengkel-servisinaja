import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'multi_vehicle_selection_provider.dart';
import 'service_configuration_provider.dart';

class BookingSummary {
  final double totalServicePrice;
  final double totalPartsPrice;
  final double grandTotal;
  final int totalDurationMinutes;

  const BookingSummary({
    required this.totalServicePrice,
    required this.totalPartsPrice,
    required this.grandTotal,
    required this.totalDurationMinutes,
  });
}

final bookingSummaryComputedProvider = Provider<BookingSummary>((ref) {
  final vehicles = ref.watch(selectedVehiclesProvider);
  final configState = ref.watch(serviceConfigurationProvider);

  double totalService = 0;
  double totalParts = 0;
  int totalDuration = 0;

  for (var v in vehicles) {
    final config = configState[v.id];
    if (config != null) {
      if (config.selectedPackage != null) {
        totalService += config.selectedPackage!.price;
        totalDuration += config.selectedPackage!.durationMinutes;
      }
      for (var part in config.selectedParts) {
        totalParts += part.price;
      }
    }
  }

  return BookingSummary(
    totalServicePrice: totalService,
    totalPartsPrice: totalParts,
    grandTotal: totalService + totalParts,
    totalDurationMinutes: totalDuration,
  );
});
