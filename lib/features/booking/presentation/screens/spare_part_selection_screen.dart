import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../logic/service_configuration_provider.dart';

class SparePartSelectionScreen extends ConsumerStatefulWidget {
  final String vehicleId;
  final String vehicleName;

  const SparePartSelectionScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleName,
  });

  @override
  ConsumerState<SparePartSelectionScreen> createState() =>
      _SparePartSelectionScreenState();
}

class _SparePartSelectionScreenState
    extends ConsumerState<SparePartSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  late List<SparePart> _tempSelectedParts;

  static const List<String> _categories = [
    'Semua',
    'Oli Mesin',
    'Oli Gardan',
    'Kelistrikan & Busi',
    'Pengereman',
    'Filter & CVT',
  ];

  @override
  void initState() {
    super.initState();
    final currentConfig = ref.read(serviceConfigurationProvider)[widget.vehicleId];
    _tempSelectedParts = List<SparePart>.from(
      currentConfig?.selectedParts ?? const [],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _togglePart(SparePart part) {
    setState(() {
      if (_tempSelectedParts.any((p) => p.id == part.id)) {
        _tempSelectedParts.removeWhere((p) => p.id == part.id);
      } else {
        _tempSelectedParts.add(part);
      }
    });
  }

  IconData _iconForCategory(String category) {
    if (category.contains('Oli')) {
      return Icons.oil_barrel_outlined;
    } else if (category.contains('Busi')) {
      return Icons.bolt_outlined;
    } else if (category.contains('Pengereman')) {
      return Icons.album_outlined;
    }
    return Icons.build_circle_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final totalSelectedPrice = _tempSelectedParts.fold<double>(
      0,
      (sum, part) => sum + part.price,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoalDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suku Cadang & Pelumas',
              style: AppTypography.headline1.copyWith(
                color: AppColors.charcoalDark,
              ),
            ),
            Text(
              widget.vehicleName,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar (UI)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              controller: _searchController,
              style: AppTypography.body1Regular,
              decoration: InputDecoration(
                hintText: 'Cari oli mesin, busi, kampas rem...',
                hintStyle: AppTypography.body2,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.surfaceGrey,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryOrange,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Filter Chips (UI)
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : AppColors.surfaceGrey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryOrange
                            : AppColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: AppTypography.caption.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),

          // Daftar Item Katalog
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: defaultSpareParts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final part = defaultSpareParts[index];
                final isSelected = _tempSelectedParts.any(
                  (p) => p.id == part.id,
                );

                return GestureDetector(
                  onTap: () => _togglePart(part),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primarySurface
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryOrange
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _iconForCategory(part.category),
                            color: AppColors.primaryOrange,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.surfaceGrey,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryOrange.withValues(
                                            alpha: 0.3,
                                          )
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  part.category,
                                  style: AppTypography.caption.copyWith(
                                    color: isSelected
                                        ? AppColors.primaryOrange
                                        : AppColors.textSecondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                part.name,
                                style: AppTypography.body1Medium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(part.price),
                                style: AppTypography.body2.copyWith(
                                  color: AppColors.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryOrange
                                : AppColors.surfaceGrey,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryOrange
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? Icons.check : Icons.add,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.charcoalDark,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isSelected ? 'Terpilih' : 'Pilih',
                                style: AppTypography.caption.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.charcoalDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Bar Konfirmasi Tambahkan
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_tempSelectedParts.length} Item Dipilih',
                        style: AppTypography.body1Medium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        currencyFormat.format(totalSelectedPrice),
                        style: AppTypography.headline2.copyWith(
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: 'Tambahkan',
                    onPressed: () {
                      ref
                          .read(serviceConfigurationProvider.notifier)
                          .setParts(widget.vehicleId, _tempSelectedParts);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
