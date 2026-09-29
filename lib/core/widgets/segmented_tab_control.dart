import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

class SegmentedTabControl extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final List<int>? disabledIndices;

  const SegmentedTabControl({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.disabledIndices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = selectedIndex == index;
          final isDisabled = disabledIndices?.contains(index) ?? false;

          return Expanded(
            child: GestureDetector(
              onTap: isDisabled ? null : () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : (isDisabled
                            ? AppColors.surfaceGrey
                            : Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isDisabled) ...[
                      Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      tabs[index],
                      style: isSelected
                          ? AppTypography.body1Medium.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.bold,
                            )
                          : AppTypography.body1Regular.copyWith(
                              color: isDisabled
                                  ? AppColors.textSecondary
                                  : AppColors.textSecondary,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
