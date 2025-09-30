import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Favori istasyonları yönetmek için provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(<String>{}) {
    _loadFavorites();
  }

  static const String _favoritesKey = 'favorite_stations';

  // Favorileri SharedPreferences'dan yükle
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList(_favoritesKey) ?? [];
      state = favorites.toSet();
    } catch (e) {
      print('Error loading favorites: $e');
      state = <String>{};
    }
  }

  // Favorileri SharedPreferences'a kaydet
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, state.toList());
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  // Favori durumunu kontrol et
  bool isFavorite(String stationId) {
    return state.contains(stationId);
  }

  // Favoriye ekle/çıkar toggle
  Future<void> toggleFavorite(String stationId) async {
    if (state.contains(stationId)) {
      // Favorilerden çıkar
      state = {...state}..remove(stationId);
    } else {
      // Favorilere ekle
      state = {...state, stationId};
    }
    await _saveFavorites();
  }

  // Tüm favorileri temizle
  Future<void> clearAllFavorites() async {
    state = <String>{};
    await _saveFavorites();
  }

  // Favori istasyonların listesini al
  List<String> get favoriteStations => state.toList();

  // Favori sayısını al
  int get favoritesCount => state.length;
}