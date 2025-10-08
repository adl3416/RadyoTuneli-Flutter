import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ana Renk Paleti
  // Gradient Renkler (RadioStationCard için)
  static const Color gradientBlue = Color(0xFF667eea); // Mavi-mor
  static const Color gradientPurple = Color(0xFF764ba2); // Mor
  static const Color gradientPink = Color(0xFFf093fb); // Pembe
  
  // Header ve Card için Mor Renk
  static const Color headerPurple = Color(0xFF8B5CF6); // Header için mor
  static const Color cardPurple = Color(0xFF9333EA); // Card arkaplanı için mor
  static const Color cardPurpleDark = Color(0xFF7C3AED); // Koyu mor variant
  
  // Orange Renk Ailesi
  static const Color orange400 = Color(0xFFFB923C); // Orange-400
  static const Color yellowOrange = Color(0xFFFCD34D); // Sarı-turuncu
  static const Color orange100 = Color(0xFFFEF3C7); // Orange-100
  
  // Gri Renk Ailesi
  static const Color white = Color(0xFFFFFFFF); // Beyaz
  static const Color lightGray = Color(0xFFF5F5F5); // Açık gri
  static const Color gray200 = Color(0xFFE5E7EB); // Gray-200
  static const Color gray500 = Color(0xFF6B7280); // Gray-500
  static const Color gray900 = Color(0xFF111827); // Gray-900
  
  // Tema Renkleri
  static const Color lightTint = Color(0xFF2f95dc); // Light Theme Tint
  static const Color lightBackground = Color(0xFFFFFFFF); // Light Background
  static const Color lightText = Color(0xFF000000); // Light Text
  
  static const Color darkTint = Color(0xFFFFFFFF); // Dark Theme Tint
  static const Color darkBackground = Color(0xFF000000); // Dark Background
  static const Color darkText = Color(0xFFFFFFFF); // Dark Text
  
  // Splash & Icon
  static const Color splashColor = Color(0xFF667eea); // Ana tema mavi-mor

  // Gradient tanımlamaları
  static const LinearGradient radioCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardPurple, cardPurpleDark, gradientPurple],
  );

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: lightText,
      displayColor: lightText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: lightTint,
        secondary: orange400,
        surface: white,
        onPrimary: white,
        onSecondary: white,
        onSurface: lightText,
        error: gradientPink,
        background: lightBackground,
        onBackground: lightText,
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: lightText,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: lightTint,
        unselectedItemColor: gray500,
        backgroundColor: white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange400,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: gray500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightTint),
        ),
        hintStyle: TextStyle(color: gray500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: darkText,
      displayColor: darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: darkTint,
        secondary: orange400,
        surface: gray900,
        onPrimary: gray900,
        onSecondary: gray900,
        onSurface: darkText,
        error: gradientPink,
        background: darkBackground,
        onBackground: darkText,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: darkTint,
        unselectedItemColor: gray500,
        backgroundColor: gray900,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange400,
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: gray500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: gray900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkTint),
        ),
        hintStyle: TextStyle(color: gray500),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: gray900,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

// Radio Card Widget için özel gradient kartı
class RadioStationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isPlaying;
  final bool isFavorite;

  const RadioStationCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.onTap,
    this.onFavoriteToggle,
    this.isPlaying = false,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.radioCardGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Station Image/Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.radio, color: Colors.white),
                            ),
                          )
                        : const Icon(Icons.radio, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  // Station Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Buttons Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Favorite Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () {
                            if (onFavoriteToggle != null) {
                              HapticFeedback.lightImpact();
                              onFavoriteToggle!();
                            }
                          },
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_outline,
                            color: isFavorite ? Colors.red.shade300 : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Play/Pause Button
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.orange400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: onTap,
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
