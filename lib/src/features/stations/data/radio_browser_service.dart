import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../domain/station_model.dart';
import 'radio_browser_station.dart';

class RadioBrowserService {
  static const List<String> _apiUrls = [
    'https://de2.api.radio-browser.info/json/stations/bycountrycodeexact/TR?limit=1000&hidebroken=true',
    'https://fi1.api.radio-browser.info/json/stations/bycountrycodeexact/TR?limit=1000&hidebroken=true',
  ];

  static const String _fallbackAssetPath = 'assets/data/TR.json';

  /// Fetches Turkish radio stations from radio-browser API with fallback
  Future<List<Station>> fetchTurkishStations() async {
    // Try API endpoints in order
    for (final url in _apiUrls) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'TurkRadyo/1.0.0',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(response.body);
          final radioBrowserStations = jsonList
              .map((json) => RadioBrowserStation.fromJson(json))
              .where((station) =>
                  (station.lastcheckok ?? 0) == 1 && // Only working stations
                  station.name.isNotEmpty &&
                  (station.urlResolved?.isNotEmpty ?? false))
              .toList();

          // Convert to our Station model
          final stations = radioBrowserStations.map(_toStation).toList();

          // Sort by votes (popularity) descending
          stations.sort((a, b) => _getVotes(b).compareTo(_getVotes(a)));

          return stations; // Return all stations
        }
      } catch (e) {
        print('Failed to fetch from $url: $e');
        // Continue to next URL or fallback
      }
    }

    // If all APIs fail, use fallback JSON
    return _loadFallbackStations();
  }

  /// Loads stations from local JSON asset
  Future<List<Station>> _loadFallbackStations() async {
    try {
      final String jsonString = await rootBundle.loadString(_fallbackAssetPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      final radioBrowserStations =
          jsonList.map((json) => RadioBrowserStation.fromJson(json)).toList();

      return radioBrowserStations.map(_toStation).toList();
    } catch (e) {
      print('Failed to load fallback stations: $e');
      return [];
    }
  }

  /// Converts RadioBrowserStation to our Station model
  Station _toStation(RadioBrowserStation apiStation) {
    return Station(
      id: apiStation.stationuuid,
      name: apiStation.name,
      streamUrl: (apiStation.urlResolved?.isNotEmpty ?? false)
          ? apiStation.urlResolved!
          : apiStation.url,
      logoUrl: _getCustomLogo(apiStation.name, apiStation.favicon),
      bitrate: '${apiStation.bitrate ?? 128} kbps',
      description: _generateDescription(apiStation),
      genre: apiStation.tags?.split(',').first ?? 'Müzik',
      country: apiStation.country ?? 'Türkiye',
    );
  }

  /// Generates a description from available data
  String _generateDescription(RadioBrowserStation station) {
    final parts = <String>[];

    if (station.tags?.isNotEmpty == true) {
      parts.add(station.tags!.split(',').take(2).join(', '));
    }

    if (station.bitrate != null) {
      parts.add('${station.bitrate} kbps');
    }

    if (station.codec?.isNotEmpty == true) {
      parts.add(station.codec!);
    }

    return parts.isNotEmpty ? parts.join(' • ') : 'Türk Radyosu';
  }

  /// Gets votes for sorting (0 if null)
  int _getVotes(Station station) {
    // We'll store original votes in a metadata way if needed
    // For now, use a simple heuristic based on name popularity
    final name = station.name.toLowerCase();
    if (name.contains('trt')) return 10000;
    if (name.contains('süper') || name.contains('super')) return 5000;
    if (name.contains('virgin')) return 4000;
    if (name.contains('power')) return 3000;
    if (name.contains('kral')) return 2500;
    return 1000;
  }

  /// Provides a default logo URL
  String _getDefaultLogo() {
    return 'https://via.placeholder.com/200x200/3B82F6/FFFFFF?text=📻';
  }

  /// Custom logo mapping for specific stations
  String _getCustomLogo(String stationName, String? originalLogo) {
    final name = stationName.toLowerCase().trim();
    
        // Custom logo mappings - istediğiniz radyolar için logo URL'leri ekleyin
    final logoMappings = {
      'trt radyo 1': 'assets/logos/trt_radyo1.png',
      'trt radyo kurdî': 'assets/logos/trt_radyokurdi_log.png',
      'trt türkü': 'assets/logos/trt türkü.png',
      'trt fm': 'assets/logos/trt fm.png',
      'trt memleketim': 'assets/logos/trt memleketim.png',
      'trt memleketim fm': 'assets/logos/trt memleketim.png',
      'trt trabzon': 'assets/logos/trt trabzon.png',
      // Çalışan URL'lerle devam edelim
      'power fm': 'https://powergroup.com.tr/assets/images/power-fm-logo.png',
      'süper fm': 'https://i.pinimg.com/474x/b5/3e/13/b53e132b4edf8b9b6e8a2a7e2d1c4c7f.jpg',
      // Daha fazla ekleyebilirsiniz...
    };
    
    print('🔍 Logo kontrol: "$name" için mapping kontrol ediliyor...');
    
    // Önce özel mapping'leri kontrol et
    for (final entry in logoMappings.entries) {
      if (name.contains(entry.key)) {
        print('✅ Logo bulundu: $name -> ${entry.value}');
        return entry.value;
      }
    }
    
    // Eğer original logo varsa onu kullan
    if (originalLogo?.isNotEmpty == true && originalLogo != 'null' && originalLogo!.trim().isNotEmpty) {
      print('📷 Original logo kullanılıyor: $originalLogo');
      return originalLogo!;
    }
    
    print('🔧 Default logo kullanılıyor');
    // Son çare olarak default logo
    return _getDefaultLogo();
  }
}
