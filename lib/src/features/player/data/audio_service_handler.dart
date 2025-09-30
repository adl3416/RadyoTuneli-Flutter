import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../domain/player_state_model.dart';

class RadioAudioHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  final AudioPlayer _player = AudioPlayer();
  
  // Android Auto / CarPlay için kategorize edilmiş radyo istasyonları
  final Map<String, List<MediaItem>> _radioCategories = {
    'haber': [
      MediaItem(
        id: 'trt_haber',
        title: 'TRT Haber',
        artist: 'Haber ve Güncel',
        genre: 'Haber',
        artUri: Uri.parse('https://example.com/trt_haber_logo.png'),
        extras: {'streamUrl': 'https://nmgvodsgemstts1.mediatriple.net/trt_haber', 'category': 'haber'},
      ),
      MediaItem(
        id: 'cnn_turk',
        title: 'CNN Türk Radyo',
        artist: 'Haber ve Güncel',
        genre: 'Haber',
        artUri: Uri.parse('https://example.com/cnn_turk_logo.png'),
        extras: {'streamUrl': 'https://cnnturk.radyotvonline.com/listen/cnnturk/radio.mp3', 'category': 'haber'},
      ),
      MediaItem(
        id: 'ntvradyo',
        title: 'NTV Radyo',
        artist: 'Haber ve Güncel',
        genre: 'Haber',
        artUri: Uri.parse('https://example.com/ntv_logo.png'),
        extras: {'streamUrl': 'https://ntvradyo.radyotvonline.com/listen/ntvradyo/radio.mp3', 'category': 'haber'},
      ),
    ],
    'muzik': [
      MediaItem(
        id: 'trt_fm',
        title: 'TRT FM',
        artist: 'Pop ve Rock',
        genre: 'Müzik',
        artUri: Uri.parse('https://example.com/trt_fm_logo.png'),
        extras: {'streamUrl': 'https://nmgvodsgemstts1.mediatriple.net/trt_fm', 'category': 'muzik'},
      ),
      MediaItem(
        id: 'radyo_viva',
        title: 'Radyo Viva',
        artist: 'Pop Müzik',
        genre: 'Müzik',
        artUri: Uri.parse('https://example.com/viva_logo.png'),
        extras: {'streamUrl': 'https://radyoviva.radyotvonline.com/listen/radyoviva/radio.mp3', 'category': 'muzik'},
      ),
      MediaItem(
        id: 'power_fm',
        title: 'Power FM',
        artist: 'Pop ve Dance',
        genre: 'Müzik',
        artUri: Uri.parse('https://example.com/power_fm_logo.png'),
        extras: {'streamUrl': 'https://powerfm.radyotvonline.com/listen/powerfm/radio.mp3', 'category': 'muzik'},
      ),
    ],
    'turkce_pop': [
      MediaItem(
        id: 'kral_pop',
        title: 'Kral Pop',
        artist: 'Türkçe Pop',
        genre: 'Türkçe Pop',
        artUri: Uri.parse('https://example.com/kral_pop_logo.png'),
        extras: {'streamUrl': 'https://kralpop.radyotvonline.com/listen/kralpop/radio.mp3', 'category': 'turkce_pop'},
      ),
      MediaItem(
        id: 'number1_fm',
        title: 'Number One FM',
        artist: 'Türkçe Pop',
        genre: 'Türkçe Pop',
        artUri: Uri.parse('https://example.com/number1_logo.png'),
        extras: {'streamUrl': 'https://number1fm.radyotvonline.com/listen/number1fm/radio.mp3', 'category': 'turkce_pop'},
      ),
    ],
    'turku': [
      MediaItem(
        id: 'trt_turku',
        title: 'TRT Türkü',
        artist: 'Türk Halk Müziği',
        genre: 'Türkü',
        artUri: Uri.parse('https://example.com/trt_turku_logo.png'),
        extras: {'streamUrl': 'https://nmgvodsgemstts1.mediatriple.net/trt_turku', 'category': 'turku'},
      ),
      MediaItem(
        id: 'turku_radyo',
        title: 'Türkü Radyo',
        artist: 'Türk Halk Müziği',
        genre: 'Türkü',
        artUri: Uri.parse('https://example.com/turku_radyo_logo.png'),
        extras: {'streamUrl': 'https://turkuradyo.radyotvonline.com/listen/turkuradyo/radio.mp3', 'category': 'turku'},
      ),
    ],
    'spor': [
      MediaItem(
        id: 'trt_spor',
        title: 'TRT Spor',
        artist: 'Spor Haberleri',
        genre: 'Spor',
        artUri: Uri.parse('https://example.com/trt_spor_logo.png'),
        extras: {'streamUrl': 'https://nmgvodsgemstts1.mediatriple.net/trt_spor', 'category': 'spor'},
      ),
      MediaItem(
        id: 'spor_fm',
        title: 'Spor FM',
        artist: 'Spor ve Müzik',
        genre: 'Spor',
        artUri: Uri.parse('https://example.com/spor_fm_logo.png'),
        extras: {'streamUrl': 'https://sporfm.radyotvonline.com/listen/sporfm/radio.mp3', 'category': 'spor'},
      ),
    ],
    'dini': [
      MediaItem(
        id: 'diyanet_radyo',
        title: 'Diyanet Radyo',
        artist: 'Dini İçerik',
        genre: 'Dini',
        artUri: Uri.parse('https://example.com/diyanet_logo.png'),
        extras: {'streamUrl': 'https://diyanetradyo.radyotvonline.com/listen/diyanetradyo/radio.mp3', 'category': 'dini'},
      ),
      MediaItem(
        id: 'kuran_radyo',
        title: 'Kuran Radyo',
        artist: 'Kuran-ı Kerim',
        genre: 'Dini',
        artUri: Uri.parse('https://example.com/kuran_logo.png'),
        extras: {'streamUrl': 'https://kuranradyo.radyotvonline.com/listen/kuranradyo/radio.mp3', 'category': 'dini'},
      ),
    ],
    'klasik': [
      MediaItem(
        id: 'trt_radyo3',
        title: 'TRT Radyo 3',
        artist: 'Klasik Müzik',
        genre: 'Klasik',
        artUri: Uri.parse('https://example.com/trt_radyo3_logo.png'),
        extras: {'streamUrl': 'https://nmgvodsgemstts1.mediatriple.net/trt_radyo3', 'category': 'klasik'},
      ),
    ],
  };

  // Kategori isimleri ve açıklamaları
  final Map<String, Map<String, String>> _categoryInfo = {
    'haber': {
      'title': 'Haber ve Güncel',
      'description': 'Güncel haberler ve yorumlar',
      'icon': 'newspaper',
    },
    'muzik': {
      'title': 'Pop ve Rock',
      'description': 'Güncel pop ve rock müzik',
      'icon': 'music_note',
    },
    'turkce_pop': {
      'title': 'Türkçe Pop',
      'description': 'Türkçe pop şarkılar',
      'icon': 'music_note',
    },
    'turku': {
      'title': 'Türkü ve Halk Müziği',
      'description': 'Türk halk müziği ve türküler',
      'icon': 'piano',
    },
    'spor': {
      'title': 'Spor',
      'description': 'Spor haberleri ve yorumları',
      'icon': 'sports_soccer',
    },
    'dini': {
      'title': 'Dini İçerik',
      'description': 'Dini yayınlar ve Kuran-ı Kerim',
      'icon': 'mosque',
    },
    'klasik': {
      'title': 'Klasik Müzik',
      'description': 'Klasik müzik eserleri',
      'icon': 'library_music',
    },
  };

  RadioAudioHandler() {
    _init();
  }

  void _init() {
    print("🎧 Initializing RadioAudioHandler...");

    // Initialize playback state
    playbackState.add(PlaybackState(
      controls: [],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.playPause,
      },
      androidCompactActionIndices: const [0, 1],
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
    } else if (processingState != ProcessingState.completed) {
      controls = [
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
      ];
    }

    playbackState.add(PlaybackState(
      controls: controls,
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.playPause,
      },
      androidCompactActionIndices: const [0, 1],
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
      String streamUrl, String title, String artist, String? artUri) async {
    try {
      print("📻 Setting up radio station: $title");

      // Set media item for system UI first
      final mediaItem = MediaItem(
        id: streamUrl,
        album: 'Turkish Radio',
        title: title,
        artist: artist,
        artUri: artUri != null && artUri.isNotEmpty ? Uri.parse(artUri) : null,
        playable: true,
        duration: Duration.zero, // Radio streams don't have duration
        extras: {
          'isLive': true,
          'streamUrl': streamUrl,
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
        playable: false,
        extras: {'browsable': true},
      );
    }
    
    // Kategoriler için kontrol
    if (_categoryInfo.containsKey(mediaId)) {
      final categoryData = _categoryInfo[mediaId]!;
      return MediaItem(
        id: mediaId,
        title: categoryData['title']!,
        artist: categoryData['description']!,
        playable: false,
        extras: {'browsable': true},
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
    print("🚗 Android Auto: getChildren called with parentMediaId: $parentMediaId");
    
    switch (parentMediaId) {
      case AudioService.browsableRootId:
        // Root level - show categories
        return _categoryInfo.entries.map((entry) {
          final categoryId = entry.key;
          final categoryData = entry.value;
          
          return MediaItem(
            id: categoryId,
            title: categoryData['title']!,
            artist: categoryData['description']!,
            playable: false,
            extras: {
              'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 1,
              'android.media.browse.CONTENT_STYLE_LIST_ITEM_HINT_VALUE': 1,
            },
          );
        }).toList();
        
      // Specific categories
      case 'haber':
      case 'muzik':
      case 'turkce_pop':
      case 'turku':
      case 'spor':
      case 'dini':
      case 'klasik':
        return _radioCategories[parentMediaId] ?? [];
        
      default:
        return [];
    }
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    print("🚗 Android Auto: Playing ${mediaItem.title}");
    
    final streamUrl = mediaItem.extras?['streamUrl'] as String?;
    if (streamUrl != null) {
      await playStation(
        streamUrl,
        mediaItem.title,
        mediaItem.artist ?? 'Radio',
        mediaItem.artUri?.toString(),
      );
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
}
