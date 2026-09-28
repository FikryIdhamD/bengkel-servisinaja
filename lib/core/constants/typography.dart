import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static TextStyle get displayTitle => GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w700, // Bold
    fontSize: 24,
    height: 32 / 24,
    color: AppColors.textPrimary,
  );

  static TextStyle get headline1 => GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w700, // Bold
    fontSize: 20,
    height: 28 / 20,
    color: AppColors.textPrimary,
  );

  static TextStyle get headline2 => GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w600, // Semi-Bold
    fontSize: 16,
    height: 24 / 16,
    color: AppColors.textPrimary,
  );

  static TextStyle get body1Regular => GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  static TextStyle get body1Medium => GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    height: 20 / 14,
    color: AppColors.textPrimary,
  );

  static TextStyle get body2 => GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 13,
    height: 18 / 13,
    color: AppColors.textSecondary,
  );

  static TextStyle get buttonText => GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w600, // Semi-Bold
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.2,
    color: AppColors.background,
  );

  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontWeight: FontWeight.w400, // Regular
    fontSize: 11,
    height: 16 / 11,
    color: AppColors.textSecondary,
  );
}
