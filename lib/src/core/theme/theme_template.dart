import 'package:flutter/material.dart';

/// Small helper types to make adding new color-based themes fast.
/// Usage:
///  - Create a `ThemeColors` with the colors you want.
///  - Call `ThemeGenerator.generateTheme(colors, isDark: true)` to get a ThemeData.

class ThemeColors {
  final Color primary; // main accent (e.g. button background)
  final Color secondary; // appbar / bottom nav background
  final Color onPrimary; // text/icon on primary
  final Color onSecondary; // text/icon on secondary
  final Color background;
  final Color surface;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.onPrimary,
    required this.onSecondary,
    required this.background,
    required this.surface,
  });
}

class ThemeGenerator {
  static ThemeData generateTheme(ThemeColors colors, {bool isDark = false}) {
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final scheme = isDark
        ? ColorScheme.dark(
            primary: colors.primary,
            onPrimary: colors.onPrimary,
            secondary: colors.secondary,
            onSecondary: colors.onSecondary,
            surface: colors.surface,
            onSurface: Colors.white,
            background: colors.background,
            onBackground: Colors.white,
            error: Colors.red,
            onError: Colors.white,
          )
        : ColorScheme.light(
            primary: colors.primary,
            onPrimary: colors.onPrimary,
            secondary: colors.secondary,
            onSecondary: colors.onSecondary,
            surface: colors.surface,
            onSurface: Colors.black,
            background: colors.background,
            onBackground: Colors.black,
            error: Colors.red,
            onError: Colors.white,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.secondary,
        foregroundColor: colors.onSecondary,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onPrimary.withOpacity(0.6),
        backgroundColor: colors.secondary,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      scaffoldBackgroundColor: colors.background,
    );
  }
}
