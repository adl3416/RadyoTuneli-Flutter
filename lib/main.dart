import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'src/features/splash/ui/splash_app.dart';
import 'src/features/player/data/audio_service_handler.dart';

// Global audio handler for fallback
RadioAudioHandler? globalAudioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
            'com.turkradyo.adl.de.turkradyo.channel.audio',
        androidNotificationChannelName: 'Radyo Tüneli',
        androidNotificationChannelDescription:
            'Radyo Tüneli - Türk Radyo İstasyonları',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidStopForegroundOnPause: true,
        artDownscaleWidth: 256,
        artDownscaleHeight: 256,
        fastForwardInterval: const Duration(seconds: 10),
        rewindInterval: const Duration(seconds: 10),
        preloadArtwork: true,
        // Modern Android Auto UI/UX Tasarımı
        androidBrowsableRootExtras: {
          // Content Style - Modern Grid görünümü
          'android.media.browse.CONTENT_STYLE_SUPPORTED': true,
          'android.media.browse.CONTENT_STYLE_PLAYABLE_HINT': 1,
          'android.media.browse.CONTENT_STYLE_BROWSABLE_HINT': 2, // Grid görünüm
          
          // Liste ve Grid öğe boyutları
          'android.media.browse.CONTENT_STYLE_LIST_ITEM_HINT_VALUE': 2, // Büyük liste öğeleri
          'android.media.browse.CONTENT_STYLE_GRID_ITEM_HINT_VALUE': 2, // 2x2 Grid
          
          // Kategori görünümü
          'android.media.browse.CONTENT_STYLE_CATEGORY_LIST_ENABLED': true,
          'android.media.browse.CONTENT_STYLE_CATEGORY_GRID_ENABLED': true,
          
          // Modern özellikler
          'android.media.extras.CONTENT_STYLE_TITLE_HINT': 'Radyo Tüneli',
          'android.media.extras.CONTENT_STYLE_SUBTITLE_HINT': 'Türk Radyo İstasyonları',
          
          // Android Auto medya kontrolü optimizasyonları
          'com.google.android.gms.car.media.ALWAYS_RESERVE_SPACE_FOR.ACTION_QUEUE': false,
          'com.google.android.gms.car.media.ALWAYS_RESERVE_SPACE_FOR.ACTION_SKIP_TO_NEXT': false,
          'com.google.android.gms.car.media.ALWAYS_RESERVE_SPACE_FOR.ACTION_SKIP_TO_PREVIOUS': false,
          'com.google.android.gms.car.media.BROWSE_SERVICE_FOR_SESSION': true,
          
          // Sürüş güvenliği - Basitleştirilmiş kontroller
          'com.google.android.gms.car.media.SLOT_RESERVATION_QUEUE': false,
          'com.google.android.gms.car.media.SLOT_RESERVATION_SKIP_TO_NEXT': false,
          'com.google.android.gms.car.media.SLOT_RESERVATION_SKIP_TO_PREV': false,
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
