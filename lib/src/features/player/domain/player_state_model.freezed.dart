// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'player_state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PlayerStateModel _$PlayerStateModelFromJson(Map<String, dynamic> json) {
  return _PlayerStateModel.fromJson(json);
}

/// @nodoc
mixin _$PlayerStateModel {
  bool get isPlaying => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  CurrentStationInfo? get currentStation => throw _privateConstructorUsedError;
  Duration get position => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this PlayerStateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerStateModelCopyWith<PlayerStateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerStateModelCopyWith<$Res> {
  factory $PlayerStateModelCopyWith(
          PlayerStateModel value, $Res Function(PlayerStateModel) then) =
      _$PlayerStateModelCopyWithImpl<$Res, PlayerStateModel>;
  @useResult
  $Res call(
      {bool isPlaying,
      bool isLoading,
      CurrentStationInfo? currentStation,
      Duration position,
      String? error});

  $CurrentStationInfoCopyWith<$Res>? get currentStation;
}

/// @nodoc
class _$PlayerStateModelCopyWithImpl<$Res, $Val extends PlayerStateModel>
    implements $PlayerStateModelCopyWith<$Res> {
  _$PlayerStateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? isLoading = null,
    Object? currentStation = freezed,
    Object? position = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      currentStation: freezed == currentStation
          ? _value.currentStation
          : currentStation // ignore: cast_nullable_to_non_nullable
              as CurrentStationInfo?,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of PlayerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CurrentStationInfoCopyWith<$Res>? get currentStation {
    if (_value.currentStation == null) {
      return null;
    }

    return $CurrentStationInfoCopyWith<$Res>(_value.currentStation!, (value) {
      return _then(_value.copyWith(currentStation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlayerStateModelImplCopyWith<$Res>
    implements $PlayerStateModelCopyWith<$Res> {
  factory _$$PlayerStateModelImplCopyWith(_$PlayerStateModelImpl value,
          $Res Function(_$PlayerStateModelImpl) then) =
      __$$PlayerStateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isPlaying,
      bool isLoading,
      CurrentStationInfo? currentStation,
      Duration position,
      String? error});

  @override
  $CurrentStationInfoCopyWith<$Res>? get currentStation;
}

/// @nodoc
class __$$PlayerStateModelImplCopyWithImpl<$Res>
    extends _$PlayerStateModelCopyWithImpl<$Res, _$PlayerStateModelImpl>
    implements _$$PlayerStateModelImplCopyWith<$Res> {
  __$$PlayerStateModelImplCopyWithImpl(_$PlayerStateModelImpl _value,
      $Res Function(_$PlayerStateModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlayerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? isLoading = null,
    Object? currentStation = freezed,
    Object? position = null,
    Object? error = freezed,
  }) {
    return _then(_$PlayerStateModelImpl(
      isPlaying: null == isPlaying
          ? _value.isPlaying
          : isPlaying // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      currentStation: freezed == currentStation
          ? _value.currentStation
          : currentStation // ignore: cast_nullable_to_non_nullable
              as CurrentStationInfo?,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as Duration,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerStateModelImpl implements _PlayerStateModel {
  const _$PlayerStateModelImpl(
      {this.isPlaying = false,
      this.isLoading = false,
      this.currentStation,
      this.position = Duration.zero,
      this.error});

  factory _$PlayerStateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerStateModelImplFromJson(json);

  @override
  @JsonKey()
  final bool isPlaying;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final CurrentStationInfo? currentStation;
  @override
  @JsonKey()
  final Duration position;
  @override
  final String? error;

  @override
  String toString() {
    return 'PlayerStateModel(isPlaying: $isPlaying, isLoading: $isLoading, currentStation: $currentStation, position: $position, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerStateModelImpl &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.currentStation, currentStation) ||
                other.currentStation == currentStation) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, isPlaying, isLoading, currentStation, position, error);

  /// Create a copy of PlayerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerStateModelImplCopyWith<_$PlayerStateModelImpl> get copyWith =>
      __$$PlayerStateModelImplCopyWithImpl<_$PlayerStateModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerStateModelImplToJson(
      this,
    );
  }
}

abstract class _PlayerStateModel implements PlayerStateModel {
  const factory _PlayerStateModel(
      {final bool isPlaying,
      final bool isLoading,
      final CurrentStationInfo? currentStation,
      final Duration position,
      final String? error}) = _$PlayerStateModelImpl;

  factory _PlayerStateModel.fromJson(Map<String, dynamic> json) =
      _$PlayerStateModelImpl.fromJson;

  @override
  bool get isPlaying;
  @override
  bool get isLoading;
  @override
  CurrentStationInfo? get currentStation;
  @override
  Duration get position;
  @override
  String? get error;

  /// Create a copy of PlayerStateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerStateModelImplCopyWith<_$PlayerStateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CurrentStationInfo _$CurrentStationInfoFromJson(Map<String, dynamic> json) {
  return _CurrentStationInfo.fromJson(json);
}

/// @nodoc
mixin _$CurrentStationInfo {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get artist => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;

  /// Serializes this CurrentStationInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CurrentStationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrentStationInfoCopyWith<CurrentStationInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentStationInfoCopyWith<$Res> {
  factory $CurrentStationInfoCopyWith(
          CurrentStationInfo value, $Res Function(CurrentStationInfo) then) =
      _$CurrentStationInfoCopyWithImpl<$Res, CurrentStationInfo>;
  @useResult
  $Res call({String id, String name, String artist, String? logoUrl});
}

/// @nodoc
class _$CurrentStationInfoCopyWithImpl<$Res, $Val extends CurrentStationInfo>
    implements $CurrentStationInfoCopyWith<$Res> {
  _$CurrentStationInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrentStationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? artist = null,
    Object? logoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CurrentStationInfoImplCopyWith<$Res>
    implements $CurrentStationInfoCopyWith<$Res> {
  factory _$$CurrentStationInfoImplCopyWith(_$CurrentStationInfoImpl value,
          $Res Function(_$CurrentStationInfoImpl) then) =
      __$$CurrentStationInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, String artist, String? logoUrl});
}

/// @nodoc
class __$$CurrentStationInfoImplCopyWithImpl<$Res>
    extends _$CurrentStationInfoCopyWithImpl<$Res, _$CurrentStationInfoImpl>
    implements _$$CurrentStationInfoImplCopyWith<$Res> {
  __$$CurrentStationInfoImplCopyWithImpl(_$CurrentStationInfoImpl _value,
      $Res Function(_$CurrentStationInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrentStationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? artist = null,
    Object? logoUrl = freezed,
  }) {
    return _then(_$CurrentStationInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      artist: null == artist
          ? _value.artist
          : artist // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CurrentStationInfoImpl implements _CurrentStationInfo {
  const _$CurrentStationInfoImpl(
      {required this.id,
      required this.name,
      required this.artist,
      this.logoUrl});

  factory _$CurrentStationInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CurrentStationInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String artist;
  @override
  final String? logoUrl;

  @override
  String toString() {
    return 'CurrentStationInfo(id: $id, name: $name, artist: $artist, logoUrl: $logoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrentStationInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.artist, artist) || other.artist == artist) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, artist, logoUrl);

  /// Create a copy of CurrentStationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrentStationInfoImplCopyWith<_$CurrentStationInfoImpl> get copyWith =>
      __$$CurrentStationInfoImplCopyWithImpl<_$CurrentStationInfoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CurrentStationInfoImplToJson(
      this,
    );
  }
}

abstract class _CurrentStationInfo implements CurrentStationInfo {
  const factory _CurrentStationInfo(
      {required final String id,
      required final String name,
      required final String artist,
      final String? logoUrl}) = _$CurrentStationInfoImpl;

  factory _CurrentStationInfo.fromJson(Map<String, dynamic> json) =
      _$CurrentStationInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get artist;
  @override
  String? get logoUrl;

  /// Create a copy of CurrentStationInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrentStationInfoImplCopyWith<_$CurrentStationInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
