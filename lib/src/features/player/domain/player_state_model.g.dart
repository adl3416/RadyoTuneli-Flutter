// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerStateModelImpl _$$PlayerStateModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PlayerStateModelImpl(
      isPlaying: json['isPlaying'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
      currentStation: json['currentStation'] == null
          ? null
          : CurrentStationInfo.fromJson(
              json['currentStation'] as Map<String, dynamic>),
      position: json['position'] == null
          ? Duration.zero
          : Duration(microseconds: (json['position'] as num).toInt()),
      error: json['error'] as String?,
    );

Map<String, dynamic> _$$PlayerStateModelImplToJson(
        _$PlayerStateModelImpl instance) =>
    <String, dynamic>{
      'isPlaying': instance.isPlaying,
      'isLoading': instance.isLoading,
      'currentStation': instance.currentStation,
      'position': instance.position.inMicroseconds,
      'error': instance.error,
    };

_$CurrentStationInfoImpl _$$CurrentStationInfoImplFromJson(
        Map<String, dynamic> json) =>
    _$CurrentStationInfoImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      artist: json['artist'] as String,
      logoUrl: json['logoUrl'] as String?,
    );

Map<String, dynamic> _$$CurrentStationInfoImplToJson(
        _$CurrentStationInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'artist': instance.artist,
      'logoUrl': instance.logoUrl,
    };
