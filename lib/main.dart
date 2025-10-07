import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'src/features/splash/ui/splash_app.dart';
import 'src/features/player/data/audio_service_handler.dart';

// Global audio handler for fallback
RadioAudioHandler? globalAudioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio service before starting app
  await _initializeAudioService();

  runApp(const ProviderScope(child: SplashApp()));
}

Future<void> _initializeAudioService() async {
  try {
    print("🎵 Starting audio service initialization...");
    print("🔧 Creating RadioAudioHandler...");
    final handler = RadioAudioHandler();
    print("🔧 Handler created, initializing AudioService...");

    await AudioService.init(
      builder: () => handler,
      config: AudioServiceConfig(
        androidNotificationChannelId:
            'com.turkradyo.bsr.de.turkradyo.channel.audio',
        androidNotificationChannelName: 'Turkish Radio',
        androidNotificationChannelDescription:
            'Turkish Radio audio playback controls',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
        androidNotificationIcon: 'drawable/ic_notification',
        androidStopForegroundOnPause: true,
        artDownscaleWidth: 256,
        artDownscaleHeight: 256,
        fastForwardInterval: const Duration(seconds: 10),
        rewindInterval: const Duration(seconds: 10),
        preloadArtwork: true,
        // Android Auto ve CarPlay desteği
        androidBrowsableRootExtras: {
          'android.media.browse.CONTENT_STYLE_SUPPORTED': true,
          'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 1,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2,
          'android.media.browse.CONTENT_STYLE_CATEGORY_LIST_ENABLED': true,
          'android.media.browse.CONTENT_STYLE_CATEGORY_GRID_ENABLED': true,
          'android.media.browse.CONTENT_STYLE_LIST_ITEM_HINT_VALUE': 1,
          'android.media.browse.CONTENT_STYLE_GRID_ITEM_HINT_VALUE': 2,
          'com.google.android.gms.car.media.ALWAYS_RESERVE_SPACE_FOR.ACTION_QUEUE': false,
          'com.google.android.gms.car.media.ALWAYS_RESERVE_SPACE_FOR.ACTION_SKIP_TO_NEXT': false,
          'com.google.android.gms.car.media.ALWAYS_RESERVE_SPACE_FOR.ACTION_SKIP_TO_PREVIOUS': false,
          'com.google.android.gms.car.media.BROWSE_SERVICE_FOR_SESSION': true,
        },
      ),
    );

    print("🔧 AudioService.init completed");
    globalAudioHandler = handler;
    print("✅ Audio service initialized successfully!");
    print(
        "🎵 Global audio handler: ${globalAudioHandler != null ? 'Available' : 'null'}");
  } catch (e, stackTrace) {
    print("❌ Audio service initialization failed: $e");
    print("Stack trace: $stackTrace");
  }
}
