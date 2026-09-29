import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/typography.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../logic/garage_provider.dart';

class AddVehicleModalSheet extends StatefulWidget {
  final WidgetRef ref;

  const AddVehicleModalSheet({super.key, required this.ref});

  @override
  State<AddVehicleModalSheet> createState() => _AddVehicleModalSheetState();
}

class _AddVehicleModalSheetState extends State<AddVehicleModalSheet> {
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  bool _isLoading = false;

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
      await widget.ref
          .read(garageProvider.notifier)
          .addVehicle(plate, model, year);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Motor berhasil ditambahkan ke Garasi')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan motor: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tambah Motor Baru', style: AppTypography.headline1),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
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
            text: 'Simpan ke Garasi',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
