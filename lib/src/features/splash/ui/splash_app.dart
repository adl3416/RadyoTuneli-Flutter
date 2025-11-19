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
    switch (colorScheme) {
      case 'kanarya':
        print('✅ KANARYA TEMASI SEÇİLDİ!');
        selectedTheme = AppTheme.kanarayaThemeDark;
        print('📱 Scaffold color: ${AppTheme.kanarayaThemeDark.scaffoldBackgroundColor}');
        print('📱 AppBar color: ${AppTheme.kanarayaThemeDark.appBarTheme.backgroundColor}');
        print('📱 BottomNav color: ${AppTheme.kanarayaThemeDark.bottomNavigationBarTheme.backgroundColor}');
        break;
      case 'varsayilan':
      default:
        print('💜 VARSAYILAN TEMA SEÇİLDİ');
        selectedTheme = themeMode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
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