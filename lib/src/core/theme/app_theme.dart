import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color constants based on the design
  static const Color primaryBackground = Color(0xFF121212); // Deep Charcoal
  static const Color primaryAccent =
      Color(0xFF3B82F6); // Primary Blue (from design)
  static const Color vibrantRed =
      Color(0xFFFF3B30); // For play buttons and active states
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFBDBDBD); // Light Gray
  static const Color surface = Color(0xFF36454F); // Surface dark (from design)
  static const Color surfaceVariant = Color(0xFF4A5568); // Surface variant
  static const Color onSurface = Color(0xFFFFFFFF); // Text on surface
  static const Color onSurfaceSecondary =
      Color(0xFFA0AEC0); // Secondary text on surface

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: vibrantRed,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        error: vibrantRed,
      ),
      scaffoldBackgroundColor: primaryBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryAccent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textSecondary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryAccent),
        ),
        hintStyle: const TextStyle(color: textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      // Custom extensions for app-specific colors
      extensions: const <ThemeExtension<dynamic>>[
        AppColorsExtension(
          vibrantRed: vibrantRed,
          textSecondary: textSecondary,
          surfaceVariant: surfaceVariant,
          onSurfaceSecondary: onSurfaceSecondary,
        ),
      ],
    );
  }
}

// Custom color extension for app-specific colors
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.vibrantRed,
    required this.textSecondary,
    required this.surfaceVariant,
    required this.onSurfaceSecondary,
  });

  final Color vibrantRed;
  final Color textSecondary;
  final Color surfaceVariant;
  final Color onSurfaceSecondary;

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? vibrantRed,
    Color? textSecondary,
    Color? surfaceVariant,
    Color? onSurfaceSecondary,
  }) {
    return AppColorsExtension(
      vibrantRed: vibrantRed ?? this.vibrantRed,
      textSecondary: textSecondary ?? this.textSecondary,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceSecondary: onSurfaceSecondary ?? this.onSurfaceSecondary,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      vibrantRed: Color.lerp(vibrantRed, other.vibrantRed, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceSecondary:
          Color.lerp(onSurfaceSecondary, other.onSurfaceSecondary, t)!,
    );
  }
}

// Extension to easily access custom colors
extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
