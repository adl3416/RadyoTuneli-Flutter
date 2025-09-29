import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'src/app/app_root.dart';
import 'src/features/player/data/audio_service_handler.dart';

// Global audio handler for fallback
RadioAudioHandler? globalAudioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize audio service before starting app
  await _initializeAudioService();

  runApp(const ProviderScope(child: AppRoot()));
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
