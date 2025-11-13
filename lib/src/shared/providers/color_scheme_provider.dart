import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Seçilen tema adı (varsayılan, kanarya, vs)
class ColorSchemeNotifier extends StateNotifier<String> {
  ColorSchemeNotifier() : super('varsayilan') {
    _loadColorScheme();
  }

  Future<void> _loadColorScheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('color_scheme') ?? 'varsayilan';
    state = saved;
  }

  Future<void> setColorScheme(String scheme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('color_scheme', scheme);
    state = scheme;
  }
}

final colorSchemeProvider =
    StateNotifierProvider<ColorSchemeNotifier, String>((ref) {
  return ColorSchemeNotifier();
});
