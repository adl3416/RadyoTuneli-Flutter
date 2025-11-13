import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/stations/ui/widgets/radio_logo.dart';

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
  
  // Light Theme Renkleri
  static const Color lightTint = Color(0xFF2f95dc); // Light Theme Tint
  static const Color lightBackground = Color(0xFFFFFFFF); // Light Background
  static const Color lightText = Color(0xFF000000); // Light Text
  
  // Dark Theme Renkleri - Yeni modern dark konsept
  static const Color darkPrimary = Color(0xFF8B5CF6); // Violet-500 - daha belirgin
  static const Color darkSecondary = Color(0xFFFF6B35); // Orange-red - dikkat çekici  
  static const Color darkBackground = Color(0xFF000000); // Tam siyah
  static const Color darkSurface = Color(0xFF121212); // Çok koyu gri
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E); // Koyu gri variant
  static const Color darkText = Color(0xFFFFFFFF); // Tam beyaz
  static const Color darkTextSecondary = Color(0xFFCCCCCC); // Açık gri
  static const Color darkBorder = Color(0xFF333333); // Kenarlık rengi
  static const Color darkAccent = Color(0xFFEF4444); // Kırmızı accent
  
  // Splash & Icon
  static const Color splashColor = Color(0xFF667eea); // Ana tema mavi-mor

  // Gradient tanımlamaları
  static const LinearGradient radioCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardPurple, cardPurpleDark, gradientPurple],
  );

  // Dark mode için yeni gradient
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4C1D95), Color(0xFF6366F1), Color(0xFF8B5CF6)],
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
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        onPrimary: white,
        onSecondary: darkBackground,
        onSurface: darkText,
        error: Color(0xFFEF4444), // Red-500
        background: darkBackground,
        onBackground: darkText,
        outline: darkBorder,
        surfaceVariant: darkSurfaceVariant,
        onSurfaceVariant: darkTextSecondary,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(color: darkText),
        headlineMedium: textTheme.headlineMedium?.copyWith(color: darkText),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: darkText),
        titleLarge: textTheme.titleLarge?.copyWith(color: darkText),
        titleMedium: textTheme.titleMedium?.copyWith(color: darkText),
        titleSmall: textTheme.titleSmall?.copyWith(color: darkText),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: darkText),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: darkText),
        bodySmall: textTheme.bodySmall?.copyWith(color: darkTextSecondary),
        labelLarge: textTheme.labelLarge?.copyWith(color: darkText),
        labelMedium: textTheme.labelMedium?.copyWith(color: darkTextSecondary),
        labelSmall: textTheme.labelSmall?.copyWith(color: darkTextSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface, // Siyah yerine koyu gri
        foregroundColor: darkText,
        elevation: 4, // Gölge ekle
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: darkPrimary.withOpacity(0.3), // Mor gölge
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: darkText,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: darkPrimary), // İkonlar mor
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: darkPrimary, // Mor seçili
        unselectedItemColor: darkTextSecondary,
        backgroundColor: darkSurface, // Koyu gri arka plan
        type: BottomNavigationBarType.fixed,
        elevation: 12, // Daha yüksek gölge
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: darkPrimary,
        ),
        unselectedLabelStyle: TextStyle(
          color: darkTextSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary, // Mor buton
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: darkPrimary.withOpacity(0.4),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: darkPrimary, // İkonlar mor
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimary, width: 2),
        ),
        hintStyle: TextStyle(color: darkTextSecondary),
        labelStyle: TextStyle(color: darkTextSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 6, // Daha yüksek gölge
        surfaceTintColor: Colors.transparent,
        shadowColor: darkPrimary.withOpacity(0.2), // Mor gölge
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Daha yuvarlak
          side: BorderSide(
            color: darkBorder,
            width: 1,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textColor: darkText,
        iconColor: darkText,
        tileColor: darkSurface,
      ),
      dividerTheme: DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPrimary;
          }
          return darkTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPrimary.withOpacity(0.3);
          }
          return darkBorder;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: darkText),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: darkText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
    );
  }

  // 🟡 KANARYA TEMASI - Sarı (#FFD700) + Lacivert (#001F3F)
  static const Color kanaryaPrimary = Color(0xFFFFD700); // Sarı
  static const Color kanaryaSecondary = Color(0xFF001F3F); // Lacivert
  static const Color kanaryaLight = Color(0xFFFFF8DC); // Açık sarı arka plan
  static const Color kanaryaDark = Color(0xFF0B1929); // Çok koyu lacivert

  static ThemeData get kanarayaTheme {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: darkText,
      displayColor: darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: kanaryaPrimary, // Sarı
        secondary: kanaryaSecondary, // Lacivert
        surface: darkSurface,
        onPrimary: kanaryaSecondary, // Lacivert yazı sarı üzerinde
        onSecondary: kanaryaPrimary, // Sarı yazı lacivert üzerinde
        onSurface: darkText,
        error: Color(0xFFEF4444),
        background: darkBackground,
        onBackground: darkText,
        outline: darkBorder,
        surfaceVariant: darkSurfaceVariant,
        onSurfaceVariant: darkTextSecondary,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme.copyWith(
        headlineLarge: textTheme.headlineLarge?.copyWith(color: darkText),
        headlineMedium: textTheme.headlineMedium?.copyWith(color: darkText),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: darkText),
        titleLarge: textTheme.titleLarge?.copyWith(color: darkText),
        titleMedium: textTheme.titleMedium?.copyWith(color: darkText),
        titleSmall: textTheme.titleSmall?.copyWith(color: darkText),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: darkText),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: darkText),
        bodySmall: textTheme.bodySmall?.copyWith(color: darkTextSecondary),
        labelLarge: textTheme.labelLarge?.copyWith(color: darkText),
        labelMedium: textTheme.labelMedium?.copyWith(color: darkTextSecondary),
        labelSmall: textTheme.labelSmall?.copyWith(color: darkTextSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: kanaryaSecondary, // 🟡 AppBar = Koyu Lacivert
        foregroundColor: kanaryaPrimary, // 🟡 Yazı = Sarı
        elevation: 4,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: kanaryaSecondary.withOpacity(0.5),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: kanaryaPrimary, // Başlık sarı
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: kanaryaPrimary), // İkonlar sarı
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: kanaryaPrimary, // Sarı seçili
        unselectedItemColor: darkTextSecondary,
        backgroundColor: darkSurface,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: kanaryaPrimary,
        ),
        unselectedLabelStyle: TextStyle(
          color: darkTextSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kanaryaPrimary, // Sarı buton
          foregroundColor: kanaryaSecondary, // Lacivert yazı
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: kanaryaPrimary.withOpacity(0.4),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: kanaryaPrimary, // İkonlar sarı
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kanaryaPrimary, width: 2), // Sarı border
        ),
        hintStyle: TextStyle(color: darkTextSecondary),
        labelStyle: TextStyle(color: darkTextSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 6,
        surfaceTintColor: Colors.transparent,
        shadowColor: kanaryaPrimary.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: darkBorder,
            width: 1,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textColor: darkText,
        iconColor: kanaryaPrimary, // İkonlar sarı
        tileColor: darkSurface,
      ),
      dividerTheme: DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return kanaryaPrimary; // Sarı switch
          }
          return darkTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return kanaryaPrimary.withOpacity(0.3);
          }
          return darkBorder;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: darkText),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: darkText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
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
                  // Station Image/Icon - Modern logo with initials
                  RadioLogo(
                    radioName: title,
                    logoUrl: imageUrl,
                    size: 56,
                    showBorder: true,
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
