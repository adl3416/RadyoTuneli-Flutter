import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App Settings Model
class AppSettings {
  final bool autoPlay;
  final double volume;
  final bool smoothTransitions;

  const AppSettings({
    this.autoPlay = false,
    this.volume = 0.7,
    this.smoothTransitions = false,
  });

  AppSettings copyWith({
    bool? autoPlay,
    double? volume,
    bool? smoothTransitions,
  }) {
    return AppSettings(
      autoPlay: autoPlay ?? this.autoPlay,
      volume: volume ?? this.volume,
      smoothTransitions: smoothTransitions ?? this.smoothTransitions,
    );
  }
}

// App Settings Notifier
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  static const String _autoPlayKey = 'autoPlay';
  static const String _volumeKey = 'volume';
  static const String _smoothTransitionsKey = 'smoothTransitions';

  Future<void> _loadSettings() async {
    print('📱 Uygulama ayarları yükleniyor...');
    final prefs = await SharedPreferences.getInstance();
    
    state = AppSettings(
      autoPlay: prefs.getBool(_autoPlayKey) ?? false,
      volume: prefs.getDouble(_volumeKey) ?? 0.7,
      smoothTransitions: prefs.getBool(_smoothTransitionsKey) ?? false,
    );
    
    print('📱 Ayarlar yüklendi: autoPlay=${state.autoPlay}');
  }

  Future<void> setAutoPlay(bool enabled) async {
    print('🔄 Otomatik oynat ayarı değiştiriliyor: $enabled');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayKey, enabled);
    state = state.copyWith(autoPlay: enabled);
    print('✅ Otomatik oynat ayarı kaydedildi: $enabled');
  }

  Future<void> setSmoothTransitions(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_smoothTransitionsKey, enabled);
    state = state.copyWith(smoothTransitions: enabled);
  }



  Future<void> setVolume(double volume) async {
    print('🔊 Ses seviyesi ayarı değiştiriliyor: $volume');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, volume);
    state = state.copyWith(volume: volume);
    print('✅ Ses seviyesi ayarı kaydedildi: $volume');
  }
}

// Provider
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});
