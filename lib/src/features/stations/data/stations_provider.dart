import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'station_repository.dart';
import '../domain/station_model.dart';

// Provider for the repository
final stationRepositoryProvider = Provider<StationRepository>((ref) {
  return StationRepository();
});

// Provider for all stations - now async with timeout
final stationsProvider = FutureProvider<List<Station>>((ref) async {
  final repository = ref.read(stationRepositoryProvider);

  // Add timeout to prevent infinite loading
  return await repository.getTurkishStations().timeout(
    const Duration(seconds: 30),
    onTimeout: () {
      print('Station loading timeout, falling back to local data');
      // This will trigger the fallback mechanism in the repository
      throw TimeoutException(
          'Station loading timeout', const Duration(seconds: 30));
    },
  );
});

// Provider for favorite stations (will be implemented with persistent storage later)
final favoriteStationsProvider = FutureProvider<List<Station>>((ref) async {
  final stations = await ref.watch(stationsProvider.future);
  return stations.where((station) => station.isFavorite).toList();
});

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider for A-Z sorting state
final sortAtoZProvider = StateProvider<bool>((ref) => false);

// Provider for category filtering
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Provider for expanded categories in drawer
final expandedCategoriesProvider = StateProvider<Set<String>>((ref) => <String>{});

// Radio categories with subcategories
const Map<String, Map<String, String>> radioCategories = {
  'muzik': {
    'title': 'Müzik',
    'pop': 'Pop Müzik',
    'rock': 'Rock Müzik',
    'arabesk': 'Arabesk',
    'turku': 'Türkü',
    '90lar': '90\'lar Müzik',
    'klasik': 'Klasik Müzik',
    'jazz': 'Jazz',
    'elektronik': 'Elektronik',
  },
  'haber_spor': {
    'title': 'Haber & Spor',
    'haber': 'Haberler',
    'spor': 'Spor',
    'ekonomi': 'Ekonomi',
    'siyaset': 'Siyaset',
  },
  'yasam': {
    'title': 'Yaşam',
    'cocuk': 'Çocuk',
    'dini': 'Dini İçerik',
    'yerel': 'Yerel Radyolar',
    'saglik': 'Sağlık',
    'egitim': 'Eğitim',
  },
};

// Provider for filtered stations based on search and category - now async
final filteredStationsProvider = FutureProvider<List<Station>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final sortAtoZ = ref.watch(sortAtoZProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final repository = ref.read(stationRepositoryProvider);

  List<Station> stations;
  if (query.isEmpty) {
    stations = await repository.getTurkishStations();
  } else {
    stations = await repository.searchStations(query);
  }
  
  // Kategori filtresi uygula
  if (selectedCategory != null) {
    stations = stations.where((station) {
      final stationGenre = station.genre?.toLowerCase() ?? '';
      final stationName = station.name.toLowerCase();
      final stationDescription = station.description?.toLowerCase() ?? '';
      
      switch (selectedCategory) {
        case 'spor':
          return stationGenre.contains('spor') || 
                 stationName.contains('spor') ||
                 stationDescription.contains('spor');
        case 'haber':
          return stationGenre.contains('haber') || 
                 stationName.contains('haber') ||
                 stationName.contains('news') ||
                 stationDescription.contains('haber');
        case 'ekonomi':
          return stationGenre.contains('ekonomi') || 
                 stationName.contains('ekonomi') ||
                 stationDescription.contains('ekonomi');
        case 'siyaset':
          return stationGenre.contains('siyaset') || 
                 stationName.contains('siyaset') ||
                 stationDescription.contains('siyaset');
        case 'cocuk':
          return stationGenre.contains('çocuk') || 
                 stationName.contains('çocuk') ||
                 stationName.contains('kids') ||
                 stationDescription.contains('çocuk');
        case 'dini':
          return stationGenre.contains('dini') || 
                 stationName.contains('dini') ||
                 stationName.contains('kuran') ||
                 stationName.contains('ilahi') ||
                 stationDescription.contains('dini');
        case 'saglik':
          return stationGenre.contains('sağlık') || 
                 stationName.contains('sağlık') ||
                 stationName.contains('health') ||
                 stationDescription.contains('sağlık');
        case 'egitim':
          return stationGenre.contains('eğitim') || 
                 stationName.contains('eğitim') ||
                 stationName.contains('education') ||
                 stationDescription.contains('eğitim');
        case 'turku':
          return stationGenre.contains('türkü') || 
                 stationName.contains('türkü') ||
                 stationName.contains('halk') ||
                 stationDescription.contains('türkü');
        case 'yerel':
          return stationName.contains('yerel') ||
                 stationName.contains('ankara') ||
                 stationName.contains('istanbul') ||
                 stationName.contains('izmir') ||
                 stationName.contains('bursa') ||
                 stationName.contains('antalya');
        case 'pop':
          return stationGenre.contains('pop') || 
                 stationName.contains('pop') ||
                 stationDescription.contains('pop');
        case 'rock':
          return stationGenre.contains('rock') || 
                 stationName.contains('rock') ||
                 stationDescription.contains('rock');
        case 'arabesk':
          return stationGenre.contains('arabesk') || 
                 stationName.contains('arabesk') ||
                 stationDescription.contains('arabesk');
        case 'jazz':
          return stationGenre.contains('jazz') || 
                 stationName.contains('jazz') ||
                 stationDescription.contains('jazz');
        case 'elektronik':
          return stationGenre.contains('elektronik') || 
                 stationName.contains('elektronik') ||
                 stationName.contains('electronic') ||
                 stationDescription.contains('elektronik');
        case '90lar':
          return stationGenre.contains('90') || 
                 stationName.contains('90') ||
                 stationName.contains('nostalji') ||
                 stationDescription.contains('90');
        case 'klasik':
          return stationGenre.contains('klasik') || 
                 stationName.contains('klasik') ||
                 stationName.contains('classical') ||
                 stationDescription.contains('klasik');
        default:
          return true;
      }
    }).toList();
  }
  
  // A-Z sıralama uygula
  if (sortAtoZ) {
    stations.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
  
  return stations;
});

// Provider for recently played stations (using featured stations for now)
final recentlyPlayedStationsProvider =
    FutureProvider<List<Station>>((ref) async {
  final repository = ref.read(stationRepositoryProvider);
  return await repository.getFeaturedStations();
});

// Provider for recently played stations management
final recentlyPlayedNotifierProvider = 
    StateNotifierProvider<RecentlyPlayedNotifier, List<String>>((ref) {
  return RecentlyPlayedNotifier();
});

// Provider to get actual recently played stations from IDs
final actualRecentlyPlayedStationsProvider = FutureProvider<List<Station>>((ref) async {
  final recentlyPlayedIds = ref.watch(recentlyPlayedNotifierProvider);
  final allStations = await ref.watch(stationsProvider.future);
  
  if (recentlyPlayedIds.isEmpty) {
    // Eğer hiç son dinlenen yoksa, boş liste dön
    return [];
  }
  
  // Return stations in the order they were recently played
  final recentStations = <Station>[];
  for (final id in recentlyPlayedIds) {
    try {
      final station = allStations.firstWhere((s) => s.id == id);
      recentStations.add(station);
    } catch (e) {
      // Station not found, skip
    }
  }
  
  return recentStations;
});

class RecentlyPlayedNotifier extends StateNotifier<List<String>> {
  RecentlyPlayedNotifier() : super([]);

  void addRecentStation(String stationId) {
    // Remove if already exists to avoid duplicates
    state = state.where((id) => id != stationId).toList();
    // Add to beginning of list
    state = [stationId, ...state];
    // Keep only last 10 items
    if (state.length > 10) {
      state = state.take(10).toList();
    }
  }

  void clearRecent() {
    state = [];
  }
}

// Provider for favorite stations count
final favoriteStationsCountProvider = FutureProvider<int>((ref) async {
  final stations = await ref.watch(stationsProvider.future);
  return stations.where((station) => station.isFavorite).length;
});

// Provider to manage favorite toggle
final favoriteNotifierProvider =
    NotifierProvider<FavoriteNotifier, void>(FavoriteNotifier.new);

class FavoriteNotifier extends Notifier<void> {
  @override
  void build() {}

  void toggleFavorite(String stationId) {
    final repository = ref.read(stationRepositoryProvider);
    repository.toggleFavorite(stationId);

    // Invalidate providers to trigger rebuild
    ref.invalidateSelf();
    ref.invalidate(stationsProvider);
  }

  void clearAll() {
    final repository = ref.read(stationRepositoryProvider);
    repository.clearAllFavorites();

    // Invalidate providers to trigger rebuild
    ref.invalidateSelf();
    ref.invalidate(stationsProvider);
  }
}
