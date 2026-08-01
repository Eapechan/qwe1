import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _lightColors = _ColorTokens(
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF1F3F5),
    onSurface: Color(0xFF1A1D21),
    onSurfaceMuted: Color(0xFF6B7280),
    primary: Color(0xFF2563EB),
    onPrimary: Color(0xFFFFFFFF),
    primaryLight: Color(0xFFDBEAFE),
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
    onSurface: Color(0xFFF1F3F5),
    onSurfaceMuted: Color(0xFF9CA3AF),
    primary: Color(0xFF60A5FA),
    onPrimary: Color(0xFF0F1117),
    primaryLight: Color(0xFF1E3A5F),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    info: Color(0xFF22D3EE),
    border: Color(0xFF2D3140),
    shimmer: Color(0xFF2D3140),
    gradientStart: Color(0xFF3B82F6),
    gradientEnd: Color(0xFF8B5CF6),
  );

  static ThemeData get lightTheme => _buildTheme(_lightColors);
  static ThemeData get darkTheme => _buildTheme(_darkColors);

  static ThemeData _buildTheme(_ColorTokens colors) {
    final colorScheme = ColorScheme(
      brightness: colors == _lightColors ? Brightness.light : Brightness.dark,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.primary,
      onSecondary: colors.onPrimary,
      error: colors.danger,
      onError: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.onSurface,
      background: colors.background,
      onBackground: colors.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
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
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.danger, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: colors.onSurfaceMuted.withOpacity(0.6)),
        labelStyle: TextStyle(color: colors.onSurfaceMuted),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: colors.primary,
        labelStyle: TextStyle(color: colors.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceMuted,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surface,
        contentTextStyle: TextStyle(color: colors.onSurface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
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
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.primary,
    required this.onPrimary,
    required this.primaryLight,
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
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color primary;
  final Color onPrimary;
  final Color primaryLight;
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
  Color get onSurface => _tokens.onSurface;
  Color get onSurfaceMuted => _tokens.onSurfaceMuted;
  Color get primary => _tokens.primary;
  Color get onPrimary => _tokens.onPrimary;
  Color get primaryLight => _tokens.primaryLight;
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
