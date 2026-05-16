import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../domain/player_state_model.dart';

class RadioAudioHandler extends BaseAudioHandler
    with SeekHandler, QueueHandler {
  // Buffer ayarları: live radio için hızlı başlatmayı önceliklendiren küçük buffer
  // Default ExoPlayer 2.5s buffer bekler → bunu 800ms'e indiriyoruz
  final AudioPlayer _player = AudioPlayer(
    audioLoadConfiguration: AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: const Duration(seconds: 5),
        maxBufferDuration: const Duration(seconds: 20),
        // ExoPlayer bu kadar buffer dolunca oynatmaya başlar (default ~2.5s → 800ms)
        bufferForPlaybackDuration: const Duration(milliseconds: 800),
        bufferForPlaybackAfterRebufferDuration: const Duration(seconds: 3),
        prioritizeTimeOverSizeThresholds: true,
      ),
      darwinLoadControl: DarwinLoadControl(
        preferredForwardBufferDuration: const Duration(seconds: 5),
        // iOS'ta minimum buffer dolunca başla, stallinge kadar bekleme
        automaticallyWaitsToMinimizeStalling: false,
      ),
    ),
  );
  
  // Audio focus management
  bool _wasPlayingBeforeInterruption = false;
  StreamSubscription? _interruptionSub;
  StreamSubscription? _becomingNoisySub;

  // Duplicate broadcast önleme
  bool? _lastPlaying;
  ProcessingState? _lastProcessingState;

  // Kullanıcı pause yaptığında true - idle state'in servisi kapatmasını engeller
  bool _userPaused = false;
  
  // Dinamik radyo kategorileri - uygulama çalışırken doldurulacak
  Map<String, List<MediaItem>> _radioCategories = {};
  
  // Favori radyo ID'leri
  Set<String> _favoriteIds = {};
  
  // Son dinlenen radyolar (maksimum 20)
  List<MediaItem> _recentlyPlayed = [];

  // Android Auto güzel arka plan resmi cache
  String? _cachedDefaultArtworkPath;

  // İstasyon logolarını yerel dosyaya indirme cache'i (http → file:// dönüşümü için)
  // Android Auto http:// URL'lerden resim yükleyemiyor, yerel dosya gerekiyor
  final Map<String, String> _logoFileCache = {}; // url -> local file path
  final Map<String, String> _assetLogoFileCache = {}; // asset path -> local file path
  final Set<String> _pendingLogoDownloads = {}; // indirilmekte olan URL'ler
  final Map<String, String> _letterAvatarCache = {}; // harf → yerel dosya yolu (A-Z + #)

  // Android Auto browse sonuçları cache - her seferinde yeniden oluşturmayı önler
  // Key: categoryId, Value: (favoritesSnapshot, result)
  final Map<String, _BrowseCacheEntry> _browseCache = {};

  // Mevcut istasyon bilgisi - play() butonundan yeniden başlatmak için
  String? _currentStreamUrl;
  String? _currentTitle;
  String? _currentArtist;
  String? _currentArtUri;
  String? _currentStationId;

  // Eş zamanlı playStation çağrılarını iptal etmek için sayaç
  // Yeni bir istek geldiğinde artırılır; eski istekler ID eşleşmeyince durur
  int _playRequestId = 0;

  // Kategori isimleri ve açıklamaları (modern Android Auto tasarımı için)
  // ÖNEMLİ: Map sırası = Android Auto tab sırası. İlk 3 tab görünür, geri kalanı "Diğer"e düşer.
  final Map<String, Map<String, String>> _categoryInfo = {
    'tum_radyolar': {
      'title': '📻 Tüm Radyolar',
      'description': 'Tüm radyo kanalları',
      'icon': 'radio',
    },
    'favoriler': {
      'title': '❤️ Favoriler',
      'description': 'Favori radyolarınız',
      'icon': 'favorite',
    },
    'son_dinlenenler': {
      'title': '🕐 Son Dinlenenler',
      'description': 'Yakın zamanda dinlediğiniz radyolar',
      'icon': 'history',
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
    'populer': {
      'title': '⭐ Popüler',
      'description': 'En çok dinlenen 50 radyo',
      'icon': 'star',
    },
  };

  RadioAudioHandler() {
    print("🚗🚗🚗 ANDROID AUTO: RadioAudioHandler CONSTRUCTOR called");
    _init();
    _setupAndroidAutoSupport();
    _loadFavorites();
  }

  void _setupAndroidAutoSupport() {
    // MediaBrowserService Android Auto discovery için hazır
  }

  // Favorileri SharedPreferences'dan yükle
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorite_stations') ?? [];
      _favoriteIds = favorites.toSet();
      print("❤️ Loaded ${_favoriteIds.length} favorites for Android Auto");
      
      // Favoriler kategorisini güncelle
      _updateFavoritesCategory();
    } catch (e) {
      print('❌ Error loading favorites: $e');
      _favoriteIds = <String>{};
    }
  }

  // Favoriler kategorisini güncelle
  void _updateFavoritesCategory() {
    if (_radioCategories.isEmpty) return;
    
    // Tüm radyolardan favorileri filtrele
    final favoriteStations = <MediaItem>[];
    
    for (var categoryStations in _radioCategories.values) {
      for (var station in categoryStations) {
        if (_favoriteIds.contains(station.id)) {
          // Favori işareti ekle
          final updatedStation = station.copyWith(
            artist: '❤️ ${station.artist}',
            extras: {
              ...?station.extras,
              'isFavorite': true,
            },
          );
          favoriteStations.add(updatedStation);
        }
      }
    }
    
    _radioCategories['favoriler'] = favoriteStations;
    print("❤️ Updated favorites category with ${favoriteStations.length} stations");
  }

  // Son dinlenenleri SharedPreferences'dan yükle
  Future<void> _loadRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentIds = prefs.getStringList('recently_played_stations') ?? [];
      
      // Son dinlenen ID'leri kullanarak MediaItem'ları bul
      _recentlyPlayed.clear();
      for (var stationId in recentIds.take(20)) {
        // Tüm kategorilerde radyoyu ara
        for (var categoryStations in _radioCategories.values) {
          final station = categoryStations.firstWhere(
            (s) => s.id == stationId,
            orElse: () => MediaItem(id: '', title: ''),
          );
          if (station.id.isNotEmpty && !_recentlyPlayed.any((s) => s.id == station.id)) {
            _recentlyPlayed.add(station);
            break;
          }
        }
      }
      
      print("🕐 Loaded ${_recentlyPlayed.length} recently played stations");
      _radioCategories['son_dinlenenler'] = _recentlyPlayed;
    } catch (e) {
      print('❌ Error loading recently played: $e');
      _recentlyPlayed = [];
    }
  }

  // Son dinlenenlere ekle
  Future<void> _addToRecentlyPlayed(MediaItem station) async {
    try {
      // Aynı radyo varsa önce çıkar (en üste gelsin)
      _recentlyPlayed.removeWhere((s) => s.id == station.id);
      
      // Başa ekle
      _recentlyPlayed.insert(0, station);
      
      // Maksimum 20 radyo tut
      if (_recentlyPlayed.length > 20) {
        _recentlyPlayed = _recentlyPlayed.take(20).toList();
      }
      
      // SharedPreferences'a kaydet
      final prefs = await SharedPreferences.getInstance();
      final recentIds = _recentlyPlayed.map((s) => s.id).toList();
      await prefs.setStringList('recently_played_stations', recentIds);
      
      // Kategoriyi güncelle
      _radioCategories['son_dinlenenler'] = _recentlyPlayed;
      
      print("🕐 Added to recently played: ${station.title} (Total: ${_recentlyPlayed.length})");
      
    } catch (e) {
      print('❌ Error adding to recently played: $e');
    }
  }

  // Favoriye ekle/çıkar
  Future<void> toggleFavorite(String stationId) async {
    try {
      if (_favoriteIds.contains(stationId)) {
        _favoriteIds.remove(stationId);
        print("💔 Removed from favorites: $stationId");
      } else {
        _favoriteIds.add(stationId);
        print("❤️ Added to favorites: $stationId");
      }
      
      // Browse cache'i temizle - favoriler değişti
      _browseCache.clear();
      
      // SharedPreferences'a kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_stations', _favoriteIds.toList());
      
      // Favoriler kategorisini güncelle
      _updateFavoritesCategory();
      
    } catch (e) {
      print('❌ Error toggling favorite: $e');
    }
  }

  // Kategori cache'sini JSON asset'inden yükle (Android Auto soğuk başlatma için)
  Future<void> _initializeDefaultCategories() async {
    if (_radioCategories.isNotEmpty) return;
    print("⚠️ Categories empty — JSON asset'ten yükleniyor...");
    try {
      final String jsonString = await rootBundle.loadString('assets/data/TR.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      await loadRadioStations(jsonList);
      print("✅ JSON asset'ten ${jsonList.length} istasyon yüklendi (Android Auto soğuk başlatma)");
    } catch (e) {
      print('❌ JSON asset yüklenemedi: $e');
    }
  }

  // Radyo listesini dışarıdan yükle (player_provider tarafından çağrılır)
  Future<void> loadRadioStations(List<dynamic> stations) async {
    print("🚗 Loading ${stations.length} stations for Android Auto");
    
    // Browse cache'i temizle - yeni veri geliyor
    _browseCache.clear();
    
    // Kategorilere göre radyoları ayır
    _radioCategories.clear();
    
    // Tüm radyoları işle (maksimum 500 radyo), alfabetik sırala
    final allStations = List<dynamic>.from(stations)
      ..sort((a, b) {
        final nameA = (a['name'] ?? '').toString().toUpperCase();
        final nameB = (b['name'] ?? '').toString().toUpperCase();
        return nameA.compareTo(nameB);
      });
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
      
      Uri? stationArtUri;
      final faviconStr = favicon.toString();
      if (faviconStr.isNotEmpty) {
        if (faviconStr.startsWith('assets/')) {
          final localAssetLogoPath = await _cacheAssetLogoToFile(faviconStr);
          stationArtUri = localAssetLogoPath != null
              ? Uri.file(localAssetLogoPath)
              : Uri.tryParse(faviconStr);
        } else {
          stationArtUri = Uri.tryParse(faviconStr);
        }
      }

      final mediaItem = MediaItem(
        id: stationId,
        title: name,
        artist: genre,
        genre: genre,
        artUri: stationArtUri,
        playable: true,
        extras: {
          'streamUrl': streamUrl,
          'category': category,
          'isLive': true,
          'logoUrl': faviconStr,
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
    
    // Favoriler kategorisini güncelle
    _updateFavoritesCategory();
    
    // Son dinlenenleri yükle
    await _loadRecentlyPlayed();
    
    print("🚗 Loaded ${allMediaItems.length} stations into ${_radioCategories.length} categories");
    _radioCategories.forEach((key, value) {
      print("  - $key: ${value.length} stations");
    });
  }

  void _init() {
    print("🎧 Initializing RadioAudioHandler...");
    print("🚗🚗🚗 ANDROID AUTO: _init() method called");

    // Configure audio session for proper focus handling
    _configureAudioSession();

    // Initialize playback state
    playbackState.add(PlaybackState(
      controls: [MediaControl.play, MediaControl.stop],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.playPause,
        MediaAction.setRating, // Android Auto kalp/favori butonu
      },
      androidCompactActionIndices: const [0, 1],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));

    // Listen to audio player state changes
    _player.playerStateStream.listen((playerState) {
      // Aynı durum tekrar gelirse broadcast etme (canlı stream spam'ini önler)
      if (playerState.playing == _lastPlaying &&
          playerState.processingState == _lastProcessingState) {
        return;
      }
      _lastPlaying = playerState.playing;
      _lastProcessingState = playerState.processingState;

      print(
          "🔊 Player state changed: playing=${playerState.playing}, processing=${playerState.processingState}");

      // Kullanıcı pause yaptıysa idle state'i yok say - pause() zaten paused state set etti
      if (_userPaused && playerState.processingState == ProcessingState.idle) {
        return;
      }

      _broadcastState(playerState);

      // If stopped (by user stop, not pause), clear notification
      if (playerState.processingState == ProcessingState.idle && !playerState.playing) {
        mediaItem.add(null);
      }
    });
    // Not: Canlı yayın için positionStream dinlemiyoruz (süre=0, gereksiz spam yaratır)

    // Artwork'ü arka planda önceden yükle - ilk play hızlı olsun
    _getDefaultArtUri().then((_) => print('🎨 Default artwork pre-warmed'));
    // Android Auto browse listesi için harf avatarlarını arka planda oluştur
    _preWarmLetterAvatars().ignore();

    print("✅ RadioAudioHandler initialized");
  }

  /// Configures the audio session for proper audio focus management.
  /// - Ducks (lowers volume) for transient interruptions (notifications, navigation)
  /// - Pauses for permanent interruptions (phone calls, other media apps)
  /// - Resumes playback when interruption ends
  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ));

      // Handle audio interruptions (calls, notifications, navigation, etc.)
      _interruptionSub?.cancel();
      _interruptionSub = session.interruptionEventStream.listen((event) {
        print("🔔 Audio interruption: begin=${event.begin}, type=${event.type}");
        if (event.begin) {
          // Interruption started
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Transient interruption (notification, nav instruction)
              // just_audio handles ducking automatically on Android
              // On iOS we lower volume manually
              _player.setVolume(0.2);
              print("🔉 Volume ducked for transient interruption");
              break;
            case AudioInterruptionType.pause:
              // Another app needs exclusive audio (phone call, etc.)
              _wasPlayingBeforeInterruption = _player.playing;
              if (_wasPlayingBeforeInterruption) {
                _player.pause();
                print("⏸️ Paused for audio interruption");
              }
              break;
            case AudioInterruptionType.unknown:
              _wasPlayingBeforeInterruption = _player.playing;
              if (_wasPlayingBeforeInterruption) {
                _player.pause();
                print("⏸️ Paused for unknown interruption");
              }
              break;
          }
        } else {
          // Interruption ended
          switch (event.type) {
            case AudioInterruptionType.duck:
              // Restore volume
              _player.setVolume(1.0);
              print("🔊 Volume restored after duck");
              break;
            case AudioInterruptionType.pause:
              // Resume if we were playing before
              if (_wasPlayingBeforeInterruption) {
                _player.play();
                print("▶️ Resumed after interruption ended");
              }
              break;
            case AudioInterruptionType.unknown:
              if (_wasPlayingBeforeInterruption) {
                _player.play();
                print("▶️ Resumed after unknown interruption ended");
              }
              break;
          }
        }
      });

      // Handle becoming noisy (headphones unplugged)
      _becomingNoisySub?.cancel();
      _becomingNoisySub = session.becomingNoisyEventStream.listen((_) {
        print("🔇 Becoming noisy (headphones unplugged) - pausing");
        // _player.pause() değil! Küpeyi takúnınca state yönetimi bozulur.
        // Kendi pause() metodumuzu çağır ki _userPaused ve bildirim doğru ayarlansın.
        pause();
      });

      print("✅ Audio session configured for focus management");
    } catch (e) {
      print("⚠️ Audio session configuration failed: $e");
    }
  }

  void _broadcastState(PlayerState playerState) {
    final isPlaying = playerState.playing;
    final processingState = playerState.processingState;

    print("📡 _broadcastState: playing=$isPlaying, processing=$processingState");

    // Favori durumuna göre kalp ikonu seç
    final isFavorite = _currentStationId != null && _favoriteIds.contains(_currentStationId);
    final heartControl = MediaControl(
      androidIcon: isFavorite ? 'drawable/ic_favorite' : 'drawable/ic_favorite_border',
      label: isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
      action: MediaAction.setRating,
    );

    List<MediaControl> controls;

    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      controls = [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        heartControl,
        MediaControl.skipToNext,
      ];
    } else if (isPlaying) {
      controls = [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        heartControl,
        MediaControl.skipToNext,
      ];
    } else {
      controls = [
        MediaControl.skipToPrevious,
        MediaControl.play,
        heartControl,
        MediaControl.skipToNext,
      ];
    }

    playbackState.add(PlaybackState(
      controls: controls,
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.playPause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.setRating,
      },
      androidCompactActionIndices: const [1, 2, 3], // Android Auto & bildirim: play/pause, kalp, next
      processingState: {
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
      print("▶️ play() CALLED - state: ${_player.processingState}, playing: ${_player.playing}");
      _userPaused = false; // Artık pause değil, çalıyor
      // Canlı radyo stream'leri için her zaman yeniden bağlan (pause sonrası bile)
      // Çünkü live stream'lerde pause sonrası buffer kaybolur
      if (_currentStreamUrl != null) {
        print("▶️ Restarting live stream: $_currentStreamUrl");
        await playStation(
          _currentStreamUrl!,
          _currentTitle ?? '',
          _currentArtist ?? '',
          _currentArtUri,
          stationId: _currentStationId,
        );
        return;
      }
      await _player.play();
      print("▶️ play() COMPLETED");
    } catch (e) {
      print('❌ Error playing audio: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      print("⏸️ pause() CALLED");
      _userPaused = true;
      await _player.stop(); // Canlı stream buffer'ını temizle
      // Bildirim'i yaşatmak için paused state yayınla (idle değil!)
      // Idle yayınlanırsa Android servisi öldürür ve radyo tamamen kapanır
      final isFavPause = _currentStationId != null && _favoriteIds.contains(_currentStationId);
      final heartControlPause = MediaControl(
        androidIcon: isFavPause ? 'drawable/ic_favorite' : 'drawable/ic_favorite_border',
        label: isFavPause ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
        action: MediaAction.setRating,
      );
      playbackState.add(PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          heartControlPause,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.play,
          MediaAction.stop,
          MediaAction.playPause,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.setRating,
        },
        androidCompactActionIndices: const [1, 2, 3], // Android Auto & bildirim: play, kalp, next
        processingState: AudioProcessingState.ready,
        playing: false,
      ));
      print("⏸️ pause() COMPLETED - stream durduruldu, bildirim aktif kaldı");
    } catch (e) {
      print('❌ Error pausing audio: $e');
      _userPaused = false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      print("⏹️ stop() CALLED - Stopping playback...");
      _userPaused = false; // Explicit stop - servisi tamamen durdur
      await _player.stop();
      
      // Bildirimin tamamen kapanması için mediaItem'ı temizle
      mediaItem.add(null);
      
      // State'i tamamen durdurulmuş olarak ayarla ve bildirim kontrollerini kaldır
      playbackState.add(PlaybackState(
        controls: [],
        systemActions: const {},
        androidCompactActionIndices: const [],
        processingState: AudioProcessingState.idle,
        playing: false,
        updatePosition: Duration.zero,
      ));
      
      // audio_service backend'ine stop çağrısını ilet ki OS servisi kapatsın
      await super.stop();
      
      print("⏹️ stop() COMPLETED");
    } catch (e) {
      print('❌ Error stopping audio: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    final stations = _radioCategories['tum_radyolar'] ?? [];
    if (stations.isEmpty || _currentStationId == null) return;
    final idx = stations.indexWhere((s) => s.id == _currentStationId);
    final nextIdx = (idx + 1) % stations.length;
    final next = stations[nextIdx];
    final streamUrl = next.extras?['streamUrl'] as String?;
    if (streamUrl == null || streamUrl.isEmpty) return;
    print('⏭️ skipToNext → ${next.title}');
    await playStation(streamUrl, next.title, next.artist ?? '', next.artUri?.toString(), stationId: next.id);
  }

  @override
  Future<void> skipToPrevious() async {
    final stations = _radioCategories['tum_radyolar'] ?? [];
    if (stations.isEmpty || _currentStationId == null) return;
    final idx = stations.indexWhere((s) => s.id == _currentStationId);
    final prevIdx = (idx - 1 + stations.length) % stations.length;
    final prev = stations[prevIdx];
    final streamUrl = prev.extras?['streamUrl'] as String?;
    if (streamUrl == null || streamUrl.isEmpty) return;
    print('⏮️ skipToPrevious → ${prev.title}');
    await playStation(streamUrl, prev.title, prev.artist ?? '', prev.artUri?.toString(), stationId: prev.id);
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    print("🔘 click() CALLED with button: $button");
    switch (button) {
      case MediaButton.media:
        if (_player.playing) {
          await pause();
        } else {
          await play();
        }
        break;
      case MediaButton.next:
        await skipToNext();
        break;
      case MediaButton.previous:
        await skipToPrevious();
        break;
    }
  }

  /// Android Auto kalp/favori butonu — BaseAudioHandler.setRating() no-op olduğu için doğrudan override.
  @override
  Future<void> setRating(Rating rating, [Map<String, dynamic>? extras]) async {
    print('⭐ setRating called: $rating');
    final currentStation = mediaItem.value;
    if (currentStation != null) {
      await toggleFavorite(currentStation.id);
      final isFavorite = _favoriteIds.contains(currentStation.id);
      final currentArtist = currentStation.artist ?? '';
      final updatedMediaItem = currentStation.copyWith(
        rating: Rating.newHeartRating(isFavorite),
        artist: isFavorite
            ? (currentArtist.startsWith('❤️') ? currentArtist : '❤️ $currentArtist')
            : currentArtist.replaceFirst('❤️ ', ''),
      );
      this.mediaItem.add(updatedMediaItem);
      _broadcastState(_player.playerState);
      print('❤️ Favorite toggled for \${currentStation.title}: \$isFavorite');
    }
  }

  // Android Auto favorileme desteği (Rating API) - eski compat
  @override
  Future<void> onSetRating(Rating rating, Map<String, dynamic>? extras) async {
    print('⭐ onSetRating called with rating: $rating');
    
    final currentStation = mediaItem.value;
    if (currentStation != null) {
      await toggleFavorite(currentStation.id);
      final isFavorite = _favoriteIds.contains(currentStation.id);
      
      // MediaItem'ı güncelle - rating değişti
      final updatedMediaItem = currentStation.copyWith(
        rating: Rating.newHeartRating(isFavorite),
        artist: isFavorite ? '❤️ ${currentStation.artist}' : currentStation.artist?.replaceFirst('❤️ ', ''),
      );
      
      this.mediaItem.add(updatedMediaItem);

      // Kalp ikonu anlık güncellenmesi için playbackState'i yenile
      _broadcastState(_player.playerState);

      print('❤️ Rating updated for ${currentStation.title}: $isFavorite');
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
    // Bu isteğe özgü ID al — yeni istek gelirse bu ID geçersiz kalır
    final myId = ++_playRequestId;
    print("📻 playStation[$myId] başladı: $title");

    // Mevcut oynatmayı hemen durdur ki ses kesilsin
    try { await _player.stop(); } catch (_) {}

    // Daha yeni bir istek geldiyse iptal et
    if (myId != _playRequestId) {
      print("🚫 playStation[$myId] iptal edildi (daha yeni istek var): $title");
      return;
    }

    try {
      print("📻 Setting up radio station: $title (ID: ${stationId ?? 'none'})");

      // Favori durumunu kontrol et
      final isFavorite = stationId != null && _favoriteIds.contains(stationId);
      
      // Set media item for system UI - Modern Android Auto tasarımı
      // initial:// ve assets:// şeması ile boş/null URI'lar için güzel arka plan kullan
      // Not: Asset path'leri (assets/logos/...) sistem bildirimleri için kullanılamaz
      final bool hasValidArt = artUri != null &&
          artUri.isNotEmpty &&
          !artUri.startsWith('initial://') &&
          !artUri.startsWith('assets/') &&
          (artUri.startsWith('http://') || artUri.startsWith('https://') || artUri.startsWith('file://'));

      // Artwork'ü BEKLEMEDEN başla - hemen launcher icon veya cache kullan, logo arka planda indirilir
      // Android Auto http:// URL'lerden resim yükleyemiyor → yerel dosya cache kullanıyoruz
      final Uri artUriParsed;
      final String? capturedArtUri = hasValidArt ? artUri : null;
      final capturedStationId = stationId;

      if (hasValidArt && _logoFileCache.containsKey(artUri)) {
        // Logo zaten local cache'de → direkt kullan, bekleme yok
        artUriParsed = Uri.file(_logoFileCache[artUri!]!);
        print('🖼️ Using cached logo for $title');
      } else if (_cachedDefaultArtworkPath != null) {
        // Pre-warmed default artwork var → hemen kullan, logo arka planda indirilir
        artUriParsed = Uri.file(_cachedDefaultArtworkPath!);
      } else {
        // Hiçbir şey yok → launcher icon ile başla
        artUriParsed = Uri.parse('android.resource://com.turkradyo.bsr.de.turkradyo/mipmap/ic_launcher');
      }

      if (myId != _playRequestId) {
        print("🚫 playStation[$myId] iptal edildi (artUri sonrası): $title");
        return;
      }

      final newMediaItem = MediaItem(
        id: stationId ?? streamUrl,
        title: title,
        artist: isFavorite ? '❤️ $artist' : artist,
        album: 'Radyo Tüneli',
        displayTitle: title,
        displaySubtitle: '🔴 CANLI YAYIN',
        displayDescription: artist,
        artUri: artUriParsed,
        playable: true,
        duration: Duration.zero, // Radio streams don't have duration
        rating: Rating.newHeartRating(isFavorite), // Favori durumuna göre
        extras: {
          'isLive': true,
          'streamUrl': streamUrl,
          'stationId': stationId,
          'logoUrl': artUri ?? '', // Orijinal logo URL'si (asset path veya http)
          // Android Auto için ek metadata
          'android.media.metadata.CONTENT_TYPE': 'audio/mpeg',
          'android.media.metadata.ADVERTISEMENT': 0, // Reklam değil
          'android.media.metadata.DOWNLOAD_STATUS': 0, // İndirilebilir değil (canlı yayın)
        },
      );

      // Mevcut istasyon bilgisini kaydet (play() butonundan yeniden başlatmak için)
      _currentStreamUrl = streamUrl;
      _currentTitle = title;
      _currentArtist = artist;
      _currentArtUri = artUri;
      _currentStationId = stationId;

      // Update media item
      mediaItem.add(newMediaItem);

      // Arka planda logo indir (http → local file, Android Auto için gerekli)
      if (capturedArtUri != null && !_logoFileCache.containsKey(capturedArtUri)) {
        _downloadLogoAndUpdate(capturedArtUri, capturedStationId ?? '').ignore();
      } else if (capturedArtUri == null && _cachedDefaultArtworkPath == null) {
        // Logo yok ve default artwork henüz oluşturulmamış → arka planda oluştur
        _getDefaultArtUri().then((uri) {
          if (_currentStationId == capturedStationId) {
            final current = mediaItem.value;
            if (current != null) {
              mediaItem.add(current.copyWith(artUri: uri));
            }
          }
        });
      }
      
      // Son dinlenenlere ekle — arka planda yap, audio başlatmayı beklemesin
      _addToRecentlyPlayed(newMediaItem).ignore();

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

      // Try to set the audio source. Some radio streams (Shoutcast/Icecast)
      // require specific headers (User-Agent, Icy-MetaData) or reject default
      // player requests; on failure we retry with common headers.
      try {
        // 8 saniye timeout: yanıt vermeyen stream'lerde takılı kalmayı önler
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.parse(streamUrl),
            tag: newMediaItem,
          ),
        ).timeout(const Duration(seconds: 8));
        print("🎵 Audio source set (default), starting playback...");
      } catch (e) {
        // Yeni bir istek geldiyse retry yapma — zaten iptal edildi
        if (myId != _playRequestId) {
          print("🚫 playStation[$myId] iptal edildi (setAudioSource catch, retry öncesi): $title");
          return;
        }
        print('⚠️ setAudioSource failed (default): $e');
        print('ℹ️ Retrying setAudioSource with headers (User-Agent + Icy-MetaData)');
        try {
          await _player.setAudioSource(
            AudioSource.uri(
              Uri.parse(streamUrl),
              tag: newMediaItem,
              // Bazı Shoutcast/Icecast sunucuları bu header'ları gerektirir
              headers: {
                'Icy-MetaData': '1',
                'User-Agent': 'Mozilla/5.0 (Android)',
              },
            ),
          ).timeout(const Duration(seconds: 8));
          print("🎵 Audio source set (with headers), starting playback...");
        } catch (e2) {
          if (myId != _playRequestId) {
            print("🚫 playStation[$myId] iptal edildi (header retry sonrası): $title");
            return;
          }
          print('❌ Retry setAudioSource with headers also failed: $e2');
          rethrow;
        }
      }

      // setAudioSource tamamlandı — yeni bir istek geldiyse oynatma
      if (myId != _playRequestId) {
        print("🚫 playStation[$myId] iptal edildi (setAudioSource sonrası): $title");
        return;
      }

      // Start playing
      await _player.play();

      print("✅ Radio station started successfully");
    } catch (e) {
      // İptal edildiyse hata gösterme — yeni istasyon zaten çalınıyor
      if (myId != _playRequestId) {
        print("🚫 playStation[$myId] iptal edildi (catch bloğu): $title");
        return;
      }
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
    print("🗑️ Notification swiped away - stopping playback");
    await stop();
  }

  void disposePlayer() {
    print("🔄 Disposing audio player...");
    _player.dispose();
  }

  /// İki Set'in eşit olup olmadığını kontrol eder (browse cache invalidation için)
  bool _setsEqual(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
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
        artUri: Uri.parse('android.resource://com.turkradyo.bsr.de.turkradyo/mipmap/ic_launcher'),
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
        artUri: Uri.parse('android.resource://com.turkradyo.bsr.de.turkradyo/mipmap/ic_launcher'),
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
      
      // Eğer kategoriler boşsa → JSON asset'ten gerçek istasyonları yükle
      if (_radioCategories.isEmpty) {
        await _initializeDefaultCategories();
      }
      
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
          artUri: Uri.parse('android.resource://com.turkradyo.bsr.de.turkradyo/mipmap/ic_launcher'),
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

      final allStations = _radioCategories[parentMediaId] ?? [];
      
      // Android Auto pagination desteği
      // options null ise tüm listeyi döndür (eski Android Auto sürümleri)
      // options varsa sayfalama uygula
      final List<MediaItem> stations;
      if (options != null) {
        final page = (options['android.media.extra.PAGE'] as int?) ?? 0;
        final pageSize = (options['android.media.extra.PAGE_SIZE'] as int?) ?? 50;
        final start = page * pageSize;
        if (start >= allStations.length) {
          stations = [];
        } else {
          final end = (start + pageSize).clamp(0, allStations.length);
          stations = allStations.sublist(start, end);
        }
        print("🚗 Pagination: page=$page, pageSize=$pageSize, total=${allStations.length}, showing ${stations.length}");
      } else {
        // Pagination olmadan maksimum 200 istasyon döndür (Android Auto limiti)
        stations = allStations.length > 200 ? allStations.sublist(0, 200) : allStations;
        print("🚗 No pagination options, returning ${stations.length}/${allStations.length} stations");
      }

      if (stations.isEmpty) {
        print("⚠️ Category $parentMediaId is empty, returning placeholder");
        final categoryName = _categoryInfo[parentMediaId]?['title'] ?? 'Bu kategori';

        // Favoriler kategorisi: istasyonlar henüz yüklenmediyse ama favoriler varsa bilgilendir.
        if (parentMediaId == 'favoriler') {
          if (_favoriteIds.isEmpty) {
            return [
              MediaItem(
                id: 'empty_favoriler',
                title: '❤️ Favori Yok',
                artist: 'Uygulamada radyo favorileyin',
                displaySubtitle: 'Diğer kategorilere göz atın',
                artUri: Uri.parse('android.resource://com.turkradyo.bsr.de.turkradyo/mipmap/ic_launcher'),
                playable: false,
                extras: {'isEmpty': true},
              )
            ];
          } else {
            // İstasyon verisi hazır değil — kullanıcıyı yönlendir.
            return [
              MediaItem(
                id: 'favorites_loading',
                title: '⏳ Yükleniyor…',
                artist: 'Lütfen uygulamayı açın, ardından geri dönün',
                artUri: Uri.parse('android.resource://com.turkradyo.bsr.de.turkradyo/mipmap/ic_launcher'),
                playable: false,
                extras: {'isEmpty': true},
              )
            ];
          }
        }

        // Boş kategori için genel kullanıcı dostu mesaj
        return [
          MediaItem(
            id: 'empty_$parentMediaId',
            title: '📭 Radyo Bulunamadı',
            artist: '$categoryName kategorisinde henüz radyo yok',
            displaySubtitle: 'Diğer kategorilere göz atın',
            artUri: Uri.parse('android.resource://com.turkradyo.bsr.de.turkradyo/mipmap/ic_launcher'),
            playable: false,
            extras: {
              'android.media.browse.CONTENT_STYLE_SUPPORTED': true,
              'isEmpty': true,
            },
          )
        ];
      }
      
      print("🚗 Returning ${stations.length} stations");

      // Browse cache kontrolü - favoriler değişmediyse cache'den döndür
      final cacheKey = '${parentMediaId}_${stations.length}';
      final cached = _browseCache[cacheKey];
      if (cached != null && _setsEqual(cached.favoritesSnapshot, _favoriteIds)) {
        print("🚗 Browse cache hit for $parentMediaId (${cached.items.length} items)");
        return cached.items;
      }

      final result = stations.asMap().entries.map((entry) {
        final index = entry.key;
        final station = entry.value;
        final isFav = _favoriteIds.contains(station.id);
        
        return MediaItem(
          id: station.id,
          title: station.title,
          artist: isFav 
              ? '❤️ CANLI  •  ${station.artist ?? 'Radyo'}' 
              : '🔴 CANLI  •  ${station.artist ?? 'Radyo'}',
          album: 'Radyo Tüneli',
          genre: station.genre,
          displayTitle: station.title,
          displaySubtitle: station.artist ?? 'Türk Radyosu',
          displayDescription: isFav ? '❤️ Favori  •  🎧 Canlı yayın' : '🎧 Canlı yayın',
          artUri: _getLocalArtUriForBrowse(station),
          playable: true,
          duration: null, // Live stream
          extras: {
            'streamUrl': station.extras?['streamUrl'],
            'isLive': true,
            'isFavorite': isFav,
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

      // Cache'e kaydet
      _browseCache[cacheKey] = _BrowseCacheEntry(Set.from(_favoriteIds), result);
      return result;
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

    // Kategoriler boşsa önce yükle (soğuk başlatma durumu)
    if (_radioCategories.isEmpty) {
      await _initializeDefaultCategories();
    }

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
    print('🎬 Custom action called: $name with extras: $extras');
    
    switch (name) {
      case 'setVolume':
        if (extras != null && extras.containsKey('volume')) {
          final volume = extras['volume'] as double;
          await _player.setVolume(volume);
          print('🔊 Volume set to: $volume');
        }
        break;
      case 'toggleFavorite':
        // Şu anda çalan radyonun ID'sini al
        final currentStation = mediaItem.value;
        if (currentStation != null) {
          await toggleFavorite(currentStation.id);
          final isFavorite = _favoriteIds.contains(currentStation.id);
          print('❤️ Favorite toggled for ${currentStation.title}: $isFavorite');
          
          // Durumu güncelle (favori butonu yenilenir)
          _broadcastState(_player.playerState);
          
          return {'isFavorite': isFavorite, 'stationId': currentStation.id};
        } else {
          print('⚠️ No station currently playing');
        }
        break;
      default:
        print('⚠️ Unknown custom action: $name');
    }
    return super.customAction(name, extras);
  }

  // Android Auto arama callback metodu
  // audio_service 0.18.x'de onSearch yok; arama Android Auto tarafından
  // doğrudan search() metoduna yönlendirilir.
  @override
  Future<void> onSearch(String query, [Map<String, dynamic>? extras]) async {
    print("🔍🔍🔍 onSearch CALLED with query: '$query'");
    // Framework otomatik olarak search() metodunu çağırır.
  }

  // Android Auto arama desteği
  @override
  Future<List<MediaItem>> search(String query, [Map<String, dynamic>? extras]) async {
    print("🔍 Android Auto: Searching for '$query'");
    
    if (query.isEmpty) {
      return [];
    }
    
    final searchResults = <MediaItem>[];
    final lowerQuery = query.toLowerCase();
    
    // Tüm radyolarda ara
    for (var categoryStations in _radioCategories.values) {
      for (var station in categoryStations) {
        final matchesTitle = station.title.toLowerCase().contains(lowerQuery);
        final matchesArtist = station.artist?.toLowerCase().contains(lowerQuery) ?? false;
        final matchesGenre = station.genre?.toLowerCase().contains(lowerQuery) ?? false;
        
        if (matchesTitle || matchesArtist || matchesGenre) {
          // Tekrar eklenmesini önle
          if (!searchResults.any((s) => s.id == station.id)) {
            // Favori durumunu ekle
            final isFavorite = _favoriteIds.contains(station.id);
            final updatedStation = station.copyWith(
              artist: isFavorite ? '❤️ ${station.artist}' : station.artist,
              extras: {
                ...?station.extras,
                'isFavorite': isFavorite,
              },
            );
            searchResults.add(updatedStation);
          }
        }
      }
    }
    
    print("🔍 Found ${searchResults.length} results for '$query'");
    return searchResults.take(20).toList(); // İlk 20 sonucu döndür
  }

  // Favori durumunu kontrol et
  bool isFavorite(String stationId) {
    return _favoriteIds.contains(stationId);
  }

  // ────────────────────────────────────────────────────────────────────
  // Android Auto güzel arka plan resmi oluşturma
  // ────────────────────────────────────────────────────────────────────

  /// İstasyon logosunu arka planda indirir ve local file:// URI'ye çevirir.
  /// Android Auto http:// URL'leri doğrudan yükleyemediği için yerel dosya gerekli.
  /// İndirme tamamlanınca, istasyon hâlâ aynıysa MediaItem güncellenir.
  Future<void> _downloadLogoAndUpdate(String logoUrl, String stationId) async {
    if (_pendingLogoDownloads.contains(logoUrl)) return;
    if (_logoFileCache.containsKey(logoUrl)) {
      // Zaten indirilmiş - direkt güncelle
      if (_currentStationId == stationId) {
        final current = mediaItem.value;
        if (current != null) {
          mediaItem.add(current.copyWith(artUri: Uri.file(_logoFileCache[logoUrl]!)));
          print('🖼️ Logo cache hit, updated artwork: $logoUrl');
        }
      }
      return;
    }

    _pendingLogoDownloads.add(logoUrl);
    try {
      final response = await http.get(
        Uri.parse(logoUrl),
        headers: {'User-Agent': 'Mozilla/5.0 (Android)'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final dir = await getTemporaryDirectory();
        final hash = logoUrl.hashCode.abs().toString();
        final file = File('${dir.path}/aa_logo_$hash.jpg');
        await file.writeAsBytes(response.bodyBytes);
        _logoFileCache[logoUrl] = file.path;

        // İstasyon hâlâ aynıysa güncelle
        if (_currentStationId == stationId) {
          final current = mediaItem.value;
          if (current != null) {
            mediaItem.add(current.copyWith(artUri: Uri.file(file.path)));
            print('🖼️ Logo downloaded & artwork updated: $logoUrl');
          }
        }
      } else {
        print('⚠️ Logo download failed (${response.statusCode}): $logoUrl');
        // HTTP başarısız - default artwork kullan
        if (_currentStationId == stationId) {
          final defaultUri = await _getDefaultArtUri();
          final current = mediaItem.value;
          if (current != null) {
            mediaItem.add(current.copyWith(artUri: defaultUri));
          }
        }
      }
    } catch (e) {
      print('❌ Logo download error: $e');
      // Hata - default artwork kullan
      if (_currentStationId == stationId) {
        final defaultUri = await _getDefaultArtUri();
        final current = mediaItem.value;
        if (current != null) {
          mediaItem.add(current.copyWith(artUri: defaultUri));
        }
      }
    } finally {
      _pendingLogoDownloads.remove(logoUrl);
    }
  }

  /// assets/... logo yolunu Android Auto için file:// URI'ye çevirir.
  Future<String?> _cacheAssetLogoToFile(String assetPath) async {
    if (_assetLogoFileCache.containsKey(assetPath)) {
      return _assetLogoFileCache[assetPath];
    }
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      if (bytes.isEmpty) return null;

      final dir = await getTemporaryDirectory();
      final hash = assetPath.hashCode.abs().toString();
      final lower = assetPath.toLowerCase();
      final ext = lower.endsWith('.png')
          ? 'png'
          : lower.endsWith('.webp')
              ? 'webp'
              : lower.endsWith('.jpg') || lower.endsWith('.jpeg')
                  ? 'jpg'
                  : 'img';
      final file = File('${dir.path}/aa_asset_logo_$hash.$ext');

      if (!await file.exists()) {
        await file.writeAsBytes(bytes, flush: true);
      }

      _assetLogoFileCache[assetPath] = file.path;
      return file.path;
    } catch (e) {
      print('⚠️ Asset logo cache error ($assetPath): $e');
      return null;
    }
  }

  /// Logo olmayan istasyonlar için güzel bir arka plan resmi döndürür.
  /// Resim ilk çağrıda oluşturulur ve cache'lenir.
  Future<Uri> _getDefaultArtUri() async {
    if (_cachedDefaultArtworkPath != null) {
      return Uri.file(_cachedDefaultArtworkPath!);
    }
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/radyo_tuneli_aa_art.png');
      if (!await file.exists()) {
        final bytes = await _generateDefaultArtworkBytes();
        if (bytes != null) {
          await file.writeAsBytes(bytes);
          print('🎨 Android Auto arka plan resmi oluşturuldu: ${file.path}');
        }
      }
      _cachedDefaultArtworkPath = file.path;
      return Uri.file(file.path);
    } catch (e) {
      print('❌ Arka plan resmi oluşturma hatası: $e');
      // Hata durumunda launcher icon'a geri dön
      return Uri.parse('android.resource://com.turkradyo.bsr.de.turkradyo/mipmap/ic_launcher');
    }
  }

  /// 1024×1024 piksel, koyu mor gradyanlı güzel bir PNG arka plan üretir.
  Future<Uint8List?> _generateDefaultArtworkBytes() async {
    try {
      const double sz = 1024.0;
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, sz, sz));

      // ── 1. Arka plan: derin çok katmanlı gradyan ─────────────────
      final bgPaint = ui.Paint()
        ..shader = ui.Gradient.linear(
          const ui.Offset(0, 0),
          ui.Offset(sz, sz),
          const [
            ui.Color(0xFF0D0020), // sol üst - çok koyu mor
            ui.Color(0xFF1A0035), // ortası
            ui.Color(0xFF0A0018), // sağ alt - neredeyse siyah
          ],
          [0.0, 0.5, 1.0],
        );
      canvas.drawRect(ui.Rect.fromLTWH(0, 0, sz, sz), bgPaint);

      // ── 2. Merkez radyal ışıma (mor/pembe ton) ─────────────────────
      final centerGlow = ui.Paint()
        ..shader = ui.Gradient.radial(
          ui.Offset(sz * 0.5, sz * 0.46),
          sz * 0.55,
          const [
            ui.Color(0x607C3AED), // vibrant violet
            ui.Color(0x30A855F7), // mor-pembe
            ui.Color(0x00000000),
          ],
          [0.0, 0.45, 1.0],
        );
      canvas.drawRect(ui.Rect.fromLTWH(0, 0, sz, sz), centerGlow);

      // ── 3. Sağ alt köşe aksanı (sıcak renk) ──────────────────────
      final accentGlow = ui.Paint()
        ..shader = ui.Gradient.radial(
          ui.Offset(sz * 0.82, sz * 0.78),
          sz * 0.35,
          const [
            ui.Color(0x40EC4899), // pembe-mor
            ui.Color(0x00000000),
          ],
          [0.0, 1.0],
        );
      canvas.drawRect(ui.Rect.fromLTWH(0, 0, sz, sz), accentGlow);

      // ── 4. Sol üst köşe aksanı (mavi ton) ────────────────────────
      final blueAccent = ui.Paint()
        ..shader = ui.Gradient.radial(
          ui.Offset(sz * 0.15, sz * 0.2),
          sz * 0.28,
          const [
            ui.Color(0x304F46E5), // indigo
            ui.Color(0x00000000),
          ],
          [0.0, 1.0],
        );
      canvas.drawRect(ui.Rect.fromLTWH(0, 0, sz, sz), blueAccent);

      // ── 5. Radyo dalgası halkaları ────────────────────────────────
      for (int i = 1; i <= 9; i++) {
        final radius = sz * 0.07 * i;
        final opacity = (0.18 - i * 0.018).clamp(0.02, 0.18);
        final ringPaint = ui.Paint()
          ..color = ui.Color.fromARGB(
              (opacity * 255).round(), 167, 105, 255)
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = sz * 0.002;
        canvas.drawCircle(ui.Offset(sz * 0.5, sz * 0.46), radius, ringPaint);
      }

      // ── 6. İnce parıltı çizgileri (dekoratif) ────────────────────
      final shimmerPaint = ui.Paint()
        ..color = const ui.Color(0x157C3AED)
        ..strokeWidth = sz * 0.001;
      for (int i = 0; i < 8; i++) {
        final angle = i * 3.14159 / 4;
        final x2 = sz * 0.5 + sz * 0.48 * (i % 2 == 0 ? 1 : -1) *
            (angle < 1.6 ? 0.9 : 0.6);
        final y2 = sz * 0.5 + sz * 0.48 *
            (i < 4 ? -0.5 : 0.7);
        canvas.drawLine(
          ui.Offset(sz * 0.5, sz * 0.46),
          ui.Offset(x2, y2),
          shimmerPaint,
        );
      }

      // ── 7. Radyo ikonu (büyük daireli merkez) ─────────────────────
      final circleBg = ui.Paint()
        ..shader = ui.Gradient.radial(
          ui.Offset(sz * 0.5, sz * 0.44),
          sz * 0.16,
          const [
            ui.Color(0xFF7C3AED),
            ui.Color(0xFF5B21B6),
          ],
          [0.0, 1.0],
        );
      canvas.drawCircle(ui.Offset(sz * 0.5, sz * 0.44), sz * 0.16, circleBg);

      // Dış çember
      final circleBorder = ui.Paint()
        ..color = const ui.Color(0x80A78BFA)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = sz * 0.004;
      canvas.drawCircle(ui.Offset(sz * 0.5, sz * 0.44), sz * 0.165, circleBorder);

      // ── 8. "RT" baş harfi büyük ────────────────────────────────────
      final rtBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontSize: sz * 0.18,
        fontWeight: ui.FontWeight.w900,
      ))
        ..pushStyle(ui.TextStyle(
          color: const ui.Color(0xFFFFFFFF),
          fontSize: sz * 0.18,
          fontWeight: ui.FontWeight.w900,
          letterSpacing: -sz * 0.006,
        ))
        ..addText('RT');
      final rtPara = rtBuilder.build();
      rtPara.layout(ui.ParagraphConstraints(width: sz));
      canvas.drawParagraph(
          rtPara, ui.Offset(0, sz * 0.44 - rtPara.height * 0.5));

      // ── 9. "Radyo Tüneli" başlık ──────────────────────────────────
      final titleBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontSize: sz * 0.055,
        fontWeight: ui.FontWeight.w700,
      ))
        ..pushStyle(ui.TextStyle(
          color: const ui.Color(0xFFEDE9FE),
          fontSize: sz * 0.055,
          fontWeight: ui.FontWeight.w700,
          letterSpacing: sz * 0.004,
        ))
        ..addText('RADYO TÜNELİ');
      final titlePara = titleBuilder.build();
      titlePara.layout(ui.ParagraphConstraints(width: sz));
      canvas.drawParagraph(titlePara, ui.Offset(0, sz * 0.65));

      // ── 10. Altyazı ───────────────────────────────────────────────
      final subBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontSize: sz * 0.032,
      ))
        ..pushStyle(ui.TextStyle(
          color: const ui.Color(0x99C4B5FD),
          fontSize: sz * 0.032,
          letterSpacing: sz * 0.003,
        ))
        ..addText('Türk Radyo İstasyonları');
      final subPara = subBuilder.build();
      subPara.layout(ui.ParagraphConstraints(width: sz));
      canvas.drawParagraph(subPara, ui.Offset(0, sz * 0.72));

      // ── 11. Dekoratif yatay çizgiler ─────────────────────────────
      final linePaint = ui.Paint()
        ..color = const ui.Color(0x447C3AED)
        ..strokeWidth = sz * 0.002;
      canvas.drawLine(
        ui.Offset(sz * 0.25, sz * 0.62),
        ui.Offset(sz * 0.75, sz * 0.62),
        linePaint,
      );
      final linePaint2 = ui.Paint()
        ..color = const ui.Color(0x257C3AED)
        ..strokeWidth = sz * 0.001;
      canvas.drawLine(
        ui.Offset(sz * 0.32, sz * 0.78),
        ui.Offset(sz * 0.68, sz * 0.78),
        linePaint2,
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(sz.toInt(), sz.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('❌ Artwork bytes üretme hatası: $e');
      return null;
    }
  }

  // ─────────────────── Harf Avatar (Browse listesi) ────────────────────────

  /// A-Z ve # için renkli daire avatarlarını temp dizine yazar ve cache'ler.
  /// _init() tarafından arka planda çağrılır; tamamlanınca browse cache sıfırlanır.
  Future<void> _preWarmLetterAvatars() async {
    try {
      final dir = await getTemporaryDirectory();
      const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ#';
      for (final letter in letters.split('')) {
        if (_letterAvatarCache.containsKey(letter)) continue;
        final file = File('${dir.path}/aa_letter_$letter.png');
        if (!await file.exists()) {
          final bytes = await _generateLetterAvatarBytes(letter);
          if (bytes != null) await file.writeAsBytes(bytes);
        }
        if (await file.exists()) {
          _letterAvatarCache[letter] = file.path;
        }
      }
      // Avatarlar hazır → eski browse cache'i sil (artUri'ler güncellensin)
      _browseCache.clear();
      print('🎨 Letter avatars ready: ${_letterAvatarCache.length}/27');
    } catch (e) {
      print('❌ Letter avatar pre-warm error: $e');
    }
  }

  /// Browse listesindeki bir istasyon için yerel file:// URI döndürür.
  /// HTTP URL'leri Android Auto yükleyemez → local dosya zorunlu.
  Uri _getLocalArtUriForBrowse(MediaItem station) {
    final remoteUrl = station.artUri?.toString() ?? '';
    // 1. İndirilen logo var mı?
    if (remoteUrl.isNotEmpty &&
        (remoteUrl.startsWith('http://') || remoteUrl.startsWith('https://')) &&
        _logoFileCache.containsKey(remoteUrl)) {
      return Uri.file(_logoFileCache[remoteUrl]!);
    }
    // 2. Zaten yerel dosya ise kullan
    if (remoteUrl.startsWith('file://')) return station.artUri!;
    // 3. Harf avatarı
    final rawFirst = station.title.trim().isNotEmpty
        ? station.title.trim()[0].toUpperCase()
        : 'R';
    final letter = RegExp(r'^[A-Z]$').hasMatch(rawFirst) ? rawFirst : '#';
    final path = _letterAvatarCache[letter] ?? _letterAvatarCache['#'];
    if (path != null) return Uri.file(path);
    // 4. Son çare: launcher icon
    return Uri.parse(
        'android.resource://com.turkradyo.bsr.de.turkradyo/mipmap/ic_launcher');
  }

  /// Verilen harf için 256×256 renkli daire + beyaz harf PNG baytları üretir.
  Future<Uint8List?> _generateLetterAvatarBytes(String letter) async {
    try {
      const double sz = 256.0;
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, sz, sz));

      // Harf başına sabit renk (modülo renk paleti)
      const List<int> palette = [
        0xFF7C3AED, // Mor
        0xFF2563EB, // Mavi
        0xFF059669, // Yeşil
        0xFFD97706, // Turuncu
        0xFFDC2626, // Kırmızı
        0xFF0891B2, // Cyan
        0xFF65A30D, // Lime
        0xFFE11D48, // Pembe
      ];
      final charCode = letter == '#' ? 35 : letter.codeUnitAt(0);
      final bgColor = ui.Color(palette[charCode % palette.length]);

      // Arka plan dairesi
      canvas.drawCircle(
          const ui.Offset(sz / 2, sz / 2), sz / 2, ui.Paint()..color = bgColor);

      // Hafif iç parlaklık
      canvas.drawCircle(
          const ui.Offset(sz / 2, sz / 2),
          sz / 2,
          ui.Paint()
            ..shader = ui.Gradient.radial(
              const ui.Offset(sz * 0.35, sz * 0.3),
              sz * 0.55,
              [
                ui.Color.fromARGB(55, 255, 255, 255),
                ui.Color.fromARGB(0, 0, 0, 0),
              ],
            ));

      // Harf metni
      final displayChar = letter == '#' ? '♪' : letter;
      final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: ui.TextAlign.center,
        fontSize: sz * 0.50,
        fontWeight: ui.FontWeight.w700,
      ))
        ..pushStyle(ui.TextStyle(
          color: const ui.Color(0xFFFFFFFF),
          fontSize: sz * 0.50,
          fontWeight: ui.FontWeight.w700,
        ))
        ..addText(displayChar);
      final para = pb.build();
      para.layout(ui.ParagraphConstraints(width: sz));
      canvas.drawParagraph(para, ui.Offset(0, sz * 0.23));

      final picture = recorder.endRecording();
      final image = await picture.toImage(sz.toInt(), sz.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('❌ Letter avatar generation error "$letter": $e');
      return null;
    }
  }
}

/// Android Auto browse sonuç cache girdisi
class _BrowseCacheEntry {
  final Set<String> favoritesSnapshot;
  final List<MediaItem> items;
  _BrowseCacheEntry(this.favoritesSnapshot, this.items);
}
