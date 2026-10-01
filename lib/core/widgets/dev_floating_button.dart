import 'package:flutter/material.dart';
import '../constants/colors.dart';

class DevFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DevFloatingButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.charcoalDark,
      shape: const CircleBorder(),
      elevation: 6,
      child: const Icon(Icons.bug_report, color: AppColors.primaryOrange),
    );
  }
}
