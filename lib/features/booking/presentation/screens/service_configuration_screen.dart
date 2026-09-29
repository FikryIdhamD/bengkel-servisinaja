import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/sticky_unit_switcher.dart';
import '../../logic/multi_vehicle_selection_provider.dart';
import '../../logic/service_configuration_provider.dart';

class ServiceConfigurationScreen extends ConsumerStatefulWidget {
  const ServiceConfigurationScreen({super.key});

  @override
  ConsumerState<ServiceConfigurationScreen> createState() =>
      _ServiceConfigurationScreenState();
}

class _ServiceConfigurationScreenState
    extends ConsumerState<ServiceConfigurationScreen> {
  int _activeUnitIndex = 0;

  final Map<String, TextEditingController> _complaintControllers = {};

  @override
  void dispose() {
    for (var c in _complaintControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicles = ref.watch(selectedVehiclesProvider);
    final configState = ref.watch(serviceConfigurationProvider);

    if (selectedVehicles.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Tidak ada kendaraan terpilih')),
      );
    }

    if (_activeUnitIndex >= selectedVehicles.length) {
      _activeUnitIndex = 0;
    }

    final activeVehicle = selectedVehicles[_activeUnitIndex];
    final activeConfig =
        configState[activeVehicle.id] ?? const VehicleConfigDraft();

    if (!_complaintControllers.containsKey(activeVehicle.id)) {
      _complaintControllers[activeVehicle.id] = TextEditingController(
        text: activeConfig.complaints,
      );
    }

    bool isAllValid = true;
    for (var v in selectedVehicles) {
      if (configState[v.id]?.isValid != true) {
        isAllValid = false;
        break;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalDark),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Konfigurasi Servis',
          style: AppTypography.headline1.copyWith(
            color: AppColors.charcoalDark,
          ),
        ),
      ),
      body: Column(
        children: [
          // Sticky Switcher
          StickyUnitSwitcher(
            units: selectedVehicles
                .asMap()
                .entries
                .map((e) => 'Unit ${e.key + 1}: ${e.value.modelName}')
                .toList(),
            selectedIndex: _activeUnitIndex,
            onUnitChanged: (index) {
              setState(() {
                _activeUnitIndex = index;
              });
            },
            completedStatus: selectedVehicles
                .map((v) => configState[v.id]?.isValid ?? false)
                .toList(),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Paket Servis Utama',
                    style: AppTypography.headline2,
                  ),
                  const SizedBox(height: 12),
                  ...defaultServicePackages.map((pkg) {
                    final isSelected =
                        activeConfig.selectedPackage?.id == pkg.id;
                    return _buildPackageCard(
                      package: pkg,
                      isSelected: isSelected,
                      onTap: () {
                        ref
                            .read(serviceConfigurationProvider.notifier)
                            .setPackage(activeVehicle.id, pkg);
                      },
                    );
                  }),

                  const SizedBox(height: 24),
                  Text(
                    'Suku Cadang & Pelumas Tambahan',
                    style: AppTypography.headline2,
                  ),
                  const SizedBox(height: 12),
                  ...defaultSpareParts.map((part) {
                    final isSelected = activeConfig.selectedParts.any(
                      (p) => p.id == part.id,
                    );
                    return _buildPartCheckbox(
                      part: part,
                      isSelected: isSelected,
                      onChanged: (val) {
                        ref
                            .read(serviceConfigurationProvider.notifier)
                            .togglePart(activeVehicle.id, part);
                      },
                    );
                  }),

                  const SizedBox(height: 24),
                  Text(
                    'Catatan Keluhan (Opsional)',
                    style: AppTypography.headline2,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    placeholder:
                        'Tuliskan gejala kerusakan, kendala mesin, atau keluhan khusus teknisi pada motor ini...',
                    minLines: 3,
                    maxLines: 5,
                    controller: _complaintControllers[activeVehicle.id],
                    onChanged: (val) {
                      ref
                          .read(serviceConfigurationProvider.notifier)
                          .setComplaints(activeVehicle.id, val);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: PrimaryButton(
                text: 'Lanjut ke Jadwal Bengkel',
                onPressed: isAllValid
                    ? () {
                        context.push('/schedule');
                      }
                    : null,
                backgroundColor: isAllValid
                    ? AppColors.primaryOrange
                    : AppColors.disabled,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required ServicePackage package,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(package.name, style: AppTypography.headline2),
                  const SizedBox(height: 4),
                  Text(
                    'Estimasi: ${package.durationMinutes} Menit',
                    style: AppTypography.body2,
                  ),
                ],
              ),
            ),
            Text(
              'Rp ${package.price.toInt()}',
              style: AppTypography.body1Medium.copyWith(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartCheckbox({
    required SparePart part,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      value: isSelected,
      onChanged: onChanged,
      title: Text(part.name, style: AppTypography.body1Medium),
      subtitle: Text(
        'Rp ${part.price.toInt()}',
        style: AppTypography.body2.copyWith(color: AppColors.primaryOrange),
      ),
      activeColor: AppColors.primaryOrange,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }
}
