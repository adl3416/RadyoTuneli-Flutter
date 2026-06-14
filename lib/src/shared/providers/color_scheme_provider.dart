import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Seçilen tema adı (varsayılan, kanarya, vs)
class ColorSchemeNotifier extends StateNotifier<String> {
  ColorSchemeNotifier() : super('beyaz') {
    // On startup, load persisted color scheme. Default to protected original 'varsayilan'.
    _loadColorScheme();
  }

  String _normalizeScheme(String? scheme) {
    if (scheme == null || scheme.isEmpty) {
      return 'beyaz';
    }

    if (scheme == 'purple') {
      return 'varsayilan';
    }

    return scheme;
  }

  Future<void> _loadColorScheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = _normalizeScheme(prefs.getString('color_scheme'));
      print('🎨 ColorScheme loaded: $saved');
      state = saved;
    } catch (e) {
      print('🎨 ColorScheme load error: $e');
      state = 'beyaz';
    }
  }

  Future<void> setColorScheme(String scheme) async {
    try {
      final normalizedScheme = _normalizeScheme(scheme);
      print('🎨 ColorScheme setting to: $scheme');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('color_scheme', normalizedScheme);
      state = normalizedScheme;
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
