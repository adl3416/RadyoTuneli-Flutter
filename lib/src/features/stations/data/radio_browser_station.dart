import 'package:freezed_annotation/freezed_annotation.dart';

part 'radio_browser_station.freezed.dart';
part 'radio_browser_station.g.dart';

@freezed
class RadioBrowserStation with _$RadioBrowserStation {
  const factory RadioBrowserStation({
    required String stationuuid,
    required String name,
    required String url,
    @JsonKey(name: 'url_resolved') String? urlResolved,
    String? homepage,
    String? favicon,
    String? country,
    String? countrycode,
    String? codec,
    int? bitrate,
    int? votes,
    String? tags,
    int? lastcheckok,
  }) = _RadioBrowserStation;

  factory RadioBrowserStation.fromJson(Map<String, dynamic> json) =>
      _$RadioBrowserStationFromJson(json);
}
