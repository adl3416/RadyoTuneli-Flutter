import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../domain/player_state_model.dart';
import '../data/audio_service_handler.dart';
import '../data/recently_played_provider.dart';
import '../../stations/domain/station_model.dart';
import '../../stations/data/stations_provider.dart';
import '../../../../main.dart' show globalAudioHandler;

// Audio Handler Provider - uses the global audio handler as AudioHandler (base type)
final audioHandlerProvider = Provider<AudioHandler?>((ref) {
  return globalAudioHandler;
});

// Player State Provider
final playerStateProvider =
    StateNotifierProvider<PlayerNotifier, PlayerStateModel>((ref) {
  final audioHandler = ref.watch(audioHandlerProvider);
  return PlayerNotifier(audioHandler, ref);
});

// Currently Playing Station Provider
final currentlyPlayingStationProvider = Provider<Station?>((ref) {
  // We'll need to implement this to return the current station
  // For now, return null
  return null;
});

class PlayerNotifier extends StateNotifier<PlayerStateModel> {
  final AudioHandler? _audioHandler;
  final Ref _ref;

  PlayerNotifier(this._audioHandler, this._ref)
      : super(const PlayerStateModel()) {
    print(
        "🎛️ PlayerNotifier created with audioHandler: ${_audioHandler != null ? 'available' : 'null'}");
    _init();

    // If audio handler is not available initially, try to set it up later
    if (_audioHandler == null || globalAudioHandler == null) {
      _waitForAudioHandler();
    }
  }

  void _init() {
    final audioHandler = _audioHandler ?? globalAudioHandler;
    if (audioHandler == null) {
      print("⚠️ Audio handler not available in _init");
      return;
    }

    print("🎧 Setting up audio handler listeners...");

    // Listen to audio handler state changes
    audioHandler.playbackState.listen((playbackState) {
      print(
          "🔊 Playback state changed: playing=${playbackState.playing}, processingState=${playbackState.processingState}");
      state = state.copyWith(
        isPlaying: playbackState.playing,
        isLoading:
            playbackState.processingState == AudioProcessingState.loading ||
                playbackState.processingState == AudioProcessingState.buffering,
      );
    });

    // Listen to media item changes
    audioHandler.mediaItem.listen((mediaItem) {
      print("🎵 Media item changed: ${mediaItem?.title}");
      if (mediaItem != null) {
        state = state.copyWith(
          currentStation: CurrentStationInfo(
            id: mediaItem.id,
            name: mediaItem.title,
            artist: mediaItem.artist ?? '',
            logoUrl: mediaItem.artUri?.toString(),
          ),
        );
      } else {
        state = state.copyWith(currentStation: null);
      }
    });

    print("✅ Audio handler listeners set up successfully");
  }

  Future<void> _waitForAudioHandler() async {
    print("⏳ Waiting for global audio handler to be ready...");

    // Check every 100ms for up to 30 seconds (increased from 10)
    for (int i = 0; i < 300; i++) {
      await Future.delayed(const Duration(milliseconds: 100));

      if (globalAudioHandler != null) {
        print("🎉 Global audio handler is now ready! Setting up listeners...");
        _init();
        return;
      }

      // Log progress every 5 seconds
      if (i % 50 == 0 && i > 0) {
        print(
            "⏳ Still waiting for audio handler... (${(i * 0.1).toStringAsFixed(1)}s elapsed)");
      }
    }

    print("⚠️ Global audio handler still not ready after 30 seconds");

    // Set error state to inform user
    state = state.copyWith(
      error:
          'Radyo çalar başlatılamadı. Uygulamayı kapatıp tekrar açmayı deneyin.',
      isLoading: false,
    );
  }

  Future<void> playStation(Station station) async {
    // Check if audio handler is available, if not try to get it
    var audioHandler = _audioHandler ?? globalAudioHandler;

    if (audioHandler == null) {
      state = state.copyWith(
        error: 'Radyo çalar serisi yükleniyor. Lütfen bir moment bekleyin...',
        isLoading: false,
      );

      // Try to wait for audio handler and retry once
      await Future.delayed(const Duration(seconds: 1));
      audioHandler = globalAudioHandler;

      if (audioHandler == null) {
        state = state.copyWith(
          error:
              'Radyo çalar başlatılamadı. Uygulamayı yeniden başlatmayı deneyin.',
          isLoading: false,
        );
        return;
      }
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      // Cast to RadioAudioHandler for playStation method
      final radioHandler = audioHandler as RadioAudioHandler;
      await radioHandler.playStation(
        station.streamUrl,
        station.name,
        station.description ?? 'Turkish Radio',
        station.logoUrl,
        stationId: station.id, // Add station ID parameter
      );

      // Update recently played with new provider
      _ref.read(recentlyPlayedNotifierProvider.notifier).addRecentStation(station.id);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e),
      );
    }
  }

  Future<void> pause() async {
    var audioHandler = _audioHandler ?? globalAudioHandler;
    if (audioHandler == null) return;

    try {
      await audioHandler.pause();
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  Future<void> resume() async {
    var audioHandler = _audioHandler ?? globalAudioHandler;
    if (audioHandler == null) return;

    try {
      await audioHandler.play();
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  Future<void> stop() async {
    var audioHandler = _audioHandler ?? globalAudioHandler;
    if (audioHandler == null) return;

    try {
      await audioHandler.stop();
      state = state.copyWith(
        isPlaying: false,
        isLoading: false,
        currentStation: null,
      );
    } catch (e) {
      state = state.copyWith(error: _getErrorMessage(e));
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Audio handler getter for external access
  AudioHandler? get audioHandler => _audioHandler ?? globalAudioHandler;

  // Navigate to next station in the filtered list
  Future<void> nextStation() async {
    try {
      print('🔄 nextStation called');
      
      // Get search and filter states
      final searchQuery = _ref.read(searchQueryProvider);
      final selectedCategory = _ref.read(selectedCategoryProvider);
      
      print('🔄 Search query: "$searchQuery"');
      print('🔄 Selected category: $selectedCategory');
      
      // Get stations based on current filters
      List<Station> availableStations;
      
      if (searchQuery.isNotEmpty || selectedCategory != null) {
        // Use filtered stations if there's active search/category
        final filteredStations = await _ref.read(filteredStationsProvider.future);
        availableStations = filteredStations;
        print('🔄 Using filtered stations: ${availableStations.length}');
      } else {
        // Use all stations if no filter
        final allStations = await _ref.read(stationsProvider.future);
        availableStations = allStations;
        print('🔄 Using all stations: ${availableStations.length}');
      }
      
      if (availableStations.isEmpty) {
        print('🔄 No stations available');
        return;
      }

      final currentStationId = state.currentStation?.id;
      print('🔄 Current station ID: $currentStationId');
      
      if (currentStationId == null) {
        print('🔄 No current station, playing first available');
        await playStation(availableStations.first);
        return;
      }

      // Find current station index in available list
      final currentIndex = availableStations.indexWhere((s) => s.id == currentStationId);
      print('🔄 Current station index: $currentIndex');
      
      if (currentIndex == -1) {
        print('🔄 Current station not in available list, playing first');
        await playStation(availableStations.first);
        return;
      }

      // Go to next station (wrap around to first if at end)
      final nextIndex = (currentIndex + 1) % availableStations.length;
      print('🔄 Next station index: $nextIndex');
      print('🔄 Next station name: ${availableStations[nextIndex].name}');
      await playStation(availableStations[nextIndex]);
    } catch (e) {
      print('❌ Error in nextStation: $e');
      state = state.copyWith(error: 'Sonraki istasyon yüklenirken hata oluştu.');
    }
  }

  // Navigate to previous station in the filtered list
  Future<void> previousStation() async {
    try {
      print('🔄 previousStation called');
      
      // Get search and filter states
      final searchQuery = _ref.read(searchQueryProvider);
      final selectedCategory = _ref.read(selectedCategoryProvider);
      
      print('🔄 Search query: "$searchQuery"');
      print('🔄 Selected category: $selectedCategory');
      
      // Get stations based on current filters
      List<Station> availableStations;
      
      if (searchQuery.isNotEmpty || selectedCategory != null) {
        // Use filtered stations if there's active search/category
        final filteredStations = await _ref.read(filteredStationsProvider.future);
        availableStations = filteredStations;
        print('🔄 Using filtered stations: ${availableStations.length}');
      } else {
        // Use all stations if no filter
        final allStations = await _ref.read(stationsProvider.future);
        availableStations = allStations;
        print('🔄 Using all stations: ${availableStations.length}');
      }
      
      if (availableStations.isEmpty) {
        print('🔄 No stations available');
        return;
      }

      final currentStationId = state.currentStation?.id;
      print('🔄 Current station ID: $currentStationId');
      
      if (currentStationId == null) {
        print('🔄 No current station, playing last available');
        await playStation(availableStations.last);
        return;
      }

      // Find current station index in available list
      final currentIndex = availableStations.indexWhere((s) => s.id == currentStationId);
      print('🔄 Current station index: $currentIndex');
      
      if (currentIndex == -1) {
        print('🔄 Current station not in available list, playing last');
        await playStation(availableStations.last);
        return;
      }

      // Go to previous station (wrap around to last if at beginning)
      final previousIndex = currentIndex == 0 ? availableStations.length - 1 : currentIndex - 1;
      print('🔄 Previous station index: $previousIndex');
      print('🔄 Previous station name: ${availableStations[previousIndex].name}');
      await playStation(availableStations[previousIndex]);
    } catch (e) {
      print('❌ Error in previousStation: $e');
      state = state.copyWith(error: 'Önceki istasyon yüklenirken hata oluştu.');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Failed to load URL')) {
      return 'Bu radyo istasyonu şu anda yayın yapmıyor. Lütfen daha sonra tekrar deneyin.';
    } else if (error.toString().contains('network')) {
      return 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
    } else if (error.toString().contains('timeout')) {
      return 'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.';
    } else {
      return 'Radyo çalarken bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
