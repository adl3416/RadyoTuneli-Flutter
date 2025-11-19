import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Seçilen tema adı (varsayılan, kanarya, vs)
class ColorSchemeNotifier extends StateNotifier<String> {
  ColorSchemeNotifier() : super('varsayilan') {
    // On startup, load persisted color scheme. Default to protected original 'varsayilan'.
    _loadColorScheme();
  }

  Future<void> _loadColorScheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('color_scheme') ?? 'varsayilan';
      print('🎨 ColorScheme loaded: $saved');
      state = saved;
    } catch (e) {
      print('🎨 ColorScheme load error: $e');
      state = 'varsayilan';
    }
  }

  Future<void> setColorScheme(String scheme) async {
    try {
      print('🎨 ColorScheme setting to: $scheme');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('color_scheme', scheme);
      state = scheme;
      print('🎨 ColorScheme updated: $scheme');
    } catch (e) {
      print('🎨 ColorScheme set error: $e');
    }
  }
}

final colorSchemeProvider =
    StateNotifierProvider<ColorSchemeNotifier, String>((ref) {
  return ColorSchemeNotifier();
});
