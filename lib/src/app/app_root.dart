import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../shared/providers/theme_provider.dart';
import '../shared/providers/color_scheme_provider.dart';
import '../core/theme/theme_registry.dart';
import 'main_screen.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final colorScheme = ref.watch(colorSchemeProvider);
    
    print('🎨 AppRoot - Theme mode: $themeMode, Color scheme: $colorScheme');
    
    // Tema seçimi
    ThemeData selectedTheme;
    // Determine if dark mode is requested
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    // Try dark variant from registry when dark mode is active
    final themeKey = isDark ? '${colorScheme}_dark' : colorScheme;
    final registered = getThemeByName(themeKey) ?? getThemeByName(colorScheme);
    if (registered != null) {
      selectedTheme = registered;
    } else {
      // fallback to default behavior
      print('💜 VARSAYILAN TEMA SEÇİLDİ');
      selectedTheme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }
    
    return MaterialApp(
      title: 'Radyo Tüneli',
      theme: selectedTheme,
      darkTheme: selectedTheme,
      themeMode: ThemeMode.light, // Her zaman light mode kullan çünkü tema kendisi dark/light belirliyor
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
