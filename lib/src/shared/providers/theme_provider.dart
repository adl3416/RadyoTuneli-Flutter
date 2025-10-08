import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  Future<void> init() async {
    print('🎨 Theme Provider: Init called');
    await _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      print('🎨 Theme Provider: Loading theme...');
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('theme_mode') ?? 1; // Default to light mode
      
      print('🎨 Theme Provider: Loaded theme index: $themeIndex');
      
      switch (themeIndex) {
        case 0:
          state = ThemeMode.system;
          print('🎨 Theme Provider: Set to System mode');
          break;
        case 1:
          state = ThemeMode.light;
          print('🎨 Theme Provider: Set to Light mode');
          break;
        case 2:
          state = ThemeMode.dark;
          print('🎨 Theme Provider: Set to Dark mode');
          break;
        default:
          state = ThemeMode.light; // Default to light
          print('🎨 Theme Provider: Default to Light mode');
      }
    } catch (e) {
      print('🎨 Theme Provider: Error loading theme: $e');
      state = ThemeMode.light; // Default to light
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      print('🎨 Theme Provider: Setting theme to $mode');
      state = mode;
      final prefs = await SharedPreferences.getInstance();
      
      int themeIndex;
      switch (mode) {
        case ThemeMode.system:
          themeIndex = 0;
          break;
        case ThemeMode.light:
          themeIndex = 1;
          break;
        case ThemeMode.dark:
          themeIndex = 2;
          break;
      }
      
      await prefs.setInt('theme_mode', themeIndex);
      print('🎨 Theme Provider: Saved theme index: $themeIndex');
    } catch (e) {
      print('🎨 Theme Provider: Error setting theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    final currentMode = state;
    ThemeMode newMode;
    
    switch (currentMode) {
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
    }
    
    await setThemeMode(newMode);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final notifier = ThemeNotifier();
  // Initialize asynchronously
  notifier.init();
  return notifier;
});