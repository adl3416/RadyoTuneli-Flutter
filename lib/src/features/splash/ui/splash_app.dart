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
    
    // Renk şemasına göre tema seç
    ThemeData getTheme() {
      if (colorScheme == 'kanarya') {
        return AppTheme.kanarayaTheme;
      }
      return AppTheme.darkTheme;
    }

    print('🎨 SplashApp - Theme mode: $themeMode, Color scheme: $colorScheme');
    
    return MaterialApp(
      title: 'Radyo Tüneli',
      theme: AppTheme.lightTheme,
      darkTheme: getTheme(), // Kanarya veya normal dark tema
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashNavigation(),
    );
  }
}