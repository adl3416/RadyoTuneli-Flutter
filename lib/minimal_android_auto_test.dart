import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// Global handler reference
MinimalAudioHandler? globalHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print("🚗🚗🚗 MINIMAL ANDROID AUTO TEST STARTED");
  
  // Create handler
  final handler = MinimalAudioHandler();
  globalHandler = handler;
  
  // AudioService'i minimal setup ile başlat
  final audioHandler = await AudioService.init(
    builder: () => handler,
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.turkradyo.bsr.de.turkradyo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: false,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidBrowsableRootExtras: {
        'android.service.media.BrowseService': true,
        'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 1,
        'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 2,
      },
    ),
  );
  
  print("🚗🚗🚗 AudioService initialized");
  
  // Hemen bir test MediaItem set et
  handler.setTestMedia();
  
  runApp(MinimalTestApp());
}

class MinimalAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  
  MinimalAudioHandler() {
    print("🚗🚗🚗 MinimalAudioHandler created");
    
    // Hemen aktif bir MediaSession oluştur
    playbackState.add(PlaybackState(
      controls: [MediaControl.play, MediaControl.stop],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
      },
      androidCompactActionIndices: const [0, 1],
      processingState: AudioProcessingState.ready,
      playing: false,
    ));
  }
  
  void setTestMedia() {
    print("🚗🚗🚗 Setting test media");
    
    final testMediaItem = MediaItem(
      id: 'test_radio_id',
      title: 'Türk Radyo Test',
      artist: 'Test Artist',
      album: 'Turkish Radio',
      genre: 'Radyo',
      artUri: Uri.parse('https://example.com/logo.png'),
      playable: true,
      extras: {
        'isLive': true,
        'streamUrl': 'https://test-stream-url.com',
      },
    );
    
    // MediaItem'ı set et
    mediaItem.add(testMediaItem);
    
    print("🚗🚗🚗 Test media set: ${testMediaItem.title}");
  }
  
  @override
  Future<void> play() async {
    print("🚗🚗🚗 Play called");
    
    playbackState.add(PlaybackState(
      controls: [MediaControl.pause, MediaControl.stop],
      systemActions: const {
        MediaAction.pause,
        MediaAction.stop,
      },
      androidCompactActionIndices: const [0, 1],
      processingState: AudioProcessingState.ready,
      playing: true,
    ));
  }
  
  @override
  Future<void> pause() async {
    print("🚗🚗🚗 Pause called");
    
    playbackState.add(PlaybackState(
      controls: [MediaControl.play, MediaControl.stop],
      systemActions: const {
        MediaAction.play,
        MediaAction.stop,
      },
      androidCompactActionIndices: const [0, 1],
      processingState: AudioProcessingState.ready,
      playing: false,
    ));
  }
  
  @override
  Future<void> stop() async {
    print("🚗🚗🚗 Stop called");
    
    playbackState.add(PlaybackState(
      controls: [MediaControl.play],
      systemActions: const {
        MediaAction.play,
      },
      androidCompactActionIndices: const [0],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }
  
  // Android Auto MediaBrowser support
  @override
  Future<MediaItem?> getMediaItem(String mediaId) async {
    print("🚗🚗🚗 Android Auto: getMediaItem($mediaId)");
    
    if (mediaId == '__ROOT__') {
      return MediaItem(
        id: '__ROOT__',
        title: 'Türk Radyo',
        playable: false,
      );
    }
    
    return MediaItem(
      id: mediaId,
      title: 'Test Radio Station',
      artist: 'Test Artist',
      playable: true,
    );
  }
  
  @override
  Future<List<MediaItem>> getChildren(String parentMediaId, [Map<String, dynamic>? options]) async {
    print("🚗🚗🚗 Android Auto: getChildren($parentMediaId)");
    
    if (parentMediaId == '__ROOT__') {
      return [
        MediaItem(
          id: 'test_station_1',
          title: 'Test Radyo 1',
          artist: 'Test Category',
          playable: true,
          extras: {'streamUrl': 'https://test-stream.com'},
        ),
        MediaItem(
          id: 'test_station_2',
          title: 'Test Radyo 2',
          artist: 'Test Category',
          playable: true,
          extras: {'streamUrl': 'https://test-stream2.com'},
        ),
      ];
    }
    
    return [];
  }
  
  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    print("🚗🚗🚗 Android Auto: playMediaItem(${mediaItem.title})");
    
    // MediaItem'ı set et
    this.mediaItem.add(mediaItem);
    
    // Playing state'e geç
    await play();
  }
  
  @override
  Future<List<MediaItem>> search(String query, [Map<String, dynamic>? extras]) async {
    print("🚗🚗🚗 Android Auto: search($query)");
    
    return [
      MediaItem(
        id: 'search_result_1',
        title: 'Arama Sonucu: $query',
        artist: 'Radyo Araması',
        playable: true,
      ),
    ];
  }
}

class MinimalTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Auto Test',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Android Auto Test'),
          backgroundColor: Colors.purple,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🚗 Android Auto Test App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'MediaSession aktif ve test media set edildi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (globalHandler != null) {
                    await globalHandler!.play();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: Text('Play Test'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  if (globalHandler != null) {
                    await globalHandler!.pause();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: Text('Pause Test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}