import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    const Duration(seconds: 12),
    onTimeout: () {
      // Timeout sonrası fallback’a düşür
      throw TimeoutException(
          'Station loading timeout', const Duration(seconds: 12));
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

  // Riverpod cache'inden al — tekrar API çağrısı yapma!
  List<Station> stations = await ref.watch(stationsProvider.future);

  // Arama filtresi
  if (query.isNotEmpty) {
    final lowerQuery = query.toLowerCase();
    stations = stations.where((s) =>
        s.name.toLowerCase().contains(lowerQuery) ||
        (s.genre?.toLowerCase().contains(lowerQuery) ?? false) ||
        (s.description?.toLowerCase().contains(lowerQuery) ?? false)).toList();
  }
  
  // Kategori filtresi uygula
  if (selectedCategory != null) {
    stations = stations.where((station) {
      final stationGenre = station.genre?.toLowerCase() ?? '';
      final stationName = station.name.toLowerCase();
      final stationDescription = station.description?.toLowerCase() ?? '';
      
      switch (selectedCategory) {
        case 'muzik':
          return stationGenre.contains('pop') ||
                 stationGenre.contains('rock') ||
                 stationGenre.contains('müzik') ||
                 stationGenre.contains('muzik') ||
                 stationGenre.contains('music') ||
                 stationGenre.contains('hit') ||
                 stationGenre.contains('türkçe') ||
                 stationGenre.contains('dance') ||
                 stationGenre.contains('top 40') ||
                 stationGenre.contains('charts') ||
                 stationGenre.contains('r&b') ||
                 stationGenre.contains('soul') ||
                 stationGenre.contains('mainstream') ||
                 stationDescription.contains('müzik') ||
                 stationName.contains('müzik') ||
                 stationName.contains('music') ||
                 stationName.contains('power') ||
                 stationName.contains('kral') ||
                 stationName.contains('metro') ||
                 stationName.contains('süper') ||
                 stationName.contains('super') ||
                 stationName.contains('best fm') ||
                 stationName.contains('joy') ||
                 stationName.contains('slow') ||
                 stationName.contains('alem') ||
                 stationName.contains('enerji') ||
                 stationName.contains('viva') ||
                 stationName.contains('virgin') ||
                 stationName.contains('number one') ||
                 stationName.contains('radyo d') ||
                 stationName.contains('show radyo') ||
                 stationName.contains('capital') ||
                 stationName.contains('1 türkiye') ||
                 stationName.contains('1türkiye');
        case 'spor':
          return stationGenre.contains('spor') ||
                 stationGenre.contains('sport') ||
                 stationGenre.contains('futbol') ||
                 stationGenre.contains('football') ||
                 stationGenre.contains('basketbol') ||
                 stationName.contains('spor') ||
                 stationName.contains('sport') ||
                 stationName.contains('futbol') ||
                 stationName.contains('basketbol') ||
                 stationName.contains('lig ') ||
                 stationName.contains('ntvspor') ||
                 stationName.contains('trtspor') ||
                 stationName.contains('a spor') ||
                 stationName.contains('aspor') ||
                 stationName.contains('radyo spor') ||
                 stationDescription.contains('spor') ||
                 stationDescription.contains('futbol');
        case 'haber':
          return stationGenre.contains('haber') ||
                 stationGenre.contains('news') ||
                 stationGenre.contains('talk') ||
                 stationGenre.contains('bilgi') ||
                 stationName.contains('haber') ||
                 stationName.contains('news') ||
                 stationName.contains('ntv') ||
                 stationName.contains('cnn') ||
                 stationName.contains('trt haber') ||
                 stationName.contains('habertürk') ||
                 stationName.contains('haberturk') ||
                 stationName.contains('radyo haber') ||
                 stationName.contains('trt radyo 1') ||
                 stationName.contains('trt1') ||
                 stationDescription.contains('haber') ||
                 stationDescription.contains('news');
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
                 stationGenre.contains('religion') ||
                 stationGenre.contains('islamic') ||
                 stationName.contains('dini') ||
                 stationName.contains('kuran') ||
                 stationName.contains('ilahi') ||
                 stationName.contains('abdüssamet') ||
                 stationName.contains('abdussamet') ||
                 stationName.contains('abdülbasit') ||
                 stationName.contains('abdulbasit') ||
                 stationName.contains('elif') ||
                 stationName.contains('ا') ||
                 stationName.contains('semerkand') ||
                 stationName.contains('cami') ||
                 stationName.contains('ezan') ||
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
                 stationGenre.contains('turku') ||
                 stationGenre.contains('folk') ||
                 stationGenre.contains('halk') ||
                 stationGenre.contains('aşık') ||
                 stationGenre.contains('bağlama') ||
                 stationGenre.contains('yöresel') ||
                 stationName.contains('türkü') ||
                 stationName.contains('turku') ||
                 stationName.contains('halk') ||
                 stationName.contains('trt türkü') ||
                 stationName.contains('folk') ||
                 stationName.contains('ozanlar') ||
                 stationName.contains('aşık') ||
                 stationName.contains('bağlama') ||
                 stationName.contains('yöresel') ||
                 stationName.contains('horon') ||
                 stationDescription.contains('türkü') ||
                 stationDescription.contains('halk müzik');
        case 'yerel':
          return stationName.contains('yerel') ||
                 stationName.contains('ankara') ||
                 stationName.contains('istanbul') ||
                 stationName.contains('izmir') ||
                 stationName.contains('bursa') ||
                 stationName.contains('antalya') ||
                 stationName.contains('adana') ||
                 stationName.contains('konya') ||
                 stationName.contains('kayseri') ||
                 stationName.contains('gaziantep') ||
                 stationName.contains('diyarbakır') ||
                 stationName.contains('diyarbakir') ||
                 stationName.contains('trabzon') ||
                 stationName.contains('samsun') ||
                 stationName.contains('eskişehir') ||
                 stationName.contains('eskisehir') ||
                 stationName.contains('mersin') ||
                 stationName.contains('kocaeli') ||
                 stationName.contains('sakarya') ||
                 stationName.contains('malatya') ||
                 stationName.contains('erzurum') ||
                 stationName.contains('sivas') ||
                 stationName.contains('van') ||
                 stationName.contains('manisa') ||
                 stationName.contains('muğla') ||
                 stationName.contains('mugla') ||
                 stationName.contains('denizli') ||
                 stationName.contains('edirne') ||
                 stationName.contains('çanakkale') ||
                 stationName.contains('canakkale') ||
                 stationName.contains('balıkesir') ||
                 stationName.contains('balikesir') ||
                 stationName.contains('zonguldak') ||
                 stationName.contains('kastamonu') ||
                 stationName.contains('çorum') ||
                 stationName.contains('corum') ||
                 stationName.contains('amasya') ||
                 stationName.contains('tokat') ||
                 stationName.contains('giresun') ||
                 stationName.contains('ordu') ||
                 stationName.contains('rize') ||
                 stationName.contains('artvin') ||
                 stationName.contains('bolu') ||
                 stationName.contains('afyon') ||
                 stationName.contains('isparta') ||
                 stationName.contains('uşak') ||
                 stationName.contains('usak') ||
                 stationName.contains('batman') ||
                 stationName.contains('şanlıurfa') ||
                 stationName.contains('sanliurfa') ||
                 stationName.contains('urfa') ||
                 stationName.contains('mardin') ||
                 stationName.contains('hatay') ||
                 stationName.contains('kahramanmaraş') ||
                 stationName.contains('kahramanmaras') ||
                 stationName.contains('kırıkkale') ||
                 stationName.contains('kirikkale') ||
                 stationName.contains('tekirdağ') ||
                 stationName.contains('tekirdag') ||
                 stationName.contains('yalova') ||
                 stationName.contains('düzce') ||
                 stationName.contains('duzce') ||
                 stationName.contains('bartın') ||
                 stationName.contains('bartin') ||
                 stationGenre.contains('yerel') ||
                 stationGenre.contains('local') ||
                 stationGenre.contains('bölgesel');
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
                 stationGenre.contains('arabesque') ||
                 stationGenre.contains('arabesk pop') ||
                 stationGenre.contains('duygusal') ||
                 stationName.contains('arabesk') ||
                 stationName.contains('kelebek') ||
                 stationName.contains('duygusal') ||
                 stationName.contains('taşlıtarla') ||
                 stationName.contains('tasli') ||
                 stationName.contains('köy') ||
                 stationDescription.contains('arabesk') ||
                 stationDescription.contains('duygusal');
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
  final notifier = RecentlyPlayedNotifier();
  notifier.loadFromPrefs();
  return notifier;
});

// Provider to get actual recently played stations from IDs
final actualRecentlyPlayedStationsProvider = FutureProvider<List<Station>>((ref) async {
  final recentlyPlayedIds = ref.watch(recentlyPlayedNotifierProvider);
  final allStations = await ref.read(stationsProvider.future);
  
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
  static const _key = 'recently_played_ids';

  RecentlyPlayedNotifier() : super([]);

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key);
    if (saved != null && saved.isNotEmpty) {
      state = saved;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  void addRecentStation(String stationId) {
    state = [stationId, ...state.where((id) => id != stationId)];
    if (state.length > 10) {
      state = state.take(10).toList();
    }
    _save();
  }

  void clearRecent() {
    state = [];
    _save();
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

    // Only invalidate filtered/favorite providers, not the base stationsProvider
    ref.invalidateSelf();
    ref.invalidate(filteredStationsProvider);
    ref.invalidate(favoriteStationsProvider);
    ref.invalidate(favoriteStationsCountProvider);
  }

  void clearAll() {
    final repository = ref.read(stationRepositoryProvider);
    repository.clearAllFavorites();

    // Only invalidate filtered/favorite providers, not the base stationsProvider
    ref.invalidateSelf();
    ref.invalidate(filteredStationsProvider);
    ref.invalidate(favoriteStationsProvider);
    ref.invalidate(favoriteStationsCountProvider);
  }
}
