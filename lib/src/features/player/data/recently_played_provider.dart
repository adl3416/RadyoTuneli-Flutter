import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../stations/domain/station_model.dart';

// Recently played stations provider
final recentlyPlayedProvider =
    StateNotifierProvider<RecentlyPlayedNotifier, List<Station>>((ref) {
  return RecentlyPlayedNotifier();
});

class RecentlyPlayedNotifier extends StateNotifier<List<Station>> {
  RecentlyPlayedNotifier() : super([]);

  void addStation(Station station) {
    // Remove if already exists
    final updatedList = state.where((s) => s.id != station.id).toList();

    // Add to front
    updatedList.insert(0, station);

    // Keep only last 10 items
    if (updatedList.length > 10) {
      updatedList.removeRange(10, updatedList.length);
    }

    state = updatedList;
  }

  void removeStation(String stationId) {
    state = state.where((s) => s.id != stationId).toList();
  }

  void clearAll() {
    state = [];
  }
}
