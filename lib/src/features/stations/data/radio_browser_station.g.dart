// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'radio_browser_station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RadioBrowserStationImpl _$$RadioBrowserStationImplFromJson(
        Map<String, dynamic> json) =>
    _$RadioBrowserStationImpl(
      stationuuid: json['stationuuid'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      urlResolved: json['url_resolved'] as String?,
      homepage: json['homepage'] as String?,
      favicon: json['favicon'] as String?,
      country: json['country'] as String?,
      countrycode: json['countrycode'] as String?,
      codec: json['codec'] as String?,
      bitrate: (json['bitrate'] as num?)?.toInt(),
      votes: (json['votes'] as num?)?.toInt(),
      tags: json['tags'] as String?,
      lastcheckok: (json['lastcheckok'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$RadioBrowserStationImplToJson(
        _$RadioBrowserStationImpl instance) =>
    <String, dynamic>{
      'stationuuid': instance.stationuuid,
      'name': instance.name,
      'url': instance.url,
      'url_resolved': instance.urlResolved,
      'homepage': instance.homepage,
      'favicon': instance.favicon,
      'country': instance.country,
      'countrycode': instance.countrycode,
      'codec': instance.codec,
      'bitrate': instance.bitrate,
      'votes': instance.votes,
      'tags': instance.tags,
      'lastcheckok': instance.lastcheckok,
    };
