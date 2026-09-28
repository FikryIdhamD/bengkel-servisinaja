import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';

class SegmentedTabControl extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const SegmentedTabControl({
    Key? key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  }) : super(key: key);

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
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tabs[index],
                  style: isSelected
                      ? AppTypography.body1Medium.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                        )
                      : AppTypography.body1Regular.copyWith(
                          color: AppColors.textSecondary,
                        ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
