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
              child: Builder(
                builder: (context) {
                  Color bgColor;
                  Color borderColor;
                  Color textColor;

                  if (isCompleted) {
                    bgColor = AppColors.primaryOrange;
                    borderColor = AppColors.primaryOrange;
                    textColor = AppColors.background;
                  } else if (isSelected) {
                    bgColor = AppColors.background;
                    borderColor = AppColors.primaryOrange;
                    textColor = AppColors.primaryOrange;
                  } else {
                    bgColor = AppColors.background;
                    borderColor = AppColors.border;
                    textColor = AppColors.textSecondary;
                  }

                  return Container(
                    margin: EdgeInsets.only(
                      right: 8,
                      top: 12,
                      bottom: 12,
                      left: index == 0 ? 16 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      units[index],
                      style: AppTypography.body1Medium.copyWith(
                        color: textColor,
                        fontWeight: isSelected || isCompleted
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
