import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'main_screen.dart';

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Radyo Tüneli',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
