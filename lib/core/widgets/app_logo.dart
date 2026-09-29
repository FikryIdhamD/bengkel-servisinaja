import 'package:flutter/material.dart';
import '../constants/assets.dart';
import '../constants/colors.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    // Rasio kelengkungan selalu 25% dari ukurannya agar konsisten proporsional
    final calculatedRadius = size * 0.25;

    return ClipRRect(
      borderRadius: BorderRadius.circular(calculatedRadius),
      child: Image.asset(
        AppAssets.logoMonogram,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback sementara jika gambar gagal dimuat
          return Icon(
            Icons.local_shipping_rounded,
            size: size,
            color: AppColors.charcoalDark,
          );
        },
      ),
    );
  }
}
