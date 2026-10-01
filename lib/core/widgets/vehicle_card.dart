import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

class VehicleSelectableCard extends StatelessWidget {
  final String plateNumber;
  final String modelName;
  final String year;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleSelectableCard({
    super.key,
    required this.plateNumber,
    required this.modelName,
    required this.year,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      plateNumber,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('$modelName • $year', style: AppTypography.headline2),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : AppColors.border,
                  width: 1.5,
                ),
                color: isSelected
                    ? AppColors.primaryOrange
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: AppColors.background,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
