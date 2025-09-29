// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'station_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StationImpl _$$StationImplFromJson(Map<String, dynamic> json) =>
    _$StationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      streamUrl: json['streamUrl'] as String,
      logoUrl: json['logoUrl'] as String,
      bitrate: json['bitrate'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      description: json['description'] as String?,
      genre: json['genre'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$$StationImplToJson(_$StationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'streamUrl': instance.streamUrl,
      'logoUrl': instance.logoUrl,
      'bitrate': instance.bitrate,
      'isFavorite': instance.isFavorite,
      'description': instance.description,
      'genre': instance.genre,
      'country': instance.country,
    };
