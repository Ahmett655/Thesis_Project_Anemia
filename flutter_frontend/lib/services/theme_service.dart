import 'package:flutter/material.dart';

/// Global app theme controller.
/// Use [ThemeService.instance] to read and toggle the current theme mode.
///
/// Wrap the part of your widget tree that needs to react to changes in a
/// `ValueListenableBuilder` listening to [ThemeService.instance].
class ThemeService extends ValueNotifier<ThemeMode> {
  ThemeService._() : super(ThemeMode.light);

  /// Global singleton.
  static final ThemeService instance = ThemeService._();

  bool get isDark => value == ThemeMode.dark;

  void toggle() {
    value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  void setMode(ThemeMode mode) {
    value = mode;
  }

  // ============================================================
  //  LIGHT THEME
  // ============================================================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    fontFamily: 'Roboto',
    primaryColor: const Color(0xFFE53935),
    scaffoldBackgroundColor: const Color(0xFFF8F9FB),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE53935),
      brightness: Brightness.light,
      primary: const Color(0xFFE53935),
      surface: Colors.white,
      onSurface: const Color(0xFF1A1A2E),
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE0E0E0),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1A1A2E),
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1A1A2E)),
      bodyMedium: TextStyle(color: Color(0xFF1A1A2E)),
      bodySmall: TextStyle(color: Color(0xFF455A64)),
      titleLarge: TextStyle(
          color: Color(0xFF1A1A2E), fontWeight: FontWeight.w700),
      titleMedium: TextStyle(
          color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.black38),
    ),
  );

  // ============================================================
  //  DARK THEME
  // ============================================================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: 'Roboto',
    primaryColor: const Color(0xFFEF5350),
    scaffoldBackgroundColor: const Color(0xFF0F0F1A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFEF5350),
      brightness: Brightness.dark,
      primary: const Color(0xFFEF5350),
      surface: const Color(0xFF1A1A2E),
      onSurface: Colors.white,
    ),
    cardColor: const Color(0xFF1A1A2E),
    dividerColor: const Color(0xFF2A2A3E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A2E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Color(0xFFB0BEC5)),
      titleLarge: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF252538),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.white38),
    ),
  );
}

/// Convenience helpers to read theme-aware colors.
extension AppColors on BuildContext {
  /// True if currently in dark mode.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Page background.
  Color get bgPage => Theme.of(this).scaffoldBackgroundColor;

  /// Card / elevated surface color.
  Color get bgCard => Theme.of(this).cardColor;

  /// Primary text color (high contrast).
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF1A1A2E);

  /// Secondary text color.
  Color get textSecondary =>
      isDark ? const Color(0xFFB0BEC5) : const Color(0xFF455A64);

  /// Muted text color (hints, captions).
  Color get textMuted =>
      isDark ? const Color(0xFF78909C) : const Color(0xFF90A4AE);

  /// Soft input field background.
  Color get inputBg =>
      isDark ? const Color(0xFF252538) : const Color(0xFFF5F5F5);

  /// Subtle border color.
  Color get borderSubtle =>
      isDark ? const Color(0xFF2A2A3E) : const Color(0xFFE0E0E0);
}
