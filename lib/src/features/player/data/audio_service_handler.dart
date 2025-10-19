import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../domain/player_state_model.dart';

class RadioAudioHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  final AudioPlayer _player = AudioPlayer();
  
  // Dinamik radyo kategorileri - uygulama çalışırken doldurulacak
  Map<String, List<MediaItem>> _radioCategories = {};

  // Kategori isimleri ve açıklamaları (modern Android Auto tasarımı için)
  final Map<String, Map<String, String>> _categoryInfo = {
    'populer': {
      'title': '⭐ Popüler',
      'description': 'En çok dinlenen 50 radyo',
      'icon': 'star',
    },
    'tum_radyolar': {
      'title': '📻 Tüm İstasyonlar',
      'description': 'Tüm radyo kanalları',
      'icon': 'radio',
    },
    'haber': {
      'title': '📰 Haber',
      'description': 'Güncel haberler',
      'icon': 'newspaper',
    },
    'muzik': {
      'title': '🎵 Müzik',
      'description': 'Pop, Rock & Eğlence',
      'icon': 'music_note',
    },
    'turku': {
      'title': '🎻 Türkü',
      'description': 'Halk Müziği & Türküler',
      'icon': 'piano',
    },
    'spor': {
      'title': '⚽ Spor',
      'description': 'Spor yayınları',
      'icon': 'sports_soccer',
    },
    'dini': {
      'title': '🕌 Dini',
      'description': 'Dini içerikler',
      'icon': 'mosque',
    },
  };

  RadioAudioHandler() {
    print("🚗🚗🚗 ANDROID AUTO: RadioAudioHandler CONSTRUCTOR called");
    _init();
    _setupAndroidAutoSupport();
  }

  void _setupAndroidAutoSupport() {
    print("🚗🚗🚗 ANDROID AUTO: Setting up support");
    
    // Force MediaBrowserService to be ready
    Future.delayed(Duration(seconds: 1), () {
      print("🚗🚗🚗 ANDROID AUTO: MediaBrowserService ready for discovery");
    });
  }

  // Radyo listesini dışarıdan yükle (player_provider tarafından çağrılır)
  void loadRadioStations(List<dynamic> stations) {
    print("🚗 Loading ${stations.length} stations for Android Auto");
    
    // Kategorilere göre radyoları ayır
    _radioCategories.clear();
    
    // Tüm radyoları işle (maksimum 200 radyo)
    final allStations = stations.take(200).toList();
    final List<MediaItem> allMediaItems = [];
    
    for (int i = 0; i < allStations.length; i++) {
      final station = allStations[i];
      final name = station['name'] ?? '';
      final stationId = station['stationuuid'] ?? station['id'] ?? name;
      final streamUrl = station['url_resolved'] ?? station['streamUrl'] ?? station['url'] ?? '';
      final genre = station['tags']?.toString().split(',').first ?? station['genre'] ?? 'Genel';
      final favicon = station['favicon'] ?? station['logoUrl'] ?? '';
      
      if (streamUrl.isEmpty) continue; // URL yoksa atla
      
      // Kategori belirle
      String category = 'muzik'; // varsayılan
      final lowerName = name.toLowerCase();
      final lowerGenre = genre.toLowerCase();
      
      if (lowerName.contains('haber') || lowerName.contains('news') || lowerGenre.contains('news') || lowerGenre.contains('haber')) {
        category = 'haber';
      } else if (lowerName.contains('spor') || lowerName.contains('sport') || lowerGenre.contains('sport') || lowerGenre.contains('spor')) {
        category = 'spor';
      } else if (lowerName.contains('türkü') || lowerName.contains('turku') || lowerGenre.contains('folk') || lowerGenre.contains('türkü')) {
        category = 'turku';
      } else if (lowerName.contains('dini') || lowerName.contains('kuran') || lowerName.contains('diyanet') || lowerGenre.contains('islamic') || lowerGenre.contains('dini')) {
        category = 'dini';
      }
      
      final mediaItem = MediaItem(
        id: stationId,
        title: name,
        artist: genre,
        genre: genre,
        artUri: favicon.isNotEmpty ? Uri.tryParse(favicon) : null,
        playable: true,
        extras: {
          'streamUrl': streamUrl,
          'category': category,
          'isLive': true,
        },
      );
      
      allMediaItems.add(mediaItem);
      
      // Kategoriye ekle
      _radioCategories.putIfAbsent(category, () => []).add(mediaItem);
      
      // İlk 50 radyoyu popüler kategorisine ekle
      if (i < 50) {
        _radioCategories.putIfAbsent('populer', () => []).add(mediaItem);
      }
    }
    
    // Tüm radyoları "tum_radyolar" kategorisine ekle
    _radioCategories['tum_radyolar'] = allMediaItems;
    
    print("🚗 Loaded ${allMediaItems.length} stations into ${_radioCategories.length} categories");
    _radioCategories.forEach((key, value) {
      print("  - $key: ${value.length} stations");
    });
  }

  void _init() {
    print("🎧 Initializing RadioAudioHandler...");
    print("🚗🚗🚗 ANDROID AUTO: _init() method called");

    // Initialize playback state
    playbackState.add(PlaybackState(
      controls: [],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.playPause,
      },
      androidCompactActionIndices: const [],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));

    // Listen to audio player state changes
    _player.playerStateStream.listen((playerState) {
      print(
          "🔊 Player state changed: playing=${playerState.playing}, processing=${playerState.processingState}");
      _broadcastState(playerState);
    });

    // Listen to current position for progress updates
    _player.positionStream.listen((position) {
      final oldState = playbackState.value;
      playbackState.add(oldState.copyWith(
        updatePosition: position,
      ));
    });

    print("✅ RadioAudioHandler initialized");
  }

  void _broadcastState(PlayerState playerState) {
    final isPlaying = playerState.playing;
    final processingState = playerState.processingState;

    List<MediaControl> controls = [];

    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      controls = [
        MediaControl.stop,
      ];
      print("🔄 Yükleniyor - Kilit ekranı kontrolleri aktif");
    } else if (processingState != ProcessingState.completed) {
      controls = [
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ];
      print("🎵 Oynatılıyor - Kilit ekranı kontrolleri aktif");
    }

    playbackState.add(PlaybackState(
      controls: controls,
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.playPause,
      },
      androidCompactActionIndices: controls.length >= 2 ? const [0, 1] : const [0],
      processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[processingState] ??
          AudioProcessingState.idle,
      playing: isPlaying,
      updatePosition: _player.position,
    ));
  }

  @override
  Future<void> play() async {
    try {
      print("▶️ Resuming playback...");
      await _player.play();
    } catch (e) {
      print('❌ Error playing audio: $e');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      print("⏸️ Pausing playback...");
      await _player.pause();
    } catch (e) {
      print('❌ Error pausing audio: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      print("⏹️ Stopping playback...");
      await _player.stop();

      // Clear the current media item
      mediaItem.add(null);

      // Set stopped state
      playbackState.add(PlaybackState(
        controls: [],
        systemActions: const {
          MediaAction.play,
        },
        androidCompactActionIndices: const [],
        processingState: AudioProcessingState.idle,
        playing: false,
        updatePosition: Duration.zero,
      ));

      print("✅ Playback stopped successfully");
    } catch (e) {
      print('❌ Error stopping audio: $e');
      rethrow;
    }
  }

  Future<void> playPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> playStation(
      String streamUrl, String title, String artist, String? artUri, {String? stationId}) async {
    try {
      print("📻 Setting up radio station: $title (ID: ${stationId ?? 'none'})");

      // Set media item for system UI - Modern Android Auto tasarımı
      final mediaItem = MediaItem(
        id: stationId ?? streamUrl,
        title: title,
        artist: artist,
        album: 'Radyo Tüneli',
        displayTitle: title,
        displaySubtitle: '🔴 CANLI YAYIN',
        displayDescription: artist,
        artUri: artUri != null && artUri.isNotEmpty ? Uri.parse(artUri) : Uri.parse('android.resource://com.turkradyo.adl.de.turkradyo/mipmap/ic_launcher'),
        playable: true,
        duration: Duration.zero, // Radio streams don't have duration
        rating: Rating.newHeartRating(true), // Favorilere eklenebilir göster
        extras: {
          'isLive': true,
          'streamUrl': streamUrl,
          'stationId': stationId,
          // Android Auto için ek metadata
          'android.media.metadata.CONTENT_TYPE': 'audio/mpeg',
          'android.media.metadata.ADVERTISEMENT': 0, // Reklam değil
          'android.media.metadata.DOWNLOAD_STATUS': 0, // İndirilebilir değil (canlı yayın)
        },
      );

      // Update media item
      this.mediaItem.add(mediaItem);

      // Set loading state
      playbackState.add(PlaybackState(
        controls: [MediaControl.stop],
        systemActions: const {
          MediaAction.stop,
        },
        androidCompactActionIndices: const [0],
        processingState: AudioProcessingState.loading,
        playing: false,
        updatePosition: Duration.zero,
      ));

      // Set the audio source
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamUrl),
          tag: mediaItem,
        ),
      );

      print("🎵 Audio source set, starting playback...");

      // Start playing
      await _player.play();

      print("✅ Radio station started successfully");
    } catch (e) {
      print('❌ Error setting up station: $e');

      // Set error state
      playbackState.add(PlaybackState(
        controls: [MediaControl.play],
        systemActions: const {
          MediaAction.play,
        },
        androidCompactActionIndices: const [0],
        processingState: AudioProcessingState.error,
        playing: false,
        updatePosition: Duration.zero,
      ));

      throw e;
    }
  }

  // Get current player state
  PlayerStateModel get currentPlayerState {
    final playerState = _player.playerState;
    final currentMedia = mediaItem.value;

    return PlayerStateModel(
      isPlaying: playerState.playing,
      isLoading: playerState.processingState == ProcessingState.loading ||
          playerState.processingState == ProcessingState.buffering,
      currentStation: currentMedia != null
          ? CurrentStationInfo(
              id: currentMedia.id,
              name: currentMedia.title,
              artist: currentMedia.artist ?? '',
              logoUrl: currentMedia.artUri?.toString(),
            )
          : null,
      position: _player.position,
      error: null,
    );
  }

  @override
  Future<void> onTaskRemoved() async {
    print("🗑️ Task removed - continuing background playback");
    // Don't stop playback when task is removed (background support)
    // Only stop if user explicitly stops from notification
  }

  @override
  Future<void> onNotificationDeleted() async {
    print("🗑️ Notification deleted - stopping playback");
    await stop();
  }

  void disposePlayer() {
    print("🔄 Disposing audio player...");
    _player.dispose();
  }

  // =====================================
  // Android Auto / CarPlay MediaBrowser Support
  // =====================================

  // Android Auto MediaBrowserService support
  @override
  Future<MediaItem?> getMediaItem(String mediaId) async {
    print("🚗 Android Auto: getMediaItem called with mediaId: $mediaId");
    
    // Ana root için özel durum
    if (mediaId == AudioService.browsableRootId) {
      return MediaItem(
        id: AudioService.browsableRootId,
        title: 'Radyo Tüneli',
        artist: 'Türk Radyo İstasyonları',
        artUri: Uri.parse('android.resource://com.turkradyo.adl.de.turkradyo/mipmap/ic_launcher'),
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_SUPPORTED': true,
          'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 1,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
        },
      );
    }
    
    // Kategoriler için kontrol
    if (_categoryInfo.containsKey(mediaId)) {
      final categoryData = _categoryInfo[mediaId]!;
      return MediaItem(
        id: mediaId,
        title: categoryData['title']!,
        artist: categoryData['description']!,
        artUri: Uri.parse('android.resource://com.turkradyo.adl.de.turkradyo/mipmap/ic_launcher'),
        playable: false,
        extras: {
          'browsable': true,
          'android.media.browse.CONTENT_STYLE_SUPPORTED': true,
          'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 1,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
        },
      );
    }
    
    // İstasyonları tüm kategorilerde ara
    for (final stations in _radioCategories.values) {
      try {
        final station = stations.firstWhere((item) => item.id == mediaId);
        return station;
      } catch (e) {
        // Continue searching in other categories
      }
    }
    
    return null;
  }

  @override
  Future<List<MediaItem>> getChildren(String parentMediaId, [Map<String, dynamic>? options]) async {
    print("🚗🚗🚗 Android Auto: getChildren called with parentMediaId: $parentMediaId");
    
    if (parentMediaId == AudioService.browsableRootId) {
      // Root level - return ALL categories (always visible)
      print("🚗🚗🚗 Returning ROOT level categories");
      print("🚗🚗🚗 Total categories defined: ${_categoryInfo.length}");
      print("🚗🚗🚗 Categories with stations: ${_radioCategories.keys.length}");
      
      // TÜM kategorileri döndür - Modern Grid görünümü
      final categories = _categoryInfo.entries.map((entry) {
        final categoryId = entry.key;
        final categoryData = entry.value;
        final stationCount = _radioCategories[categoryId]?.length ?? 0;
        
        print("🚗 Category: $categoryId - ${categoryData['title']} ($stationCount stations)");
        
        return MediaItem(
          id: categoryId,
          title: categoryData['title']!,
          artist: stationCount > 0 
              ? '$stationCount radyo istasyonu' 
              : 'Yakında...',
          album: categoryData['description'],
          artUri: Uri.parse('android.resource://com.turkradyo.adl.de.turkradyo/mipmap/ic_launcher'),
          playable: false,
          extras: {
            'android.media.browse.CONTENT_STYLE_SUPPORTED': true,
            'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2, // Grid görünüm
            'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 1,
            'android.media.browse.CONTENT_STYLE_LIST_ITEM_HINT_VALUE': 2, // Büyük liste öğeleri
            'android.media.browse.CONTENT_STYLE_GRID_ITEM_HINT_VALUE': 2, // 2x2 Grid
            'android.media.extras.CONTENT_STYLE_GROUP_TITLE_HINT': 'Kategoriler',
          },
        );
      }).toList();
      
      print("🚗🚗🚗 Returning ${categories.length} categories to Android Auto");
      return categories;
    }
    
    // Kategori seviyesi - o kategorideki istasyonları döndür
    if (_categoryInfo.containsKey(parentMediaId)) {
      print("🚗🚗🚗 Returning stations for category: $parentMediaId");
      
      final stations = _radioCategories[parentMediaId] ?? [];
      
      if (stations.isEmpty) {
        print("⚠️ Category $parentMediaId is empty, returning placeholder");
        final categoryName = _categoryInfo[parentMediaId]?['title'] ?? 'Bu kategori';
        // Boş kategori için kullanıcı dostu mesaj
        return [
          MediaItem(
            id: 'empty_$parentMediaId',
            title: '📭 Radyo Bulunamadı',
            artist: '$categoryName kategorisinde henüz radyo yok',
            displaySubtitle: 'Diğer kategorilere göz atın',
            artUri: Uri.parse('android.resource://com.turkradyo.adl.de.turkradyo/mipmap/ic_launcher'),
            playable: false,
            extras: {
              'android.media.browse.CONTENT_STYLE_SUPPORTED': true,
              'isEmpty': true,
            },
          )
        ];
      }
      
      print("🚗 Returning ${stations.length} stations");
      return stations.asMap().entries.map((entry) {
        final index = entry.key;
        final station = entry.value;
        
        return MediaItem(
          id: station.id,
          title: station.title,
          artist: '🔴 CANLI  •  ${station.artist ?? 'Radyo'}',
          album: 'Radyo Tüneli',
          genre: station.genre,
          displayTitle: station.title,
          displaySubtitle: station.artist ?? 'Türk Radyosu',
          displayDescription: '🎧 Canlı yayın',
          artUri: station.artUri ?? Uri.parse('android.resource://com.turkradyo.adl.de.turkradyo/mipmap/ic_launcher'),
          playable: true,
          duration: null, // Live stream
          extras: {
            'streamUrl': station.extras?['streamUrl'],
            'isLive': true,
            'android.media.metadata.CONTENT_TYPE': 'audio/mpeg',
            'android.media.browse.CONTENT_STYLE_SUPPORTED': true,
            'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 1,
            'android.media.browse.CONTENT_STYLE_LIST_ITEM_HINT_VALUE': 2, // Büyük liste öğeleri
            'android.media.extras.CONTENT_STYLE_SINGLE_ITEM': false,
            'android.media.extras.CONTENT_STYLE_SUPPORTED': true,
            'com.google.android.gms.car.media.CONTENT_STYLE_QUEUE_POSITION': index,
          },
        );
      }).toList();
    }
    
    print("🚗🚗🚗 Unknown parentMediaId: $parentMediaId, returning empty");
    return [];
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    print("🚗 Android Auto: Playing ${mediaItem.title}");
    
    try {
      final streamUrl = mediaItem.extras?['streamUrl'] as String?;
      
      if (streamUrl == null || streamUrl.isEmpty) {
        print("❌ Android Auto: Stream URL is null or empty for ${mediaItem.title}");
        throw Exception('Stream URL not found for ${mediaItem.title}');
      }
      
      print("🚗 Android Auto: Stream URL: $streamUrl");
      
      await playStation(
        streamUrl,
        mediaItem.title,
        mediaItem.artist ?? 'Radio',
        mediaItem.artUri?.toString(),
        stationId: mediaItem.id, // Use mediaItem.id as station ID
      );
      
      print("✅ Android Auto: Successfully started playing ${mediaItem.title}");
    } catch (e, stackTrace) {
      print("❌ Android Auto: Error playing ${mediaItem.title}: $e");
      print("Stack trace: $stackTrace");
      
      // Set error state
      playbackState.add(PlaybackState(
        controls: [MediaControl.play],
        systemActions: const {
          MediaAction.play,
        },
        androidCompactActionIndices: const [0],
        processingState: AudioProcessingState.error,
        playing: false,
        updatePosition: Duration.zero,
        errorMessage: 'Radyo istasyonu çalınamadı: ${e.toString()}',
      ));
      
      rethrow;
    }
  }

  @override
  Future<List<MediaItem>> search(String query, [Map<String, dynamic>? extras]) async {
    print("🚗 Android Auto: Search query: $query");
    
    // Tüm kategorilerdeki istasyonları tek listede topla
    final allStations = <MediaItem>[];
    for (final stations in _radioCategories.values) {
      allStations.addAll(stations);
    }
    
    // Search in radio station titles, artists and genres
    final results = allStations
        .where((station) => 
            station.title.toLowerCase().contains(query.toLowerCase()) ||
            (station.artist?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (station.genre?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .toList();
    
    return results;
  }

  // CarPlay support
  @override
  Future<void> prepareFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    print("🚗 CarPlay: Preparing media ID: $mediaId");
    
    // Tüm kategorilerdeki istasyonları ara
    MediaItem? foundStation;
    for (final stations in _radioCategories.values) {
      try {
        foundStation = stations.firstWhere((item) => item.id == mediaId);
        break;
      } catch (e) {
        // Continue searching in other categories
      }
    }
    
    if (foundStation != null) {
      // Set the media item but don't start playing yet
      this.mediaItem.add(foundStation);
    }
  }

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    print("🚗 Android Auto: playFromMediaId -> $mediaId");

    // İstasyonu tüm kategorilerde ara
    MediaItem? foundStation;
    for (final stations in _radioCategories.values) {
      try {
        foundStation = stations.firstWhere((item) => item.id == mediaId);
        break;
      } catch (e) {
        // Continue searching in other categories
      }
    }

    if (foundStation != null) {
      final streamUrl = foundStation.extras?['streamUrl'] as String?;
      if (streamUrl != null) {
        print("🚗 Found station: ${foundStation.title} with URL: $streamUrl");
        
        // Set media item first
        mediaItem.add(foundStation);
        print("🚗 MediaItem set for Android Auto");

        // Then start playback
        await playStation(
          streamUrl,
          foundStation.title,
          foundStation.artist ?? 'Radio',
          foundStation.artUri?.toString(),
          stationId: foundStation.id, // Use station ID
        );
        
        print("🚗 playStation completed for $mediaId");
        return;
      }
    }

    // Fallback: hardcoded mapping for some main stations
    final Map<String, String> fallbackUrls = {
      'trt_haber': 'https://nmgvodsgemstts1.mediatriple.net/trt_haber',
      'trt_fm': 'https://nmgvodsgemstts1.mediatriple.net/trt_fm',
      'kral_pop': 'https://kralpop.radyotvonline.com/listen/kralpop/radio.mp3',
      'power_fm': 'https://powerfm.radyotvonline.com/listen/powerfm/radio.mp3',
    };

    final streamUrl = fallbackUrls[mediaId];
    if (streamUrl != null) {
      print("🚗 Using fallback URL for $mediaId: $streamUrl");
      
      // Create MediaItem for the current selection
      final currentItem = MediaItem(
        id: mediaId,
        title: mediaId.replaceAll('_', ' ').toUpperCase(),
        artist: 'Turkish Radio',
        album: 'Live Stream',
        artUri: Uri.parse('android.resource://com.turkradyo.bsr.de.turkradyo/mipmap/ic_launcher'),
        playable: true,
        duration: null, // Live stream
        extras: {
          'streamUrl': streamUrl,
          'isLive': true,
        },
      );

      // Set media item first
      mediaItem.add(currentItem);
      print("🚗 MediaItem set for Android Auto");

      // Then start playback
      await playStation(
        streamUrl,
        currentItem.title,
        currentItem.artist ?? 'Radio',
        currentItem.artUri?.toString(),
        stationId: currentItem.id, // Use station ID
      );
      
      print("🚗 playStation completed for $mediaId");
      return;
    }

    print('❌ playFromMediaId failed: Unknown mediaId $mediaId');
  }

  // Handle custom actions (like volume control)
  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'setVolume':
        if (extras != null && extras.containsKey('volume')) {
          final volume = extras['volume'] as double;
          await _player.setVolume(volume);
          print('🔊 Volume set to: $volume');
        }
        break;
      default:
        print('⚠️ Unknown custom action: $name');
    }
    return super.customAction(name, extras);
  }
}
