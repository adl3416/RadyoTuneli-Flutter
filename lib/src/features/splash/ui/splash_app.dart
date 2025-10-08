import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/theme_provider.dart';
import 'splash_navigation.dart';

class SplashApp extends ConsumerWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    // Tema durumunu kontrol et
    print('🎨 SplashApp - Current theme mode: $themeMode');
    
    return MaterialApp(
      title: 'Radyo Tüneli',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashNavigation(),
    );
  }
}