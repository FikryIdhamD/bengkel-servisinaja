import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/typography.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../data/models/vehicle_model.dart';
import '../../../logic/garage_provider.dart';

class AddVehicleModalSheet extends StatefulWidget {
  final WidgetRef ref;
  final Vehicle? vehicleToEdit;

  const AddVehicleModalSheet({
    super.key,
    required this.ref,
    this.vehicleToEdit,
  });

  @override
  State<AddVehicleModalSheet> createState() => _AddVehicleModalSheetState();
}

class _AddVehicleModalSheetState extends State<AddVehicleModalSheet> {
  late final TextEditingController _plateController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  bool _isLoading = false;

  bool get _isEditMode => widget.vehicleToEdit != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicleToEdit;
    _plateController = TextEditingController(text: v?.plateNumber ?? '');
    _modelController = TextEditingController(text: v?.modelName ?? '');
    _yearController = TextEditingController(
      text: v != null ? v.year.toString() : '',
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submit() async {
    final plate = _plateController.text.trim();
    final model = _modelController.text.trim();
    final year = int.tryParse(_yearController.text.trim()) ?? 0;

    if (plate.isEmpty || model.isEmpty || year == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data dengan benar')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        await widget.ref
            .read(garageProvider.notifier)
            .updateVehicle(widget.vehicleToEdit!.id, plate, model, year);
      } else {
        await widget.ref
            .read(garageProvider.notifier)
            .addVehicle(plate, model, year);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Data kendaraan berhasil diperbarui'
                  : 'Motor berhasil ditambahkan ke Garasi',
            ),
            backgroundColor: AppColors.statusSuccess,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode
                  ? 'Gagal memperbarui motor: $e'
                  : 'Gagal menambahkan motor: $e',
            ),
            backgroundColor: AppColors.statusError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _isEditMode ? 'Edit Kendaraan' : 'Tambah Motor Baru',
                    style: AppTypography.headline1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Nomor Polisi', style: AppTypography.body1Medium),
            const SizedBox(height: 8),
            CustomTextField(
              placeholder: 'Misal: B 1234 ABC',
              controller: _plateController,
            ),
            const SizedBox(height: 16),
            Text('Merk & Model Motor', style: AppTypography.body1Medium),
            const SizedBox(height: 8),
            CustomTextField(
              placeholder: 'Misal: Honda Vario 160',
              controller: _modelController,
            ),
            const SizedBox(height: 16),
            Text('Tahun Pembuatan', style: AppTypography.body1Medium),
            const SizedBox(height: 8),
            CustomTextField(
              placeholder: 'Misal: 2023',
              keyboardType: TextInputType.number,
              controller: _yearController,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: _isEditMode ? 'Simpan Perubahan' : 'Simpan ke Garasi',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
