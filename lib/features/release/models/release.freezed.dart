// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'release.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Release {

@JsonKey(name: "tag_name") String get tagName; String get name; String get body;@JsonKey(name: "published_at") DateTime get publishedAt; bool get draft; bool get prerelease; List<ReleaseAsset> get assets;
/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReleaseCopyWith<Release> get copyWith => _$ReleaseCopyWithImpl<Release>(this as Release, _$identity);

  /// Serializes this Release to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Release;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Release&&(identical(other.tagName, _this.tagName) || other.tagName == _this.tagName)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.publishedAt, _this.publishedAt) || other.publishedAt == _this.publishedAt)&&(identical(other.draft, _this.draft) || other.draft == _this.draft)&&(identical(other.prerelease, _this.prerelease) || other.prerelease == _this.prerelease)&&const DeepCollectionEquality().equals(other.assets, _this.assets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Release;
  return Object.hash(runtimeType,_this.tagName,_this.name,_this.body,_this.publishedAt,_this.draft,_this.prerelease,const DeepCollectionEquality().hash(_this.assets));
}

@override
String toString() {
  final _this = this as Release;
  return 'Release(tagName: ${_this.tagName}, name: ${_this.name}, body: ${_this.body}, publishedAt: ${_this.publishedAt}, draft: ${_this.draft}, prerelease: ${_this.prerelease}, assets: ${_this.assets})';
}


}

/// @nodoc
abstract mixin class $ReleaseCopyWith<$Res>  {
  factory $ReleaseCopyWith(Release value, $Res Function(Release) _then) = _$ReleaseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "tag_name") String tagName, String name, String body,@JsonKey(name: "published_at") DateTime publishedAt, bool draft, bool prerelease, List<ReleaseAsset> assets
});




}
/// @nodoc
class _$ReleaseCopyWithImpl<$Res>
    implements $ReleaseCopyWith<$Res> {
  _$ReleaseCopyWithImpl(this._self, this._then);

  final Release _self;
  final $Res Function(Release) _then;

/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tagName = null,Object? name = null,Object? body = null,Object? publishedAt = null,Object? draft = null,Object? prerelease = null,Object? assets = null,}) {
  return _then(Release(
tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as bool,prerelease: null == prerelease ? _self.prerelease : prerelease // ignore: cast_nullable_to_non_nullable
as bool,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as List<ReleaseAsset>,
  ));
}

}


/// Adds pattern-matching-related methods to [Release].
extension ReleasePatterns on Release {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Release value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Release() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Release value)  $default,){
final _that = this;
switch (_that) {
case _Release():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Release value)?  $default,){
final _that = this;
switch (_that) {
case _Release() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: "tag_name")  String tagName,  String name,  String body, @JsonKey(name: "published_at")  DateTime publishedAt,  bool draft,  bool prerelease,  List<ReleaseAsset> assets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Release() when $default != null:
return $default(_that.tagName,_that.name,_that.body,_that.publishedAt,_that.draft,_that.prerelease,_that.assets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: "tag_name")  String tagName,  String name,  String body, @JsonKey(name: "published_at")  DateTime publishedAt,  bool draft,  bool prerelease,  List<ReleaseAsset> assets)  $default,) {final _that = this;
switch (_that) {
case _Release():
return $default(_that.tagName,_that.name,_that.body,_that.publishedAt,_that.draft,_that.prerelease,_that.assets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: "tag_name")  String tagName,  String name,  String body, @JsonKey(name: "published_at")  DateTime publishedAt,  bool draft,  bool prerelease,  List<ReleaseAsset> assets)?  $default,) {final _that = this;
switch (_that) {
case _Release() when $default != null:
return $default(_that.tagName,_that.name,_that.body,_that.publishedAt,_that.draft,_that.prerelease,_that.assets);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _Release implements Release {
  const _Release({@JsonKey(name: "tag_name") required this.tagName, required this.name, required this.body, @JsonKey(name: "published_at") required this.publishedAt, required this.draft, required this.prerelease,  List<ReleaseAsset> assets = const <ReleaseAsset>[]}): _assets = assets;
  factory _Release.fromJson(Map<String, dynamic> json) => _$ReleaseFromJson(json);

@override@JsonKey(name: "tag_name") final  String tagName;
@override final  String name;
@override final  String body;
@override@JsonKey(name: "published_at") final  DateTime publishedAt;
@override final  bool draft;
@override final  bool prerelease;
 final  List<ReleaseAsset> _assets;
@override@JsonKey() List<ReleaseAsset> get assets {
  if (_assets is EqualUnmodifiableListView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assets);
}


/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReleaseCopyWith<_Release> get copyWith => __$ReleaseCopyWithImpl<_Release>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReleaseToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Release&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.name, name) || other.name == name)&&(identical(other.body, body) || other.body == body)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.prerelease, prerelease) || other.prerelease == prerelease)&&const DeepCollectionEquality().equals(other.assets, _assets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,tagName,name,body,publishedAt,draft,prerelease,const DeepCollectionEquality().hash(_assets));
}

@override
String toString() {
    return 'Release(tagName: $tagName, name: $name, body: $body, publishedAt: $publishedAt, draft: $draft, prerelease: $prerelease, assets: $assets)';
}


}

/// @nodoc
abstract mixin class _$ReleaseCopyWith<$Res> implements $ReleaseCopyWith<$Res> {
  factory _$ReleaseCopyWith(_Release value, $Res Function(_Release) _then) = __$ReleaseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: "tag_name") String tagName, String name, String body,@JsonKey(name: "published_at") DateTime publishedAt, bool draft, bool prerelease, List<ReleaseAsset> assets
});




}
/// @nodoc
class __$ReleaseCopyWithImpl<$Res>
    implements _$ReleaseCopyWith<$Res> {
  __$ReleaseCopyWithImpl(this._self, this._then);

  final _Release _self;
  final $Res Function(_Release) _then;

/// Create a copy of Release
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tagName = null,Object? name = null,Object? body = null,Object? publishedAt = null,Object? draft = null,Object? prerelease = null,Object? assets = null,}) {
  return _then(_Release(
tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,publishedAt: null == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as bool,prerelease: null == prerelease ? _self.prerelease : prerelease // ignore: cast_nullable_to_non_nullable
as bool,assets: null == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as List<ReleaseAsset>,
  ));
}


}

// dart format on
