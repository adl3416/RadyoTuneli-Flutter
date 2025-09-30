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

// Provider for filtered stations based on search - now async
final filteredStationsProvider = FutureProvider<List<Station>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final sortAtoZ = ref.watch(sortAtoZProvider);
  final repository = ref.read(stationRepositoryProvider);

  List<Station> stations;
  if (query.isEmpty) {
    stations = await repository.getTurkishStations();
  } else {
    stations = await repository.searchStations(query);
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

// Provider to manage fa