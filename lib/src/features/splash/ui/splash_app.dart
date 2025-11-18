import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/providers/color_scheme_provider.dart';
import 'splash_navigation.dart';

class SplashApp extends ConsumerWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final colorScheme = ref.watch(colorSchemeProvider);
    
    // Renk şemasına göre tema seç (Light + Dark)
    ThemeData getSelectedTheme(bool isDark) {
      if (colorScheme == 'kanarya') {
        return isDark ? AppTheme.kanarayaThemeDark : AppTheme.kanarayaThemeLight;
      } else if (colorScheme == 'aslan') {
        return isDark ? AppTheme.aslanThemeDark : AppTheme.aslanThemeLight;
      } else if (colorScheme == 'karadeniz') {
        return isDark ? AppTheme.karadenizThemeDark : AppTheme.karadenizThemeLight;
      } else if (colorScheme == 'kartal') {
        return isDark ? AppTheme.kartalThemeDark : AppTheme.kartalThemeLight;
      } else if (colorScheme == 'timsah') {
        return isDark ? AppTheme.timsahThemeDark : AppTheme.timsahThemeLight;
      } else if (colorScheme == 'varsayilan' || colorScheme.isEmpty) {
        // Orijinal (Varsayılan) mor tema
        return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
      }
      // Fallback: Varsayılan mor tema
      return isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
    }

    print('🎨 SplashApp - Theme mode: $themeMode, Color scheme: $colorScheme');
    
    return MaterialApp(
      title: 'Radyo Tüneli',
      theme: getSelectedTheme(false), // Light theme
      darkTheme: getSelectedTheme(true), // Dark theme
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashNavigation(),
    );
  }
}