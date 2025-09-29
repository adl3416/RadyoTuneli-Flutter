import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/station_model.dart';

class MockStationRepository {
  static final List<Station> _stations = [
    const Station(
      id: '1',
      name: 'TRT Radyo 1',
      streamUrl: 'https://radyo1.radyomedia.trt.com.tr/master.m3u8',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/tr/thumb/c/c3/TRT_Radyo_1_logo.svg/200px-TRT_Radyo_1_logo.svg.png',
      bitrate: '128 kbps',
      description: 'TRT\'nin genel yayın kanalı',
      genre: 'Genel',
      country: 'Türkiye',
    ),
    const Station(
      id: '2',
      name: 'TRT FM',
      streamUrl: 'https://trtfm.radyomedia.trt.com.tr/master.m3u8',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/tr/thumb/2/2e/TRT_FM_logo.svg/200px-TRT_FM_logo.svg.png',
      bitrate: '128 kbps',
      description: 'Müzik ve eğlence kanalı',
      genre: 'Pop',
      country: 'Türkiye',
    ),
    const Station(
      id: '3',
      name: 'TRT Radyo 3',
      streamUrl: 'https://radyo3.radyomedia.trt.com.tr/master.m3u8',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/tr/thumb/f/f1/TRT_Radyo_3_logo.svg/200px-TRT_Radyo_3_logo.svg.png',
      bitrate: '320 kbps',
      description: 'Klasik müzik kanalı',
      genre: 'Klasik',
      country: 'Türkiye',
    ),
    const Station(
      id: '4',
      name: 'Açık Radyo',
      streamUrl: 'https://ssl5.radyotvonline.com/acikradyo.mp3',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Acik_radyo_logo.png/200px-Acik_radyo_logo.png',
      bitrate: '128 kbps',
      description: 'Alternatif müzik ve kültür',
      genre: 'Alternatif',
      country: 'Türkiye',
    ),
    const Station(
      id: '5',
      name: 'Radyo Eksen',
      streamUrl: 'https://ssl6.radyotvonline.com/radyoeksen.mp3',
      logoUrl: 'https://www.radyoeksen.com/images/logo.png',
      bitrate: '128 kbps',
      description: 'Rock ve alternatif müzik',
      genre: 'Rock',
      country: 'Türkiye',
    ),
    const Station(
      id: '6',
      name: 'Radyo Viva',
      streamUrl: 'https://ssl5.radyotvonline.com/radyoviva.mp3',
      logoUrl: 'https://www.radyoviva.com.tr/images/logo.png',
      bitrate: '128 kbps',
      description: 'Türkçe pop müzik',
      genre: 'Türkçe Pop',
      country: 'Türkiye',
    ),
    const Station(
      id: '7',
      name: 'Slow Türk',
      streamUrl: 'https://ssl5.radyotvonline.com/slowturk.mp3',
      logoUrl: 'https://www.slowturk.com/images/logo.png',
      bitrate: '128 kbps',
      description: 'Slow müzik',
      genre: 'Slow',
      country: 'Türkiye',
    ),
    const Station(
      id: '8',
      name: 'Best FM',
      streamUrl: 'https://ssl5.radyotvonline.com/bestfm.mp3',
      logoUrl: 'https://www.bestfm.com.tr/images/logo.png',
      bitrate: '128 kbps',
      description: 'Pop ve hit müzikler',
      genre: 'Pop',
      country: 'Türkiye',
    ),
    const Station(
      id: '9',
      name: 'Radyo D',
      streamUrl: 'https://ssl5.radyotvonline.com/radyod.mp3',
      logoUrl: 'https://www.radyod.com/images/logo.png',
      bitrate: '128 kbps',
      description: 'Damar müzik',
      genre: 'Damar',
      country: 'Türkiye',
    ),
    const Station(
      id: '10',
      name: 'Metro FM',
      streamUrl: 'https://ssl5.radyotvonline.com/metrofm.mp3',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/tr/thumb/c/c7/Metro_FM_logo.svg/200px-Metro_FM_logo.svg.png',
      bitrate: '128 kbps',
      description: 'Pop müzik ve eğlence',
      genre: 'Pop',
      country: 'Türkiye',
    ),
    const Station(
      id: '11',
      name: 'Power FM',
      streamUrl: 'https://ssl5.radyotvonline.com/powerfm.mp3',
      logoUrl: 'https://www.powerfm.com.tr/images/logo.png',
      bitrate: '128 kbps',
      description: 'Türkiye\'nin enerjik radyosu',
      genre: 'Pop',
      country: 'Türkiye',
    ),
    const Station(
      id: '12',
      name: 'Joy FM',
      streamUrl: 'https://ssl5.radyotvonline.com/joyfm.mp3',
      logoUrl: 'https://www.joyfm.com.tr/images/logo.png',
      bitrate: '128 kbps',
      description: 'Neşeli müzikler',
      genre: 'Pop',
      country: 'Türkiye',
    ),
    const Station(
      id: '13',
      name: 'Kral FM',
      streamUrl: 'https://ssl5.radyotvonline.com/kralfm.mp3',
      logoUrl: 'https://www.kralfm.com.tr/images/logo.png',
      bitrate: '128 kbps',
      description: 'Pop müzikte kral',
      genre: 'Pop',
      country: 'Türkiye',
    ),
    const Station(
      id: '14',
      name: 'Virgin Radio',
      streamUrl: 'https://ssl5.radyotvonline.com/virginradio.mp3',
      logoUrl: 'https://www.virginradio.com.tr/images/logo.png',
      bitrate: '128 kbps',
      description: 'Rock ve alternatif',
      genre: 'Rock',
      country: 'Türkiye',
    ),
    const Station(
      id: '15',
      name: 'Radyo Fenomen',
      streamUrl: 'https://ssl5.radyotvonline.com/fenomen.mp3',
      logoUrl: 'https://www.radyofenomen.com/images/logo.png',
      bitrate: '128 kbps',
      description: 'Fenomen müzikler',
      genre: 'Pop',
      country: 'Türkiye',
    ),
  ];

  List<Station> getAllStations() => List.unmodifiable(_stations);

  List<Station> getFavoriteStations() =>
      _stations.where((station) => station.isFavorite).toList();

  Station? getStationById(String id) {
    try {
      return _stations.firstWhere((station) => station.id == id);
    } catch (e) {
      return null;
    }
  }

  void toggleFavorite(String stationId) {
    final index = _stations.indexWhere((station) => station.id == stationId);
    if (index != -1) {
      _stations[index] = _stations[index].copyWith(
        isFavorite: !_stations[index].isFavorite,
      );
    }
  }

  void clearAllFavorites() {
    for (int i = 0; i < _stations.length; i++) {
      if (_stations[i].isFavorite) {
        _stations[i] = _stations[i].copyWith(isFavorite: false);
      }
    }
  }

  List<Station> searchStations(String query) {
    if (query.isEmpty) return getAllStations();

    final lowerQuery = query.toLowerCase();
    return _stations
        .where((station) =>
            station.name.toLowerCase().contains(lowerQuery) ||
            (station.genre?.toLowerCase().contains(lowerQuery) ?? false) ||
            (station.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }
}

// Provider for the repository
final stationRepositoryProvider = Provider<MockStationRepository>((ref) {
  return MockStationRepository();
});
