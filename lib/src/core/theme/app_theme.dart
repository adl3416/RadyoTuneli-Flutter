import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/stations/ui/widgets/radio_logo.dart';

class AppTheme {
  // Ana Renk Paleti
  // Gradient Renkler (RadioStationCard için)
  static const Color gradientBlue = Color(0xFF1B3A6B); // Koyu lacivert mavi
  static const Color gradientPurple = Color(0xFF0D2644); // Derin koyu lacivert
  static const Color gradientPink = Color(0xFFF97316); // Canlı turuncu (vurgu)

  // Header ve Card için Ana Renk
  static const Color headerPurple = Color(0xFF1D4ED8); // Elektrik mavi (kurumsal)
  static const Color cardPurple = Color(0xFF1E40AF); // Derin mavi
  static const Color cardPurpleDark = Color(0xFF1E3A8A); // Çok derin mavi

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

  // Dark Theme Renkleri - Derin koyu lacivert konsept
  static const Color darkPrimary =
      Color(0xFF60A5FA); // Blue-400 - parlak mavi
  static const Color darkSecondary =
      Color(0xFFFBBF24); // Amber-400 - sıcak altın kontrast
  static const Color darkBackground = Color(0xFF000000); // Tam siyah
  static const Color darkSurface = Color(0xFF121212); // Çok koyu gri
  static const Color darkSurfaceVariant = Color(0xFF1E1E1E); // Koyu gri variant
  static const Color darkText = Color(0xFFFFFFFF); // Tam beyaz
  static const Color darkTextSecondary = Color(0xFFCCCCCC); // Açık gri
  static const Color darkBorder = Color(0xFF333333); // Kenarlık rengi
  static const Color darkAccent = Color(0xFFFBBF24); // Altın accent

  // Splash & Icon
  static const Color splashColor = Color(0xFF1D4ED8); // Ana tema elektrik mavi

  // Gradient tanımlamaları
  static const LinearGradient radioCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A), Color(0xFF0D2644)],
  );

  // Dark mode için derin lacivert gradient
  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D2644), Color(0xFF1E3A8A), Color(0xFF1D4ED8)],
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
        primary: const Color(0xFF0F1F3D), // Derin gece laciverdisi
        secondary: const Color(0xFF1D4ED8), // Elektrik mavi aksan
        surface: white,
        onPrimary: white,
        onSecondary: white,
        onSurface: const Color(0xFF0F1F3D),
        error: const Color(0xFFDC2626),
        background: const Color(0xFFF0F4FF), // Hafif mavi tonlu beyaz
        onBackground: const Color(0xFF0F1F3D),
        outline: const Color(0xFFBFD0F0),
        surfaceVariant: const Color(0xFFE8EFFC),
        onSurfaceVariant: const Color(0xFF3D5A8A),
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F4FF),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F1F3D), // Derin gece laciverdisi
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: white,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: const Color(0xFF1D4ED8), // Elektrik mavi
        unselectedItemColor: const Color(0xFF64748B),
        backgroundColor: white,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1D4ED8), // Elektrik mavi buton
          foregroundColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: const Color(0xFF3D5A8A),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE8EFFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1D4ED8)),
        ),
        hintStyle: const TextStyle(color: Color(0xFF64748B)),
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
      tabBarTheme: TabBarThemeData(
        labelColor: const Color(0xFF1D4ED8), // Seçili tab = Elektrik mavi
        unselectedLabelColor: gray500, // Seçili olmayan = Gri
        indicatorColor: const Color(0xFF1D4ED8), // Alt çizgi = Elektrik mavi
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: Color(0xFF1D4ED8), width: 3),
        ),
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
        primary: const Color(0xFF60A5FA), // Blue-400 - parlak mavi
        secondary: const Color(0xFFFBBF24), // Amber-400 - altın kontrast
        surface: const Color(0xFF0D1626), // Koyu lacivert yüzey
        onPrimary: const Color(0xFF060A12),
        onSecondary: const Color(0xFF060A12),
        onSurface: darkText,
        error: const Color(0xFFF87171), // Red-400
        background: const Color(0xFF060A12), // Neredeyse siyah lacivert
        onBackground: darkText,
        outline: const Color(0xFF1E3A5F), // Koyu lacivert kenarlık
        surfaceVariant: const Color(0xFF142036), // Koyu lacivert varyant
        onSurfaceVariant: const Color(0xFF94A3B8),
      ),
      scaffoldBackgroundColor: const Color(0xFF060A12),
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
        backgroundColor: const Color(0xFF060A12), // Derin koyu lacivert siyah
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: darkText,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: darkText), // İkonlar beyaz
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: darkPrimary, // Parlak mavi seçili
        unselectedItemColor: darkTextSecondary,
        backgroundColor: const Color(0xFF060A12), // Derin koyu lacivert
        type: BottomNavigationBarType.fixed,
        elevation: 0,
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
          backgroundColor: darkPrimary, // Mavi buton
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
          foregroundColor: darkText, // İkonlar beyaz
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0D1626), // Koyu lacivert dolgu
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkPrimary, width: 2),
        ),
        hintStyle: TextStyle(color: darkTextSecondary),
        labelStyle: TextStyle(color: darkTextSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF0D1626), // Koyu lacivert kart
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF1E3A5F), // Lacivert kenarlık
            width: 1,
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textColor: darkText,
        iconColor: darkText,
        tileColor: Color(0xFF0D1626),
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
        backgroundColor: const Color(0xFF0D1626), // Koyu lacivert diyalog
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: darkText),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: darkText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF0D1626), // Koyu lacivert bottom sheet
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: darkPrimary, // Seçili tab = Parlak mavi
        unselectedLabelColor: darkTextSecondary, // Seçili olmayan = Açık gri
        indicatorColor: darkPrimary, // Alt çizgi = Parlak mavi
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: darkPrimary, width: 3),
        ),
      ),
    );
  }

  // 🟡 KANARYA TEMASI - Sarı (#FFD700) + Lacivert (#001F3F)
  static const Color kanaryaPrimary = Color(0xFFFFD700); // Sarı
  static const Color kanaryaSecondary = Color(0xFF001F3F); // Lacivert
  static const Color kanaryaLight = Color(0xFFFFF8DC); // Açık sarı arka plan
  static const Color kanaryaDark = Color(0xFF0B1929); // Çok koyu lacivert

  static ThemeData get kanarayaThemeDark {
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
      scaffoldBackgroundColor: darkBackground, // ✅ Siyah arka plan
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
        backgroundColor: kanaryaSecondary, // ✅ AppBar = Lacivert (#001F3F)
        foregroundColor: kanaryaPrimary, // ✅ Yazı/İkonlar = Sarı (#FFD700)
        elevation: 4,
        centerTitle: true,
        surfaceTintColor: kanaryaSecondary, // Material 3 için gerekli
        shadowColor: kanaryaSecondary.withOpacity(0.5),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: kanaryaPrimary, // Başlık sarı
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: kanaryaPrimary), // İkonlar sarı
        actionsIconTheme:
            IconThemeData(color: kanaryaPrimary), // Action ikonlar sarı
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: kanaryaPrimary, // ✅ Seçili = Sarı (#FFD700)
        unselectedItemColor: darkTextSecondary, // Seçili olmayan gri
        backgroundColor: kanaryaSecondary, // ✅ Arka plan = Lacivert (#001F3F)
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
          borderSide:
              BorderSide(color: kanaryaPrimary, width: 2), // Sarı border
        ),
        hintStyle: TextStyle(color: darkTextSecondary),
        labelStyle: TextStyle(color: darkTextSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 6,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.4),
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
      tabBarTheme: TabBarThemeData(
        labelColor: kanaryaPrimary, // Seçili tab = Sarı
        unselectedLabelColor: darkTextSecondary, // Seçili olmayan = Gri
        indicatorColor: kanaryaPrimary, // Alt çizgi = Sarı
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: kanaryaPrimary, width: 3),
        ),
      ),
    );
  }

  static ThemeData get kanarayaThemeLight {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: kanaryaPrimary,
        secondary: kanaryaSecondary,
        surface: Colors.white,
        onPrimary: kanaryaSecondary,
        onSecondary: kanaryaPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: kanaryaSecondary, // 🟡 AppBar = Lacivert
        foregroundColor: kanaryaPrimary, // Yazılar = Sarı
        elevation: 0,
        centerTitle: true,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: kanaryaPrimary, // Seçili tab = Sarı
        unselectedLabelColor: kanaryaSecondary
            .withOpacity(0.6), // Seçili olmayan = Yarı-saydam Lacivert
        indicatorColor: kanaryaPrimary, // Alt çizgi = Sarı
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: kanaryaPrimary, width: 3),
        ),
      ),
    );
  }

  // 🦁 ASLAN TEMASI - Sarı + Arı Kırmızı (orijinal renkler)
  static const Color aslanYellow = Color(0xFFFDB813); // Orijinal amber sarı
  // Arı kırmızı - orijinal koyu kırmızı
  static const Color aslanRed = Color(0xFFC8102E);

  static ThemeData get aslanThemeDark {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: darkText,
      displayColor: darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: aslanYellow, // Sarı
        secondary: aslanRed, // Kırmızı
        surface: darkSurface,
        onPrimary: aslanRed, // Kırmızı yazı sarı üzerinde
        onSecondary: aslanYellow, // Sarı yazı kırmızı üzerinde
        onSurface: darkText,
        error: Color(0xFFEF4444),
        background: darkBackground,
        onBackground: darkText,
        outline: darkBorder,
        surfaceVariant: darkSurfaceVariant,
        onSurfaceVariant: darkTextSecondary,
      ),
      scaffoldBackgroundColor: darkBackground, // ✅ Siyah arka plan
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
        backgroundColor: aslanRed, // ✅ AppBar = Kırmızı (#DC143C)
        foregroundColor: aslanYellow, // ✅ Yazı/İkonlar = Sarı (#FFD700)
        elevation: 4,
        centerTitle: true,
        surfaceTintColor: aslanRed, // Material 3 uyumlu
        shadowColor: aslanRed.withOpacity(0.5),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: aslanYellow, // Başlık sarı
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: aslanYellow), // İkonlar sarı
        actionsIconTheme: IconThemeData(color: aslanYellow),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: aslanYellow, // ✅ Seçili = Sarı (#FFD700)
        unselectedItemColor: darkTextSecondary, // Seçili olmayan gri
        backgroundColor: aslanRed, // ✅ Arka plan = Kırmızı (#DC143C)
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: aslanYellow,
        ),
        unselectedLabelStyle: TextStyle(
          color: darkTextSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: aslanYellow, // Sarı buton
          foregroundColor: aslanRed, // Kırmızı yazı
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: aslanYellow.withOpacity(0.4),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: aslanYellow, // İkonlar sarı
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
          borderSide: BorderSide(color: aslanYellow, width: 2), // Sarı border
        ),
        hintStyle: TextStyle(color: darkTextSecondary),
        labelStyle: TextStyle(color: darkTextSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 6,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.4),
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
        iconColor: darkText,
        tileColor: darkSurface,
      ),
      dividerTheme: DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return aslanYellow;
          return darkTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return aslanYellow.withOpacity(0.3);
          }
          return darkBorder;
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: aslanYellow, // Seçili tab = Sarı
        unselectedLabelColor: darkTextSecondary, // Seçili olmayan = Gri
        indicatorColor: aslanYellow, // Alt çizgi = Sarı
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: aslanYellow, width: 3),
        ),
      ),
    );
  }

  static ThemeData get aslanThemeLight {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: aslanYellow,
        secondary: aslanRed,
        surface: Colors.white,
        onPrimary: aslanRed,
        onSecondary: aslanYellow,
      ),
      scaffoldBackgroundColor: Colors.white,
      // Bottom nav styling for Aslan light theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: aslanYellow,
        unselectedItemColor: aslanYellow.withOpacity(0.5),
        backgroundColor: aslanRed,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      // Ensure AppBar matches the provided colors
      appBarTheme: AppBarTheme(
        backgroundColor: aslanRed,
        foregroundColor: aslanYellow,
        elevation: 0,
        centerTitle: true,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: aslanYellow, // Seçili tab = Sarı
        unselectedLabelColor:
            aslanRed.withOpacity(0.6), // Seçili olmayan = Yarı-saydam Kırmızı
        indicatorColor: aslanYellow, // Alt çizgi = Sarı
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: aslanYellow, width: 3),
        ),
      ),
    );
  }

  // 🌊 KARADENIZ FIRTINASI TEMASI - Bordo (#800000) + Mavi (#4169E1)
  static const Color karadenizBordo = Color(0xFF800000);
  static const Color karadenizMavi = Color(0xFF1E90FF);

  static ThemeData get karadenizThemeDark {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: darkText,
      displayColor: darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: karadenizMavi,
        secondary: karadenizBordo,
        surface: darkSurface,
        onPrimary: karadenizBordo,
        onSecondary: karadenizMavi,
        onSurface: darkText,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: karadenizBordo, // 🌊 AppBar = Bordo
        foregroundColor: karadenizMavi, // Yazılar = Mavi
        elevation: 4,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: karadenizMavi,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: karadenizMavi),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: karadenizMavi,
        unselectedItemColor: darkTextSecondary,
        // Make BottomNavigationBar background match AppBar (bordo)
        backgroundColor: karadenizBordo,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: karadenizMavi,
          foregroundColor: karadenizBordo,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: karadenizMavi),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: karadenizMavi, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return karadenizMavi;
          return darkTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return karadenizMavi.withOpacity(0.3);
          }
          return darkBorder;
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: karadenizMavi, // Seçili tab = Mavi
        unselectedLabelColor: karadenizBordo
            .withOpacity(0.6), // Seçili olmayan = Yarı-saydam Bordo
        indicatorColor: karadenizMavi, // Alt çizgi = Mavi
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: karadenizMavi, width: 3),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textColor: darkText,
        iconColor: darkText,
        tileColor: darkSurface,
      ),
    );
  }

  static ThemeData get karadenizThemeLight {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: karadenizMavi,
        secondary: karadenizBordo,
        surface: Colors.white,
        onPrimary: karadenizBordo,
        onSecondary: karadenizMavi,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: karadenizBordo,
        foregroundColor: karadenizMavi,
        elevation: 0,
        centerTitle: true,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: karadenizMavi, // Seçili tab = Mavi
        unselectedLabelColor: karadenizBordo
            .withOpacity(0.6), // Seçili olmayan = Yarı-saydam Bordo
        indicatorColor: karadenizMavi, // Alt çizgi = Mavi
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: karadenizMavi, width: 3),
        ),
      ),
    );
  }

  // 🦅 KARTAL TEMASI - Siyah (#000000) + Beyaz (#FFFFFF)
  static const Color kartalBlack = Color(0xFF000000);
  static const Color kartalWhite = Color(0xFFFFFFFF);

  static ThemeData get kartalThemeDark {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: kartalWhite,
      displayColor: kartalWhite,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: kartalWhite,
        secondary: Color(0xFFBDBDBD), // Gümüş gri accent
        surface: Color(0xFF1A1A1A),
        onPrimary: kartalBlack,
        onSecondary: kartalBlack,
        onSurface: kartalWhite,
        surfaceVariant: Color(0xFF2A2A2A),
        outline: Color(0xFF444444),
      ),
      scaffoldBackgroundColor: Color(0xFF0D0D0D),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: kartalBlack,
        foregroundColor: kartalWhite,
        elevation: 4,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: kartalWhite,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: kartalWhite),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: kartalWhite,
        unselectedItemColor: Color(0xFF888888),
        backgroundColor: Color(0xFF111111),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kartalWhite,
          foregroundColor: kartalBlack,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: kartalWhite),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF444444)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF444444)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kartalWhite, width: 2),
        ),
        hintStyle: TextStyle(color: Color(0xFF888888)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return kartalWhite;
          return Color(0xFF666666);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return kartalWhite.withOpacity(0.3);
          }
          return Color(0xFF333333);
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: kartalWhite,
        unselectedLabelColor: Color(0xFF888888),
        indicatorColor: kartalWhite,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: kartalWhite, width: 3),
        ),
      ),
      cardTheme: CardThemeData(
        color: Color(0xFF1A1A1A),
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Color(0xFF333333), width: 0.5),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textColor: kartalWhite,
        iconColor: kartalWhite,
        tileColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: Color(0xFF333333)),
      dialogTheme: DialogThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: kartalWhite),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: kartalWhite),
      ),
    );
  }

  static ThemeData get kartalThemeLight {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: kartalBlack,
      displayColor: kartalBlack,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: kartalBlack,
        secondary: Color(0xFF424242),
        surface: kartalWhite,
        onPrimary: kartalWhite,
        onSecondary: kartalWhite,
        onSurface: kartalBlack,
      ),
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: kartalBlack,
        foregroundColor: kartalWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: kartalWhite,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: kartalWhite),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: kartalWhite,
        unselectedItemColor: Color(0xFFBDBDBD),
        backgroundColor: kartalBlack,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: kartalWhite,
        unselectedLabelColor: Color(0xFFBDBDBD),
        indicatorColor: kartalWhite,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: kartalWhite, width: 3),
        ),
      ),
      cardTheme: CardThemeData(
        color: kartalWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        textColor: kartalBlack,
        iconColor: kartalBlack,
      ),
    );
  }

  // 🐊 TIMSAH TEMASI - Yeşil (#228B22) + Beyaz (#FFFFFF)
  static const Color timsahGreen = Color(0xFF228B22);
  static const Color timsahWhite = Color(0xFFFFFFFF);

  static ThemeData get timsahThemeDark {
    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: darkText,
      displayColor: darkText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: timsahGreen,
        secondary: Color(0xFF1B5E20),
        surface: darkSurface,
        onPrimary: timsahWhite,
        onSecondary: timsahGreen,
        onSurface: darkText,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: timsahGreen, // 🐊 AppBar = Yeşil
        foregroundColor: timsahWhite, // Yazılar = Beyaz
        elevation: 4,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: timsahWhite,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: timsahWhite),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        // Selected icons should be white on Timsah theme's darker surface
        selectedItemColor: timsahWhite,
        unselectedItemColor: darkTextSecondary,
        backgroundColor: darkSurface,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: timsahGreen,
          foregroundColor: timsahWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: timsahGreen),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: timsahGreen, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return timsahGreen;
          return darkTextSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return timsahGreen.withOpacity(0.3);
          }
          return darkBorder;
        }),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: timsahGreen, // Seçili tab = Yeşil
        unselectedLabelColor:
            timsahWhite.withOpacity(0.6), // Seçili olmayan = Yarı-saydam Beyaz
        indicatorColor: timsahGreen, // Alt çizgi = Yeşil
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: timsahGreen, width: 3),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textColor: darkText,
        iconColor: darkText,
        tileColor: darkSurface,
      ),
    );
  }

  static ThemeData get timsahThemeLight {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: timsahGreen,
        secondary: Color(0xFF1B5E20),
        surface: Colors.white,
        onPrimary: timsahWhite,
        onSecondary: timsahGreen,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: timsahGreen,
        foregroundColor: timsahWhite,
        elevation: 0,
        centerTitle: true,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: timsahGreen, // Seçili tab = Yeşil
        unselectedLabelColor:
            timsahWhite.withOpacity(0.6), // Seçili olmayan = Yarı-saydam Beyaz
        indicatorColor: timsahGreen, // Alt çizgi = Yeşil
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: timsahGreen, width: 3),
        ),
      ),
    );
  }

  // ⬜ SADE TEMASI - Koyu Gri (#3D3D3D) + Beyaz (#FFFFFF)
  static const Color sadeDarkGrey = Color(0xFF3D3D3D);
  static const Color sadeWhite = Color(0xFFFFFFFF);
  static const Color sadeLightGrey = Color(0xFFF0F0F0); // Zebra satır rengi
  static const Color sadeMediumGrey = Color(0xFF757575);
  static const Color sadeDeepDark = Color(0xFF2A2A2A); // Dark tema AppBar

  static ThemeData get sadeThemeLight {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: sadeDarkGrey,
        secondary: sadeMediumGrey,
        surface: sadeWhite,
        onPrimary: sadeWhite,
        onSecondary: sadeWhite,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: sadeWhite,
      appBarTheme: AppBarTheme(
        backgroundColor: sadeDarkGrey,
        foregroundColor: sadeWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: sadeWhite),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: sadeDarkGrey,
        selectedItemColor: sadeWhite,
        unselectedItemColor: sadeWhite.withOpacity(0.65),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sadeDarkGrey,
          foregroundColor: sadeWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardThemeData(
        color: sadeWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: sadeDarkGrey,
        unselectedLabelColor: sadeMediumGrey,
        indicatorColor: sadeDarkGrey,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: sadeDarkGrey, width: 3),
        ),
      ),
    );
  }

  static ThemeData get sadeThemeDark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: sadeLightGrey,
        secondary: sadeMediumGrey,
        surface: const Color(0xFF1E1E1E),
        onPrimary: sadeDarkGrey,
        onSecondary: sadeWhite,
        onSurface: sadeWhite,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: sadeDeepDark,
        foregroundColor: sadeWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: sadeWhite),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: sadeDeepDark,
        selectedItemColor: sadeWhite,
        unselectedItemColor: sadeWhite.withOpacity(0.55),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: sadeDarkGrey,
          foregroundColor: sadeWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: sadeWhite,
        unselectedLabelColor: sadeWhite.withOpacity(0.5),
        indicatorColor: sadeWhite,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: sadeWhite, width: 3),
        ),
      ),
    );
  }
}
