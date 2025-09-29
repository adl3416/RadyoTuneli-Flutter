import 'package:freezed_annotation/freezed_annotation.dart';

part 'station_model.freezed.dart';
part 'station_model.g.dart';

@freezed
class Station with _$Station {
  const factory Station({
    required String id,
    required String name,
    required String streamUrl,
    required String logoUrl,
    required String bitrate,
    @Default(false) bool isFavorite,
    String? description,
    String? genre,
    String? country,
  }) = _Station;

  factory Station.fromJson(Map<String, dynamic> json) => _$StationFromJson(json);
}