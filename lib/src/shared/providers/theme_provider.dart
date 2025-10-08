import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  Future<void> init() async {
    await _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('theme_mode') ?? 1; // Default to light mode
      
      switch (themeIndex) {
        case 0:
          state = ThemeMode.system;
          break;
        case 1:
          state = ThemeMode.light;
          break;
        case 2:
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.light; // Default to light
      }
    } catch (e) {
      state = ThemeMode.light; // Default to light
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    try {
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
    } catch (e) {
      // Silent error handling
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