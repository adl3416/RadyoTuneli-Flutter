import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../shared/providers/theme_provider.dart';
import '../shared/providers/color_scheme_provider.dart';
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
