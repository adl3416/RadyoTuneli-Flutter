// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'station_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Station _$StationFromJson(Map<String, dynamic> json) {
  return _Station.fromJson(json);
}

/// @nodoc
mixin _$Station {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get streamUrl => throw _privateConstructorUsedError;
  String get logoUrl => throw _privateConstructorUsedError;
  String get bitrate => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get genre => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;

  /// Serializes this Station to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Station
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StationCopyWith<Station> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StationCopyWith<$Res> {
  factory $StationCopyWith(Station value, $Res Function(Station) then) =
      _$StationCopyWithImpl<$Res, Station>;
  @useResult
  $Res call(
      {String id,
      String name,
      String streamUrl,
      String logoUrl,
      String bitrate,
      bool isFavorite,
      String? description,
      String? genre,
      String? country});
}

/// @nodoc
class _$StationCopyWithImpl<$Res, $Val extends Station>
    implements $StationCopyWith<$Res> {
  _$StationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Station
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? streamUrl = null,
    Object? logoUrl = null,
    Object? bitrate = null,
    Object? isFavorite = null,
    Object? description = freezed,
    Object? genre = freezed,
    Object? country = freezed,
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
      streamUrl: null == streamUrl
          ? _value.streamUrl
          : streamUrl // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: null == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bitrate: null == bitrate
          ? _value.bitrate
          : bitrate // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      genre: freezed == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StationImplCopyWith<$Res> implements $StationCopyWith<$Res> {
  factory _$$StationImplCopyWith(
          _$StationImpl value, $Res Function(_$StationImpl) then) =
      __$$StationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String streamUrl,
      String logoUrl,
      String bitrate,
      bool isFavorite,
      String? description,
      String? genre,
      String? country});
}

/// @nodoc
class __$$StationImplCopyWithImpl<$Res>
    extends _$StationCopyWithImpl<$Res, _$StationImpl>
    implements _$$StationImplCopyWith<$Res> {
  __$$StationImplCopyWithImpl(
      _$StationImpl _value, $Res Function(_$StationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Station
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? streamUrl = null,
    Object? logoUrl = null,
    Object? bitrate = null,
    Object? isFavorite = null,
    Object? description = freezed,
    Object? genre = freezed,
    Object? country = freezed,
  }) {
    return _then(_$StationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      streamUrl: null == streamUrl
          ? _value.streamUrl
          : streamUrl // ignore: cast_nullable_to_non_nullable
              as String,
      logoUrl: null == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      bitrate: null == bitrate
          ? _value.bitrate
          : bitrate // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      genre: freezed == genre
          ? _value.genre
          : genre // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StationImpl implements _Station {
  const _$StationImpl(
      {required this.id,
      required this.name,
      required this.streamUrl,
      required this.logoUrl,
      required this.bitrate,
      this.isFavorite = false,
      this.description,
      this.genre,
      this.country});

  factory _$StationImpl.fromJson(Map<String, dynamic> json) =>
      _$$StationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String streamUrl;
  @override
  final String logoUrl;
  @override
  final String bitrate;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final String? description;
  @override
  final String? genre;
  @override
  final String? country;

  @override
  String toString() {
    return 'Station(id: $id, name: $name, streamUrl: $streamUrl, logoUrl: $logoUrl, bitrate: $bitrate, isFavorite: $isFavorite, description: $description, genre: $genre, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.streamUrl, streamUrl) ||
                other.streamUrl == streamUrl) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.bitrate, bitrate) || other.bitrate == bitrate) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.genre, genre) || other.genre == genre) &&
            (identical(other.country, country) || other.country == country));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, streamUrl, logoUrl,
      bitrate, isFavorite, description, genre, country);

  /// Create a copy of Station
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StationImplCopyWith<_$StationImpl> get copyWith =>
      __$$StationImplCopyWithImpl<_$StationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StationImplToJson(
      this,
    );
  }
}

abstract class _Station implements Station {
  const factory _Station(
      {required final String id,
      required final String name,
      required final String streamUrl,
      required final String logoUrl,
      required final String bitrate,
      final bool isFavorite,
      final String? description,
      final String? genre,
      final String? country}) = _$StationImpl;

  factory _Station.fromJson(Map<String, dynamic> json) = _$StationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get streamUrl;
  @override
  String get logoUrl;
  @override
  String get bitrate;
  @override
  bool get isFavorite;
  @override
  String? get description;
  @override
  String? get genre;
  @override
  String? get country;

  /// Create a copy of Station
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StationImplCopyWith<_$StationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
