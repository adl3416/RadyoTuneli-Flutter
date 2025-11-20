import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'theme_template.dart';

/// A simple in-memory registry for themes. Register new themes here
/// by calling `registerTheme('myname', ThemeGenerator.generateTheme(...))`.

final Map<String, ThemeData> _themeRegistry = {
  'varsayilan': AppTheme.lightTheme,
  'kanarya': AppTheme.kanarayaThemeDark,
  'aslan': AppTheme.aslanThemeDark,
  'karadeniz': AppTheme.karadenizThemeDark,
};

void registerTheme(String name, ThemeData theme) {
  _themeRegistry[name] = theme;
}

ThemeData? getThemeByName(String? name) {
  if (name == null) return null;
  return _themeRegistry[name];
}

List<String> availableThemes() => _themeRegistry.keys.toList(growable: false);

/// Example helper: build a new karadeniz-like theme quickly from colors
ThemeData buildQuickTheme({required Color primary, required Color secondary, bool isDark = false}) {
  final colors = ThemeColors(
    primary: primary,
    secondary: secondary,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    background: isDark ? Colors.black : Colors.white,
    surface: isDark ? Colors.grey[850]! : Colors.white,
  );
  return ThemeGenerator.generateTheme(colors, isDark: isDark);
}
