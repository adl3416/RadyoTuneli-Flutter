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

    // Helper to choose between light/dark based on themeMode
    ThemeData getTheme(ThemeData light, ThemeData dark) {
      if (themeMode == ThemeMode.system) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        return brightness == Brightness.dark ? dark : light;
      }
      return themeMode == ThemeMode.dark ? dark : light;
    }

    // Tema seçimi
    ThemeData selectedTheme;

    if (themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark)) {
      selectedTheme = AppTheme.pureBlackDarkTheme;
    } else {
      switch (colorScheme) {
        case 'kanarya':
          selectedTheme = getTheme(AppTheme.kanarayaThemeLight, AppTheme.kanarayaThemeDark);
          break;
        case 'aslan':
          selectedTheme = getTheme(AppTheme.aslanThemeLight, AppTheme.aslanThemeDark);
          break;
        case 'karadeniz':
          selectedTheme = getTheme(AppTheme.karadenizThemeLight, AppTheme.karadenizThemeDark);
          break;
        case 'kartal':
          selectedTheme = getTheme(AppTheme.kartalThemeLight, AppTheme.kartalThemeDark);
          break;
        case 'timsah':
          selectedTheme = getTheme(AppTheme.timsahThemeLight, AppTheme.timsahThemeDark);
          break;
        case 'beyaz':
          selectedTheme = getTheme(AppTheme.beyazThemeLight, AppTheme.beyazThemeDark);
          break;
        case 'varsayilan':
        default:
          selectedTheme = getTheme(AppTheme.lightTheme, AppTheme.darkTheme);
      }
    }

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
