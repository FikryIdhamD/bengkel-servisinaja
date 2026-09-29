import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServicePackage {
  final String id;
  final String name;
  final int durationMinutes;
  final double price;

  const ServicePackage(this.id, this.name, this.durationMinutes, this.price);
}

class SparePart {
  final String id;
  final String name;
  final double price;

  const SparePart(this.id, this.name, this.price);
}

const defaultServicePackages = [
  ServicePackage('SP_1', 'Ganti Pelumas Cepat', 15, 15000),
  ServicePackage('SP_2', 'Servis Ringan / Rutin', 30, 65000),
  ServicePackage('SP_3', 'Servis Berkala / Tune Up', 45, 110000),
  ServicePackage('SP_4', 'Servis Transmisi CVT', 35, 55000),
  ServicePackage('SP_5', 'Perbaikan Khusus & Keluhan Berat', 60, 95000),
];

const defaultSpareParts = [
  SparePart('PART_1', 'Oli Mesin MPX 2 (0.8L)', 54000),
  SparePart('PART_2', 'Oli Sintetik SPX 2 (0.8L)', 67000),
  SparePart('PART_3', 'Oli Gardan Scooter (120ml)', 18000),
  SparePart('PART_4', 'Busi Standar NGK / Denso', 25000),
  SparePart('PART_5', 'Kampas Rem Cakram / Tromol', 45000),
];

class VehicleConfigDraft {
  final ServicePackage? selectedPackage;
  final List<SparePart> selectedParts;
  final String complaints;

  const VehicleConfigDraft({
    this.selectedPackage,
    this.selectedParts = const [],
    this.complaints = '',
  });

  VehicleConfigDraft copyWith({
    ServicePackage? selectedPackage,
    List<SparePart>? selectedParts,
    String? complaints,
  }) {
    return VehicleConfigDraft(
      selectedPackage: selectedPackage ?? this.selectedPackage,
      selectedParts: selectedParts ?? this.selectedParts,
      complaints: complaints ?? this.complaints,
    );
  }

  bool get isValid => selectedPackage != null;
}

final serviceConfigurationProvider =
    NotifierProvider<
      ServiceConfigurationNotifier,
      Map<String, VehicleConfigDraft>
    >(ServiceConfigurationNotifier.new);

class ServiceConfigurationNotifier
    extends Notifier<Map<String, VehicleConfigDraft>> {
  @override
  Map<String, VehicleConfigDraft> build() {
    return {};
  }

  void setPackage(String vehicleId, ServicePackage package) {
    final current = state[vehicleId] ?? const VehicleConfigDraft();
    state = {...state, vehicleId: current.copyWith(selectedPackage: package)};
  }

  void togglePart(String vehicleId, SparePart part) {
    final current = state[vehicleId] ?? const VehicleConfigDraft();
    final parts = List<SparePart>.from(current.selectedParts);
    if (parts.any((p) => p.id == part.id)) {
      parts.removeWhere((p) => p.id == part.id);
    } else {
      parts.add(part);
    }
    state = {...state, vehicleId: current.copyWith(selectedParts: parts)};
  }

  void setComplaints(String vehicleId, String text) {
    final current = state[vehicleId] ?? const VehicleConfigDraft();
    state = {...state, vehicleId: current.copyWith(complaints: text)};
  }
}
