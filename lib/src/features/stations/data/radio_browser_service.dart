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
    List<Station> apiStations = [];
    bool apiSuccess = false;

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

          // Remove duplicates based on station names
          apiStations = _removeDuplicateStations(stations);
          apiSuccess = true;
          break; // Stop after first successful API call
        }
      } catch (e) {
        print('Failed to fetch from $url: $e');
        // Continue to next URL
      }
    }

    // Always load local stations to ensure custom added radios (like Herkul, Cihan) are present
    // even if API call was successful.
    final localStations = await _loadFallbackStations();

    if (!apiSuccess) {
      return localStations;
    }

    // Merge API and Local stations
    // We put API stations first so they take precedence for duplicates (unless local has higher votes)
    // Local-only stations will be appended.
    final allStations = [...apiStations, ...localStations];
    
    // Remove duplicates again after merge
    return _removeDuplicateStations(allStations);
  }

  /// Loads stations from local JSON asset
  Future<List<Station>> _loadFallbackStations() async {
    try {
      final String jsonString = await rootBundle.loadString(_fallbackAssetPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      final radioBrowserStations =
          jsonList.map((json) => RadioBrowserStation.fromJson(json)).toList();

      final stations = radioBrowserStations.map(_toStation).toList();
      
      // Remove duplicates from fallback stations as well
      final uniqueStations = _removeDuplicateStations(stations);
      
      return uniqueStations;
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

    // Only show genre/tags, hide technical information (bitrate, codec)
    if (station.tags?.isNotEmpty == true) {
      parts.add(station.tags!.split(',').take(2).join(', '));
    }

    // Commented out technical information as requested
    // if (station.bitrate != null) {
    //   parts.add('${station.bitrate} kbps');
    // }

    // if (station.codec?.isNotEmpty == true) {
    //   parts.add(station.codec!);
    // }

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

  /// Removes duplicate stations based on normalized names
  List<Station> _removeDuplicateStations(List<Station> stations) {
    final Map<String, Station> uniqueStations = {};
    
    for (final station in stations) {
      final normalizedName = _normalizeStationName(station.name);
      
      // If we haven't seen this normalized name before, or if this station
      // has higher quality (better votes), keep it
      if (!uniqueStations.containsKey(normalizedName) ||
          _getVotes(station) > _getVotes(uniqueStations[normalizedName]!)) {
        uniqueStations[normalizedName] = station;
      }
    }
    
    return uniqueStations.values.toList();
  }

  /// Normalizes station name for duplicate detection
  String _normalizeStationName(String name) {
    // Convert to lowercase and remove common patterns that create duplicates
    String normalized = name.toLowerCase().trim();
    
    // Remove leading/trailing spaces and special characters
    normalized = normalized.replaceAll(RegExp(r'^[\s\-_\.]+|[\s\-_\.]+$'), '');
    
    // Remove common prefixes/suffixes that cause duplicates
    normalized = normalized.replaceAll(RegExp(r'\s*(radyo|radio|fm|am)\s*'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s*(türkiye|turkey|tr)\s*'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s*\d+[\.,]?\d*\s*(mhz|khz|fm|am)\s*'), ' ');
    
    // Remove multiple spaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Remove special characters that might differ between duplicates
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), '');
    
    return normalized;
  }

  /// Custom logo mapping for specific stations
  String _getCustomLogo(String stationName, String? originalLogo) {
    final name = stationName.toLowerCase().trim();
    
    // TRT Radyoları için özel logo mappings
    final logoMappings = {
      'trt fm': 'assets/logos/trt fm.png',
      'trt memleketim': 'assets/logos/trt memleketim.png',
      'trt memleketim fm': 'assets/logos/trt memleketim.png',
      'trt trabzon': 'assets/logos/trt trabzon.png',
      'trt tsr': 'assets/logos/trt tsr.png',
      'trt türkü': 'assets/logos/trt türkü.png',
      'trt radyo 1': 'assets/logos/trt_radyo1.png',
      'trt radyo kurdî': 'assets/logos/trt_radyokurdi_log.png',
      'trt radyo kurdi': 'assets/logos/trt_radyokurdi_log.png', // Alternatif yazım
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
    
    print('� Baş harf logosu oluşturuluyor: ${stationName.substring(0, 1).toUpperCase()}');
    // Son çare olarak baş harf logosu
    return _generateInitialLogo(stationName);
  }

  /// Generates a logo based on the first letter of station name
  String _generateInitialLogo(String stationName) {
    // İlk harfi al ve büyük harfe çevir
    String initial = stationName.trim().isNotEmpty 
        ? stationName.trim().substring(0, 1).toUpperCase() 
        : 'R';
    
    // Türkçe karakterleri İngilizce eşdeğerlerine çevir
    final turkishToEnglish = {
      'Ç': 'C', 'Ğ': 'G', 'İ': 'I', 'Ö': 'O', 'Ş': 'S', 'Ü': 'U',
      'ç': 'c', 'ğ': 'g', 'ı': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u'
    };
    
    if (turkishToEnglish.containsKey(initial)) {
      initial = turkishToEnglish[initial]!;
    }
    
    // Renk seçimi - radyo adına göre sabit renk
    final colors = [
      '3B82F6', // Blue
      'EF4444', // Red  
      '10B981', // Green
      'F59E0B', // Yellow
      '8B5CF6', // Purple
      'F97316', // Orange
      '06B6D4', // Cyan
      'EC4899', // Pink
    ];
    
    int colorIndex = stationName.hashCode.abs() % colors.length;
    String color = colors[colorIndex];
    
    // Özel protokol ile baş harf bilgisini gönder
    return 'initial://$initial/$color';
  }

  /// Provides a default logo URL
  String _getDefaultLogo() {
    return 'assets/images/vintage_radio_logo.png';
  }
}
