// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release_asset.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReleaseAsset {

 String get name;@JsonKey(name: "browser_download_url") String get browserDownloadUrl;
/// Create a copy of ReleaseAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseAssetCopyWith<ReleaseAsset> get copyWith => _$ReleaseAssetCopyWithImpl<ReleaseAsset>(this as ReleaseAsset, _$identity);

  /// Serializes this ReleaseAsset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ReleaseAsset;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReleaseAsset&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.browserDownloadUrl, _this.browserDownloadUrl) || other.browserDownloadUrl == _this.browserDownloadUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ReleaseAsset;
  return Object.hash(runtimeType,_this.name,_this.browserDownloadUrl);
}

@override
String toString() {
  final _this = this as ReleaseAsset;
  return 'ReleaseAsset(name: ${_this.name}, browserDownloadUrl: ${_this.browserDownloadUrl})';
}


}

/// @nodoc
abstract mixin class $ReleaseAssetCopyWith<$Res>  {
  factory $ReleaseAssetCopyWith(ReleaseAsset value, $Res Function(ReleaseAsset) _then) = _$ReleaseAssetCopyWithImpl;
@useResult
$Res call({
 String name,@JsonKey(name: "browser_download_url") String browserDownloadUrl
});




}
/// @nodoc
class _$ReleaseAssetCopyWithImpl<$Res>
    implements $ReleaseAssetCopyWith<$Res> {
  _$ReleaseAssetCopyWithImpl(this._self, this._then);

  final ReleaseAsset _self;
  final $Res Function(ReleaseAsset) _then;

/// Create a copy of ReleaseAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? browserDownloadUrl = null,}) {
  return _then(ReleaseAsset(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,browserDownloadUrl: null == browserDownloadUrl ? _self.browserDownloadUrl : browserDownloadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ReleaseAsset].
extension ReleaseAssetPatterns on ReleaseAsset {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReleaseAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReleaseAsset() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReleaseAsset value)  $default,){
final _that = this;
switch (_that) {
case _ReleaseAsset():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReleaseAsset value)?  $default,){
final _that = this;
switch (_that) {
case _ReleaseAsset() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name, @JsonKey(name: "browser_download_url")  String browserDownloadUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReleaseAsset() when $default != null:
return $default(_that.name,_that.browserDownloadUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name, @JsonKey(name: "browser_download_url")  String browserDownloadUrl)  $default,) {final _that = this;
switch (_that) {
case _ReleaseAsset():
return $default(_that.name,_that.browserDownloadUrl);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name, @JsonKey(name: "browser_download_url")  String browserDownloadUrl)?  $default,) {final _that = this;
switch (_that) {
case _ReleaseAsset() when $default != null:
return $default(_that.name,_that.browserDownloadUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReleaseAsset implements ReleaseAsset {
  const _ReleaseAsset({required this.name, @JsonKey(name: "browser_download_url") required this.browserDownloadUrl});
  factory _ReleaseAsset.fromJson(Map<String, dynamic> json) => _$ReleaseAssetFromJson(json);

@override final  String name;
@override@JsonKey(name: "browser_download_url") final  String browserDownloadUrl;

/// Create a copy of ReleaseAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseAssetCopyWith<_ReleaseAsset> get copyWith => __$ReleaseAssetCopyWithImpl<_ReleaseAsset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseAssetToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReleaseAsset&&(identical(other.name, name) || other.name == name)&&(identical(other.browserDownloadUrl, browserDownloadUrl) || other.browserDownloadUrl == browserDownloadUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,name,browserDownloadUrl);
}

@override
String toString() {
    return 'ReleaseAsset(name: $name, browserDownloadUrl: $browserDownloadUrl)';
}


}

/// @nodoc
abstract mixin class _$ReleaseAssetCopyWith<$Res> implements $ReleaseAssetCopyWith<$Res> {
  factory _$ReleaseAssetCopyWith(_ReleaseAsset value, $Res Function(_ReleaseAsset) _then) = __$ReleaseAssetCopyWithImpl;
@override @useResult
$Res call({
 String name,@JsonKey(name: "browser_download_url") String browserDownloadUrl
});




}
/// @nodoc
class __$ReleaseAssetCopyWithImpl<$Res>
    implements _$ReleaseAssetCopyWith<$Res> {
  __$ReleaseAssetCopyWithImpl(this._self, this._then);

  final _ReleaseAsset _self;
  final $Res Function(_ReleaseAsset) _then;

/// Create a copy of ReleaseAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? browserDownloadUrl = null,}) {
  return _then(_ReleaseAsset(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,browserDownloadUrl: null == browserDownloadUrl ? _self.browserDownloadUrl : browserDownloadUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
