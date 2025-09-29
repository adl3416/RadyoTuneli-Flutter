import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_state_model.freezed.dart';
part 'player_state_model.g.dart';

@freezed
class PlayerStateModel with _$PlayerStateModel {
  const factory PlayerStateModel({
    @Default(false) bool isPlaying,
    @Default(false) bool isLoading,
    CurrentStationInfo? currentStation,
    @Default(Duration.zero) Duration position,
    String? error,
  }) = _PlayerStateModel;

  factory PlayerStateModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerStateModelFromJson(json);
}

@freezed
class CurrentStationInfo with _$CurrentStationInfo {
  const factory CurrentStationInfo({
    required String id,
    required String name,
    required String artist,
    String? logoUrl,
  }) = _CurrentStationInfo;

  factory CurrentStationInfo.fromJson(Map<String, dynamic> json) =>
      _$CurrentStationInfoFromJson(json);
}
