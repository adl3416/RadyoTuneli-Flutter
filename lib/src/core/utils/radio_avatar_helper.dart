import 'dart:ui';

/// Radyo logosu olmayan istasyonlar için renkli avatar oluşturur
class RadioAvatarHelper {
  // Modern, canlı renk paleti (Material Design 3 inspired)
  static const List<Color> _colorPalette = [
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    Color(0xFFF44336), // Red
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF5E35B1), // Deep Purple Accent
    Color(0xFF1E88E5), // Blue 600
    Color(0xFF43A047), // Green 600
    Color(0xFFFB8C00), // Orange 600
    Color(0xFFE53935), // Red 600
  ];

  /// Radyo adından baş harfi al
  static String getInitial(String radioName) {
    if (radioName.isEmpty) return '?';
    
    // Özel karakterleri ve sayıları kaldır
    final cleanName = radioName.trim().replaceAll(RegExp(r'[^\p{L}\s]', unicode: true), '');
    
    if (cleanName.isEmpty) return radioName[0].toUpperCase();
    
    // İlk harfi al
    return cleanName[0].toUpperCase();
  }

  /// Radyo adından tutarlı bir renk seç (her radyo için aynı renk)
  static Color getColorForRadio(String radioName) {
    if (radioName.isEmpty) return _colorPalette[0];
    
    // Radyo adının hash'ini kullanarak tutarlı bir renk seç
    int hash = radioName.hashCode.abs();
    return _colorPalette[hash % _colorPalette.length];
  }

  /// Rengin daha koyu versiyonu (border için)
  static Color getDarkerColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      (color.red * 0.7).round(),
      (color.green * 0.7).round(),
      (color.blue * 0.7).round(),
    );
  }

  /// Rengin daha açık versiyonu (gradient için)
  static Color getLighterColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      (color.red + (255 - color.red) * 0.3).round(),
      (color.green + (255 - color.green) * 0.3).round(),
      (color.blue + (255 - color.blue) * 0.3).round(),
    );
  }
}
