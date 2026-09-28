import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

class StickyUnitSwitcher extends StatelessWidget {
  final List<String> units;
  final int selectedIndex;
  final ValueChanged<int> onUnitChanged;
  final List<bool> completedStatus;

  const StickyUnitSwitcher({
    Key? key,
    required this.units,
    required this.selectedIndex,
    required this.onUnitChanged,
    required this.completedStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(units.length, (index) {
            final isSelected = selectedIndex == index;
            final isCompleted = completedStatus[index];
            return GestureDetector(
              onTap: () => onUnitChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppColors.primaryOrange
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      units[index],
                      style: isSelected
                          ? AppTypography.body1Medium.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.bold,
                            )
                          : AppTypography.body1Regular.copyWith(
                              color: AppColors.textSecondary,
                            ),
                    ),
                    if (isCompleted) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.statusSuccess,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
