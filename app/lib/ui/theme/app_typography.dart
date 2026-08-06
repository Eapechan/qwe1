import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qwe1/ui/theme/app_theme.dart';

class AppTypography {
  AppTypography._();

  static TextStyle displayLarge(BuildContext context) => GoogleFonts.inter(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle displayMedium(BuildContext context) => GoogleFonts.inter(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      );

  static TextStyle displaySmall(BuildContext context) => GoogleFonts.inter(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle headingMedium(BuildContext context) => GoogleFonts.inter(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static TextStyle headingSmall(BuildContext context) => GoogleFonts.inter(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      );

  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
        color: context.onSurfaceMuted,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
        color: context.onSurfaceMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  static TextStyle labelLarge(BuildContext context) => GoogleFonts.inter(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.inter(
        color: context.onSurfaceMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

  static TextStyle labelSmall(BuildContext context) => GoogleFonts.inter(
        color: context.onSurfaceMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle numberMedium(BuildContext context) => GoogleFonts.jetBrainsMono(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle numberSmall(BuildContext context) => GoogleFonts.jetBrainsMono(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle numberLabel(BuildContext context) => GoogleFonts.jetBrainsMono(
        color: context.onSurfaceMuted,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );
}