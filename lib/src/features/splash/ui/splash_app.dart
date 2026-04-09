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
    
    // Tema seçimi
    ThemeData selectedTheme;
    
    // Helper to choose between light/dark based on themeMode
    ThemeData getTheme(ThemeData light, ThemeData dark) {
      if (themeMode == ThemeMode.system) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        return brightness == Brightness.dark ? dark : light;
      }
      return themeMode == ThemeMode.dark ? dark : light;
    }

    switch (colorScheme) {
      case 'kanarya':
        print('✅ KANARYA TEMASI SEÇİLDİ!');
        selectedTheme = getTheme(AppTheme.kanarayaThemeLight, AppTheme.kanarayaThemeDark);
        break;
      case 'aslan':
        print('🦁 ASLAN TEMASI SEÇİLDİ!');
        selectedTheme = getTheme(AppTheme.aslanThemeLight, AppTheme.aslanThemeDark);
        break;
      case 'karadeniz':
        print('🌊 KARADENİZ TEMASI SEÇİLDİ!');
        selectedTheme = getTheme(AppTheme.karadenizThemeLight, AppTheme.karadenizThemeDark);
        break;
      case 'kartal':
        print('🦅 KARTAL TEMASI SEÇİLDİ!');
        selectedTheme = getTheme(AppTheme.kartalThemeLight, AppTheme.kartalThemeDark);
        break;
      case 'timsah':
        print('🐊 TİMSAH TEMASI SEÇİLDİ!');
        selectedTheme = getTheme(AppTheme.timsahThemeLight, AppTheme.timsahThemeDark);
        break;
      case 'varsayilan':
      default:
        print('💜 VARSAYILAN TEMA SEÇİLDİ');
        selectedTheme = getTheme(AppTheme.lightTheme, AppTheme.darkTheme);
    }

    print('🎨 SplashApp - Theme mode: $themeMode, Color scheme: $colorScheme');
    
    return MaterialApp(
      title: 'Radyo Tüneli',
      theme: selectedTheme,
      darkTheme: selectedTheme,
      themeMode: ThemeMode.light, // Her zaman light mode kullan çünkü tema kendisi dark/light belirliyor
      debugShowCheckedModeBanner: false,
      home: const SplashNavigation(),
    );
  }
}