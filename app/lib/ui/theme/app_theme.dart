import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _lightColors = _ColorTokens(
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF1F3F5),
    surfaceContainerLow: Color(0xFFF1F3F5),
    surfaceContainer: Color(0xFFF5F7FA),
    surfaceContainerHighest: Color(0xFFF0F2F5),
    onSurface: Color(0xFF1A1D21),
    onSurfaceMuted: Color(0xFF6B7280),
    onSurfaceVariant: Color(0xFF6B7280),
    primary: Color(0xFF2563EB),
    onPrimary: Color(0xFFFFFFFF),
    primaryLight: Color(0xFFDBEAFE),
    secondary: Color(0xFF6D28D9),
    onSecondary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF0284C7),
    onTertiary: Color(0xFFFFFFFF),
    success: Color(0xFF16A34A),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
    info: Color(0xFF06B6D4),
    border: Color(0xFFE5E7EB),
    shimmer: Color(0xFFE5E7EB),
    gradientStart: Color(0xFF2563EB),
    gradientEnd: Color(0xFF7C3AED),
  );

  static const _darkColors = _ColorTokens(
    background: Color(0xFF0F1117),
    surface: Color(0xFF1A1D27),
    surfaceVariant: Color(0xFF232733),
    surfaceContainerLow: Color(0xFF1F242D),
    surfaceContainer: Color(0xFF272E38),
    surfaceContainerHighest: Color(0xFF2D3540),
    onSurface: Color(0xFFF1F3F5),
    onSurfaceMuted: Color(0xFF9CA3AF),
    onSurfaceVariant: Color(0xFF6B7280),
    primary: Color(0xFF60A5FA),
    onPrimary: Color(0xFF0F1117),
    primaryLight: Color(0xFF1E3A5F),
    secondary: Color(0xFFA855F7),
    onSecondary: Color(0xFF0F1117),
    tertiary: Color(0xFF38BDF8),
    onTertiary: Color(0xFF0F1117),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    info: Color(0xFF22D3EE),
    border: Color(0xFF2D3140),
    shimmer: Color(0xFF2D3140),
    gradientStart: Color(0xFF3B82F6),
    gradientEnd: Color(0xFF8B5CF6),
  );

  static ThemeData get lightTheme => _buildTheme(_lightColors, false);
  static ThemeData get darkTheme => _buildTheme(_darkColors, true);

  static ThemeData _buildTheme(_ColorTokens c, bool isDark) {
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.secondary,
      onSecondary: c.onSecondary,
      tertiary: c.tertiary,
      onTertiary: c.onTertiary,
      error: c.danger,
      onError: c.onPrimary,
      surface: c.surface,
      surfaceVariant: c.surfaceVariant,
      onSurface: c.onSurface,
      onSurfaceVariant: c.onSurfaceVariant,
      background: c.background,
      onBackground: c.onSurface,
      surfaceContainerLow: c.surfaceContainerLow,
      surfaceContainer: c.surfaceContainer,
      surfaceContainerHighest: c.surfaceContainerHighest,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      textTheme: GoogleFonts.inter(
        Theme.of(() {
          final l = TextTheme();
          return isDark ? l.copyWith(
            bodyLarge: GoogleFonts.inter(color: c.onSurface),
            bodyMedium: GoogleFonts.inter(color: c.onSurfaceMuted),
          ) : l.copyWith(
            bodyLarge: GoogleFonts.inter(color: c.onSurface),
            bodyMedium: GoogleFonts.inter(color: c.onSurfaceMuted),
          );
        })(),
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: c.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardTheme(
        color: c.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: c.primary, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: c.onSurfaceMuted.withOpacity(0.6)),
        labelStyle: TextStyle(color: c.onSurfaceMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceVariant,
        selectedColor: c.primary,
        labelStyle: TextStyle(color: c.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.onSurfaceMuted,
        elevation: 0,
        type: BottomNavigationBarType.shifting,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surface,
        contentTextStyle: TextStyle(color: c.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: 1,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}

class _ColorTokens {
  const _ColorTokens({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.onSurfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.primaryLight,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.onTertiary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.border,
    required this.shimmer,
    required this.gradientStart,
    required this.gradientEnd,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHighest;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color onSurfaceVariant;
  final Color primary;
  final Color onPrimary;
  final Color primaryLight;
  final Color secondary;
  final Color onSecondary;
  final Color tertiary;
  final Color onTertiary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color border;
  final Color shimmer;
  final Color gradientStart;
  final Color gradientEnd;
}

extension AppColors on BuildContext {
  _ColorTokens get _tokens => Theme.of(this).brightness == Brightness.light
      ? AppTheme._lightColors
      : AppTheme._darkColors;

  Color get background => _tokens.background;
  Color get surface => _tokens.surface;
  Color get surfaceVariant => _tokens.surfaceVariant;
  Color get surfaceContainerLow => _tokens.surfaceContainerLow;
  Color get surfaceContainer => _tokens.surfaceContainer;
  Color get surfaceContainerHighest => _tokens.surfaceContainerHighest;
  Color get onSurface => _tokens.onSurface;
  Color get onSurfaceMuted => _tokens.onSurfaceMuted;
  Color get onSurfaceVariant => _tokens.onSurfaceVariant;
  Color get primary => _tokens.primary;
  Color get onPrimary => _tokens.onPrimary;
  Color get primaryLight => _tokens.primaryLight;
  Color get secondary => _tokens.secondary;
  Color get onSecondary => _tokens.onSecondary;
  Color get tertiary => _tokens.tertiary;
  Color get onTertiary => _tokens.onTertiary;
  Color get success => _tokens.success;
  Color get warning => _tokens.warning;
  Color get danger => _tokens.danger;
  Color get info => _tokens.info;
  Color get border => _tokens.border;
  Color get shimmer => _tokens.shimmer;
  Color get gradientStart => _tokens.gradientStart;
  Color get gradientEnd => _tokens.gradientEnd;

  LinearGradient get primaryGradient => LinearGradient(
        colors: [_tokens.gradientStart, _tokens.gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}