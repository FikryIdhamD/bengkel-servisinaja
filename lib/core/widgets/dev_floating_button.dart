import 'package:flutter/material.dart';
import '../constants/colors.dart';

class DevFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DevFloatingButton({Key? key, required this.onPressed})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppColors.charcoalDark,
      child: const Icon(Icons.bug_report, color: AppColors.primaryOrange),
      shape: const CircleBorder(),
      elevation: 6,
    );
  }
}
