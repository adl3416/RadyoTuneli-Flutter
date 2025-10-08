import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App Settings Model
class AppSettings {
  final bool autoPlay;
  final bool notificationsEnabled;
  final bool showLockScreenControls;
  final double volume;

  const AppSettings({
    this.autoPlay = false,
    this.notificationsEnabled = true,
    this.showLockScreenControls = true,
    this.volume = 0.7,
  });

  AppSettings copyWith({
    bool? autoPlay,
    bool? notificationsEnabled,
    bool? showLockScreenControls,
    double? volume,
  }) {
    return AppSettings(
      autoPlay: autoPlay ?? this.autoPlay,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      showLockScreenControls: showLockScreenControls ?? this.showLockScreenControls,
      volume: volume ?? this.volume,
    );
  }
}

// App Settings Notifier
class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  static const String _autoPlayKey = 'autoPlay';
  static const String _notificationsKey = 'notificationsEnabled';
  static const String _lockScreenKey = 'showLockScreenControls';
  static const String _volumeKey = 'volume';

  Future<void> _loadSettings() async {
    print('📱 Uygulama ayarları yükleniyor...');
    final prefs = await SharedPreferences.getInstance();
    
    state = AppSettings(
      autoPlay: prefs.getBool(_autoPlayKey) ?? false,
      notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
      showLockScreenControls: prefs.getBool(_lockScreenKey) ?? true,
      volume: prefs.getDouble(_volumeKey) ?? 0.7,
    );
    
    print('📱 Ayarlar yüklendi: autoPlay=${state.autoPlay}, notifications=${state.notificationsEnabled}');
  }

  Future<void> setAutoPlay(bool enabled) async {
    print('🔄 Otomatik oynat ayarı değiştiriliyor: $enabled');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayKey, enabled);
    state = state.copyWith(autoPlay: enabled);
    print('✅ Otomatik oynat ayarı kaydedildi: $enabled');
  }

  Future<void> setNotifications(bool enabled) async {
    print('🔔 Bildirim ayarı değiştiriliyor: $enabled');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    state = state.copyWith(notificationsEnabled: enabled);
    print('✅ Bildirim ayarı kaydedildi: $enabled');
  }

  Future<void> setLockScreenControls(bool enabled) async {
    print('🔒 Kilit ekranı kontrolleri ayarı değiştiriliyor: $enabled');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lockScreenKey, enabled);
    state = state.copyWith(showLockScreenControls: enabled);
    print('✅ Kilit ekranı kontrolleri ayarı kaydedildi: $enabled');
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