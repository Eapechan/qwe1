import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Color tokens from design system
  static const _lightColors = _ColorTokens(
    background: Color(0xFFFAFAF9),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF2F2F0),
    onSurface: Color(0xFF1C1917),
    onSurfaceMuted: Color(0xFF57534E),
    primary: Color(0xFF2563EB),
    onPrimary: Color(0xFFFFFFFF),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
    info: Color(0xFF0891B2),
    border: Color(0xFFE7E5E4),
  );

  static const _darkColors = _ColorTokens(
    background: Color(0xFF0C0A09),
    surface: Color(0xFF171412),
    surfaceVariant: Color(0xFF1F1C1A),
    onSurface: Color(0xFFF5F5F4),
    onSurfaceMuted: Color(0xFFA8A29E),
    primary: Color(0xFF60A5FA),
    onPrimary: Color(0xFF0C0A09),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFFBBF24),
    danger: Color(0xFFF87171),
    info: Color(0xFF22D3EE),
    border: Color(0xFF292524),
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
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colors.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: colors.primary,
        labelStyle: TextStyle(color: colors.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
    required this.border,
  });

  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color primary;
  final Color onPrimary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;
  final Color border;
}

// Extension for accessing colors from context
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
  Color get success => _tokens.success;
  Color get warning => _tokens.warning;
  Color get danger => _tokens.danger;
  Color get info => _tokens.info;
  Color get border => _tokens.border;
}
