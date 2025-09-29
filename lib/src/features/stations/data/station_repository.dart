import '../domain/station_model.dart';
import 'radio_browser_service.dart';

class StationRepository {
  final RadioBrowserService _apiService = RadioBrowserService();

  // Local storage for favorites (in memory for now, will be persisted later)
  final Set<String> _favoriteStationIds = {};

  /// Fetches Turkish radio stations with fallback mechanism
  Future<List<Station>> getTurkishStations() async {
    try {
      final stations = await _apiService.fetchTurkishStations();
      // Update favorite status based on local storage
      return stations
          .map((station) => station.copyWith(
                isFavorite: _favoriteStationIds.contains(station.id),
              ))
          .toList();
    } catch (e) {
      print('Error fetching stations: $e');
      return [];
    }
  }

  /// Searches stations by query (currently filters by name)
  Future<List<Station>> searchStations(String query) async {
    final stations = await getTurkishStations();

    if (query.isEmpty) return stations;

    final lowerQuery = query.toLowerCase();
    return stations
        .where((station) =>
            station.name.toLowerCase().contains(lowerQuery) ||
            (station.genre?.toLowerCase().contains(lowerQuery) ?? false) ||
            (station.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  /// Gets a specific station by ID
  Future<Station?> getStationById(String id) async {
    final stations = await getTurkishStations();
    try {
      return stations.firstWhere((station) => station.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets popular/featured stations (top 10)
  Future<List<Station>> getFeaturedStations() async {
    final stations = await getTurkishStations();
    return stations.take(10).toList();
  }

  /// Gets favorite stations
  Future<List<Station>> getFavoriteStations() async {
    final stations = await getTurkishStations();
    return stations.where((station) => station.isFavorite).toList();
  }

  /// Toggles favorite status for a station
  Future<void> toggleFavorite(String stationId) async {
    if (_favoriteStationIds.contains(stationId)) {
      _favoriteStationIds.remove(stationId);
    } else {
      _favoriteStationIds.add(stationId);
    }
    // TODO: Persist to local storage
  }

  /// Clears all favorites
  Future<void> clearAllFavorites() async {
    _favoriteStationIds.clear();
    // TODO: Persist to local storage
  }

  /// Gets all stations (alias for getTurkishStations for compatibility)
  Future<List<Station>> getAllStations() async {
    return getTurkishStations();
  }
}
